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
import { HMError } from '../log/ErrorCode';
import { HMLogger } from '../log/HMLogger';
import { AllLifecycleState } from '../api/HMLifecycleState';
import { HMNavDstLifecycleRegistry } from './HMNavDstLifecycleRegistry';
import { HMNavDstLifecycleOwner } from './implement/HMNavDstLifecycleOwner';

export class HMNavDstLifecycleMgr {
  private static instance: HMNavDstLifecycleMgr = new HMNavDstLifecycleMgr();
  private navDstLifecycleMap: Map<string, HMNavDstLifecycleRegistry> = new Map(); // key: navigationId

  public static getInstance(): HMNavDstLifecycleMgr {
    return HMNavDstLifecycleMgr.instance;
  }

  /**
   * 页面跳转生成对应NavDestination生命周期实例
   * @param navigationId
   * @param pageUrl
   * @param uiContext
   * @param onceLifecycle
   * @param singleton
   * @returns
   */
  createLifecycle(uiContext: UIContext, navigationId: string, pageUrl: string,
    singleton?: boolean): HMNavDstLifecycleOwner {
    let navDstLifecycleRegistry = this.navDstLifecycleMap.get(navigationId);
    if (!navDstLifecycleRegistry) {
      navDstLifecycleRegistry = new HMNavDstLifecycleRegistry(uiContext);
      this.navDstLifecycleMap.set(navigationId, navDstLifecycleRegistry);
    }
    return navDstLifecycleRegistry.createLifecycle(pageUrl, singleton);
  }

  /**
   * Destroy NavDestination lifecycle
   * @param navigationId
   * @param pageUrl
   * @param navId
   */
  destroyLifecycle(navigationId: string, pageUrl: string, navDestinationId: string) {
    const navDestinationLifecycleOwnerMgr = this.navDstLifecycleMap.get(navigationId);
    navDestinationLifecycleOwnerMgr?.destroyLifecycle(pageUrl, navDestinationId);
  }

  /**
   * 更新NavDestination生命周期的Key.navDestinationId
   * @param navigationId
   * @param pageUrl
   * @param navId
   */
  updateLifecycleKey(navigationId: string, pageUrl: string, navContext: NavDestinationContext): void {
    const navDestinationLifecycleOwnerMgr = this.navDstLifecycleMap.get(navigationId);
    navDestinationLifecycleOwnerMgr?.updateLifecycleKey(pageUrl, navContext);
  }

  /**
   * Dispatch NavDestination lifecycle
   * @param state
   * @param navigationId
   * @param pageUrl
   * @param navDestinationId
   * @returns
   */
  dispatchEvent(state: AllLifecycleState, navigationId: string, pageUrl: string,
    navDestinationId?: string): boolean | void {
    const navDestinationLifecycleOwnerMgr = this.navDstLifecycleMap.get(navigationId);
    try {
      return navDestinationLifecycleOwnerMgr?.dispatch(state, pageUrl, navDestinationId);
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}`);
    }
  }

  /**
   * 通过PageUrl获取NavDestinationLifecycleObserver，供获取当前NavDestination生命周期使用
   * Retrieve NavDestination Lifecycle Observer through PageURL for get the current NavDestination lifecycle
   * @param navigationId
   * @param pageUrl
   * @returns
   */
  getLifecycleOwnerByPageUrl(navigationId: string, pageUrl: string): HMNavDstLifecycleOwner {
    const navDestinationLifecycleOwnerMgr = this.navDstLifecycleMap.get(navigationId);
    const lifecycle = navDestinationLifecycleOwnerMgr?.getLifecycleOwnerByPageUrl(pageUrl);
    if (!lifecycle) {
      throw new Error('get current NavDestinaion pageLifecycle is failed');
    }
    return lifecycle;
  }
}