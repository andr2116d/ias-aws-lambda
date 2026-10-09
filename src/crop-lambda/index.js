exports.handler = async (event) => {
  const records = event.Records || [];

  for (const record of records) {
    try {
      const message = JSON.parse(record.body);
      console.log("Mensaje recibido de SQS:", message);
    } catch (error) {
      console.error("Error al procesar el mensaje:", error);
      throw error;
    }
  }

  return {
    batchItemFailures: []
  };
};