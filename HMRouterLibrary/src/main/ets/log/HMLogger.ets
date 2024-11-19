/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { DEFINED_ERROR } from './ErrorCode';

export enum HMLoggerLevel {
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR'
}

export class HMLogger {
  private static singleHMLogger = new HMLogger();
  private static loggerLevel: string = '';
  private static readonly LOGGER_DOMAIN: number = 0xFF00;
  private static readonly LOGGER_TAG: string = 'HMRouter Logger';

  private constructor() {
  }

  static getInstance() {
    return HMLogger.singleHMLogger;
  }

  public static openLog(level: 'DEBUG' | 'INFO') {
    HMLogger.loggerLevel = level;
  }

  public static isLoggable(type: HMLoggerLevel): boolean {
    if (!hilog.isLoggable(HMLogger.LOGGER_DOMAIN, HMLogger.LOGGER_TAG, hilog.LogLevel[type]) ||
      (type === 'DEBUG' && HMLogger.loggerLevel !== 'DEBUG') || (type === 'INFO' && !HMLogger.loggerLevel)) {
      return false;
    }

    return true;
  }

  public static d(format: string, ...args: Array<string | number>): void {
    if (!HMLogger.isLoggable(HMLoggerLevel.DEBUG)) {
      return;
    }

    const publicFormat =
      `[HMRouter DEBUG]${format.replaceAll('%s', '%{public}s')
        .replaceAll('%d', '%{public}d')
        .replaceAll('%i', '%{public}i')}`;
    hilog.debug(HMLogger.LOGGER_DOMAIN, HMLogger.LOGGER_TAG, publicFormat, ...args);
  }

  public static i(format: string, ...args: Array<string | number>): void {
    if (!HMLogger.isLoggable(HMLoggerLevel.INFO)) {
      return;
    }

    const publicFormat =
      `[HMRouter INFO]${format.replaceAll('%s', '%{public}s')
        .replaceAll('%d', '%{public}d')
        .replaceAll('%i', '%{public}i')}`;
    hilog.info(HMLogger.LOGGER_DOMAIN, HMLogger.LOGGER_TAG, publicFormat, ...args);
  }

  public static w(format: string, ...args: Array<string | number>): void {
    if (!HMLogger.isLoggable(HMLoggerLevel.WARN)) {
      return;
    }

    const publicFormat =
      `[HMRouter WARN]${format.replaceAll('%s', '%{public}s')
        .replaceAll('%d', '%{public}d')
        .replaceAll('%i', '%{public}i')}`;
    hilog.warn(HMLogger.LOGGER_DOMAIN, HMLogger.LOGGER_TAG, publicFormat, ...args);
  }

  public static e(format: string, ...args: Array<string | number>): void {
    if (!HMLogger.isLoggable(HMLoggerLevel.ERROR)) {
      return;
    }

    let formatStr: string = format;
    if (DEFINED_ERROR.has(format)) {
      formatStr = `${format} ${DEFINED_ERROR.get(format)?.errorCode} ${DEFINED_ERROR.get(format)?.errorMsg}`;
    }

    const publicFormat =
      `[HMRouter ERROR]${formatStr.replaceAll('%s', '%{public}s')
        .replaceAll('%d', '%{public}d')
        .replaceAll('%i', '%{public}i')}`;
    hilog.error(HMLogger.LOGGER_DOMAIN, HMLogger.LOGGER_TAG, publicFormat, ...args);
  }
}