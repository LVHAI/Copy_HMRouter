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

import { HvigorLogger } from '@ohos/hvigor';

export class Logger {
  static error(format: string, ...args: string[]) {
    let formatStr: string = format;
    if (DEFINED_ERROR.has(format)) {
      formatStr = `errorCode ${DEFINED_ERROR.get(format)?.errorCode}, errorMsg: ${DEFINED_ERROR.get(format)?.errorMsg}`;
    }
    const publicFormat =
      `[HMRouterPlugin] ERROR: ${formatStr.replace('%s', args[0])}`;
    HvigorLogger.getLogger().error(publicFormat);
  }

  static info(msg: string, ...args: unknown[]) {
    HvigorLogger.getLogger().info('[HMRouterPlugin] ' + msg, ...args);
  }

  static warn(msg: string, ...args: unknown[]) {
    HvigorLogger.getLogger().warn('[HMRouterPlugin] ' + msg, ...args);
  }
}

export enum PluginError {
  ERR_DUPLICATE_NAME = 'ERR_DUPLICATE_NAME',
  ERR_WRONG_DECORATION = 'ERR_DUPLICATE_',
  ERR_REPEAT_ANNOTATION = 'ERR_INIT_FRAMEWORK',
  ERR_ERROR_CONFIG = 'ERR_INIT_COMPONENT',
  ERR_NOT_EMPTY_STRING = 'ERR_INIT_NOT_READY',
  ERR_INVALID_STRING_VALUE = 'ERR_INVALID_STRING_VALUE'
}

interface PluginErrorInfo {
  errorCode: number;
  errorMsg: string;
}

const DEFINED_ERROR: Map<string, PluginErrorInfo> = new Map();

DEFINED_ERROR.set(PluginError.ERR_DUPLICATE_NAME, {
  errorCode: 40000001,
  errorMsg: 'Duplicate pageUrl/interceptor/service/animator/lifecycle - %s'
});

DEFINED_ERROR.set(PluginError.ERR_WRONG_DECORATION, {
  errorCode: 40000002,
  errorMsg: 'Struct with @HMRouter annotation could not contain NavDestination component - %s'
});

DEFINED_ERROR.set(PluginError.ERR_REPEAT_ANNOTATION, {
  errorCode: 40000003,
  errorMsg: 'File: %s contains multiple annotations'
});

DEFINED_ERROR.set(PluginError.ERR_ERROR_CONFIG, {
  errorCode: 40000004,
  errorMsg: 'moduleContext is null, Please check hvigorfile.ts file in module directory - %s'
});

DEFINED_ERROR.set(PluginError.ERR_NOT_EMPTY_STRING, {
  errorCode: 40000005,
  errorMsg: '%s constant value cannot be empty string - %s'
});

DEFINED_ERROR.set(PluginError.ERR_INVALID_STRING_VALUE, {
  errorCode: 40000006,
  errorMsg: 'invalid string value: %s'
});