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

import { application, bundleManager, common } from '@kit.AbilityKit';
import { collections } from '@kit.ArkTS';
import { HMLogger } from '../log/HMLogger';
import { HMRouterUtils } from '../utils/HMRouterUtils';
import { HMComponent } from './entity/HMComponent';

/**
 * get bundle info from rawfile
 * @returns
 */
@Concurrent
export function getComponentInfosFromRawfile(context: common.Context,
  hspModuleNames: collections.Set<string>): collections.Array<HMComponent> {
  let hmComponentInfos: collections.Array<HMComponent> = new collections.Array();
  let bundleInfo = HMRouterUtils.getBundleInfoFromRawFile(context);
  if (bundleInfo) {
    HMRouterUtils.parseBundleInfo(bundleInfo, hmComponentInfos);
    for (const hspModuleName of bundleInfo.hspModuleNames) {
      hspModuleNames.add(hspModuleName);
      try {
        let hspContext = context.createModuleContext(hspModuleName);
        let hspBundleInfo = HMRouterUtils.getBundleInfoFromRawFile(hspContext);
        if (hspBundleInfo) {
          HMRouterUtils.parseBundleInfo(hspBundleInfo, hmComponentInfos);
        }
      } catch (error) {
        HMLogger.d('get bundle info from rawfile fail,hsp name is %s', hspModuleName);
      }
    }
  }
  return hmComponentInfos;
}

/**
 * get bundle info from bundleManager
 * @param context
 * @param hspModuleNames
 * @returns
 */
@Concurrent
export async function getComponentInfosFromBundleManager(context: common.Context,
  hspModuleNames: collections.Set<string>): Promise<collections.Array<HMComponent>> {
  let hmComponentInfos: collections.Array<HMComponent> = new collections.Array();
  let bundleFlags =
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE;
  let bundleData = await bundleManager.getBundleInfoForSelf(bundleFlags);
  for (let hapModulesInfoElement of bundleData.hapModulesInfo) {
    let hspModuleName = hapModulesInfoElement.name;
    if (hapModulesInfoElement.type == bundleManager.ModuleType.SHARED &&
      !hspModuleNames.has(hapModulesInfoElement.name)) {
      hspModuleNames.add(hspModuleName);
      try {
        let hspContext = await application.createModuleContext(context, hspModuleName);
        let hspBundleInfo = HMRouterUtils.getBundleInfoFromRawFile(hspContext);
        if (hspBundleInfo) {
          HMRouterUtils.parseBundleInfo(hspBundleInfo, hmComponentInfos);
        }
      } catch (error) {
        HMLogger.d('get bundle info from rawfile fail,hsp name is %s', hspModuleName);
      }
    }
  }
  return hmComponentInfos;
}



