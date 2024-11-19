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

import { HashMap } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { HMNavPathStack } from '../router/HMNavPathStack';
import { HMLifecycleState } from '../api/HMLifecycleState';
import { HMLogger } from '../log/HMLogger';
import { HMRouterUtils } from '../utils/HMRouterUtils';
import { HMNavBarLifecycleObserver } from './implement/HMNavBarLifecycleOwner';
import { NavBarParentTypes } from './enums/NavBarParentTypes';
import { NavBarLifecycleKey } from './interface/NavBarLifecycleKey';
import { HMLifecycleOwner } from './implement/HMLifecycleOwner';
import { HMNavDstLifecycleMgr } from './HMNavDstLifecycleMgr';

export class HMNavBarLifecycleMgr {
  private static instance: HMNavBarLifecycleMgr = new HMNavBarLifecycleMgr();
  private lifecycleMap: HashMap<NavBarLifecycleKey, HMNavBarLifecycleObserver> = new HashMap(); // NavBar对应的多个生命周期实例
  private navDestinationLifecycleMgr: HMNavDstLifecycleMgr = HMNavDstLifecycleMgr.getInstance();
  private uiContext!: UIContext;

  static getInstance(): HMNavBarLifecycleMgr {
    return HMNavBarLifecycleMgr.instance;
  }

  /**
   * Generate Key through PathStack corresponding to NavBar
   * @param pathStack
   * @param routerInfo
   * @returns
   */
  public generateNavBarLifecycleKey(pathStack: HMNavPathStack): NavBarLifecycleKey {
    const parent = pathStack.getParent() as HMNavPathStack;
    let parentType: NavBarParentTypes;
    let parentId: string;
    if (parent) {
      const allPath = parent.getAllPathName();
      if (allPath.length === 0) {
        parentType = NavBarParentTypes.NavBar;
        parentId = parent.navigationId;
      } else {
        parentType = NavBarParentTypes.NavDestination;
        const index = allPath.length - 1;
        parentId = `${index}_${allPath[index]}`;
      }
    } else {
      let routerState = router.getState();
      parentId = `${routerState.index}_${routerState.path}_${routerState.name}`;
      parentType = NavBarParentTypes.Page;
    }
    return {
      navigationId: pathStack.navigationId,
      pathStack: pathStack,
      parentType: parentType,
      parentId: parentId,
      parentPathStack: parent
    };
  }

  /**
   * Create NavBar lifecycle owner
   * @param pathStack
   * @returns
   */
  public createNavBarLifecycleOwner(pathStack: HMNavPathStack): HMNavBarLifecycleObserver {
    this.uiContext = pathStack.uiContext;
    const key = this.generateNavBarLifecycleKey(pathStack);
    let navbarLifecycleOwner = this.getLifecycleOwner(key);
    if (!navbarLifecycleOwner) {
      let parentLifecycle: HMLifecycleOwner | undefined = undefined;
      if (key.parentType !== NavBarParentTypes.Page) {
        if (key.parentPathStack.size() === 0) { // NavBar生命周期
          parentLifecycle = this.createNavBarLifecycleOwner(key.parentPathStack);
        } else { // NavDestination生命周期
          const srcPageInfo = HMRouterUtils.getSrcPage(key.parentPathStack);
          parentLifecycle =
            this.navDestinationLifecycleMgr.getLifecycleOwnerByPageUrl(key.parentPathStack.navigationId,
              srcPageInfo.name);
          // 处理单例页面跳转，NavBar关联的NavDestination生命周期Key值变化
          parentLifecycle?.addObserver?.(HMLifecycleState.onShown, (ctx): void => {
            if (ctx.navContext) {
              const navDestinationName = ctx.navContext.pathInfo.name;
              const navDestinationIndex = ctx.navContext.pathStack.getIndexByName(navDestinationName);
              const parentId = `${navDestinationIndex}_${navDestinationName}`;
              if (parentId !== key.parentId) { // 单例页面发生跳转之后，index下标变化，对比触发
                key.parentId = parentId;
              }
            }
          });
        }
      }
      navbarLifecycleOwner = new HMNavBarLifecycleObserver(parentLifecycle);
      this.lifecycleMap.set(key, navbarLifecycleOwner);
    }
    return navbarLifecycleOwner;
  }

  /**
   * NavBar销毁时，回收NavBar生命周期
   * @param key
   */
  public deleteNavBarLifecycle(key: NavBarLifecycleKey): void {
    for (let iter of this.lifecycleMap) {
      let lifecycleKey = iter[0];
      if (lifecycleKey.navigationId === key.navigationId
        && lifecycleKey.pathStack === key.pathStack
        && lifecycleKey.parentType === key.parentType
        && lifecycleKey.parentId === key.parentId
        && lifecycleKey.parentPathStack === key.parentPathStack) {
        this.lifecycleMap.remove(lifecycleKey);
        HMLogger.d('[HMNavBarLifecycleMgr] deleteNavBarLifecycle success, navigationId is ' + key.navigationId);
        break;
      }
    }
  }

  /**
   * NavBar内页面跳转，或者是Router发生跳转时执行NavBar的生命周期
   * @param state
   * @param parentType
   * @param stackInfo
   * @returns
   */
  public dispatchEvent(state: HMLifecycleState, parentType: NavBarParentTypes,
    stackInfo: HMNavPathStack | router.RouterState): void | boolean {

    if (parentType === NavBarParentTypes.NavBar) { // 通过NavBar所在路由跳转触发
      const pathStack = stackInfo as HMNavPathStack;
      const key = this.generateNavBarLifecycleKey(pathStack);
      const navbarLifecycleInstance = this.getLifecycleOwner(key);
      if (navbarLifecycleInstance) {
        if (state === HMLifecycleState.onShown) {
          navbarLifecycleInstance.navbarState = state;
        }
        navbarLifecycleInstance.dispatch(state, { uiContext: this.uiContext });
        if (state === HMLifecycleState.onHidden) {
          navbarLifecycleInstance.navbarState = state;
        }
      }
    } else if (parentType === NavBarParentTypes.Page) { // 页面路由触发
      const routerState = stackInfo as router.RouterState;
      const parentId = `${routerState.index}_${routerState.path}_${routerState.name}`;
      const parentType = NavBarParentTypes.Page;
      let returnValue: boolean = false;
      this.lifecycleMap.forEach((lifecycle, key) => {
        if (key?.parentType === parentType && key.parentId === parentId && lifecycle) {
          const result = lifecycle.dispatch(state, { uiContext: this.uiContext });
          if (state === HMLifecycleState.onBackPressed && result) {
            returnValue = result;
          }
        }
      });
      return returnValue;
    }
  }

  /**
   * 判断对应生命周期实例
   * @param key
   * @returns
   */
  private getLifecycleOwner(key: NavBarLifecycleKey): HMNavBarLifecycleObserver | undefined {
    let lifecycle: HMNavBarLifecycleObserver | undefined = undefined;
    this.lifecycleMap.forEach((lifecycleVal, lifecycleKey) => {
      if (lifecycleKey?.navigationId === key.navigationId &&
        lifecycleKey.parentType === key.parentType &&
        lifecycleKey.parentId === key.parentId &&
        lifecycleKey.parentPathStack === key.parentPathStack) {
        lifecycle = lifecycleVal;
      }
    });
    return lifecycle;
  }
}