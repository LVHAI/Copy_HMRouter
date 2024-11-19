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

import { HMLifecycleCallback, HMLifecycleContext, IHMLifecycle } from '../../api/IHMLifecycle';
import { AllLifecycleState, HMLifecycleState, InnerLifecycleState } from '../../api/HMLifecycleState';
import { HMLifecycleInstance } from '../../store/ComponentInstance';
import { hmRouterStore } from '../../store/RouterStoreFactory';
import { HMRouterConst } from '../../constants/Constants';
import { IHMLifecycleOwner } from '../interface/IHMLifecycleOwner';

export abstract class HMLifecycleOwner implements IHMLifecycleOwner {
  public navContext?: NavDestinationContext;
  private lifecycleInstance?: HMLifecycleInstance;
  private observerMap?: Map<AllLifecycleState, HMLifecycleInstance[]>;

  constructor(lifecycleInstance?: HMLifecycleInstance | null) {
    if (lifecycleInstance) {
      this.lifecycleInstance = lifecycleInstance;
    }
  }

  public getLifecycle(): IHMLifecycle | undefined {
    return this.lifecycleInstance?.lifecycle;
  }

  public addObserver(state: HMLifecycleState, callback: HMLifecycleCallback,
    priority: number = HMRouterConst.HM_ROUTER_LIFECYCLE_DEFAULT_PRIORITY): void {
    if (!this.observerMap) {
      this.observerMap = new Map();
    }
    let callbackArr = this.observerMap.get(state);
    const lifecycle: Record<string, HMLifecycleCallback> = {};
    lifecycle[state] = callback;
    const lifecycleInstance: HMLifecycleInstance = {
      lifecycle: lifecycle,
      lifecycleName: 'observer',
      priority: priority
    };
    if (callbackArr) {
      callbackArr.push(lifecycleInstance);
    } else {
      this.observerMap.set(state, [lifecycleInstance]);
    }
  }

  /**
   * dispatch NavDestination lifecycle
   * @param state
   * @param ctx
   * @returns
   */
  public dispatch(state: AllLifecycleState, ctx: HMLifecycleContext): boolean | void {
    const globalLifecycle = hmRouterStore.getGlobalLifecycle();
    const observerArr = this.observerMap?.get(state) ?? [];
    let allLifecycles: HMLifecycleInstance[] = globalLifecycle.concat(observerArr);
    if (this.lifecycleInstance) {
      allLifecycles.push(this.lifecycleInstance);
    }
    if (allLifecycles.length > 0 && allLifecycles.length > globalLifecycle.length) {
      allLifecycles.sort((instanceA: HMLifecycleInstance, instanceB: HMLifecycleInstance) => instanceB.priority -
      instanceA.priority);
    }
    for (let index = 0; index < allLifecycles.length; index++) {
      const lifecycleInstance = allLifecycles[index];
      const result = this.executeLifecycle(state, lifecycleInstance.lifecycle, ctx);
      // onBackPress触发时，按照优先级，如果存在return true时，阻止后续执行
      // When onBackPress is triggered, according to priority, if there is a return true, it will prevent subsequent execution
      if (state === HMLifecycleState.onBackPressed && result === true) {
        return result;
      }
    }
    if (state === HMLifecycleState.onBackPressed) {
      return false;
    }
  }

  /**
   * execute NavDestination lifecycle
   * @param state
   * @param lifecycle
   * @returns
   */
  private executeLifecycle(state: AllLifecycleState, lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void | boolean {
    if (executeLifecycleHandlerMap.has(state)) {
      return executeLifecycleHandlerMap.get(state)?.executeLifecycle(lifecycle, ctx);
    }
  }
}

/**
 * Lifecycle execute handler
 */
interface IExecuteLifecycleHandler {
  /**
   * executeLifecycle
   * @param lifecycle lifecycle
   * @param ctx HMLifecycleContext
   */
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void | boolean;
}

/**
 * onPrepare
 */
class OnPrepare implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onPrepare?.(ctx);
  }
}

/**
 * onAppear
 */
class OnAppear implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onAppear?.(ctx);
  }
}

/**
 * onDisAppear
 */
class OnDisAppear implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onDisAppear?.(ctx);
  }
}

/**
 * onShown
 */
class OnShown implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onShown?.(ctx);
  }
}

/**
 * onHidden
 */
class OnHidden implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onHidden?.(ctx);
  }
}

/**
 * onWillAppear
 */
class OnWillAppear implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onWillAppear?.(ctx);
  }
}

/**
 * onWillDisappear
 */
class OnWillDisappear implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onWillDisappear?.(ctx);
  }
}

/**
 * onWillShow
 */
class OnWillShow implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onWillShow?.(ctx);
  }
}

/**
 * onWillHide
 */
class OnWillHide implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onWillHide?.(ctx);
  }
}

/**
 * onReady
 */
class OnReady implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void {
    lifecycle.onReady?.(ctx);
  }
}

/**
 * onBackPressed
 */
class OnBackPressed implements IExecuteLifecycleHandler {
  executeLifecycle(lifecycle: IHMLifecycle, ctx: HMLifecycleContext): void | boolean {
    return lifecycle.onBackPressed?.(ctx);
  }
}

const executeLifecycleHandlerMap: Map<AllLifecycleState, IExecuteLifecycleHandler> = new Map();
executeLifecycleHandlerMap.set(InnerLifecycleState.onPrepare, new OnPrepare());
executeLifecycleHandlerMap.set(InnerLifecycleState.onAppear, new OnAppear());
executeLifecycleHandlerMap.set(HMLifecycleState.onDisAppear, new OnDisAppear());
executeLifecycleHandlerMap.set(HMLifecycleState.onShown, new OnShown());
executeLifecycleHandlerMap.set(HMLifecycleState.onHidden, new OnHidden());
executeLifecycleHandlerMap.set(InnerLifecycleState.onWillAppear, new OnWillAppear());
executeLifecycleHandlerMap.set(HMLifecycleState.onWillDisappear, new OnWillDisappear());
executeLifecycleHandlerMap.set(HMLifecycleState.onWillShow, new OnWillShow());
executeLifecycleHandlerMap.set(HMLifecycleState.onWillHide, new OnWillHide());
executeLifecycleHandlerMap.set(InnerLifecycleState.onReady, new OnReady());
executeLifecycleHandlerMap.set(HMLifecycleState.onBackPressed, new OnBackPressed());
