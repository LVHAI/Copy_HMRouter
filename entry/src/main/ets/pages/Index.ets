/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMDefaultGlobalAnimator, HMNavigation, HMRouterMgr } from '@hadss/hmrouter';
import { AttributeUpdater, uiObserver } from '@kit.ArkUI';
import { JumpInfoInterceptor } from '../interceptor/JumpInfoInterceptor';
import { PageDurationLifecycle } from '../lifecycle/PageDurationLifecycle';

class MyNavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.hideNavBar(true);
  }
}

@Entry
@Component
struct Index {
  modifier: MyNavModifier = new MyNavModifier();
  private readonly refreshPages: Array<string> = ['HomeContent', 'shoppingBag', 'myAccount'];

  aboutToAppear(): void {
    HMRouterMgr.registerGlobalInterceptor({
      interceptor: new JumpInfoInterceptor(),
      interceptorName: 'JumpInfo',
      priority: 5
    });

    HMRouterMgr.registerGlobalLifecycle({
      lifecycle: new PageDurationLifecycle(),
      lifecycleName: 'PageDuration',
      priority: 5
    });

    uiObserver.on('navDestinationSwitch', this.getUIContext(), {
      navigationId: 'mainNavigationId'
    }, (info) => {
      if(this.refreshPages.includes((info.to as NavDestinationInfo).name.toString())) {
        AppStorage.setOrCreate('currentPage', (info.to as NavDestinationInfo).name.toString());
      }
    });
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationSwitch', this.getUIContext(), {
      navigationId: 'mainNavigationId'
    });
  }

  build() {
    Column() {
      HMNavigation({
        navigationId: 'mainNavigationId', homePageUrl: 'HomeContent', options: {
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          modifier: this.modifier
        }
      });
    }
    .height('100%')
    .width('100%');
  }
}