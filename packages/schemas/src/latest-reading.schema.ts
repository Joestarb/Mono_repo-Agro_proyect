import { Schema, Document } from 'mongoose';

export const LatestReadingSchema = new Schema({
  sensorType:  { type: String, required: true },
  sensorId:    { type: String, required: true },
  ts:          { type: Date,   required: true },
  value:       { type: Number, required: true },
  payloadHash: { type: String },
  updatedAt:   { type: Date,   default: () => new Date() },
}, { versionKey: false });

LatestReadingSchema.index({ sensorType: 1, sensorId: 1 }, { unique: true });

export interface LatestReading {
  sensorType: string;
  sensorId: string;
  ts: Date;
  value: number;
  payloadHash?: string;
  updatedAt?: Date;
}

export type LatestReadingDocument = LatestReading & Document;
