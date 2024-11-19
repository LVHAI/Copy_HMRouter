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

import {
  HMInterceptor,
  HMInterceptorAction,
  HMInterceptorInfo,
  HMRouter,
  HMRouterMgr,
  IHMInterceptor
} from '@hadss/hmrouter';
import { PageConstant } from '../../constant/PageConstant';
import { ConfirmDialog } from '../common/ConfirmDialog';
import { MineConstants } from '../common/constants/MineConstants'

@HMInterceptor({interceptorName: 'exitLoginInterceptor'})
export class ExitLoginInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    return HMInterceptorAction.DO_NEXT;
  }
}

@HMRouter({pageUrl: PageConstant.EXIT_LOGIN, dialog: true, interceptors: ['exitLoginInterceptor']})
@Component
export struct ExitLogin {

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
      ConfirmDialog({
        title: MineConstants.EXIT_LOGIN_TITLE,
        content: MineConstants.EXIT_LOGIN_CONTENT,
        leftButtonName: MineConstants.EXIT_LOGIN_LEFT_BUTTON,
        rightButtonName: MineConstants.EXIT_LOGIN_RIGHT_BUTTON,
        leftButtonFunc: () => {
          HMRouterMgr.pop({
            navigationId: this.queryNavigationInfo()?.navigationId
          });
        },
        rightButtonFunc: () => {
          AppStorage.set('isLogin', false);
          HMRouterMgr.pop({
            pageUrl: 'myAccount',
            navigationId: this.queryNavigationInfo()?.navigationId,
            animator: false
          });
        }
      })
        .backgroundColor($r('app.color.exit_login_background_color'))
        .borderRadius(20);
    }
  }
}