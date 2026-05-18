/**
 * Storage module for flexible clock configuration and data persistence
 * Handles saving/loading configuration and today's record using file IO
 */

import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';

/**
 * Configuration class with default and user-configurable settings
 */
export class Config {
  flex_start_begin: string = '08:00';
  flex_start_end: string = '09:30';
  flex_end_begin: string = '17:00';
  flex_end_end: string = '18:30';
  work_hours: number = 8.0;
  exclude_lunch: boolean = true;
  lunch_start: string = '12:00';
  lunch_end: string = '13:00';

  constructor() {
  }

  /**
   * Creates a Config from a JSON object
   */
  static fromJson(json: Record<string, Object>): Config {
    const config = new Config();
    if (json['flex_start_begin']) {
      config.flex_start_begin = json['flex_start_begin'] as string;
    }
    if (json['flex_start_end']) {
      config.flex_start_end = json['flex_start_end'] as string;
    }
    if (json['flex_end_begin']) {
      config.flex_end_begin = json['flex_end_begin'] as string;
    }
    if (json['flex_end_end']) {
      config.flex_end_end = json['flex_end_end'] as string;
    }
    if (json['work_hours']) {
      config.work_hours = json['work_hours'] as number;
    }
    if (json['exclude_lunch'] !== undefined) {
      config.exclude_lunch = json['exclude_lunch'] as boolean;
    }
    if (json['lunch_start']) {
      config.lunch_start = json['lunch_start'] as string;
    }
    if (json['lunch_end']) {
      config.lunch_end = json['lunch_end'] as string;
    }
    return config;
  }

  /**
   * Converts Config to a JSON-serializable object
   */
  toJson(): Record<string, Object> {
    return {
      'flex_start_begin': this.flex_start_begin,
      'flex_start_end': this.flex_start_end,
      'flex_end_begin': this.flex_end_begin,
      'flex_end_end': this.flex_end_end,
      'work_hours': this.work_hours,
      'exclude_lunch': this.exclude_lunch,
      'lunch_start': this.lunch_start,
      'lunch_end': this.lunch_end
    };
  }
}

/**
 * Today's clock-in record
 */
export class TodayRecord {
  hasClockIn: boolean = false;
  clockInTime: string = '';
  calculatedEndTime: string = '';
  scenario: string = '';
  recordDate: string = ''; // Format: YYYY-MM-DD

  constructor() {
  }

  /**
   * Creates a TodayRecord from a JSON object
   */
  static fromJson(json: Record<string, Object>): TodayRecord {
    const record = new TodayRecord();
    if (json['hasClockIn'] !== undefined) {
      record.hasClockIn = json['hasClockIn'] as boolean;
    }
    if (json['clockInTime']) {
      record.clockInTime = json['clockInTime'] as string;
    }
    if (json['calculatedEndTime']) {
      record.calculatedEndTime = json['calculatedEndTime'] as string;
    }
    if (json['scenario']) {
      record.scenario = json['scenario'] as string;
    }
    if (json['recordDate']) {
      record.recordDate = json['recordDate'] as string;
    }
    return record;
  }

  /**
   * Converts TodayRecord to a JSON-serializable object
   */
  toJson(): Record<string, Object> {
    return {
      'hasClockIn': this.hasClockIn,
      'clockInTime': this.clockInTime,
      'calculatedEndTime': this.calculatedEndTime,
      'scenario': this.scenario,
      'recordDate': this.recordDate
    };
  }

  /**
   * Gets today's date string in YYYY-MM-DD format
   */
  static getTodayDateString(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * Checks if the record is from today
   */
  isToday(): boolean {
    return this.recordDate === TodayRecord.getTodayDateString();
  }
}

/**
 * Storage manager for persisting config and today's record
 */
export class StorageManager {
  private config: Config;
  private todayRecord: TodayRecord;
  private dataDir: string;
  private configFilePath: string;
  private recordFilePath: string;
  private isInitialized: boolean = false;

  constructor() {
    // Use proper HarmonyOS app data directory
    this.dataDir = '/data/data/<package>/files/';
    this.configFilePath = this.dataDir + 'config.json';
    this.recordFilePath = this.dataDir + 'today_record.json';
    this.config = new Config();
    this.todayRecord = new TodayRecord();
  }

  /**
   * Initializes storage by loading data from files
   * Checks if the date has changed and clears record if it's a new day
   */
  async initialize(): Promise<void> {
    try {
      // Ensure directory exists
      await this.ensureDataDir();

      // Load config
      this.config = await this.loadConfig();

      // Load today's record
      this.todayRecord = await this.loadRecord();

      // Check if date has changed - if so, clear the record for new day
      if (this.todayRecord.recordDate && !this.todayRecord.isToday()) {
        this.todayRecord = new TodayRecord();
        await this.saveRecord();
      }

      this.isInitialized = true;
    } catch (error) {
      console.error('Storage initialization error:', error);
      // Use defaults on error
      this.config = new Config();
      this.todayRecord = new TodayRecord();
      this.isInitialized = true;
    }
  }

  /**
   * Ensures the data directory exists
   */
  private async ensureDataDir(): Promise<void> {
    try {
      const dirInfo = fs.listSync(this.dataDir);
    } catch (error) {
      // Directory doesn't exist, create it
      fs.mkdirSync(this.dataDir, true);
    }
  }

  /**
   * Loads configuration from file
   */
  private async loadConfig(): Promise<Config> {
    try {
      const fileContent = fs.readFileSync(this.configFilePath, 'utf-8');
      const json = JSON.parse(fileContent) as Record<string, Object>;
      return Config.fromJson(json);
    } catch (error) {
      // File doesn't exist or is invalid, return default config
      const defaultConfig = new Config();
      await this.saveConfigInternal(defaultConfig);
      return defaultConfig;
    }
  }

  /**
   * Internal method to save config to file
   */
  private async saveConfigInternal(config: Config): Promise<void> {
    const jsonContent = JSON.stringify(config.toJson());
    fs.writeFileSync(this.configFilePath, jsonContent, 'utf-8');
  }

  /**
   * Loads today's record from file
   */
  private async loadRecord(): Promise<TodayRecord> {
    try {
      const fileContent = fs.readFileSync(this.recordFilePath, 'utf-8');
      const json = JSON.parse(fileContent) as Record<string, Object>;
      return TodayRecord.fromJson(json);
    } catch (error) {
      // File doesn't exist or is invalid, return empty record
      return new TodayRecord();
    }
  }

  /**
   * Internal method to save record to file
   */
  private async saveRecordInternal(record: TodayRecord): Promise<void> {
    record.recordDate = TodayRecord.getTodayDateString();
    const jsonContent = JSON.stringify(record.toJson());
    fs.writeFileSync(this.recordFilePath, jsonContent, 'utf-8');
  }

  /**
   * Gets the current configuration
   */
  getConfig(): Config {
    return this.config;
  }

  /**
   * Updates and saves the configuration
   */
  async saveConfig(config: Config): Promise<void> {
    this.config = config;
    await this.saveConfigInternal(config);
  }

  /**
   * Gets today's record
   */
  getTodayRecord(): TodayRecord {
    return this.todayRecord;
  }

  /**
   * Saves today's clock-in record
   */
  async saveClockIn(clockInTime: string, calculatedEndTime: string, scenario: string): Promise<void> {
    this.todayRecord.hasClockIn = true;
    this.todayRecord.clockInTime = clockInTime;
    this.todayRecord.calculatedEndTime = calculatedEndTime;
    this.todayRecord.scenario = scenario;
    this.todayRecord.recordDate = TodayRecord.getTodayDateString();
    await this.saveRecordInternal(this.todayRecord);
  }

  /**
   * Clears today's clock-in record (for clock-out)
   */
  async clearClockIn(): Promise<void> {
    this.todayRecord = new TodayRecord();
    await this.saveRecordInternal(this.todayRecord);
  }

  /**
   * Gets the remaining time for today
   */
  getRemainingTime(): { hours: number; minutes: number; seconds: number; isOver: boolean } | null {
    if (!this.todayRecord.hasClockIn) {
      return null;
    }
    const endTime = this.todayRecord.calculatedEndTime;
    return this.calculateRemaining(endTime);
  }

  /**
   * Calculates remaining time from end time string
   */
  private calculateRemaining(endTime: string): { hours: number; minutes: number; seconds: number; isOver: boolean } {
    const now = new Date();
    const endParts = endTime.split(':');
    const endHour = parseInt(endParts[0], 10);
    const endMinute = parseInt(endParts[1], 10);

    const endDate = new Date();
    endDate.setHours(endHour, endMinute, 0, 0);

    let diff = endDate.getTime() - now.getTime();

    // If end time is earlier than current time, work day is over
    const isOver = diff < 0;

    if (isOver) {
      return { hours: 0, minutes: 0, seconds: 0, isOver: true };
    }

    const totalSeconds = Math.floor(diff / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    return { hours, minutes, seconds, isOver: false };
  }
}

// Singleton instance for easy access
let storageInstance: StorageManager | null = null;

/**
 * Gets the singleton StorageManager instance
 */
export function getStorageManager(): StorageManager {
  if (!storageInstance) {
    storageInstance = new StorageManager();
  }
  return storageInstance;
}

/**
 * Initializes storage - call this at app startup
 */
export async function initStorage(): Promise<void> {
  const manager = getStorageManager();
  await manager.initialize();
}
