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

import { collections, HashMap, taskpool } from '@kit.ArkTS';
import { HMLogger } from '../log/HMLogger';
import { HMError } from '../log/ErrorCode';
import { HMRouterUtils } from '../utils/HMRouterUtils';
import { HMRouterConst } from '../constants/Constants';
import { IHMAnimator } from '../api/IHMAnimator';
import { IHMLifecycle } from '../api/IHMLifecycle';
import { HMRouterConfig } from '../api/HMRouterConfig';
import { HMInterceptorStoreData } from './entity/HMInterceptor';
import { HMLifecycleStoreData } from './entity/HMLifecycle';
import { HMAnimatorStoreData } from './entity/HMAnimator';
import { HMServiceData } from './entity/HMService';
import { HMComponent } from './entity/HMComponent';
import { getComponentInfosFromBundleManager, getComponentInfosFromRawfile } from './HMRouterStoreInit';
import {
  HMInterceptorInstance,
  HMLifecycleInstance,
  HMPageInfo,
  HMPageInstance,
  HMServiceInstance
} from './ComponentInstance';
import { IHMRouterStore } from './IHMRouterStore';
import { HMRouterAnnotationFactory } from './HMRouterAnnotationHandler';

export class HMRouterStoreImpl implements IHMRouterStore {
  private static instance: IHMRouterStore | null = null;
  /**
   * 是否初始化
   */
  private flag: boolean = false;
  /**
  * page info
  */
  public pageStoreInfoMap: HashMap<string, HMPageInfo> = new HashMap();
  /**
   * 全局拦截器，每次页面跳转触发一次（包括Dialog类型NavDestination）此处排好序了，新增需要重新排序
   */
  private globalInterceptorArray: Array<HMInterceptorInstance> = new Array();
  /**
   * key:interceptor，全局唯一，value:HMInterceptorInstance
   */
  private interceptorMap: HashMap<string, HMInterceptorStoreData> = new HashMap();
  /**
   * 全局生命周期，每次页面跳转触发一次（包括Dialog类型NavDestination）此处排好序了，新增需要重新排序
   */
  private globalLifecycleArray: Array<HMLifecycleInstance> = new Array();
  /**
   * key:lifecycle name，全局唯一，value:HMLifecycleInstance
   */
  private lifecycleMap: HashMap<string, HMLifecycleStoreData> = new HashMap();
  /**
   * key:animator name，全局唯一，value:HMAnimatorInstance
   */
  private animatorMap: HashMap<string, HMAnimatorStoreData> = new HashMap();
  /**
   * key:service name，全局唯一，value: HMServiceData
   */
  private serviceMap: HashMap<string, HMServiceData> = new HashMap();

  private constructor() {
  }

  public isInit() {
    return this.flag;
  }

  public getGlobalInterceptorArray() {
    return this.globalInterceptorArray;
  }

  public getInterceptorMap() {
    return this.interceptorMap;
  }

  public getGlobalLifecycleArray() {
    return this.globalLifecycleArray;
  }

  public getLifecycleMap() {
    return this.lifecycleMap;
  }

  public getPageStoreInfoMap() {
    return this.pageStoreInfoMap;
  }

  public getAnimatorMap() {
    return this.animatorMap;
  }

  public getServiceMap() {
    return this.serviceMap;
  }

  public static getInstance(): IHMRouterStore {
    if (HMRouterStoreImpl.instance == null) {
      HMRouterStoreImpl.instance = new HMRouterStoreImpl();
    }
    return HMRouterStoreImpl.instance;
  }

  public async init(config: HMRouterConfig): Promise<void> {
    HMLogger.i('[HMRouterStore] init from rawFile begin');
    let hspModuleNames: collections.Set<string> = new collections.Set();
    await this.initModuleInfo(config, hspModuleNames, getComponentInfosFromRawfile, taskpool.Priority.HIGH);
    this.flag = true;
    HMLogger.i('[HMRouterStore] init from rawFile end');

    // 如果在hap中没有获取到hsp的名称，通过bundleManager接口获取,已经加载的不会重复加载
    HMLogger.i('[HMRouterStore] init from bundleManager begin');
    await this.initModuleInfo(config, hspModuleNames, getComponentInfosFromBundleManager, taskpool.Priority.LOW);
    HMLogger.i('[HMRouterStore] init from bundleManager end');

  }

  async initModuleInfo(config: HMRouterConfig, hspModuleNames: collections.Set<string>, func: Function,
    priority: taskpool.Priority) {
    let hmComponentInfos: collections.Array<HMComponent>;
    if (config.initWithTaskPool || config.initWithTaskPool === undefined) {
      let task: taskpool.Task = new taskpool.Task(func, config.context, hspModuleNames);
      hmComponentInfos = await taskpool.execute(task, priority) as collections.Array<HMComponent>;
    } else {
      hmComponentInfos = await func(config.context, hspModuleNames);
    }
    this.initStoreInfo(hmComponentInfos);
  }

  getGlobalInterceptor(): HMInterceptorInstance[] {
    return this.globalInterceptorArray;
  }

  getInterceptorByPageUrl(pageUrl: string): Array<HMInterceptorInstance> {
    let interceptorInstanceArray = new Array<HMInterceptorInstance>();
    if (!this.pageStoreInfoMap.hasKey(pageUrl)) {
      HMLogger.i('[HMRouterStore] not exist pageUrl in store, pageUrl is %s', pageUrl);
      return interceptorInstanceArray;
    }
    let pageStoreInfo = this.pageStoreInfoMap.get(pageUrl);
    let interceptors = pageStoreInfo.interceptors;
    if (interceptors == undefined) {
      HMLogger.i('[HMRouterStore] not exist interceptors in store');
      return interceptorInstanceArray;
    }
    for (let interceptorName of interceptors) {
      if (!this.interceptorMap.hasKey(interceptorName)) {
        HMLogger.e('[HMRouterStore] not exist %s in interceptorMap', interceptorName);
        continue;
      }
      let hmInterceptorStoreData = this.interceptorMap.get(interceptorName);
      if (hmInterceptorStoreData.interceptor == undefined) {
        // 动态import创建interceptor
        let hmInterceptorData = hmInterceptorStoreData.hmInterceptorData;
        hmInterceptorStoreData.interceptor = hmInterceptorData.importComponent();
      }
      if (hmInterceptorStoreData.interceptor == undefined) {
        continue;
      }
      interceptorInstanceArray.push({
        interceptor: hmInterceptorStoreData.interceptor,
        interceptorName: hmInterceptorStoreData.hmInterceptorData.className,
        priority: hmInterceptorStoreData.hmInterceptorData.priority
      });
    }
    return interceptorInstanceArray;
  }

  getGlobalLifecycle(): HMLifecycleInstance[] {
    return this.globalLifecycleArray;
  }

  public getLifecycleInstanceByPageUrl(pageUrl: string): HMLifecycleInstance | null {
    if (!this.pageStoreInfoMap.hasKey(pageUrl)) {
      HMLogger.e('[HMRouterStore][loadLifecycle] not exist pageUrl in store,pageUrl is %s', pageUrl);
      return null;
    }
    let pageStoreInfo = this.pageStoreInfoMap.get(pageUrl);
    let lifecycleName = pageStoreInfo.lifecycle;
    if (lifecycleName == undefined) {
      HMLogger.i('[HMRouterStore][loadLifecycle] not exist lifecycle in store,pageUrl is %s', pageUrl);
      return null;
    }
    if (!this.lifecycleMap.hasKey(lifecycleName)) {
      HMLogger.e('[HMRouterStore] not exist lifecycle in store,lifecycle name is %s', lifecycleName);
      return null;
    }

    let hmLifecycleData = this.lifecycleMap.get(lifecycleName).hmLifecycleData;
    let hmLifecycle: IHMLifecycle | undefined = hmLifecycleData.importComponent();
    if (hmLifecycle == undefined) {
      return null;
    } else {
      let hmLifecycleInstance: HMLifecycleInstance = {
        lifecycle: hmLifecycle,
        lifecycleName: hmLifecycleData.className,
        priority: hmLifecycleData.priority != undefined ? hmLifecycleData.priority :
        HMRouterConst.HM_ROUTER_LIFECYCLE_DEFAULT_PRIORITY
      };
      return hmLifecycleInstance;
    }
  }


  getAnimatorByPageUrl(pageUrl: string): IHMAnimator | null {
    if (!this.pageStoreInfoMap.hasKey(pageUrl)) {
      HMLogger.i('[HMRouterStore][not exist pageUrl in store, pageUrl is %s', pageUrl);
      return null;
    }
    let pageStoreInfo = this.pageStoreInfoMap.get(pageUrl);
    let animator = pageStoreInfo.animator;
    if (animator == undefined) {
      HMLogger.i('[HMRouterStore][getAnimatorByPageUrl] not exist interceptors in store, pageUrl is %s', pageUrl);
      return null;
    }
    if (!this.animatorMap.hasKey(animator)) {
      HMLogger.e('[HMRouterStore] not exist animator in store',);
      return null;
    }
    let hmAnimatorStoreData = this.animatorMap.get(animator);
    if (hmAnimatorStoreData.animator == undefined) {
      // 动态import创建animator
      let hmAnimatorData = hmAnimatorStoreData.hmAnimatorData;
      if (hmAnimatorData != undefined) {
        hmAnimatorStoreData.animator = hmAnimatorData.importComponent<IHMAnimator>();
      }
    }
    if (hmAnimatorStoreData.animator == undefined) {
      HMLogger.e(HMError.ERR_INTERNAL,
        `[HMRouterStore] import animator error, can not get animator, animator name is ${animator}`);
      return null;
    }
    return hmAnimatorStoreData.animator;
  }

  hasAnimator(name: string): boolean {
    return this.animatorMap.hasKey(name);
  }


  getAnimatorByName(name: string): IHMAnimator | null {
    if (!this.animatorMap.hasKey(name)) {
      HMLogger.d(
        '[HMRouterStore][getAnimatorByName] not exist animator in store,animator name is %s', name);
      return null;
    }
    let animator = this.animatorMap.get(name).animator;
    return animator != undefined ? animator : null;
  }

  registerAnimator(name: string, hmAnimator: IHMAnimator): boolean {
    if (this.animatorMap.hasKey(name)) {
      HMLogger.w('[HMRouterStore][registerAnimator] animator was registered, store has %s', name);
    }
    this.animatorMap.set(name, { animator: hmAnimator });
    return true;
  }

  unRegisterAnimator(name: string): boolean {
    if (!this.animatorMap.hasKey(name)) {
      HMLogger.i('[HMRouterStore][unRegisterAnimator] not exist animator in store,animator name is %s', name);
      return false;
    }
    this.animatorMap.remove(name);
    return true;
  }

  registerHMPageInstance(hmPageInstance: HMPageInstance): boolean {
    if (this.pageStoreInfoMap.hasKey(hmPageInstance.pageUrl)) {
      HMLogger.w('[HMRouterStore] register hm page instance fail, pageUrl is %s, pageUrl already exist',
        hmPageInstance.pageUrl);
      return false;
    }
    let hmPageInfo = new HMPageInfo();
    hmPageInfo.registerFlag = true;
    hmPageInfo.builder = hmPageInstance.builder;
    hmPageInfo.pageUrl = hmPageInstance.pageUrl;
    hmPageInfo.singleton = hmPageInstance.singleton;
    if (hmPageInstance.interceptorArray != undefined) {
      for (let interceptorName of hmPageInstance.interceptorArray) {
        if (!this.interceptorMap.hasKey(interceptorName)) {
          HMLogger.i('[HMRouterStore] register hm page instance fail, pageUrl is %s, error message is interceptor %s not exist',
            hmPageInstance.pageUrl, interceptorName);
          return false;
        }
      }
    }
    this.pageStoreInfoMap.set(hmPageInstance.pageUrl, hmPageInfo);
    return true;
  }

  registerGlobalInterceptor(interceptor: HMInterceptorInstance): void {
    if (this.existGlobalInterceptor(interceptor.interceptorName)) {
      HMLogger.w('globalInterceptorArray exist %s,will replace', interceptor.interceptorName);
    }
    this.globalInterceptorArray.push(interceptor);
    this.globalInterceptorArray.sort((a: HMInterceptorInstance, b: HMInterceptorInstance) => a.priority -
    b.priority);
  }

  existGlobalInterceptor(interceptorName: string): boolean {
    for (let interceptorInstance of this.globalInterceptorArray) {
      if (interceptorName === interceptorInstance.interceptorName) {
        return true;
      }
    }
    return false;
  }

  unRegisterGlobalInterceptor(interceptorName: string): boolean {
    let index = -1;
    for (let i = 0; i < this.globalInterceptorArray.length; i++) {
      if (interceptorName == this.globalInterceptorArray[i].interceptorName) {
        index = i;
      }
    }
    if (index == -1) {
      HMLogger.w('[HMRouterStore] globalInterceptorArray not exist %s,can not unRegister', interceptorName);
      return false;
    }
    this.globalInterceptorArray.slice(index, 1);
    HMLogger.d('[HMRouterStore] remove interceptor success ,interceptorName is %s', interceptorName);
    return true;
  }

  registerGlobalLifecycle(lifecycle: HMLifecycleInstance): void {
    if (this.existGlobalLifecycle(lifecycle.lifecycleName)) {
      HMLogger.w('[HMRouterStore] globalLifecycleArray exist %s,will replace', lifecycle.lifecycleName);
    }
    this.globalLifecycleArray.push(lifecycle);
    this.globalLifecycleArray.sort((a: HMLifecycleInstance, b: HMLifecycleInstance) => a.priority -
    b.priority);
  }

  unRegisterGlobalLifecycle(lifecycleName: string): boolean {
    let index = -1;
    for (let i = 0; i < this.globalLifecycleArray.length; i++) {
      if (lifecycleName == this.globalLifecycleArray[i].lifecycleName) {
        index = i;
      }
    }
    if (index == -1) {
      HMLogger.w('[HMRouterStore] globalLifecycleArray not exist %s,can not unRegister', lifecycleName);
      return false;
    }
    this.globalLifecycleArray.slice(index, 1);
    HMLogger.d('[HMRouterStore] remove lifecycle success ,lifecycleName is %s', lifecycleName);
    return true;
  }

  existGlobalLifecycle(lifecycleName: string): boolean {
    for (let lifecycleInstance of this.globalLifecycleArray) {
      if (lifecycleName === lifecycleInstance.lifecycleName) {
        return true;
      }
    }
    return false;
  }

  getHMPageInfo(pageUrl: string): HMPageInstance | null {
    if (pageUrl == HMRouterUtils.HMBavBar_PAGE_NAME) {
      return null;
    }
    if (!this.pageStoreInfoMap.hasKey(pageUrl)) {
      HMLogger.e(HMError.ERR_INTERNAL, `[HMRouterStore] pageStoreInfoMap not exist pageUrl, pageUrl is ${pageUrl}`);
      return null;
    }
    let pageStoreInfo = this.pageStoreInfoMap.get(pageUrl);
    let hmPageInstance: HMPageInstance = {
      builder: pageStoreInfo.builder,
      pageUrl: pageStoreInfo.pageUrl,
      interceptorArray: pageStoreInfo.interceptors,
      singleton: pageStoreInfo.singleton
    };
    return hmPageInstance;
  }

  loadService(serviceName: string): HMServiceInstance | undefined {
    const targetService: HMServiceData = this.serviceMap.get(serviceName);
    if (!targetService) {
      HMLogger.e(HMError.ERR_SERVICE_NOT_EXIST, serviceName);
      return;
    }
    const targetClass: ESObject | undefined = targetService.importComponent<ESObject>();
    if (!targetClass) {
      HMLogger.e(HMError.ERR_SERVICE_IMPORT_FAILED, serviceName);
      return;
    }
    let serviceInstance: HMServiceInstance = {
      serviceName: targetService.serviceName,
      functionName: targetService.functionName,
      singleton: targetService.singleton,
      instance: targetClass
    };
    return serviceInstance;
  }


  private initStoreInfo(hmComponentInfos: collections.Array<HMComponent>) {
    hmComponentInfos.forEach((item: HMComponent) => {
      let name = item.name;
      let hmRouterAnnotationFactory = new HMRouterAnnotationFactory();
      let handler = hmRouterAnnotationFactory.create(name);
      if (handler) {
        handler.handlerHMComponent(item, this);
      }
    });
  }
}

