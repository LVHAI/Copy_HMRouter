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
import { HMRouterConst } from '../constants/Constants';
import { HMLogger } from '../log/HMLogger';
import { hmRouterStore } from '../store/RouterStoreFactory';
import { HMError } from '../log/ErrorCode';
import { HMAnimatorHandle } from './HMAnimatorHandle';
import { OpacityOption, ScaleOption, TranslateOption } from '../template/AnimatorModel';

export class HMAnimatorMgr {
  private static instance: HMAnimatorMgr = new HMAnimatorMgr();
  private static interactiveHandleMap: Map<string, HMAnimatorHandle> = new Map();
  private static enterAnimatorHandleMap: Map<string, HMAnimatorHandle> = new Map();
  private static exitAnimatorHandleMap: Map<string, HMAnimatorHandle> = new Map();
  private static onceAnimatorMap: Map<string, IHMAnimator> = new Map();
  isAnimatorPlay: boolean = false;

  public static getInstance() {
    return HMAnimatorMgr.instance;
  }

  /**
   * interactive animation start
   * @param navigationId
   * @param navDestinationId
   * @param event
   */
  interactiveStart(navigationId: string, navDestinationId: string, event: GestureEvent) {
    if (this.isAnimatorPlay) {
      return;
    }
    const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
    HMAnimatorMgr.interactiveHandleMap.get(name)?.doActionStart(event);
  }

  /**
   * interactive animation finish
   * @param navigationId
   * @param navDestinationId
   * @param event
   */
  interactiveFinish(navigationId: string, navDestinationId: string, event: GestureEvent) {
    const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
    HMAnimatorMgr.interactiveHandleMap.get(name)?.doActionEnd(event);
  }

  /**
   * interactive animation progress change
   * @param navigationId
   * @param navDestinationId
   * @param event
   */
  interactiveProgress(navigationId: string, navDestinationId: string, event: GestureEvent) {
    const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
    HMAnimatorMgr.interactiveHandleMap.get(name)?.doUpdateProgress(event);
  }

  getInteractiveAnimatorHandle(navigationId: string, navDestinationId?: string): HMAnimatorHandle | undefined {
    if (navDestinationId) {
      const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
      return HMAnimatorMgr.interactiveHandleMap.get(name);
    } else {
      HMLogger.d(HMError.ERR_PARAM_REQUIRED, 'navDestinationId');
      return undefined;
    }
  }

  /**
   * get once animator
   * @param handleType
   * @param navigationId
   * @param pageUrl
   * @param navDestinationId
   * @returns
   */
  getOnceAnimatorHandle(handleType: HandleType, navigationId: string, pageUrl?: string,
    navDestinationId?: string): HMAnimatorHandle | undefined {
    let onceAnimator: IHMAnimator | undefined;
    if (pageUrl) {
      onceAnimator = HMAnimatorMgr.onceAnimatorMap.get(pageUrl);
    } else {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'pageUrl');
      return undefined;
    }
    if (onceAnimator) {
      const onceAnimatorEnter = this.getPageAnimatorHandle(HandleType.ENTER, navigationId, navDestinationId);
      const onceAnimatorExit = this.getPageAnimatorHandle(HandleType.EXIT, navigationId, navDestinationId);
      if (onceAnimatorEnter || onceAnimatorExit) {
        if (handleType === HandleType.ENTER) {
          onceAnimator.effect(onceAnimatorEnter!, new HMAnimatorHandle());
          return onceAnimatorEnter;
        } else {
          onceAnimator.effect(new HMAnimatorHandle(), onceAnimatorExit!);
          return onceAnimatorExit;
        }
      } else {
        HMLogger.e('onceAnimatorEnter or onceAnimatorExit is undefined');
        return undefined;
      }
    } else {
      HMLogger.e('onceAnimator is undefined');
      return undefined;
    }
  }

  /**
   * get NavDestination page custom animator
   * @param handleType
   * @param navigationId
   * @param navDestinationId
   * @returns
   */
  getPageAnimatorHandle(handleType: HandleType, navigationId: string,
    navDestinationId?: string): HMAnimatorHandle | undefined {
    if (navDestinationId) {
      const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
      if (handleType === HandleType.ENTER) {
        return HMAnimatorMgr.enterAnimatorHandleMap.get(name);
      } else {
        return HMAnimatorMgr.exitAnimatorHandleMap.get(name);
      }
    } else {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'navDestinationId');
      return undefined;
    }
  }

  /**
   * register once animator
   * @param pageUrl
   * @param animator
   */
  registerOnceAnimator(pageUrl: string, animator?: IHMAnimator) {
    if (animator) {
      HMAnimatorMgr.onceAnimatorMap.set(pageUrl, animator);
    } else {
      HMLogger.i('[Animator] onceAnimator is null');
    }
  }

  /**
   * register page animator by navigationId and pageUrl;
   * @param navigationId
   * @param pageUrl
   * @param dialog
   * @param translateOption
   * @param scaleOption
   * @param opacityOption
   */
  registerAnimatorHandle(navigationId: string, pageUrl: string, dialog: boolean, translateOption?: TranslateOption,
    scaleOption?: ScaleOption,
    opacityOption?: OpacityOption): void {
    let animator = hmRouterStore.getAnimatorByPageUrl(pageUrl);
    if (!animator) {
      animator = this.getGlobalNavigationAnimator(navigationId, dialog);
    }
    const interactiveHandle = new HMAnimatorHandle(translateOption, scaleOption, opacityOption);
    const enterAnimatorHandle = new HMAnimatorHandle(translateOption, scaleOption, opacityOption);
    const exitAnimatorHandle = new HMAnimatorHandle(translateOption, scaleOption, opacityOption);
    if (animator) {
      if (animator.interactive) {
        animator.interactive(interactiveHandle);
        HMAnimatorMgr.interactiveHandleMap.set(pageUrl, interactiveHandle);
      } else {
        HMLogger.i('[Animator] animator interactive is null');
      }
      animator.effect(enterAnimatorHandle, exitAnimatorHandle);
    } else {
      HMLogger.i('[Animator] animator is null');
    }
    HMAnimatorMgr.enterAnimatorHandleMap.set(pageUrl, enterAnimatorHandle);
    HMAnimatorMgr.exitAnimatorHandleMap.set(pageUrl, exitAnimatorHandle);
  }

  /**
   * update animator handle key equal pageUrl add navDestinationId
   * @param pageUrl
   * @param navigationId
   * @param navDestinationId
   */
  updateHandleKey(pageUrl: string, navigationId: string, navDestinationId: string) {
    const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
    let enterAnimatorHandle = HMAnimatorMgr.enterAnimatorHandleMap.get(pageUrl);
    if (enterAnimatorHandle) {
      HMAnimatorMgr.enterAnimatorHandleMap.set(name, enterAnimatorHandle);
      HMAnimatorMgr.enterAnimatorHandleMap.delete(pageUrl);
    }
    let exitAnimatorHandle = HMAnimatorMgr.exitAnimatorHandleMap.get(pageUrl);
    if (exitAnimatorHandle) {
      HMAnimatorMgr.exitAnimatorHandleMap.set(name, exitAnimatorHandle);
      HMAnimatorMgr.exitAnimatorHandleMap.delete(pageUrl);
    }
    let interactiveHandle = HMAnimatorMgr.interactiveHandleMap.get(pageUrl);
    if (interactiveHandle) {
      HMAnimatorMgr.interactiveHandleMap.set(name, interactiveHandle);
      HMAnimatorMgr.interactiveHandleMap.delete(pageUrl);
    }
  }

  /**
   * unregister animator
   * @param navigationId
   * @param navDestinationId
   */
  unRegisterAnimatorHandle(navigationId: string, navDestinationId: string) {
    const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
    HMAnimatorMgr.interactiveHandleMap.delete(name);
    HMAnimatorMgr.enterAnimatorHandleMap.delete(name);
    HMAnimatorMgr.exitAnimatorHandleMap.delete(name);
  }

  /**
   * unregister once animator
   * @param pageUrl
   */
  unRegisterOnceAnimatorHandle(pageUrl: string) {
    HMAnimatorMgr.onceAnimatorMap.delete(pageUrl);
  }

  /**
   * Determine whether the page animation exists
   * @param handleType
   * @param navigationId
   * @param navDestinationId
   * @returns
   */
  isPageAnimatorExists(handleType: HandleType, navigationId: string, navDestinationId?: string) {
    if (navDestinationId) {
      const name = navigationId + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR + navDestinationId;
      if (handleType === HandleType.ENTER) {
        return !!HMAnimatorMgr.enterAnimatorHandleMap.get(name)?.finishCallback;
      } else {
        return !!HMAnimatorMgr.exitAnimatorHandleMap.get(name)?.finishCallback;
      }
    } else {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'navDestinationId');
      return true;
    }
  }

  /**
   * Determine whether a one-time animation exists
   * @param pageUrl
   * @returns
   */
  isOnceAnimatorExists(pageUrl?: string) {
    if (pageUrl) {
      return HMAnimatorMgr.onceAnimatorMap.has(pageUrl);
    } else {
      HMLogger.w(HMError.ERR_PARAM_REQUIRED, 'name');
      return true;
    }
  }

  /**
   * Get global animation
   * @param navigationId
   * @param dialog
   * @returns
   */
  getGlobalNavigationAnimator(navigationId: string, dialog: boolean): IHMAnimator | null {
    let defaultAnimator: IHMAnimator | null;
    if (dialog) {
      defaultAnimator =
        hmRouterStore.getAnimatorByName(HMRouterConst.NAV_MODE_DIALOG + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR +
          navigationId);
    } else {
      defaultAnimator =
        hmRouterStore.getAnimatorByName(HMRouterConst.NAV_MODE_STANDARD + HMRouterConst.HM_ROUTER_MAP_KEY_SEPARATOR +
          navigationId);
    }
    return defaultAnimator;
  }
}

export enum HandleType {
  ENTER,
  EXIT
}