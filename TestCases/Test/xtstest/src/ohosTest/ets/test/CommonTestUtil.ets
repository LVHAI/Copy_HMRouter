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

import { abilityDelegatorRegistry, Driver } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import {
  HMInterceptorAction,
  HMInterceptorInfo,
  HMLifecycleContext,
  IHMInterceptor,
  IHMLifecycle
} from '@hadss/hmrouter';

const delegator: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

const want: Want = {
  bundleName: 'com.hadss.hmrouter',
  abilityName: 'XtstestAbility'
};

export const driver = Driver.create();

export async function startAbility() {
  await delegator.startAbility(want);
}

export class XtsTestIHMInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    console.log('Test api cost time, execute interceptor');
    return HMInterceptorAction.DO_NEXT;
  }
}

export class XtsTestIHMLifecycle implements IHMLifecycle {
  onShown(ctx: HMLifecycleContext): void {
    console.log('Test api cost time, execute lifecycle');
  }
}
