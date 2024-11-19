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
import { HMAnimatorHandle } from './HMAnimatorHandle';
import { HandleType, HMAnimatorMgr } from './HMAnimatorMgr';

export class HMNavCustomTransition {
  private static readonly TransitionMap: Map<string, HMNavCustomTransition> = new Map();
  proxy: NavigationTransitionProxy | undefined = undefined;
  operation: NavigationOperation = NavigationOperation.PUSH;
  navigationId: string = '';
  hideNavBar: boolean = true;
  private animatorMgr: HMAnimatorMgr = HMAnimatorMgr.getInstance();

  static getInstance(navigationId: string, hideNavBar: boolean) {
    let instance = HMNavCustomTransition.TransitionMap.get(navigationId);
    if (instance) {
      return instance;
    }
    instance = new HMNavCustomTransition();
    instance.navigationId = navigationId;
    instance.hideNavBar = hideNavBar;
    HMNavCustomTransition.TransitionMap.set(navigationId, instance);
    return instance;
  }

  static destroyInstance(navigationId: string) {
    HMNavCustomTransition.TransitionMap.delete(navigationId);
  }

  getCustomAnimation(from: NavContentInfo, to: NavContentInfo,
    operation: NavigationOperation): NavigationAnimatedTransition | undefined {
    if (this.hideNavBar) {
      if (from.index === -1 || to.index === -1) {
        return undefined;
      }
    }
    // 设置isAnimatorPlay为true，转场动画结束前无法触发交互动画
    this.animatorMgr.isAnimatorPlay = true;
    let interactiveAnimatorHandle: HMAnimatorHandle | undefined =
      this.animatorMgr.getInteractiveAnimatorHandle(this.navigationId, from.navDestinationId);
    let handleTuple: HandleTuple = new HandleTuple();
    if (interactiveAnimatorHandle?.interactive) {
      handleTuple.enterAnimatorHandle =
        this.animatorMgr.getPageAnimatorHandle(HandleType.ENTER, this.navigationId, to.navDestinationId);
      handleTuple.exitAnimatorHandle =
        this.animatorMgr.getPageAnimatorHandle(HandleType.EXIT, this.navigationId, from.navDestinationId);
    } else {
      // 如果跳转类型为push
      if (operation === NavigationOperation.PUSH) {
        // 存在一次性动画
        if (this.animatorMgr.isOnceAnimatorExists(to.name)) {
          this.getPushOnceAnimatorHandle(from, to, handleTuple);
          // 存在页面动画
        } else if (this.animatorMgr.isPageAnimatorExists(HandleType.ENTER, this.navigationId, to.navDestinationId)) {
          this.getPushPageAnimatorHandle(from, to, handleTuple);
        }
        // 如果跳转类型为replace/pop
      } else {
        // 存在一次性动画
        if (this.animatorMgr.isOnceAnimatorExists(from.name)) {
          this.getPopOrReplaceOnceAnimatorHandle(from, to, handleTuple);
          // 存在页面动画
        } else if (this.animatorMgr.isPageAnimatorExists(HandleType.EXIT, this.navigationId, from.navDestinationId)) {
          this.getPopOrReplacePageAnimatorHandle(from, to, handleTuple);
        }
      }
    }

    // 如果存在入场动画或出场动画
    if (handleTuple.enterAnimatorHandle || handleTuple.exitAnimatorHandle) {
      return this.animatedTransition(from, to, operation, handleTuple.enterAnimatorHandle,
        handleTuple.exitAnimatorHandle,
        interactiveAnimatorHandle);
    } else {
      this.animatorMgr.isAnimatorPlay = false;
      return undefined;
    }
  }

  getPopOrReplacePageAnimatorHandle(from: NavContentInfo, to: NavContentInfo, handleTuple: HandleTuple) {
    // 只有当目标页和当前页的页面类型同时为standard时执行目标页的入场动画
    if (to.mode === NavDestinationMode.STANDARD && from.mode === NavDestinationMode.STANDARD) {
      handleTuple.enterAnimatorHandle =
        this.animatorMgr.getPageAnimatorHandle(HandleType.ENTER, this.navigationId, to.navDestinationId);
    }
    // 当前页和目标页任一页面类型为dialog时只执行当前页的离场动画
    handleTuple.exitAnimatorHandle =
      this.animatorMgr.getPageAnimatorHandle(HandleType.EXIT, this.navigationId, from.navDestinationId);
  }

  private getPushOnceAnimatorHandle(from: NavContentInfo, to: NavContentInfo, handleTuple: HandleTuple) {
    // 只有当目标页和当前页的页面类型同时为standard时执行当前页的离场动画
    if (to.mode === NavDestinationMode.STANDARD && from.mode === NavDestinationMode.STANDARD) {
      handleTuple.exitAnimatorHandle =
        this.animatorMgr.getOnceAnimatorHandle(HandleType.EXIT, this.navigationId, to.name, from.navDestinationId);
    }
    // 当前页和目标页任一页面类型为dialog时只执行目标页的入场动画
    handleTuple.enterAnimatorHandle =
      this.animatorMgr.getOnceAnimatorHandle(HandleType.ENTER, this.navigationId, to.name, to.navDestinationId);
  }

  private getPopOrReplaceOnceAnimatorHandle(from: NavContentInfo, to: NavContentInfo, handleTuple: HandleTuple) {
    // 只有当目标页和当前页的页面类型同时为standard时执行目标页的入场动画
    if (to.mode === NavDestinationMode.STANDARD && from.mode === NavDestinationMode.STANDARD) {
      handleTuple.enterAnimatorHandle =
        this.animatorMgr.getOnceAnimatorHandle(HandleType.ENTER, this.navigationId, from.name, to.navDestinationId);
    }
    // 当前页和目标页任一页面类型为dialog时只执行当前页的离场动画
    handleTuple.exitAnimatorHandle =
      this.animatorMgr.getOnceAnimatorHandle(HandleType.EXIT, this.navigationId, from.name, from.navDestinationId);
  }

  private getPushPageAnimatorHandle(from: NavContentInfo, to: NavContentInfo, handleTuple: HandleTuple) {
    // 只有当目标页和当前页的页面类型同时为standard时执行当前页的离场动画
    if (to.mode === NavDestinationMode.STANDARD && from.mode === NavDestinationMode.STANDARD) {
      handleTuple.exitAnimatorHandle =
        this.animatorMgr.getPageAnimatorHandle(HandleType.EXIT, this.navigationId, from.navDestinationId);
    }
    // 当前页和目标页任一页面类型为dialog时只执行目标页的入场动画
    handleTuple.enterAnimatorHandle =
      this.animatorMgr.getPageAnimatorHandle(HandleType.ENTER, this.navigationId, to.navDestinationId);
  }

  private animatedTransition(from: NavContentInfo, to: NavContentInfo,
    operation: NavigationOperation, enterAnimatorHandle: HMAnimatorHandle | undefined,
    exitAnimatorHandle: HMAnimatorHandle | undefined,
    interactiveAnimatorHandle: HMAnimatorHandle | undefined): NavigationAnimatedTransition {
    let customAnimation: NavigationAnimatedTransition = {
      onTransitionEnd: (isSuccess: boolean) => {
        // 转场动画结束，将isAnimatorPlay设为false
        this.animatorMgr.isAnimatorPlay = false;
        // 释放内存
        interactiveAnimatorHandle?.recoverState();
        if (this.animatorMgr.isOnceAnimatorExists(to.name)) {
          this.animatorMgr.unRegisterOnceAnimatorHandle(to.name!);
        }
        if (this.animatorMgr.isOnceAnimatorExists(from.name)) {
          this.animatorMgr.unRegisterOnceAnimatorHandle(from.name!);
        }
        HMLogger.i('[Animator] current interactive transition result is ' + isSuccess);
      },
      timeout: operation === NavigationOperation.PUSH ? enterAnimatorHandle?.timeout : exitAnimatorHandle?.timeout,
      transition: (transitionProxy: NavigationTransitionProxy) => {
        if (interactiveAnimatorHandle?.interactive) {
          interactiveAnimatorHandle.proxy = transitionProxy;
        }
        if (operation === NavigationOperation.PUSH) {
          // 跳转类型为push
          // 执行目标页主动入场动画
          enterAnimatorHandle?.doStart();
          // 执行当前页被动离场动画
          exitAnimatorHandle?.doPassiveStart();
        } else {
          // 跳转类型为replace/pop
          // 执行目标页被动入场动画
          enterAnimatorHandle?.doPassiveStart();
          // 执行当前页主动离场动画
          exitAnimatorHandle?.doStart();
        }
        animateTo({
          duration: operation === NavigationOperation.PUSH ? enterAnimatorHandle?.duration :
            exitAnimatorHandle?.duration,
          curve: operation === NavigationOperation.PUSH ? enterAnimatorHandle?.curve : exitAnimatorHandle?.curve,
          onFinish: () => {
            if (operation === NavigationOperation.PUSH) {
              enterAnimatorHandle?.doOnFinish();
              exitAnimatorHandle?.doPassiveOnFinish();
            } else {
              enterAnimatorHandle?.doPassiveOnFinish();
              exitAnimatorHandle?.doOnFinish();
            }
            transitionProxy.finishTransition();
          }
        }, () => {
          if (operation === NavigationOperation.PUSH) {
            enterAnimatorHandle?.doFinish();
            exitAnimatorHandle?.doPassiveFinish();
          } else {
            enterAnimatorHandle?.doPassiveFinish();
            exitAnimatorHandle?.doFinish();
          }
        });
      },
      isInteractive: interactiveAnimatorHandle?.interactive
    };
    return customAnimation;
  }
}

export class HandleTuple {
  enterAnimatorHandle: HMAnimatorHandle | undefined;
  exitAnimatorHandle: HMAnimatorHandle | undefined;
}