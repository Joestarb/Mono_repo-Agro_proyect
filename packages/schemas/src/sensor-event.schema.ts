// packages/schemas/src/sensor-event.schema.ts
import { Schema } from 'mongoose';

export const SensorEventSchema = new Schema({
  sensorType: { type: String, index: true, required: true }, // 'temperatura', 'humedad', etc.
  sensorId:    { type: String, index: true, required: true }, // id estable por sensor
  ts:          { type: Date,   index: true, required: true }, // timestamp lectura
  value:       { type: Number, required: true },
  source:      { type: String, default: 'sensores-async-api' },
  payloadHash: { type: String, index: true },
  receivedAt:  { type: Date,   default: () => new Date() },
}, { versionKey: false });

SensorEventSchema.index({ sensorType: 1, sensorId: 1, ts: 1 }, { unique: true });
SensorEventSchema.index({ sensorType: 1, ts: 1 });
