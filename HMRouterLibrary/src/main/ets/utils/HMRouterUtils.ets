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

import { common } from '@kit.AbilityKit';
import { collections, util } from '@kit.ArkTS';
import { HMLogger } from '../log/HMLogger';
import { HMError } from '../log/ErrorCode';
import { HMRouterConst } from '../constants/Constants';
import { HMNavPathStack } from '../router/HMNavPathStack';
import { HMPageInstance } from '../store/ComponentInstance';
import { hmRouterStore } from '../store/RouterStoreFactory';
import { BundleInfo } from '../store/entity/BundleInfo';
import { HMRouterAnnotationFactory } from '../store/HMRouterAnnotationHandler';
import { HMComponent } from '../store/entity/HMComponent';

export namespace HMRouterUtils {
  export const HMBavBar_PAGE_NAME: string = 'HM_NavBar';

  /**
   * 路由pop操作时，构造的目标页面和源页面名称和路由栈所处位置信息
   * When routing pop operations, the names of the constructed target and source pages and the location information of the routing stack
   */
  export interface PageInfo {
    name: string;
    index: number;
  }

  /**
   * Check the pageURL parameter
   * @param pathInfo
   * @returns
   */
  export function checkPageUrl(pageUrl?: string): boolean {
    if (!pageUrl) {
      HMLogger.e(HMError.ERR_PARAM_REQUIRED, 'pageUrl');
      return false;
    }
    return true;
  }

  /**
   * Get page configuration information based on pageURL
   * @param pageUrl
   * @param errType
   * @param onLost
   * @returns
   */
  export function getPageInfoByPageUrl(pageUrl: string, errType: HMError, onLost?: () => void): HMPageInstance | null {
    let pageInfo: HMPageInstance | null = { pageUrl: pageUrl };
    if (hmRouterStore.isInit()) {
      pageInfo = hmRouterStore.getHMPageInfo(pageUrl);
      if (!pageInfo) {
        HMLogger.e(errType, pageUrl);
        onLost?.();
        return null;
      }
    }
    return pageInfo;
  }

  export function getSrcPage(pathStack: HMNavPathStack): PageInfo {
    const allPath: string[] = pathStack.getAllPathName();
    const srcPageIndex = allPath.length - 1;
    const srcPage = allPath[srcPageIndex] ?? HMBavBar_PAGE_NAME;
    return {
      index: srcPageIndex,
      name: srcPage
    };
  }

  /**
   * Get target page information
   * @param pathStack
   * @param pageUrl
   * @param skipedLayerNumber
   * @returns
   */
  export function getTargetPage(pathStack: HMNavPathStack, pageUrl?: string,
    skipedLayerNumber: number = 0): PageInfo | null {
    let allPathName = pathStack.getAllPathName();
    let targetIndex: number = -1;
    let targetName: string = '';
    if (pageUrl) {
      targetIndex = allPathName.indexOf(pageUrl);
      targetName = pageUrl;
      if (targetIndex === -1) { // pageUrl参数无效
        HMLogger.e(HMError.ERR_POP_INVALID, `name: ${pageUrl}, index: ${targetIndex}`);
        return null;
      }
    } else {
      targetIndex = allPathName.length - 1 - (skipedLayerNumber + 1);
      targetName = allPathName[targetIndex];
      if (targetIndex === -1) {
        targetName = 'HM_NavBar';
      } else if (targetIndex < -1) { // 获取目标页面失败
        HMLogger.e(HMError.ERR_POP_INVALID, `name: ${pageUrl}, index: ${targetIndex}`);
        return null;
      }
    }
    return {
      name: targetName,
      index: targetIndex
    };
  }

  export function getBundleInfoFromRawFile(context: common.Context): BundleInfo | undefined {
    try {
      let hmRouterContent = context.resourceManager.getRawFileContentSync(HMRouterConst.HM_ROUTER_MAP_FILE_NAME);
      let decoder = util.TextDecoder.create();
      let routerMapJsonStr = decoder.decodeToString(hmRouterContent);
      let info: BundleInfo = JSON.parse(routerMapJsonStr);
      return info;
    } catch (error) {
      HMLogger.d('can not get router info from %s', context.applicationInfo.name);
      return undefined;
    }
  }

  export function parseBundleInfo(bundleInfo: BundleInfo, hmComponentInfos: collections.Array<HMComponent>) {
    bundleInfo.routerMap.forEach((routerItem) => {
      let name = routerItem.name;
      let hmRouterAnnotationFactory = new HMRouterAnnotationFactory();
      let handler = hmRouterAnnotationFactory.create(name);
      if (handler) {
        let hmComponent = handler.parseRouterItem(routerItem);
        hmComponentInfos.push(hmComponent);
      }
    });
  }


}