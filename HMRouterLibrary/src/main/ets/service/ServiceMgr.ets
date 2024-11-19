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

import { HMServiceResp, SERVICE_EXECUTE_FAILED, SERVICE_EXECUTE_SUCCESS, SERVICE_NOT_EXIST } from '../api/IHMService';
import { HMError } from '../log/ErrorCode';
import { HMLogger } from '../log/HMLogger';
import { HMServiceInstance } from '../store/ComponentInstance';
import { hmRouterStore } from '../store/RouterStoreFactory';

export class HMServiceMgr {
  static classInfoOfSingletonServiceMap: Map<string, HMServiceInstance> = new Map();

  static execute(targetClass: ESObject, functionName: string, ...args: Object[]): ESObject {
    return targetClass[functionName](...args);
  }

  /**
   * Method of synchronously calling HMService decoration
   * @returns
   */
  static request(serviceName: string, ...args: Object[]): HMServiceResp {
    let instance: HMServiceInstance | undefined;
    if (HMServiceMgr.classInfoOfSingletonServiceMap.has(serviceName)) {
      instance = HMServiceMgr.classInfoOfSingletonServiceMap.get(serviceName);
    } else {
      instance = hmRouterStore.loadService(serviceName);
      if (instance?.singleton) {
        HMServiceMgr.classInfoOfSingletonServiceMap.set(instance.serviceName, instance);
      }
    }
    if (!instance) {
      return SERVICE_NOT_EXIST;
    }
    try {
      let data: ESObject = HMServiceMgr.execute(instance.instance, instance.functionName, ...args);
      let resp = SERVICE_EXECUTE_SUCCESS;
      resp.data = data;
      return resp;
    } catch (e) {
      HMLogger.e(HMError.ERR_SERVICE_EXECUTE_FAILED, serviceName);
      HMLogger.e(`${e.message}\n${e.stack}\n`);
      return SERVICE_EXECUTE_FAILED;
    }
  }
}