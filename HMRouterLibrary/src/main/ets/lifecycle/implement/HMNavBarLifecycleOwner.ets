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

import { HMLifecycleState } from '../../api/HMLifecycleState';
import { HMLifecycleOwner } from './HMLifecycleOwner';

export class HMNavBarLifecycleObserver extends HMLifecycleOwner {
  public navbarState?: HMLifecycleState;

  constructor(parentLifecycle?: HMLifecycleOwner) {
    super();
    parentLifecycle?.addObserver?.(HMLifecycleState.onDisAppear, (ctx): void => {
      this.dispatch(HMLifecycleState.onDisAppear, ctx);
    });
    parentLifecycle?.addObserver?.(HMLifecycleState.onShown, (ctx): void => {
      if (this.navbarState === HMLifecycleState.onHidden) {
        return;
      }
      this.dispatch(HMLifecycleState.onShown, ctx);
    }, Number.MAX_SAFE_INTEGER);
    parentLifecycle?.addObserver?.(HMLifecycleState.onHidden, (ctx): void => {
      if (this.navbarState === HMLifecycleState.onHidden) {
        return;
      }
      this.dispatch(HMLifecycleState.onHidden, ctx);
    }, Number.MAX_SAFE_INTEGER);
    parentLifecycle?.addObserver?.(HMLifecycleState.onBackPressed, (ctx): boolean => {
      return this.dispatch(HMLifecycleState.onBackPressed, ctx) as boolean;
    }, Number.MAX_SAFE_INTEGER);
  }
}