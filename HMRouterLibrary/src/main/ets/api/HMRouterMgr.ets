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

import { HMInterceptorInstance, HMLifecycleInstance, HMPageInstance } from '../store/ComponentInstance';
import { HMRouterPathCallback } from './HMRouterPathCallback';
import { HMRouterPathInfo } from './HMRouterPathInfo';
import { HMRouterMgrService } from '../router/HMRouterMgrService';
import { HMLogger } from '../log/HMLogger';
import { HMError } from '../log/ErrorCode';
import { IHMAnimator } from './IHMAnimator';
import { HMRouterConfig } from './HMRouterConfig';
import { IHMRouterStore } from '../store/IHMRouterStore';
import { hmRouterStore } from '../store/RouterStoreFactory';
import { HMPageLifecycle } from '../lifecycle/HMPageLifecycle';
import { HMPageLifecycleMgr } from '../lifecycle/HMPageLifecycleMgr';
import { HMActionType } from '../router/HMActionType';
import { HMServiceMgr } from '../service/ServiceMgr';
import { IHMLifecycleOwner } from '../lifecycle/interface/IHMLifecycleOwner';
import { HMRouterConst } from '../constants/Constants';
import { HMServiceResp } from './IHMService';

export class HMRouterMgr {
  public static isInit: boolean = false;
  private static service: HMRouterMgrService = HMRouterMgrService.getInstance();
  private static routerStore: IHMRouterStore = hmRouterStore;
  private static pageLifecycleMgr: HMPageLifecycleMgr = HMPageLifecycleMgr.getInstance();

  /**
   * Initialize HMRouter
   * @Param config
   */
  static init(config: HMRouterConfig): void {
    HMRouterMgr.routerStore.init(config);
    HMRouterMgr.isInit = true;
  }

  /**
   * Enable HMRouter logs
   * @param level
   */
  static openLog(level: 'DEBUG' | 'INFO'): void {
    HMLogger.openLog(level);
  }

  /**
   * Push to target page
   * @param pathInfo
   * @param callback
   */
  @initCheck
  static push(pathInfo: HMRouterPathInfo, callback?: HMRouterPathCallback): void {
    try {
      HMRouterMgr.service.pushOrReplace(HMActionType.PUSH, pathInfo, callback);
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
    }
  }

  /**
   * Replace current page to target page
   * @param pathInfo
   * @param callback
   */
  @initCheck
  static replace(pathInfo: HMRouterPathInfo, callback?: HMRouterPathCallback): void {
    try {
      HMRouterMgr.service.pushOrReplace(HMActionType.REPLACE, pathInfo, callback);
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
    }
  }

  /**
   * Back to target page
   * @param pathInfo
   * @param skipedLayerNumber
   * The number of levels returned by the page, default to 0, indicates returning to the previous level,
   * 1 indicates skipping one level of page return, two pages are pushed out at the same time,
   * and the pathInfo.pathInfo parameter has higher priority than skipedLayerNumber
   */
  @initCheck
  static pop(pathInfo?: HMRouterPathInfo, skipedLayerNumber?: number): void {
    try {
      HMRouterMgr.service.pop(pathInfo, skipedLayerNumber);
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
    }
  }

  /**
   * Get pathStack by navigationId
   * @param navigationId
   * @returns
   */
  @initCheck
  static getPathStack(navigationId: string): NavPathStack | null {
    try {
      return HMRouterMgr.service.getPathStack(navigationId);
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
      return null;
    }
  }

  /**
   * Get current page params
   * @returns
   */
  @initCheck
  static getCurrentParam(): Object | null {
    try {
      return HMRouterMgr.service.getCurrentParam();
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
      return null;
    }
  }

  /**
   * Get the current page lifecycle management instance
   *
   * which can be used to retrieve the data content initialized during lifecycle stages
   * @returns
   */
  @initCheck
  static getCurrentLifecycleOwner(): IHMLifecycleOwner | null {
    try {
      const lifecycle = HMRouterMgr.service.getCurrentLifecycleOwner();
      return lifecycle;
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
      return null;
    }
  }

  /**
   * Register global interceptor
   * @param interceptorInstance
   * @returns
   */
  @initCheck
  static registerGlobalInterceptor(interceptorInstance: HMInterceptorInstance): void {
    HMRouterMgr.routerStore.registerGlobalInterceptor(interceptorInstance);
  }

  /**
   * Unregister global interceptor
   * @param interceptorName
   * @returns
   */
  @initCheck
  static unRegisterGlobalInterceptor(interceptorName: string): boolean {
    return HMRouterMgr.routerStore.unRegisterGlobalInterceptor(interceptorName);
  }

  /**
   * Register global lifecycle
   * @param lifecycleInstance
   * @returns
   */
  @initCheck
  static registerGlobalLifecycle(lifecycleInstance: HMLifecycleInstance): void {
    HMRouterMgr.routerStore.registerGlobalLifecycle(lifecycleInstance);
  }

  /**
   * Unregister global lifecycle
   * @param lifecycleName
   * @returns
   */
  @initCheck
  static unRegisterGlobalLifecycle(lifecycleName: string): boolean {
    return HMRouterMgr.routerStore.unRegisterGlobalLifecycle(lifecycleName);
  }

  /**
   * Register global animator
   * @param key
   * @param animator
   */
  @initCheck
  static registerGlobalAnimator(navigationId: string, key: 'standard' | 'dialog', animator: IHMAnimator): void {
    const name = key + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navigationId;
    HMRouterMgr.routerStore.registerAnimator(name, animator);
  }

  /**
   * Unregister global animator
   * @param key
   * @returns
   */
  @initCheck
  static unRegisterGlobalAnimator(navigationId: string, key: 'standard' | 'dialog'): boolean {
    const name = key + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navigationId;
    return HMRouterMgr.routerStore.unRegisterAnimator(name);
  }

  /**
   * Register custom dynamic router
   * @param pageInstance
   */
  @initCheck
  static registerPageBuilder(pageInstance: HMPageInstance): boolean {
    if (!pageInstance.builder) {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'pageInstance.builder');
      return false;
    }
    return HMRouterMgr.routerStore.registerHMPageInstance(pageInstance);
  }

  /**
   * Generate page lifecycle management instance
   * @returns Unique identifier for page lifecycle instance
   */
  @initCheck
  static generatePageLifecycleId(): string {
    try {
      return HMRouterMgr.pageLifecycleMgr.createPageLifecycle();
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
      return '';
    }
  }

  /**
   * get page lifecycle by id
   * @param pageLifecycleId
   * @returns page lifecycle instance
   */
  @initCheck
  static getPageLifecycleById(pageLifecycleId: string): HMPageLifecycle | undefined {
    try {
      return HMRouterMgr.pageLifecycleMgr.getPageLifecycle(pageLifecycleId);
    } catch (e) {
      HMLogger.e(HMError.ERR_INTERNAL, `${e.message}\n${e.stack}\n`);
      return undefined;
    }
  }

  /**
   * Execute service
   * @param serviceName
   * @param args
   * @returns service response
   */
  @initCheck
  static request(serviceName: string, ...args: Object[]): HMServiceResp {
    return HMServiceMgr.request(serviceName, ...args);
  }
}


/**
 * Check init status
 * @param target
 * @param propertyKey
 * @param descriptor
 */
function initCheck(target: ESObject, propertyKey: string, descriptor: PropertyDescriptor) {
  const oldVal: Function = descriptor.value;
  descriptor.value =
    (args1: ESObject, args2: ESObject, args3: ESObject, args4: ESObject, args5: ESObject): ESObject => {
      if (!target.isInit) {
        HMLogger.e(HMError.ERR_INIT_NOT_READY);
      } else {
        return oldVal(args1, args2, args3, args4, args5);
      }
    };
}