const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");

const s3 = new S3Client({});

exports.handler = async (event) => {
  const records = event.Records || [];
  const batchItemFailures = [];

  for (const record of records) {
    try {
      const message = JSON.parse(record.body);
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

      console.log(`Imagen descargada: ${key}, tamaño: ${imageBuffer.length}`);
    } catch (error) {
      console.error("Error al descargar la imagen:", error);
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures };
};