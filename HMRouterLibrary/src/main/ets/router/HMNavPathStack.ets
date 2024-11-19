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

import { router } from '@kit.ArkUI';
import { HMLogger } from '../log/HMLogger';
import { HMError } from '../log/ErrorCode';
import { StopWatch } from '../utils/StopWatch';
import { HMRouterUtils } from '../utils/HMRouterUtils';
import { HMRouterPathCallback } from '../api/HMRouterPathCallback';
import { HMRouterPathInfo } from '../api/HMRouterPathInfo';
import { HMLifecycleState, InnerLifecycleState } from '../api/HMLifecycleState';
import { HMNavBarLifecycleMgr } from '../lifecycle/HMNavBarLifecycleMgr';
import { HMNavDstLifecycleMgr } from '../lifecycle/HMNavDstLifecycleMgr';
import { NavBarParentTypes } from '../lifecycle/enums/NavBarParentTypes';
import { HMAnimatorMgr } from '../animator/HMAnimatorMgr';
import { HMActionType } from './HMActionType';
import { HMInterceptorMgr } from './HMInterceptorMgr';

interface SrcPageInfo {
  srcPage: string,
  srcPageIndex: number,
  srcPageParam: Object,
  param: Object
}

export class HMNavPathStack extends NavPathStack {
  public uiContext: UIContext;
  public navigationId: string;
  public hideNavbar: boolean;
  private interceptorMgr: HMInterceptorMgr = HMInterceptorMgr.getInstance();
  private animatorMgr: HMAnimatorMgr = HMAnimatorMgr.getInstance();
  private navbarLifecycleMgr: HMNavBarLifecycleMgr = HMNavBarLifecycleMgr.getInstance();
  private navDestinationLifecycleMgr = HMNavDstLifecycleMgr.getInstance();
  private changeLastNavigationId: (navigationId: string) => void;

  constructor(uiContext: UIContext, navigationId: string, hideNavbar: boolean,
    changeLastNavigationId: (navigationId: string) => void) {
    super();
    this.uiContext = uiContext;
    this.navigationId = navigationId;
    this.hideNavbar = hideNavbar;
    this.changeLastNavigationId = changeLastNavigationId;
  }

  /**
   * Custom push/replace method
   * @param type Route jump type push or pop
   * @param pathInfo Route jump parameters
   * @param callback Route jump callback
   * @param mode Route jump mode
   */
  hmPushOrReplace(type: HMActionType, pathInfo: HMRouterPathInfo, callback?: HMRouterPathCallback,
    mode: LaunchMode = LaunchMode.STANDARD): void {
    StopWatch.start(`${type}`);
    const srcPageInfo = HMRouterUtils.getSrcPage(this);
    HMLogger.d(`[HMNavPathStack] ${srcPageInfo.name} ${type} to ${pathInfo.pageUrl} with param: ${pathInfo.param}`);

    StopWatch.start(`${type} interceptor`);

    const oldPageUrl = pathInfo.pageUrl;

    const interceptorResult = this.interceptorMgr.executeInterceptor({
      srcName: srcPageInfo.name,
      targetName: pathInfo.pageUrl!,
      type: type,
      routerPathInfo: pathInfo,
      routerPathCallback: callback,
      context: this.uiContext
    });
    if (interceptorResult) {
      HMLogger.d(`[HMNavPathStack] ${srcPageInfo.name} ${type} to ${pathInfo?.pageUrl}, interceptor is blocked`);
      return;
    }
    HMLogger.d(`[Performance] HMRouterMgr.${type}方法，拦截器 耗时%dms`, StopWatch.end(`${type} interceptor`));

    if (oldPageUrl !== pathInfo.pageUrl) { // 当目前页面在拦截器中有修改
      const pageUrlIsValid: boolean = HMRouterUtils.checkPageUrl(pathInfo.pageUrl);
      if (!pageUrlIsValid) {
        return;
      }
      const pageInfo =
        HMRouterUtils.getPageInfoByPageUrl(pathInfo.pageUrl!, HMError.ERR_PUSH_INVALID, callback?.onLost);
      if (!pageInfo) {
        return;
      }
      mode = pageInfo.singleton ? LaunchMode.MOVE_TO_TOP_SINGLETON : mode;
    }

    // 创建生命周期，执行生命onPrepare方法，只有push单例的时候，页面才不会重新创建
    StopWatch.start(`${type} lifecycle`);
    let lifecycleOwner =
      this.navDestinationLifecycleMgr.createLifecycle(this.uiContext, this.navigationId, pathInfo.pageUrl!,
        type === HMActionType.PUSH &&
          (mode === LaunchMode.MOVE_TO_TOP_SINGLETON || mode === LaunchMode.POP_TO_SINGLETON));
    lifecycleOwner.dispatch(InnerLifecycleState.onPrepare, {
      uiContext: this.uiContext
    });
    HMLogger.d(`[Performance] HMRouterMgr.${type}方法，生命周期 耗时%dms`, StopWatch.end(`${type} lifecycle`));

    // 注册一次性动画
    StopWatch.start(`${type} animator`);
    if (typeof pathInfo.animator !== 'boolean' && pathInfo.animator) {
      this.animatorMgr.registerOnceAnimator(pathInfo.pageUrl!, pathInfo.animator);
    }
    HMLogger.d(`[Performance] HMRouterMgr.${type}方法，动画注册 耗时%dms`, StopWatch.end(`${type} animator`));

    StopWatch.start(`${type} system`);
    try {
      const info: NavPathInfo = {
        name: pathInfo.pageUrl!,
        param: pathInfo.param,
        onPop: callback?.onResult ? (info: PopInfo) => {
          const result = info.result as SrcPageInfo;
          callback?.onResult?.({
            srcPageInfo: {
              name: result.srcPage,
              param: result.srcPageParam
            },
            info: info.info,
            result: result.param
          });
        } : undefined
      };
      const options: NavigationOptions = {
        launchMode: mode,
        animated: pathInfo.animator !== false
      };
      if (type === HMActionType.PUSH) {
        super.pushPath(info, options);
      } else if (type === HMActionType.REPLACE) {
        super.replacePath(info, options);
      } else {
        HMLogger.e(HMError.ERR_INTERNAL, `[HMNavPathStack] type params is error, value is ${type}`);
        return;
      }

      this.changeLastNavigationId(this.navigationId);

      HMLogger.d(`[Performance] HMRouterMgr.${type}方法，系统原生接口 耗时%dms`, StopWatch.end(`${type} system`));
      HMLogger.d(`[Performance] HMRouterMgr.${type}方法，总耗时%dms`, StopWatch.end(`${type}`));

      callback?.onArrival?.();

      // 触发NavBar的onHidden
      if (srcPageInfo.name === HMRouterUtils.HMBavBar_PAGE_NAME && !this.hideNavbar) {
        this.navbarLifecycleMgr.dispatchEvent(HMLifecycleState.onHidden, NavBarParentTypes.NavBar, this);
      }
    } catch (e) {
      HMLogger.e(type === HMActionType.PUSH ? HMError.ERR_PUSH_SYS : HMError.ERR_REPLACE_SYS, e.code,
        `${e.message}\n${e.stack}\n`);
    }
  }

  hmPop(targetPageInfo: HMRouterUtils.PageInfo, pathInfo: HMRouterPathInfo) {
    StopWatch.start('pop');

    const srcPageInfo = HMRouterUtils.getSrcPage(this);

    HMLogger.d(`[HMNavPathStack] ${srcPageInfo.name} pop to ${targetPageInfo.name} with param: ${pathInfo?.param}`);

    StopWatch.start('pop interceptor');
    const oldPageUrl = pathInfo.pageUrl;
    const interceptorResult = this.interceptorMgr.executeInterceptor({
      srcName: srcPageInfo.name,
      targetName: targetPageInfo.name,
      type: HMActionType.POP,
      routerPathInfo: pathInfo,
      context: this.uiContext
    });
    if (interceptorResult) {
      HMLogger.d(`[HMNavPathStack] ${srcPageInfo.name} pop to ${targetPageInfo.name}, interceptor is blocked`);
      return;
    }

    HMLogger.d(`[Performance] HMRouterMgr.pop方法，拦截器 耗时%dms`, StopWatch.end('pop interceptor'));

    if (pathInfo.pageUrl !== oldPageUrl) { // 目标页面在拦截器中发生变更
      const info = HMRouterUtils.getTargetPage(this, pathInfo?.pageUrl);
      if (!info) {
        return;
      }
      targetPageInfo = info;
    }

    // 注册一次性动画
    StopWatch.start('pop animator');
    if (typeof pathInfo.animator !== 'boolean' && pathInfo.animator) {
      this.animatorMgr.registerOnceAnimator(srcPageInfo.name!, pathInfo.animator);
    }
    HMLogger.d(`[Performance] HMRouterMgr.pop方法，动画注册 耗时%dms`, StopWatch.end('pop animator'));

    StopWatch.start('pop system');
    try {
      if (srcPageInfo!.index - targetPageInfo!.index >= 2) {
        super.popToIndex(targetPageInfo!.index + 1, false);
      }
      const popParam: ESObject = {
        srcPage: srcPageInfo.name,
        srcPageIndex: srcPageInfo.index,
        srcPageParam: super.getParamByIndex(srcPageInfo.index),
        param: pathInfo.param
      };
      if (this.hideNavbar && targetPageInfo!.index === -1) { // 回空白首页时
        const parentPathStack = super.getParent();
        if (parentPathStack) {
          parentPathStack.pop(popParam, !!pathInfo?.animator);
          this.changeLastNavigationId((parentPathStack as HMNavPathStack).navigationId);
        } else {
          router.back();
          this.changeLastNavigationId('');
        }
      } else { // 正常返回上一页
        super.pop(popParam, pathInfo?.animator !== false);
        this.changeLastNavigationId(this.navigationId);
      }

      HMLogger.d(`[Performance] HMRouterMgr.pop方法，系统原生接口 耗时%dms`, StopWatch.end('pop system'));
      HMLogger.d(`[Performance] HMRouterMgr.pop方法，总耗时%dms`, StopWatch.end('pop'));

      // 触发Navbar的onShown
      if (targetPageInfo.name === HMRouterUtils.HMBavBar_PAGE_NAME && !this.hideNavbar) {
        this.navbarLifecycleMgr.dispatchEvent(HMLifecycleState.onShown, NavBarParentTypes.NavBar, this);
      }
    } catch (e) {
      HMLogger.e(HMError.ERR_POP_SYS, e.code, `${e.message}\n${e.stack}\n`);
    }
  }

  pushPath(info: NavPathInfo, animated?: boolean | undefined): void

  pushPath(info: NavPathInfo, options?: NavigationOptions | undefined): void

  pushPath(info: NavPathInfo, options?: NavigationOptions | boolean | undefined): void {
    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(info.name, HMError.ERR_PUSH_INVALID);
    if (!pageInfo) {
      return;
    }

    this.hmPushOrReplace(HMActionType.PUSH, {
      pageUrl: info.name,
      param: info.param,
      animator: typeof options === 'boolean' ? options : options?.animated
    }, info.onPop ? { onResult: info.onPop } : undefined,
      typeof options === 'boolean' ? LaunchMode.STANDARD : options?.launchMode);
  }

  pushPathByName(name: string, param: Object, animated?: boolean | undefined): void

  pushPathByName(name: string, param: Object, onPop: Callback<PopInfo>, animated?: boolean | undefined): void

  pushPathByName(name: string, param: Object, onPop?: boolean | undefined | Callback<PopInfo>,
    animated?: boolean | undefined): void {
    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(name, HMError.ERR_PUSH_INVALID);
    if (!pageInfo) {
      return;
    }
    this.hmPushOrReplace(HMActionType.PUSH, {
      pageUrl: name,
      param: param,
      animator: typeof onPop === 'function' ? animated : onPop
    }, typeof onPop === 'function' ? { onResult: onPop } : undefined);
  }

  pushDestination(info: NavPathInfo, animated?: boolean | undefined): Promise<void>

  pushDestination(info: NavPathInfo, options?: NavigationOptions | undefined): Promise<void>

  pushDestination(info: NavPathInfo, options?: NavigationOptions | boolean | undefined): Promise<void> {
    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(info.name, HMError.ERR_PUSH_INVALID);
    if (!pageInfo) {
      return Promise.reject();
    }
    this.hmPushOrReplace(HMActionType.PUSH, {
      pageUrl: info.name,
      param: info.param,
      animator: typeof options === 'boolean' ? options : options?.animated
    }, info.onPop ? { onResult: info.onPop } : undefined,
      typeof options === 'boolean' ? LaunchMode.STANDARD : options?.launchMode);
    return Promise.resolve();
  }

  pushDestinationByName(name: string, param: Object, animated?: boolean | undefined): Promise<void>

  pushDestinationByName(name: string, param: Object, onPop: Callback<PopInfo>,
    animated?: boolean | undefined): Promise<void>

  pushDestinationByName(name: string, param: Object, onPop?: Callback<PopInfo> | boolean | undefined,
    animated?: boolean | undefined): Promise<void> {
    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(name, HMError.ERR_PUSH_INVALID);
    if (!pageInfo) {
      return Promise.reject();
    }
    this.hmPushOrReplace(HMActionType.PUSH, {
      pageUrl: name,
      param: param,
      animator: typeof onPop === 'function' ? animated : onPop
    }, typeof onPop === 'function' ? {
      onResult: onPop
    } : undefined);
    return Promise.resolve();
  }

  replacePath(info: NavPathInfo, animated?: boolean | undefined): void

  replacePath(info: NavPathInfo, options?: NavigationOptions | undefined): void

  replacePath(info: NavPathInfo, options?: NavigationOptions | boolean | undefined): void {
    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(info.name, HMError.ERR_REPLACE_INVALID);
    if (!pageInfo) {
      return;
    }
    this.hmPushOrReplace(HMActionType.REPLACE, {
      pageUrl: info.name,
      param: info.param,
      animator: typeof options === 'boolean' ? options : options?.animated
    }, info.onPop ? {
      onResult: info.onPop
    } : undefined, typeof options === 'boolean' ? LaunchMode.STANDARD : options?.launchMode);
  }

  replacePathByName(name: string, param: Object, animated?: boolean | undefined): void {
    // 判断pageUrl参数是否有效
    const pageInfo = HMRouterUtils.getPageInfoByPageUrl(name, HMError.ERR_PUSH_INVALID);
    if (!pageInfo) {
      return;
    }
    this.hmPushOrReplace(HMActionType.REPLACE, {
      pageUrl: name,
      param: param,
      animator: animated
    });
  }

  pop(animated?: boolean | undefined): NavPathInfo | undefined

  pop(result: Object, animated?: boolean | undefined): NavPathInfo | undefined

  pop(result?: Object, animated?: boolean | undefined): NavPathInfo | undefined {
    const targetPageInfo = HMRouterUtils.getTargetPage(this);
    if (!targetPageInfo) {
      return;
    }
    this.hmPop(targetPageInfo, {
      pageUrl: targetPageInfo?.name,
      param: typeof result === 'boolean' ? animated : result,
      animator: typeof result === 'boolean' ? result : animated
    });
    return {
      name: targetPageInfo.name
    };
  }

  popToName(name: string, animated?: boolean | undefined): number

  popToName(name: string, result: Object, animated?: boolean | undefined): number

  popToName(name: string, result?: Object, animated?: boolean | undefined): number {
    const targetPageInfo = HMRouterUtils.getTargetPage(this, name);
    if (!targetPageInfo) {
      return -1;
    }
    this.hmPop(targetPageInfo, {
      pageUrl: targetPageInfo?.name,
      param: typeof result === 'boolean' ? animated : result,
      animator: typeof result === 'boolean' ? result : animated
    });
    return targetPageInfo.index;
  }

  popToIndex(index: number, animated?: boolean | undefined): void

  popToIndex(index: number, result: Object, animated?: boolean | undefined): void

  popToIndex(index: number, result?: Object, animated?: boolean | undefined): void {
    const targetPageInfo = HMRouterUtils.getTargetPage(this, undefined, this.size() - index - 2);
    if (!targetPageInfo) {
      return;
    }
    this.hmPop(targetPageInfo, {
      pageUrl: targetPageInfo?.name,
      param: typeof result === 'boolean' ? animated : result,
      animator: typeof result === 'boolean' ? result : animated
    });
  }
}