
const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand
} = require("@aws-sdk/client-s3");
const sharp = require("sharp");

const s3 = new S3Client({});

exports.handler = async (event) => {
  const batchItemFailures = [];

  for (const record of event.Records || []) {
    try {
      const message = JSON.parse(record.body);
      if (message.Event === "s3:TestEvent")
        continue;
      const s3Record = message.Records?.[0];

      if (!s3Record) {
        throw new Error("El mensaje no contiene un registro de S3");
      }

      const bucket = s3Record.s3.bucket.name;
      const key = decodeURIComponent(
        s3Record.s3.object.key.replace(/\+/g, " ")
      );

      if (!key.startsWith("uploads/")) {
        throw new Error(`La imagen no pertenece a uploads/: ${key}`);
      }

      const response = await s3.send(
        new GetObjectCommand({ Bucket: bucket, Key: key })
      );

      const imageBuffer = Buffer.from(
        await response.Body.transformToByteArray()
      );

      const circularSvg = Buffer.from(
        '<svg width="40" height="40"><circle cx="20" cy="20" r="20" fill="white"/></svg>'
      );

      const processedImage = await sharp(imageBuffer)
        .resize(40, 40, { fit: "cover" })
        .composite([{
          input: circularSvg,
          blend: "dest-in"
        }])
        .png()
        .toBuffer();

      const fileName = key.split("/").pop().replace(/\.[^.]+$/, "");
      const outputPrefix = process.env.PROCESSED_PREFIX || "processed/";
      const outputKey = `${outputPrefix}${fileName}_circular.png`;

      await s3.send(
        new PutObjectCommand({
          Bucket: bucket,
          Key: outputKey,
          Body: processedImage,
          ContentType: "image/png"
        })
      );

      console.log(`Imagen guardada: s3://${bucket}/${outputKey}`);
    } catch (error) {
      console.error("Error al procesar imagen:", error);
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures };
};