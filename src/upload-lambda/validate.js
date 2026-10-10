export const MAX_SIZE_BYTES = 10 * 1024 * 1024;

export const ALLOWED_TYPES = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/gif": "gif",
  "image/webp": "webp",
};

export class ValidationError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.name = "ValidationError";
    this.statusCode = statusCode;
  }
}

const startsWith = (buffer, bytes, offset = 0) =>
  bytes.every((byte, i) => buffer[offset + i] === byte);

export function detectContentType(buffer) {
  if (startsWith(buffer, [0xff, 0xd8, 0xff])) return "image/jpeg";
  if (startsWith(buffer, [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) return "image/png";
  if (startsWith(buffer, [0x47, 0x49, 0x46, 0x38, 0x37, 0x61])) return "image/gif";
  if (startsWith(buffer, [0x47, 0x49, 0x46, 0x38, 0x39, 0x61])) return "image/gif";
  if (
    startsWith(buffer, [0x52, 0x49, 0x46, 0x46]) &&
    startsWith(buffer, [0x57, 0x45, 0x42, 0x50], 8)
  ) {
    return "image/webp";
  }
  return null;
}

export function validateImage(buffer) {
  if (!buffer || buffer.length === 0) {
    throw new ValidationError(400, "No se recibió ninguna imagen");
  }
  if (buffer.length > MAX_SIZE_BYTES) {
    throw new ValidationError(413, "La imagen supera el máximo de 10 MB");
  }
  const contentType = detectContentType(buffer);
  if (!contentType) {
    throw new ValidationError(415, "Formato no permitido. Use jpg, png, gif o webp");
  }
  return { contentType, extension: ALLOWED_TYPES[contentType] };
}