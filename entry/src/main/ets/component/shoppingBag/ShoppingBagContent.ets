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

import { taskpool } from '@kit.ArkTS';
import { uiObserver } from '@kit.ArkUI';
import {
  HMDefaultGlobalAnimator,
  HMLifecycle,
  HMLifecycleContext,
  HMNavigation,
  HMRouter,
  HMRouterMgr,
  IHMLifecycle
} from '@hadss/hmrouter';
import { ShoppingNavModifier } from './ShoppingNavModifier';
import { ShoppingBagContentNavBar } from './components/ShoppingBagContentNavBar';
import { PageConstant } from '../../constant/PageConstant';
import { TempObj } from '../../service/ServiceSample';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';

@Concurrent
async function networkRequest(lifecycle: string): Promise<string> {
  return await new Promise<string>((resolve) => {
    setTimeout(() => {
      resolve(`${lifecycle} request Http sucess`);
    }, 5000);
  });
}

@HMLifecycle({ lifecycleName: 'requestLifecycle' })
export class ExampleLifecycle implements IHMLifecycle {
  private requestModel: RequestModel = new RequestModel();

  onPrepare(): void {
    console.log(this.requestModel.data);
    let task: taskpool.Task = new taskpool.Task(networkRequest, 'onPrepare');
    taskpool.execute(task).then((res: Object) => {
      console.log(res + '');
    });
  }

  onBackPressed(ctx: HMLifecycleContext): boolean {
    HMRouterMgr.pop({ navigationId: 'mainNavigationId', animator: false });
    return true;
  }
}

@Observed
export class RequestModel {
  data: string = 'lifecycle onPrepare init data';
}


@HMRouter({
  pageUrl: PageConstant.SHOPPING_BAG,
  singleton: true,
  interceptors: ['LoginCheckInterceptor'],
  lifecycle: 'requestLifecycle'
})
@Component
export struct ShoppingBagContent {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @State showTabsBtn: boolean = true;
  @Provide('ShoppingNavModifier') modifier: ShoppingNavModifier = new ShoppingNavModifier();

  aboutToAppear(): void {
    let task: taskpool.Task = new taskpool.Task(networkRequest, 'aboutToAppear');
    taskpool.execute(task).then((res: Object) => {
      console.log(JSON.stringify(res));
    });
    uiObserver.on('navDestinationSwitch', this.getUIContext(), {
      navigationId: 'shoppingNavigation'
    }, (info) => {
      if (info.from === 'navBar') {
        this.showTabsBtn = false;
        this.modifier.attribute?.mode(NavigationMode.Auto);
      }
      if (info.to === 'navBar') {
        this.showTabsBtn = true;
        this.modifier.attribute?.mode(NavigationMode.Stack);
      }
    });
    this.service();
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationSwitch', this.getUIContext(), {
      navigationId: 'shoppingNavigation'
    });
  }

  service(): void {
    HMRouterMgr.request('testConsole');

    console.log(HMRouterMgr.request('testFunWithReturn').data);

    // Asynchronous calls will be executed at the end
    HMRouterMgr.request('testAsyncFun').data.then((res: string) => console.log(res));

    const tempObjParam: TempObj = { paramA: '', paramB: 20 };
    console.log(HMRouterMgr.request('testFunWithParams', 'testStr', 10, false, tempObjParam).data);
  }

  build() {
    HMNavigation({
      navigationId: 'shoppingNavigation', options: {
        standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
        modifier: this.modifier
      }
    }) {
      ShoppingBagContentNavBar({ showTabsBtn: this.showTabsBtn });
    };
  }
}