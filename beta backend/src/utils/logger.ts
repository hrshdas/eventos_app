import { config } from '../config/env';

export enum LogLevel {
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
  DEBUG = 'DEBUG',
}

const log = (level: LogLevel, message: string, ...args: any[]) => {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] [${level}] ${message}`;
  
  if (level === LogLevel.ERROR) {
    console.error(logMessage, ...args);
  } else if (level === LogLevel.WARN) {
    console.warn(logMessage, ...args);
  } else if (config.nodeEnv === 'development') {
    console.log(logMessage, ...args);
  }
};

export const logger = {
  info: (message: string, ...args: any[]) => log(LogLevel.INFO, message, ...args),
  warn: (message: string, ...args: any[]) => log(LogLevel.WARN, message, ...args),
  error: (message: string, ...args: any[]) => log(LogLevel.ERROR, message, ...args),
  debug: (message: string, ...args: any[]) => log(LogLevel.DEBUG, message, ...args),
};

