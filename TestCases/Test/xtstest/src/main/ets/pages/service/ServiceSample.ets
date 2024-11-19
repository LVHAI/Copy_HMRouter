/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HMService } from '@hadss/hmrouter'

export interface TempObj {
  paramA: string,
  paramB: number
}

export class CustomService {
  @HMService({ serviceName: 'testConsole' })
  testConsole(): void {
    console.log('调用服务 testConsole')
  }

  @HMService({ serviceName: 'testFunWithReturn' })
  testFunWithReturn(): string {
    return '调用服务 testFunWithReturn'
  }

  @HMService({ serviceName: 'testFunWithParams', singleton: true })
  testFunWithParams(str: string, num: number, bool: boolean, obj: TempObj) {
    console.log('服务 testFunWithParams 参数1 ' + str)
    console.log('服务 testFunWithParams 参数2 ' + num)
    console.log('服务 testFunWithParams 参数3 ' + bool)
    console.log('服务 testFunWithParams 参数4 ' + JSON.stringify(obj))

    return obj.paramA || obj.paramB
  }

  // 定义异步服务，服务名与函数名可以不一致
  @HMService({ serviceName: 'testAsyncFun', singleton: true })
  async testAsyncFunction(): Promise<string> {
    return new Promise((resolve) => {
      resolve('调用异步服务 testAsyncFun')
    })
  }

  @HMService({ serviceName: 'testFunWithError' })
  testFunWithError(): void {
    throw new Error('调用服务 testFunWithError')
  }
}