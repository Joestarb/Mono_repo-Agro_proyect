import { Document } from 'mongoose';

export interface LatestReading {
  sensorType: string;
  sensorId: string;
  ts: Date;
  value: number;
  payloadHash?: string;
  updatedAt?: Date;
}

export type LatestReadingDocument = LatestReading & Document;
