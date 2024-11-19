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

import { IHMAnimator } from './IHMAnimator';
import { IHMInterceptor } from './IHMInterceptor';

/**
 * Router push/replace/pop params
 */
export interface HMRouterPathInfo {
  // 操作页面栈，当navigationId为空时，表示对最近一次操作的navigation进行路由跳转
  navigationId?: string;
  // 需要跳转的目标页面，push/replace操作必填参数
  pageUrl?: string;
  // 跳转页面携带参数，push/replace表示传递给下个页面的参数，pop表示回传给上一个页面的返回参数
  param?: ESObject;
  // 自定义拦截器，最高优先级执行
  interceptors?: IHMInterceptor[];
  // 自定义动画，使用传入的动画进行专场，不再使用原先定义的转场动画，传入false时将禁用动画
  animator?: IHMAnimator | boolean;
  // 是否跳过所有拦截器执行，不能跳过传入的interceptors拦截器
  skipAllInterceptor?: boolean;
}