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

import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { PageConstant } from '../../constant/PageConstant';
import { ConfirmDialog } from '../common/ConfirmDialog';
import { PayConstants } from '../common/constants/PayConstants'

@HMRouter({pageUrl: PageConstant.PAY_CANCEL, dialog: true})
@Component
export struct PayCancel {
  pageUrl: string = '';

  aboutToAppear(): void {
    let pageUrl = HMRouterMgr.getCurrentParam() as string;
    this.pageUrl = pageUrl;
  }

  build() {
    Stack({alignContent: Alignment.Center}) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
      ConfirmDialog({
        title: PayConstants.PAY_CANCEL_TITLE,
        content: PayConstants.PAY_CANCEL_CONTENT,
        leftButtonName: PayConstants.PAY_CANCEL_BUTTON1,
        rightButtonName: PayConstants.PAY_CANCEL_BUTTON2,
        leftButtonFunc: () => {
          HMRouterMgr.pop({
            navigationId: this.queryNavigationInfo()?.navigationId
          });
        },
        rightButtonFunc: () => {
          let pathStack = HMRouterMgr.getPathStack(this.queryNavigationInfo()?.navigationId!);
          if (this.pageUrl === 'shoppingBag') {
            for (let i = 0; i < 2; i++) {
              pathStack?.pop(false);
            }
          } else {
            for(let i = 0; i < 3; i++) {
              pathStack?.pop(false);
            }
          }
        }
      });
    }
    .width('100%')
    .height('100%');
  }
}