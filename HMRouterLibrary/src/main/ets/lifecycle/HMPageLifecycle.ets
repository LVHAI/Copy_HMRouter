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
import { HMLifecycleState } from '../api/HMLifecycleState';
import { NavBarParentTypes } from './enums/NavBarParentTypes';
import { HMNavBarLifecycleMgr } from './HMNavBarLifecycleMgr';

export class HMPageLifecycle {
  private routerInfo: router.RouterState;
  private navbarLifecycleMgr: HMNavBarLifecycleMgr = HMNavBarLifecycleMgr.getInstance();

  constructor(routerInfo: router.RouterState) {
    this.routerInfo = routerInfo;
  }

  onDisAppear(): void {
    this.navbarLifecycleMgr.dispatchEvent(HMLifecycleState.onDisAppear, NavBarParentTypes.Page,
      this.routerInfo);
  }

  onShown(): void {
    this.navbarLifecycleMgr.dispatchEvent(HMLifecycleState.onShown, NavBarParentTypes.Page,
      this.routerInfo);
  }

  onHidden(): void {
    this.navbarLifecycleMgr.dispatchEvent(HMLifecycleState.onHidden, NavBarParentTypes.Page,
      this.routerInfo);
  }

  onBackPressed(): boolean {
    const result = this.navbarLifecycleMgr.dispatchEvent(HMLifecycleState.onBackPressed, NavBarParentTypes.Page,
      this.routerInfo);
    return result as boolean;
  }
}