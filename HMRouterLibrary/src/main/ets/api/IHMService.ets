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

export class HMServiceResp {
  code: number = 0;
  msg?: string;
  data?: ESObject;

  constructor(code: number, msg: string) {
    this.code = code;
    this.msg = msg;
  }
}

export const SERVICE_NOT_EXIST = new HMServiceResp(4001, 'Service not exist');

export const SERVICE_EXECUTE_FAILED = new HMServiceResp(4002, 'Service execute failed');

export const SERVICE_EXECUTE_SUCCESS = new HMServiceResp(0, 'Service execute success');
