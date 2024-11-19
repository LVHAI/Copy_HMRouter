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

import { HMAnimatorMgr } from '../animator/HMAnimatorMgr';
import { HMLifecycleState, InnerLifecycleState } from '../api/HMLifecycleState';
import { HMNavDstLifecycleMgr } from '../lifecycle/HMNavDstLifecycleMgr';
import { OpacityOption, ScaleOption, TranslateOption } from './AnimatorModel';

export class TemplateService {
  private static animatorMgr: HMAnimatorMgr = HMAnimatorMgr.getInstance();
  private static navDestinationLifecycleMgr: HMNavDstLifecycleMgr = HMNavDstLifecycleMgr.getInstance();

  static aboutToAppear(navigationId: string, pageUrl: string, dialog: boolean, translateOption: TranslateOption,
    scaleOption: ScaleOption,
    opacityOption: OpacityOption) {
    TemplateService.animatorMgr.registerAnimatorHandle(navigationId, pageUrl, dialog, translateOption, scaleOption,
      opacityOption);
  }

  static aboutToDisappear(navigationId: string, pageUrl: string, ndId: string) {
    TemplateService.animatorMgr.unRegisterAnimatorHandle(navigationId, ndId);
    TemplateService.navDestinationLifecycleMgr.destroyLifecycle(navigationId, pageUrl, ndId);
  }

  static onDisAppear(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onDisAppear, navigationId, pageUrl,
      navId);
  }

  static onAppear(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(InnerLifecycleState.onAppear, navigationId, pageUrl,
      navId);
  }

  static onShown(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onShown, navigationId, pageUrl, navId);
  }

  static onHidden(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onHidden, navigationId, pageUrl, navId);
  }

  static onWillAppear(navigationId: string, pageUrl: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(InnerLifecycleState.onWillAppear, navigationId, pageUrl);
  }

  static onWillDisappear(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onWillDisappear, navigationId, pageUrl,
      navId);
  }

  static onWillShow(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onWillShow, navigationId, pageUrl, navId);
  }

  static onWillHide(navigationId: string, pageUrl: string, navId: string) {
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onWillHide, navigationId, pageUrl, navId);
  }

  static onReady(navigationId: string, pageUrl: string, navContext: NavDestinationContext) {
    TemplateService.animatorMgr.updateHandleKey(pageUrl, navigationId, navContext.navDestinationId!);
    TemplateService.navDestinationLifecycleMgr.updateLifecycleKey(navigationId, pageUrl, navContext);
    TemplateService.navDestinationLifecycleMgr.dispatchEvent(InnerLifecycleState.onReady, navigationId, pageUrl,
      navContext.navDestinationId);
  }

  static onBackPressed(navigationId: string, pageUrl: string, navId: string): boolean {
    return TemplateService.navDestinationLifecycleMgr.dispatchEvent(HMLifecycleState.onBackPressed, navigationId,
      pageUrl,
      navId) as boolean;
  }

  static interactiveStart(navigationId: string, ndId: string, event: GestureEvent) {
    TemplateService.animatorMgr.interactiveStart(navigationId, ndId, event);
  }

  static interactiveFinish(navigationId: string, ndId: string, event: GestureEvent) {
    TemplateService.animatorMgr.interactiveFinish(navigationId, ndId, event);
  }

  static interactiveProgress(navigationId: string, ndId: string, event: GestureEvent) {
    TemplateService.animatorMgr.interactiveProgress(navigationId, ndId, event);
  }
}