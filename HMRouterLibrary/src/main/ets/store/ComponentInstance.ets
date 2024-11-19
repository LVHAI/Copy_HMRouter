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

import { collections } from '@kit.ArkTS';
import { IHMInterceptor } from '../api/IHMInterceptor';
import { IHMLifecycle } from '../api/IHMLifecycle';

export interface HMLifecycleInstance {
  lifecycle: IHMLifecycle;
  lifecycleName: string;
  priority: number;
}

export interface HMInterceptorInstance {
  interceptor: IHMInterceptor;
  interceptorName: string;
  priority: number;
}

export interface HMServiceInstance {
  serviceName: string;
  functionName: string;
  singleton?: boolean;
  instance: ESObject;
}

export interface HMPageInstance {
  builder?: WrappedBuilder<object[]>;
  pageUrl: string;
  interceptorArray?: collections.Array<string>;
  singleton?: boolean;
}

export class HMPageInfo {
  registerFlag: boolean = false;
  builder?: WrappedBuilder<object[]>;
  pageUrl: string = '';
  interceptors?: collections.Array<string>;
  singleton?: boolean;
  animator?: string;
  lifecycle?: string;
  dialog?: boolean;
}