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

import { IHMAnimator } from '../api/IHMAnimator';
import { HMRouterConfig } from '../api/HMRouterConfig';
import { HMInterceptorInstance, HMLifecycleInstance, HMPageInstance, HMServiceInstance } from './ComponentInstance';

/**
 * Router store
 *
 * use for store the instance of the page, service, interceptor, and animator
 */
export interface IHMRouterStore {
  /**
   * Init Router store
   * @returns void
   */
  init(config: HMRouterConfig): Promise<void>;

  /**
   * Get global interceptor
   * @returns Array<HMInterceptorInstance>
   */
  getGlobalInterceptor(): Array<HMInterceptorInstance>;

  /**
   * Get the corresponding interceptor based on the pageURL
   * @param pageUrl
   * @returns Array<HMInterceptorInstance>
   */
  getInterceptorByPageUrl(pageUrl: string): Array<HMInterceptorInstance>;

  /**
   * Get global lifecycle array
   * @returns Array<HMLifecycleInstance>
   */
  getGlobalLifecycle(): Array<HMLifecycleInstance>;

  /**
   * Get the lifecycle of the corresponding page by pageUrl
   * @param pageUrl
   * @returns HMLifecycleInstance | null
   */
  getLifecycleInstanceByPageUrl(pageUrl: string): HMLifecycleInstance | null;

  /**
   * Get the animator of the corresponding page by pageUrl
   * @param pageUrl
   * @returns IHMAnimator | null
   */
  getAnimatorByPageUrl(pageUrl: string): IHMAnimator | null;

  /**
   * Retrieve the animator based on its name. This API currently only provides
   * registered animators and does not dynamically import them. It returns synchronously
   * @param name
   * @returns IHMAnimator | null
   */
  getAnimatorByName(name: string): IHMAnimator | null;

  /**
   * Does it include Animator
   * @param name
   * @returns boolean
   */
  hasAnimator(name: string): boolean;

  /**
   * register animator
   * @param name
   * @param hmAnimator IHMAnimator
   * @returns Registration success or failure
   */
  registerAnimator(name: string, hmAnimator: IHMAnimator): boolean;

  /**
   * delete animator
   * @param name
   * @returns 取消Animator
   */
  unRegisterAnimator(name: string): boolean;

  /**
   * register HMPageInstance
   * @param hmPageInstance HMPageInstance
   * @returns boolean
   */
  registerHMPageInstance(hmPageInstance: HMPageInstance): boolean;

  /**
   * register global animator
   * @param interceptor HMInterceptorInstance
   */
  registerGlobalInterceptor(interceptor: HMInterceptorInstance): void;

  /**
   * Log out the global interceptor with the interceptor
   * name as the parameter, and return whether the logout was successful
   * @param interceptorName
   * @returns
   */
  unRegisterGlobalInterceptor(interceptorName: string): boolean;

  /**
   * register global lifecycle
   * @param lifecycle HMLifecycleInstance
   */
  registerGlobalLifecycle(lifecycle: HMLifecycleInstance): void;

  /**
   * Register the global lifecycle, with the parameter being the global lifecycle name, and return whether the logout was successful
   * @param interceptorName
   * @returns
   */
  unRegisterGlobalLifecycle(lifecycleName: string): boolean;

  /**
   * Get page info
   * @param pageUrl
   * @returns HMPageInstance | null
   */
  getHMPageInfo(pageUrl: string): HMPageInstance | null;

  /**
   * Load service instance
   * @param serviceName
   * @returns
   */
  loadService(serviceName: string): HMServiceInstance | undefined;

  /**
   * Is initialization complete
   * @returns
   */
  isInit(): boolean;

}

