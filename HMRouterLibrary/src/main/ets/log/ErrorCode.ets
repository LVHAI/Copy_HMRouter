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

enum HMError {
  ERR_DUPLICATE_PAGE = 'ERR_DUPLICATE_PAGE',
  ERR_DUPLICATE_COMPONENT = 'ERR_DUPLICATE_COMPONENT',
  ERR_INIT_FRAMEWORK = 'ERR_INIT_FRAMEWORK',
  ERR_INIT_COMPONENT = 'ERR_INIT_COMPONENT',
  ERR_INIT_NOT_READY = 'ERR_INIT_NOT_READY',
  ERR_PUSH_INVALID = 'ERR_PUSH_INVALID',
  ERR_PUSH_SYS = 'ERR_PUSH_SYS',
  ERR_POP_INVALID = 'ERR_POP_INVALID',
  ERR_POP_SYS = 'ERR_POP_SYS',
  ERR_REPLACE_INVALID = 'ERR_REPLACE_INVALID',
  ERR_REPLACE_SYS = 'ERR_REPLACE_SYS',
  ERR_PARAM_REQUIRED = 'ERR_PARAM_REQUIRED',
  ERR_PARAM_ILLEGAL = 'ERR_PARAM_ILLEGAL',
  ERR_COMPONENT_GET_FAILED = 'ERR_COMPONENT_GET_FAILED',
  ERR_COMPONENT_NOT_EXIST = 'ERR_COMPONENT_NOT_EXIST',
  ERR_COMPONENT_PROCESS = 'ERR_COMPONENT_PROCESS',
  ERR_INTERNAL = 'ERR_INTERNAL',
  ERR_SERVICE_NOT_EXIST = 'ERR_SERVICE_NOT_EXIST',
  ERR_SERVICE_IMPORT_FAILED = 'ERR_SERVICE_IMPORT_FAILED',
  ERR_SERVICE_EXECUTE_FAILED = 'ERR_SERVICE_EXECUTE_FAILED',
  ERR_DYNAMIC_IMPORT_FAILED = 'ERR_DYNAMIC_IMPORT_FAILED'
}

interface HMErrorInfo {
  errorCode: number;
  errorMsg: string;
}

const DEFINED_ERROR: Map<string, HMErrorInfo> = new Map();

DEFINED_ERROR.set(HMError.ERR_DUPLICATE_PAGE, {
  errorCode: 40000001,
  errorMsg: 'Duplicate page definition - %s'
});

DEFINED_ERROR.set(HMError.ERR_DUPLICATE_COMPONENT, {
  errorCode: 40000002,
  errorMsg: 'Duplicate components - %s - %s'
});

DEFINED_ERROR.set(HMError.ERR_INIT_FRAMEWORK, {
  errorCode: 40001001,
  errorMsg: 'Framework initialization failed'
});

DEFINED_ERROR.set(HMError.ERR_INIT_COMPONENT, {
  errorCode: 40001002,
  errorMsg: '%s - %s initialization failed'
});

DEFINED_ERROR.set(HMError.ERR_INIT_NOT_READY, {
  errorCode: 40001003,
  errorMsg: 'Framework initialization not completed'
});

DEFINED_ERROR.set(HMError.ERR_PUSH_INVALID, {
  errorCode: 40002001,
  errorMsg: 'Push failed, invalid page - %s'
});

DEFINED_ERROR.set(HMError.ERR_PUSH_SYS, {
  errorCode: 40002002,
  errorMsg: 'Push failed, system error - %s - %s'
});

DEFINED_ERROR.set(HMError.ERR_POP_INVALID, {
  errorCode: 40002003,
  errorMsg: 'Pop failed, invalid page - %s'
});

DEFINED_ERROR.set(HMError.ERR_POP_SYS, {
  errorCode: 40002004,
  errorMsg: 'Pop failed, system error - %s - %s'
});

DEFINED_ERROR.set(HMError.ERR_REPLACE_INVALID, {
  errorCode: 40002005,
  errorMsg: 'Replace failed, invalid page - %s'
});

DEFINED_ERROR.set(HMError.ERR_REPLACE_SYS, {
  errorCode: 40002006,
  errorMsg: 'Replace failed, system error - %s - %s'
});

DEFINED_ERROR.set(HMError.ERR_PARAM_REQUIRED, {
  errorCode: 40003001,
  errorMsg: 'Missing parameter: %s'
});

DEFINED_ERROR.set(HMError.ERR_PARAM_ILLEGAL, {
  errorCode: 40003002,
  errorMsg: 'Illegal input parameters - %s: %s'
});

DEFINED_ERROR.set(HMError.ERR_COMPONENT_GET_FAILED, {
  errorCode: 40005001,
  errorMsg: '%s component loading failed'
});

DEFINED_ERROR.set(HMError.ERR_COMPONENT_NOT_EXIST, {
  errorCode: 40005002,
  errorMsg: '%s not exists'
});

DEFINED_ERROR.set(HMError.ERR_COMPONENT_PROCESS, {
  errorCode: 40005003,
  errorMsg: '%s execution failed - %s'
});

DEFINED_ERROR.set(HMError.ERR_INTERNAL, {
  errorCode: 40005004,
  errorMsg: 'Internal error - %s'
});

DEFINED_ERROR.set(HMError.ERR_SERVICE_NOT_EXIST, {
  errorCode: 40005005,
  errorMsg: '%s service does not exist'
});

DEFINED_ERROR.set(HMError.ERR_SERVICE_IMPORT_FAILED, {
  errorCode: 40005006,
  errorMsg: '%s service loading failed, internal error'
});

DEFINED_ERROR.set(HMError.ERR_SERVICE_EXECUTE_FAILED, {
  errorCode: 40005007,
  errorMsg: '%s service execution failed'
});

DEFINED_ERROR.set(HMError.ERR_DYNAMIC_IMPORT_FAILED, {
  errorCode: 40005008,
  errorMsg: 'Dynamic import failed - %s - %s - %s'
});

export { HMError, DEFINED_ERROR };