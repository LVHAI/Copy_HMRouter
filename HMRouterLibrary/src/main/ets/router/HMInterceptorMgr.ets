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
import { HMError } from '../log/ErrorCode';
import { hmRouterStore } from '../store/RouterStoreFactory';
import { HMInterceptorInstance } from '../store/ComponentInstance';
import { HMInterceptorAction } from './HMInterceptorAction';
import { HMInterceptorInfo } from './HMInterceptorInfo';

interface HMInterceptorSrcInstance extends HMInterceptorInstance {
  isSrc?: boolean;
}

export class HMInterceptorMgr {
  private static instance: HMInterceptorMgr = new HMInterceptorMgr();

  public static getInstance(): HMInterceptorMgr {
    return HMInterceptorMgr.instance;
  }

  /**
   * Execute interceptor
   * @param {HMInterceptorInfo} info - interceptor info
   * @return {boolean}
   * If the interceptor returns DO-REJECT and no longer executes subsequent interceptors and intercepts jumps, it is true.
   * If it returns DO-NEXT or DO_TRANSITION and no longer executes subsequent interceptors and does not intercept jumps, it is false
   */
  executeInterceptor(info: HMInterceptorInfo): boolean {
    if (!info.srcName) {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'srcName');
      return true;
    }
    if (!info.targetName) {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'targetName');
      return true;
    }
    const interceptorInstanceArray: Array<HMInterceptorSrcInstance> = [];
    info.routerPathInfo.interceptors?.forEach(item => {
      interceptorInstanceArray.push({
        interceptor: item,
        interceptorName: 'onceInterceptor',
        priority: 0,
        isSrc: true
      });
    });
    // 获取一次性拦截器执行结果
    const result = this.getInterceptorResult(interceptorInstanceArray, info);
    // 如果结果为DO_REJECT，拦截，返回true
    if (result === HMInterceptorAction.DO_REJECT) {
      return true;
      // 如果结果为DO_TRANSITION，不拦截，返回false
    } else if (result === HMInterceptorAction.DO_TRANSITION) {
      return false;
      // 如果结果为DO_NEXT
    } else {
      // 如果skipAllInterceptor为true，跳过后续所有拦截器，直接返回false
      if (info.routerPathInfo.skipAllInterceptor) {
        return false;
        // 如果skipAllInterceptor为false，执行后续全局、当前和目标页拦截器
      } else {
        // 初始化拦截器数据并执行拦截器handle
        return this.initInterceptor(info);
      }
    }
  }

  // 初始化拦截器数据
  private initInterceptor(info: HMInterceptorInfo) {
    const srcPageInstance = hmRouterStore.getHMPageInfo(info.srcName);
    const targetPageInstance = hmRouterStore.getHMPageInfo(info.targetName);
    // 获取发起页拦截器数据
    let srcInterceptorData: Array<HMInterceptorInstance> = [];
    if (srcPageInstance?.interceptorArray && srcPageInstance.interceptorArray.length > 0) {
      srcInterceptorData = hmRouterStore.getInterceptorByPageUrl(info.srcName);
    }
    // 获取目标页拦截器数据
    let targetInterceptorData: Array<HMInterceptorInstance> = [];
    if (targetPageInstance?.interceptorArray && targetPageInstance.interceptorArray.length > 0) {
      targetInterceptorData = hmRouterStore.getInterceptorByPageUrl(info.targetName);
    }
    // 获取全局拦截器数据
    const globalInterceptorData = hmRouterStore.getGlobalInterceptor();
    let allInterceptorData: Array<HMInterceptorSrcInstance> = [];
    allInterceptorData = allInterceptorData.concat(srcInterceptorData, targetInterceptorData, globalInterceptorData);
    if (allInterceptorData.length === 0) {
      return false;
    }
    const srcInterceptorLength = srcInterceptorData.length;
    const allInterceptorLength = allInterceptorData.length;
    for (let i = 0; i < allInterceptorLength; i++) {
      // 没写priority则给默认值9
      if (allInterceptorData[i].priority === undefined) {
        allInterceptorData[i].priority = 9;
      }
      if (i < srcInterceptorLength) {
        allInterceptorData[i].isSrc = true;
      } else {
        allInterceptorData[i].isSrc = false;
      }
    }
    // 排序
    if (allInterceptorData.length > 0 && globalInterceptorData.length < allInterceptorData.length) {
      allInterceptorData.sort((a, b) => b.priority - a.priority);
    }
    return this.getInterceptorResult(allInterceptorData, info) === HMInterceptorAction.DO_REJECT;
  }

  private getInterceptorResult(interceptorInstanceArray: Array<HMInterceptorSrcInstance>,
    info: HMInterceptorInfo): HMInterceptorAction {
    const len = interceptorInstanceArray.length;
    let result: HMInterceptorAction = HMInterceptorAction.DO_NEXT;
    for (let i = 0; i < len; i++) {
      result = this.runInterceptor(interceptorInstanceArray[i], info);
      // 当前拦截器返回DO_NEXT就继续循环执行下一个拦截器
      if (result === HMInterceptorAction.DO_NEXT) {
        continue;
        // 当前拦截器返回DO_REJECT或DO_TRANSITION跳出循环停止执行后续拦截器
      } else {
        break;
      }
    }
    return result;
  }

  // 执行拦截器函数
  private runInterceptor(interceptorInstance: HMInterceptorSrcInstance,
    info: HMInterceptorInfo): HMInterceptorAction {
    info.isSrc = !!interceptorInstance.isSrc;
    return interceptorInstance.interceptor.handle(info);
  }
}