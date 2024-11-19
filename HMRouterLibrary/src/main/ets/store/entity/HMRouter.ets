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
import { HMComponent } from './HMComponent';

@Sendable
export class HMRouterData extends HMComponent {
  /**
   * 跳转路径pushName
   */
  pageUrl: string = '';
  /**
   * 是否弹窗类型页面
   */
  dialog?: boolean;
  /**
   * 是否单例页面
   */
  singleton?: boolean;
  /**
   * 动效实例
   */
  animator?: string;
  /**
   * 路由拦截器
   */
  interceptors?: collections.Array<string>;
  /**
   * 生命周期处理
   */
  lifecycle?: string;

  constructor() {
    super();
  }

  /**
   * page 不需要动态import
   * @returns undefined
   */
  public override importComponent<T>(): T | undefined {
    return undefined;
  }
}