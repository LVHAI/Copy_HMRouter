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

import { HMLogger } from '../log/HMLogger';
import { AllLifecycleState, InnerLifecycleState } from '../api/HMLifecycleState';
import { HMNavDstLifecycleOwner } from './implement/HMNavDstLifecycleOwner';
import { NavDstLifecycleKey } from './interface/NavDstLifecycleKey';

/**
 * Navigation中NavDestination页面生命周期管理类，管理Navigation中所有NavDestination生命周期
 */
export class HMNavDstLifecycleRegistry {
  private lifecycleMap: Map<NavDstLifecycleKey, HMNavDstLifecycleOwner> = new Map();
  private uiContext: UIContext;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  /**
   * 通过PageUrl获取生命周期，如果页面在栈中存在多个实例，则只返回最后一个
   * @param pageUrl
   * @returns
   */
  public getLifecycleOwnerByPageUrl(pageUrl: string): HMNavDstLifecycleOwner | null {
    let lifecycle: HMNavDstLifecycleOwner | null = null;
    for (const iter of this.lifecycleMap) {
      const key = iter[0];
      if (key.pageUrl === pageUrl) {
        lifecycle = iter[1];
      }
    }
    return lifecycle;
  }

  /**
   * Create NavDestination page corresponding lifecycle
   * @param pageUrl
   * @param singleton
   * @returns
   */
  public createLifecycle(pageUrl: string,
    singleton?: boolean): HMNavDstLifecycleOwner {
    let lifecycleOwner: HMNavDstLifecycleOwner;
    const key: NavDstLifecycleKey = { pageUrl: pageUrl, navDestinationId: '' };
    let lifecycleResult = this.getLifecycleOwnerByKey(key, singleton);
    if (!lifecycleResult) {
      lifecycleOwner = new HMNavDstLifecycleOwner(pageUrl);
      this.lifecycleMap.set(key, lifecycleOwner);
    } else {
      lifecycleOwner = lifecycleResult[1];
    }
    return lifecycleOwner;
  }

  /**
   * 更新NavDestination生命周期中的navDestinationId
   * @param pageUrl
   * @param navDestinationId
   * @returns
   */
  public updateLifecycleKey(pageUrl: string, navContext: NavDestinationContext): boolean {
    let counts = 0;
    const navDestinationId = navContext.navDestinationId;
    if (!navDestinationId) {
      return false;
    }
    for (const iter of this.lifecycleMap) {
      counts += 1;
      if (counts === this.lifecycleMap.size) { // 判断Map最后一条数据
        const lastKey = iter[0];
        if (lastKey.pageUrl === pageUrl && lastKey.navDestinationId === '') {
          lastKey.navDestinationId = navDestinationId;
          iter[1].navContext = navContext;
          return true;
        }
      }
    }
    return false;
  }

  /**
   * 页面销毁时，删除对应生命周期实例
   * @param pageUrl
   * @param navDestinationId
   * @returns
   */
  public destroyLifecycle(pageUrl: string, navDestinationId: string): boolean {
    const key: NavDstLifecycleKey = { pageUrl: pageUrl, navDestinationId: navDestinationId };
    const lifecycleResult = this.getLifecycleOwnerByKey(key, false);
    if (lifecycleResult) {
      this.lifecycleMap.delete(lifecycleResult[0]);
      return true;
    }
    return false;
  }

  public dispatch(state: AllLifecycleState, pageUrl: string, navDestinationId?: string): boolean | void {
    HMLogger.d(`[Lifecycle] dispatch NavDestination: ${pageUrl} ${state}, navDestinationId is ${navDestinationId}`);
    if (!navDestinationId) {
      if (state === InnerLifecycleState.onPrepare || state === InnerLifecycleState.onWillAppear) {
        navDestinationId = '';
      } else {
        throw new Error(`navDestinationId is required, run ${pageUrl} ${state} is failed`);
      }
    }
    const lifecycle = this.getLifecycleOwnerByKey({ pageUrl: pageUrl, navDestinationId: navDestinationId });
    if (!lifecycle) {
      throw new Error(`${pageUrl} lifecycle is empty, run ${pageUrl} ${state} is failed`);
    }
    return lifecycle[1].dispatch(state, {
      uiContext: this.uiContext,
      navContext: lifecycle[1].navContext
    });
  }

  /**
   * 获取生命周期实例
   * @param key
   * @param singleton
   * @returns
   */
  private getLifecycleOwnerByKey(key: NavDstLifecycleKey,
    singleton?: boolean): [NavDstLifecycleKey, HMNavDstLifecycleOwner] | null {
    let lifecycle: [NavDstLifecycleKey, HMNavDstLifecycleOwner] | null = null;
    for (const iter of this.lifecycleMap) {
      const k = iter[0];
      const v = iter[1];
      let isEqual: boolean = false;
      if (singleton) { // 如果页面是单例，仅需要判断pageUrl对应生命周期实例是否存在
        isEqual = k.pageUrl === key.pageUrl;
      } else { // 如果页面不是单例，需要判断pageUrl以及对应的NavDestinationId
        isEqual = key.pageUrl === k.pageUrl && key.navDestinationId === k.navDestinationId;
      }
      if (isEqual) {
        lifecycle = [k, v];
        break;
      }
    }
    return lifecycle;
  }
}