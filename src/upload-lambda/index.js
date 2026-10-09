import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import Busboy from "busboy";
import { v4 as uuidv4 } from "uuid";
import { MAX_SIZE_BYTES, ValidationError, validateImage } from "./validate.js";

const s3 = new S3Client({});

const response = (statusCode, body) => ({
  statusCode,
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(body),
});

const getHeader = (headers = {}, name) => {
  const key = Object.keys(headers).find((h) => h.toLowerCase() === name);
  return key ? headers[key] : undefined;
};

function parseMultipart(event, contentType) {
  const body = Buffer.from(
    event.body ?? "",
    event.isBase64Encoded ? "base64" : "binary",
  );

  return new Promise((resolve, reject) => {
    const busboy = Busboy({
      headers: { "content-type": contentType },
      limits: { files: 1, fileSize: MAX_SIZE_BYTES },
    });
    const chunks = [];
    let truncated = false;

    busboy.on("file", (_field, stream) => {
      stream.on("data", (chunk) => chunks.push(chunk));
      stream.on("limit", () => {
        truncated = true;
      });
    });
    busboy.on("filesLimit", () =>
      reject(
        new ValidationError(400, "Solo se permite una imagen por solicitud"),
      ),
    );
    busboy.on("error", () =>
      reject(new ValidationError(400, "multipart/form-data inválido")),
    );
    busboy.on("close", () => {
      if (truncated)
        return reject(
          new ValidationError(413, "La imagen supera el máximo de 10 MB"),
        );
      resolve(Buffer.concat(chunks));
    });

    busboy.end(body);
  });
}

function parseJson(event) {
  const raw = event.isBase64Encoded
    ? Buffer.from(event.body ?? "", "base64").toString("utf8")
    : (event.body ?? "");

  let payload;
  try {
    payload = JSON.parse(raw);
  } catch {
    throw new ValidationError(400, "El cuerpo JSON es inválido");
  }
  if (typeof payload?.image !== "string") {
    throw new ValidationError(
      400,
      "Falta el campo image con la imagen en base64",
    );
  }
  const base64 = payload.image.replace(/^data:[^;]+;base64,/, "");
  return Buffer.from(base64, "base64");
}

async function readImage(event) {
  const contentType = getHeader(event.headers, "content-type") ?? "";
  if (contentType.toLowerCase().startsWith("multipart/form-data")) {
    return parseMultipart(event, contentType);
  }
  if (contentType.toLowerCase().startsWith("application/json")) {
    return parseJson(event);
  }
  throw new ValidationError(
    415,
    "Content-Type debe ser multipart/form-data o application/json",
  );
}

export const handler = async (event) => {
  try {
    const image = await readImage(event);
    const { contentType, extension } = validateImage(image);

    const key = `${process.env.UPLOAD_PREFIX}${uuidv4()}.${extension}`;
    await s3.send(
      new PutObjectCommand({
        Bucket: process.env.S3_BUCKET,
        Key: key,
        Body: image,
        ContentType: contentType,
      }),
    );

    return response(201, { key, contentType, size: image.length });
  } catch (error) {
    if (error instanceof ValidationError) {
      return response(error.statusCode, { message: error.message });
    }
    console.error("Error al subir la imagen", error);
    return response(500, { message: "Error interno al guardar la imagen" });
  }
};
