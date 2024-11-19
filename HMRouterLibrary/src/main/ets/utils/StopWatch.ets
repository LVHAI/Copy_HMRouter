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

import { systemDateTime } from '@kit.BasicServicesKit';
import { HMLogger, HMLoggerLevel } from '../log/HMLogger';

export class StopWatch {
  private static tasks: Map<string, number> = new Map();

  public static start(taskName: string): void {
    if (HMLogger.isLoggable(HMLoggerLevel.DEBUG)) {
      StopWatch.tasks.set(taskName, systemDateTime.getTime(true));
    }
  }

  public static end(taskName: string): number {
    const taskStartTimeNanos = StopWatch.tasks.get(taskName);
    if (taskStartTimeNanos) {
      StopWatch.tasks.delete(taskName);
      return (systemDateTime.getTime(true) - taskStartTimeNanos) / 1000000;
    } else {
      return 0;
    }
  }
}