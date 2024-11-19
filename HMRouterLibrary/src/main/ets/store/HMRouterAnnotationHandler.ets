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

import { collections, HashMap } from '@kit.ArkTS';
import { HMLogger } from '../log/HMLogger';
import { HMRouterConst } from '../constants/Constants';
import { IHMInterceptor } from '../api/IHMInterceptor';
import { IHMLifecycle } from '../api/IHMLifecycle';
import { HMAnimatorData, HMAnimatorStoreData } from './entity/HMAnimator';
import { HMInterceptorData, HMInterceptorStoreData } from './entity/HMInterceptor';
import { HMLifecycleData, HMLifecycleStoreData } from './entity/HMLifecycle';
import { HMComponent } from './entity/HMComponent';
import { HMRouterData } from './entity/HMRouter';
import { HMServiceData } from './entity/HMService';
import { RouterItem } from './entity/BundleInfo';
import { HMPageInfo } from './ComponentInstance';
import { HMRouterStoreImpl } from './HMRouterStoreImpl';

export interface HMRouterAnnotationHandler {
  parseRouterItem(item: RouterItem): HMComponent;

  handlerHMComponent(hmComponent: HMComponent, hmRouterStore: HMRouterStoreImpl): void;
}

/**
 * Interceptor handler
 */
class HMRouterInterceptorHandler implements HMRouterAnnotationHandler {
  parseRouterItem(item: RouterItem): HMComponent {
    let interceptorData: HMInterceptorData = new HMInterceptorData();
    if (!item.customData) {
      return interceptorData;
    }
    interceptorData.convertItem(item);
    interceptorData.interceptorName = item.customData[HMRouterConst.HM_ROUTER_INTERCEPTOR_NAME];
    interceptorData.priority = item.customData[HMRouterConst.HM_ROUTER_ANNOTATION_PRIORITY] |
    HMRouterConst.HM_ROUTER_INTERCEPTOR_DEFAULT_PRIORITY;
    interceptorData.global = item.customData[HMRouterConst.HM_ROUTER_ANNOTATION_GLOBAL];
    return interceptorData;
  }

  handlerHMComponent(hmComponent: HMComponent, hmRouterStore: HMRouterStoreImpl): void {
    let interceptorData: HMInterceptorData = hmComponent as HMInterceptorData;
    let hmInterceptorStoreData = new HMInterceptorStoreData();
    let interceptorName: string;
    try {

      let interceptorMap: HashMap<string, HMInterceptorStoreData> = hmRouterStore.getInterceptorMap();
      interceptorName = interceptorData.interceptorName;

      // if exist, replace
      hmInterceptorStoreData.hmInterceptorData = interceptorData;
      interceptorMap.set(interceptorName, hmInterceptorStoreData);
    } catch (err) {
      HMLogger.e('HMRouterInterceptorHandler execute error, error message is %s', err);
      return;
    }

    // if global, import in init, other, import in use
    if (interceptorData.global) {
      let interceptor: IHMInterceptor | undefined = interceptorData.importComponent<IHMInterceptor>();
      if (!interceptor) {
        HMLogger.e('import interceptor error,result is undefined');
        return;
      }
      let globalInterceptorArray = hmRouterStore.getGlobalInterceptorArray();
      if (hmRouterStore.existGlobalInterceptor(interceptorName)) {
        HMLogger.w('global interceptor has %s,will replace', interceptorName);
      }
      globalInterceptorArray.push({
        interceptorName: interceptorName,
        interceptor: interceptor,
        priority: interceptorData.priority
      });
      globalInterceptorArray.sort((a, b) => a.priority - b.priority);
      hmInterceptorStoreData.interceptor = interceptor;
    }
  }
}

/**
 * 生命周期 handler
 */
class HMRouterLifecycleHandler implements HMRouterAnnotationHandler {
  parseRouterItem(item: RouterItem): HMComponent {
    let lifecycleData: HMLifecycleData = new HMLifecycleData();
    if (!item.customData) {
      return lifecycleData;
    }
    lifecycleData.convertItem(item);
    lifecycleData.lifecycleName = item.customData[HMRouterConst.HM_ROUTER_LIFECYCLE_NAME];
    lifecycleData.priority = item.customData[HMRouterConst.HM_ROUTER_ANNOTATION_PRIORITY] |
    HMRouterConst.HM_ROUTER_LIFECYCLE_DEFAULT_PRIORITY;
    lifecycleData.global = item.customData[HMRouterConst.HM_ROUTER_ANNOTATION_GLOBAL];
    return lifecycleData;
  }

  handlerHMComponent(hmComponent: HMComponent, hmRouterStore: HMRouterStoreImpl): void {
    let lifecycleData: HMLifecycleData = hmComponent as HMLifecycleData;
    let lifecycleName: string;
    let hmLifecycleStoreData = new HMLifecycleStoreData();
    try {

      let lifecycleMap: HashMap<string, HMLifecycleStoreData> = hmRouterStore.getLifecycleMap();
      lifecycleName = lifecycleData.lifecycleName;

      // if exist, replace
      hmLifecycleStoreData.hmLifecycleData = lifecycleData;
      lifecycleMap.set(lifecycleName, hmLifecycleStoreData);
    } catch (err) {
      HMLogger.e('HMRouterInterceptorHandler execute error, error message is %s', err);
      return;
    }

    if (lifecycleData.global) {
      let lifecycle: IHMLifecycle | undefined = hmLifecycleStoreData.hmLifecycleData.importComponent<IHMLifecycle>();
      if (!lifecycle) {
        return;
      }
      let globalLifecycleArray = hmRouterStore.getGlobalLifecycleArray();
      if (hmRouterStore.existGlobalLifecycle(lifecycleName)) {
        HMLogger.w('global lifecycle has %s,will replace', lifecycleName);
      }
      globalLifecycleArray.push({
        lifecycle: lifecycle,
        priority: lifecycleData.priority,
        lifecycleName: lifecycleName
      });
      globalLifecycleArray.sort((a, b) => a.priority - b.priority);
      hmLifecycleStoreData.lifecycle = lifecycle;
    }
  }
}

/**
 * 动画 handler
 */
class HMRouterAnimatorHandler implements HMRouterAnnotationHandler {
  parseRouterItem(item: RouterItem): HMComponent {
    let animatorData: HMAnimatorData = new HMAnimatorData();
    if (!item.customData) {
      return animatorData;
    }
    animatorData.convertItem(item);
    animatorData.animatorName = item.customData[HMRouterConst.HM_ROUTER_ANIMATOR_NAME];
    return animatorData;
  }

  handlerHMComponent(hmComponent: HMComponent, hmRouterStore: HMRouterStoreImpl): void {
    let animatorData: HMAnimatorData = hmComponent as HMAnimatorData;
    try {
      let animatorMap: HashMap<string, HMAnimatorStoreData> = hmRouterStore.getAnimatorMap();
      let hmAnimatorStoreData = new HMAnimatorStoreData();
      hmAnimatorStoreData.hmAnimatorData = animatorData;
      if (animatorMap.hasKey(animatorData.animatorName)) {
        HMLogger.e('HMRouterAnimatorHandler animatorMap has %s, while be replace', animatorData.className);
      }
      animatorMap.set(animatorData.animatorName, hmAnimatorStoreData);
    } catch (err) {
      HMLogger.e('HMRouterAnimatorHandler execute error, error message is %s', err);
    }
  }
}

/**
 * page handler
 */
class HMRouterPageHandler implements HMRouterAnnotationHandler {
  parseRouterItem(item: RouterItem): HMRouterData {
    let pageData = new HMRouterData();
    pageData.pageUrl = item.name;
    try {
      if (item.customData) {
        pageData.convertItem(item);
        if (item.customData[HMRouterConst.HM_ROUTER_PAGE_INTERCEPTORS]) {
          pageData.interceptors =
            collections.Array.from<string>(item.customData[HMRouterConst.HM_ROUTER_PAGE_INTERCEPTORS]);
        }
        pageData.lifecycle = item.customData[HMRouterConst.HM_ROUTER_PAGE_LIFECYCLE];
        pageData.animator = item.customData[HMRouterConst.HM_ROUTER_PAGE_ANIMATOR];
        pageData.singleton = item.customData[HMRouterConst.HM_ROUTER_PAGE_SINGLETON];
        pageData.dialog = item.customData[HMRouterConst.HM_ROUTER_PAGE_DIALOG];
      }
    } catch (err) {
      HMLogger.e('HMRouterPageHandler execute error,pageurl is %s,error message is %s', item.name, err);
    }
    return pageData;
  }

  handlerHMComponent(hmRouterData: HMRouterData, hmRouterStore: HMRouterStoreImpl): void {
    let pageStoreInfoMap = hmRouterStore.getPageStoreInfoMap();
    let hmPageInfo = new HMPageInfo();
    hmPageInfo.registerFlag = false;
    hmPageInfo.pageUrl = hmRouterData.pageUrl;
    hmPageInfo.interceptors = hmRouterData.interceptors;
    hmPageInfo.singleton = hmRouterData.singleton;
    hmPageInfo.animator = hmRouterData.animator;
    hmPageInfo.lifecycle = hmRouterData.lifecycle;
    hmPageInfo.dialog = hmRouterData.dialog;
    pageStoreInfoMap.set(hmPageInfo.pageUrl, hmPageInfo);
  }
}

/**
 * service handler
 */
class HMRouterServiceHandler implements HMRouterAnnotationHandler {
  parseRouterItem(item: RouterItem): HMComponent {
    let serviceData: HMServiceData = new HMServiceData();
    if (!item.customData) {
      HMLogger.e('HMRouterInterceptorHandler function execute error, item data value is null');
      return serviceData;
    }
    try {
      serviceData.convertItem(item);
      serviceData.serviceName = item.customData[HMRouterConst.HM_ROUTER_SERVICE_NAME];
      serviceData.functionName = item.customData[HMRouterConst.HM_ROUTER_SERVICE_FUNCTION];
      serviceData.singleton = item.customData[HMRouterConst.HM_ROUTER_SERVICE_SINGLETON];
    } catch (err) {
      HMLogger.e('HMRouterInterceptorHandler execute error, error message is %s', err);
    }
    return serviceData;
  }

  handlerHMComponent(hmComponent: HMComponent, hmRouterStore: HMRouterStoreImpl): void {
    let serviceData: HMServiceData = hmComponent as HMServiceData;
    let serviceMap: HashMap<string, HMServiceData> = hmRouterStore.getServiceMap();
    let serviceName: string = serviceData.serviceName;
    serviceMap.set(serviceName, serviceData);

  }
}


export class HMRouterAnnotationFactory {
  private hmRouterAnnotationHandlerMap: Map<string, HMRouterAnnotationHandler> = new Map();

  constructor() {
    if (this.hmRouterAnnotationHandlerMap.size == 0) {
      this.hmRouterAnnotationHandlerMap.set(HMRouterConst.PAGE_URL_PREFIX, new HMRouterPageHandler());
      this.hmRouterAnnotationHandlerMap.set(HMRouterConst.INTERCEPTOR_PREFIX, new HMRouterInterceptorHandler());
      this.hmRouterAnnotationHandlerMap.set(HMRouterConst.LIFECYCLE_PREFIX, new HMRouterLifecycleHandler());
      this.hmRouterAnnotationHandlerMap.set(HMRouterConst.ANIMATOR_PREFIX, new HMRouterAnimatorHandler());
      this.hmRouterAnnotationHandlerMap.set(HMRouterConst.SERVICE_PREFIX, new HMRouterServiceHandler());
    }
  }

  public create(name: string): HMRouterAnnotationHandler | undefined {
    const regex = /__(animator|interceptor|lifecycle|service)__/g;
    const matches = name.match(regex);
    if (matches) {
      return this.hmRouterAnnotationHandlerMap.get(matches[0]);
    } else {
      return this.hmRouterAnnotationHandlerMap.get(HMRouterConst.PAGE_URL_PREFIX);
    }
  }
}
