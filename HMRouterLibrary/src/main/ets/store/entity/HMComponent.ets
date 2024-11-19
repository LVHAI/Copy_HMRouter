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
import { HMRouterConst } from '../../constants/Constants';
import { HMLogger } from '../../log/HMLogger';
import { ImportUtil } from '../../utils/ImportUtil';
import { RouterItem } from './BundleInfo';

/**
 * HMComponent
 */
@Sendable
export class HMComponent {
  /**
   * 名称
   */
  name: string = '';
  /**
   * 动态import所需要的className
   */
  className: string = '';
  /**
   * pageSourceFile
   */
  pageSourceFile: string = '';
  /**
   * moduleName,eg:entry
   */
  moduleName: string = '';
  /**
   * bundleName,eg:com.example.hmrouter
   */
  bundleName: string = '';
  /**
   * ohmurl,eg:@normalized:N&&&entry/src/main/ets/animation/CustomPageAnimator&
   */
  ohmurl: string = '';

  /**
   * importComponent
   * @returns T|undefined
   */
  public importComponent<T>(): T | undefined {
    let modulePath: string | undefined = ImportUtil.getModuleInfoFromOhmUrl(this.ohmurl);
    if (!modulePath) {
      HMLogger.e('[HMRouter Store] get module path error,HMComponent data is %s', JSON.stringify(this));
      return undefined;
    }
    let moduleInfo = this.bundleName + HMRouterConst.MODULE_INFO_SEPARATOR + this.moduleName;
    return ImportUtil.nativeImport<T>(modulePath, moduleInfo, this.className);
  }

  public convertItem(item: RouterItem) {
    this.className = item.customData[HMRouterConst.HM_ROUTER_ANNOTATION_NAME];
    this.pageSourceFile = item.pageSourceFile;
    this.moduleName = item.moduleName;
    this.bundleName = item.bundleName;
    this.ohmurl = item.ohmurl;
    this.name = item.name;
  }
}