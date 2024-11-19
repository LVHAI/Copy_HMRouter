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

import { HMNavPathStack } from './HMNavPathStack';
import { HMLogger } from '../log/HMLogger';
import { HMError } from '../log/ErrorCode';
import { HMRouterUtils } from '../utils/HMRouterUtils';
import { HMRouterPathInfo } from '../api/HMRouterPathInfo';
import { HMRouterPathCallback } from '../api/HMRouterPathCallback';
import { HMNavBarLifecycleMgr } from '../lifecycle/HMNavBarLifecycleMgr';
import { HMNavDstLifecycleMgr } from '../lifecycle/HMNavDstLifecycleMgr';
import { IHMLifecycleOwner } from '../lifecycle/interface/IHMLifecycleOwner';
import { HMActionType } from './HMActionType';

export class HMRouterMgrService {
  private static instance: HMRouterMgrService = new HMRouterMgrService();
  private navPathStackMap: Map<string, HMNavPathStack> = new Map();
  private lastNavigationId: string = '';
  private navbarLifecycleMgr: HMNavBarLifecycleMgr = HMNavBarLifecycleMgr.getInstance();
  private navDestinationLifecycleMgr: HMNavDstLifecycleMgr = HMNavDstLifecycleMgr.getInstance();

  private constructor() {
  }

  /**
   * Get HMRouterMgrService instance
   * @returns
   */
  public static getInstance(): HMRouterMgrService {
    return HMRouterMgrService.instance;
  }

  /**
   * HMNavigation创建时，调用该方法，生成与之绑定的PathStack
   * @param navigationId
   * @param hideNavBar
   * @param context
   * @returns
   */
  public createPathStack(navigationId: string, hideNavBar: boolean, context: UIContext): HMNavPathStack {
    const pathStack = this.navPathStackMap.get(navigationId);
    if (pathStack) {
      HMLogger.w('getOrCreatePathStack navigationId对应的pathStack已经存在绑定关系');
    }
    const newPathStack = new HMNavPathStack(context, navigationId, hideNavBar, (navigationId: string) => {
      this.lastNavigationId = navigationId;
    });
    this.navPathStackMap.set(navigationId, newPathStack);
    this.lastNavigationId = navigationId;
    return newPathStack;
  }

  /**
   * HMNavigation销毁时，清楚navigation
   * @param navigationId
   */
  public deletePathStack(pathStack: HMNavPathStack): void {
    for (let iter of this.navPathStackMap) {
      if (iter[1] === pathStack) {
        this.navPathStackMap.delete(iter[0]);
        HMLogger.d(`[HMRouterMgrService] delete ${pathStack.navigationId} bind pathstack success`);
        break;
      }
    }
    if (this.lastNavigationId === pathStack.navigationId) { // 查找有效的NavigationId
      this.lastNavigationId = '';
      this.lastNavigationId = this.getLastNavigationId();
    }
  }

  /**
   * Retrieve routing information, and when no navigationId is passed in, use the most recent navigationId passed in
   * @param navigationId
   * @returns
   */
  public getPathStack(navigationId?: string): HMNavPathStack | null {
    let lastNavigationId = navigationId || this.getLastNavigationId();
    if (lastNavigationId == null) {
      throw new Error('获取最近一次操作的PathStack失败');
    }
    const pathStack = this.navPathStackMap.get(lastNavigationId);
    if (pathStack) {
      return pathStack;
    } else {
      if (navigationId) {
        HMLogger.e(HMError.ERR_PARAM_ILLEGAL, 'navigationId', navigationId);
      } else {
        throw new Error('通过最近一次操作的navigationId获取PathStack失败');
      }
    }
    return null;
  }

  /**
   * 路由操作push/replace
   * @param pathInfo
   * @param callback
   */
  public pushOrReplace(type: HMActionType, pathInfo: HMRouterPathInfo, callback?: HMRouterPathCallback): void {
    // 检查pageUrl参数
    const pageUrlIsValid: boolean = HMRouterUtils.checkPageUrl(pathInfo.pageUrl);
    if (!pageUrlIsValid) {
      return;
    }

    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(pathInfo.pageUrl!, HMError.ERR_PUSH_INVALID, callback?.onLost);
    if (!pageInfo) {
      return;
    }

    const pathStack = this.getPathStack(pathInfo.navigationId);
    if (!pathStack) {
      return;
    }

    pathStack.hmPushOrReplace(type, pathInfo, callback,
      pageInfo.singleton ? LaunchMode.MOVE_TO_TOP_SINGLETON : LaunchMode.STANDARD);
  }

  /**
   * 路由pop操作
   * @param pathInfo
   * @param skipedLayerNumber
   */
  public pop(pathInfo?: HMRouterPathInfo, skipedLayerNumber?: number): void {
    const pathStack = this.getPathStack(pathInfo?.navigationId);
    if (!pathStack) {
      return;
    }

    const targetPageInfo = HMRouterUtils.getTargetPage(pathStack, pathInfo?.pageUrl, skipedLayerNumber);
    if (!targetPageInfo) {
      return;
    }

    pathStack.hmPop(targetPageInfo, pathInfo || {
      navigationId: pathStack.navigationId,
      pageUrl: targetPageInfo.name,
      animator: true
    });
  }

  /**
   * Get current page parameters
   * @returns
   */
  public getCurrentParam(): Object | null {
    let pathStack = this.getPathStack();
    if (!pathStack) {
      return null;
    }
    let allPath = pathStack.getAllPathName();
    const param = pathStack.getParamByIndex(allPath.length - 1) as Object;
    return param;
  }

  /**
   * Get the lifecycle instance corresponding to the current page
   * @returns
   */
  public getCurrentLifecycleOwner(): IHMLifecycleOwner | null {
    const pathStack = this.getPathStack();
    if (!pathStack) {
      return null;
    }
    if (pathStack.size() === 0 && !pathStack.hideNavbar) { // NavBar生命周期
      const currentPageLifecycle = this.navbarLifecycleMgr.createNavBarLifecycleOwner(pathStack);
      return currentPageLifecycle;
    } else { //  NavDestination生命周期
      const allPath = pathStack.getAllPathName();
      const currentPage = allPath[allPath.length - 1];
      const currentPageLifecycle =
        this.navDestinationLifecycleMgr.getLifecycleOwnerByPageUrl(this.getLastNavigationId(), currentPage);
      if (!currentPageLifecycle) {
        throw new Error('获取当前页面生命周期失败');
      }
      return currentPageLifecycle;
    }
  }

  private getLastNavigationId(): string {
    let lastNavigationId = this.lastNavigationId;
    if (!this.lastNavigationId) {
      this.navPathStackMap.forEach((val, key) => {
        lastNavigationId = key;
      });
    }
    return lastNavigationId;
  }
}