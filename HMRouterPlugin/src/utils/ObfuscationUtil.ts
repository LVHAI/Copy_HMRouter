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

import { HMServiceResult, RouterInfo } from '../common/PluginModel';
import HMRouterPluginConstant from '../constants/CommonConstants';

export default class ObfuscationUtil {
  // 根据 routerMap 生成混淆字符串
  static buildObfuscatedStrings(routerMap: RouterInfo[]) {
    let srcPathArr = [...new Set(routerMap.map((routerInfo) => {
      return HMRouterPluginConstant.CURRENT_DELIMITER + routerInfo.pageSourceFile!;
    }))];
    let classNameArr = [...new Set(routerMap.filter((routerInfo) => {
      return routerInfo.name.includes('__');
    }).map((routerInfo) => {
      return routerInfo.customData.name!;
    }))];
    let functionName = [...new Set(routerMap.filter((routerInfo) => {
      return routerInfo.name.includes(HMRouterPluginConstant.SERVICE_PREFIX);
    }).map((routerInfo) => {
      return (routerInfo.customData as HMServiceResult).functionName!;
    }))];
    return HMRouterPluginConstant.KEEP_FILE_NAME + HMRouterPluginConstant.LINE_BREAK +
    srcPathArr.concat(HMRouterPluginConstant.KEEP_PROPERTY_NAME, classNameArr, functionName)
      .join(HMRouterPluginConstant.LINE_BREAK);
  }
};