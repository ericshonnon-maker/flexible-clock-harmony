/**
 * Calculator module for flexible clock time calculations
 * Handles end time calculation based on clock-in time and scenario determination
 */

/**
 * Parses a time string (HH:mm) to minutes since midnight
 */
function parseTimeToMinutes(time: string): number {
  const parts = time.split(':');
  const hours = parseInt(parts[0], 10);
  const minutes = parseInt(parts[1], 10);
  return hours * 60 + minutes;
}

/**
 * Converts minutes since midnight to HH:mm format
 */
function minutesToTimeString(minutes: number): string {
  const hours = Math.floor(minutes / 60) % 24;
  const mins = minutes % 60;
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
}

/**
 * Parses a datetime string (YYYY-MM-DD HH:mm:ss or YYYY-MM-DDTHH:mm:ss) to Date object
 */
function parseDateTime(dateTimeStr: string): Date {
  // Handle both space and T separators
  const normalizedStr = dateTimeStr.replace('T', ' ');
  return new Date(normalizedStr);
}

/**
 * Main calculation function
 * @param clockInTime - Clock in time in format "HH:mm" or "YYYY-MM-DD HH:mm"
 * @returns Object containing endTime and scenario
 */
export function calculate(clockInTime: string): { endTime: string; scenario: string } {
  // Extract time portion if full datetime is provided
  let timeStr = clockInTime;
  if (clockInTime.includes(' ') || clockInTime.includes('T')) {
    const parts = clockInTime.includes('T') ? clockInTime.split('T') : clockInTime.split(' ');
    timeStr = parts[1] || parts[0];
  }

  const clockInMinutes = parseTimeToMinutes(timeStr);
  const eightHours = 8 * 60; // 480 minutes
  const flexStartBegin = parseTimeToMinutes('08:00');
  const flexStartEnd = parseTimeToMinutes('09:30');
  const flexEndBegin = parseTimeToMinutes('17:00');
  const flexEndEnd = parseTimeToMinutes('18:30');
  const lunchStart = parseTimeToMinutes('12:00');
  const lunchEnd = parseTimeToMinutes('13:00');

  let scenario: string;
  let endMinutes: number;

  if (clockInMinutes < flexStartBegin) {
    // Early scenario: clock in before 08:00
    scenario = 'early';
    endMinutes = flexEndBegin; // 17:00
  } else if (clockInMinutes > flexStartEnd) {
    // Late scenario: clock in after 09:30
    scenario = 'late';
    endMinutes = flexEndBegin; // 17:00
  } else {
    // Normal scenario: clock in between 08:00 and 09:30 (inclusive)
    scenario = 'normal';
    endMinutes = clockInMinutes + eightHours; // Add 8 work hours

    // Check if we need to add lunch break
    // If raw end time would be after 12:00 AND clock in was before 12:00
    if (endMinutes > lunchStart && clockInMinutes < lunchStart) {
      const lunchDuration = lunchEnd - lunchStart; // 60 minutes
      endMinutes += lunchDuration;
    }
  }

  // Ensure end time is within valid range (between 17:00 and 18:30)
  if (endMinutes < flexEndBegin) {
    endMinutes = flexEndBegin;
  } else if (endMinutes > flexEndEnd) {
    endMinutes = flexEndEnd;
  }

  return {
    endTime: minutesToTimeString(endMinutes),
    scenario: scenario
  };
}

/**
 * Remaining time result interface
 */
export interface RemainingTime {
  hours: number;
  minutes: number;
  seconds: number;
  isOver: boolean;
}

/**
 * Gets remaining time until end time
 * @param endTime - Target end time in "HH:mm" format
 * @returns RemainingTime object with hours, minutes, seconds, and isOver flag
 */
export function getRemaining(endTime: string): RemainingTime {
  const now = new Date();
  const endParts = endTime.split(':');
  const endHour = parseInt(endParts[0], 10);
  const endMinute = parseInt(endParts[1], 10);

  const endDate = new Date();
  endDate.setHours(endHour, endMinute, 0, 0);

  let diff = endDate.getTime() - now.getTime();

  // If end time is earlier than current time, assume it's tomorrow
  if (diff < 0) {
    endDate.setDate(endDate.getDate() + 1);
    diff = endDate.getTime() - now.getTime();
  }

  const isOver = diff < 0;

  if (isOver) {
    return {
      hours: 0,
      minutes: 0,
      seconds: 0,
      isOver: true
    };
  }

  const totalSeconds = Math.floor(diff / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  return {
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    isOver: false
  };
}

/**
 * Formats remaining time components into a readable string
 * @param hours - Hours component
 * @param minutes - Minutes component
 * @param seconds - Seconds component
 * @returns Formatted string "HH:mm:ss"
 */
export function formatRemaining(hours: number, minutes: number, seconds: number): string {
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}
