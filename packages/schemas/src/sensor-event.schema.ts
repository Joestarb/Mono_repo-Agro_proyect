import { Schema, Document } from 'mongoose';

export const SensorEventSchema = new Schema({
  sensorType: { type: String, index: true, required: true },
  sensorId:    { type: String, index: true, required: true },
  ts:          { type: Date,   index: true, required: true },
  value:       { type: Number, required: true },
  source:      { type: String, default: 'sensores-async-api' },
  payloadHash: { type: String, index: true },
  receivedAt:  { type: Date,   default: () => new Date() },
}, { versionKey: false });

SensorEventSchema.index({ sensorType: 1, sensorId: 1, ts: 1 }, { unique: true });
SensorEventSchema.index({ sensorType: 1, ts: 1 });
SensorEventSchema.index({ receivedAt: 1 }, { expireAfterSeconds: 60 * 5 }); // TTL

export interface SensorEvent {
  sensorType: string;
  sensorId: string;
  ts: Date;
  value: number;
  source?: string;
  payloadHash?: string;
  receivedAt?: Date;
}

export type SensorEventDocument = SensorEvent & Document;
