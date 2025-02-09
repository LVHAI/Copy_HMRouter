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

import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

const delegator: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

const want: Want = {
  bundleName: 'com.hadss.hmrouter',
  abilityName: 'EntryAbility'
};

export const driver = Driver.create();

export async function startAbility() {
  await delegator.startAbility(want);
}

const delayTime = 500;

export async function findAndClickComponent(componentName: string): Promise<void> {
  let button = await driver.findComponent(ON.text(componentName));
  await button.click();
  await driver.delayMs(delayTime);
}

export async function findAndClickComponentById(componentId: string): Promise<void> {
  let button = await driver.findComponent(ON.id(componentId));
  await button.click();
  await driver.delayMs(delayTime);
}

export async function pressBack(): Promise<void> {
  await driver.pressBack();
  await driver.delayMs(delayTime);
}
