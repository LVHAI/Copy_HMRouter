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

import { IHMInterceptor } from '../../api/IHMInterceptor';
import { HMComponent } from './HMComponent';

/**
 * HMInterceptorData
 */
@Sendable
export class HMInterceptorData extends HMComponent {
  /**
   * InterceptorName:非空，唯一
   */
  interceptorName: string = '';
  /**
   * 优先级，名，默认9，值越大优先级越高
   */
  priority: number = 9;
  /**
   * 是否全局，默认false
   */
  global?: boolean = false;

  constructor() {
    super();
  }
}

/**
 * HMInterceptorStoreData
 */
export class HMInterceptorStoreData {
  interceptor?: IHMInterceptor;
  hmInterceptorData: HMInterceptorData = new HMInterceptorData();
}

