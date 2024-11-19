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
import HMRouterNapi from 'libhmrouterlibrary.so';

import { HMLogger } from '../log/HMLogger';
import { HMError } from '../log/ErrorCode';


/**
 * Dynamic import util
 */
export class ImportUtil {
  private static readonly ETS_SUFFIX: string = '.ets';
  private static readonly TS_SUFFIX = '.ts';
  private static readonly SEPARATOR = '/';
  private static readonly OHM_URL_FIRST_SEPARATOR = '&&&';
  private static readonly OHM_URL_SECOND_SEPARATOR = '&';
  private static readonly ETS_SEPARATOR = 'ets';

  /**
   * Splicing module and path
   * eg:
   * input: entry,src/main/ets/pages/Index.ets
   * output: entry/src/main/ets/pages/Index
   * @param module moduleName
   * @param path path
   * @returns splice result
   */
  public static spliceModuleAndPath(module: string, path: string): string {
    if (module === null) {
      return '';
    }

    if (path === null) {
      return '';
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    } else if (path.startsWith('./')) {
      path = path.substring(2);
    }

    if (path.endsWith(ImportUtil.ETS_SUFFIX)) {
      path = path.replace(ImportUtil.ETS_SUFFIX, '');
    } else if (path.endsWith(ImportUtil.TS_SUFFIX)) {
      path = path.replace(ImportUtil.TS_SUFFIX, '');
    }

    return module + ImportUtil.SEPARATOR + path;
  }

  public static getModulePathByUhmUrl(ohmUrl: string) {

  }

  /**
   * Get import path in the HAP package
   * har import hap : ets/pages/Index1
   * har import har : har/src/main/ets/components/MainPage
   * har import hsp : hsp/src/main/ets/utils/Calc
   * #param module moduleName
   * @param path path
   * @returns splice result
   */
  public static getHapImportPath(path: string): string {
    if (path === null) {
      return '';
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    } else if (path.startsWith('./')) {
      path = path.substring(2);
    }

    if (path.endsWith(ImportUtil.ETS_SUFFIX)) {
      path = path.replace(ImportUtil.ETS_SUFFIX, '');
    } else if (path.endsWith(ImportUtil.TS_SUFFIX)) {
      path = path.replace(ImportUtil.TS_SUFFIX, '');
    }
    return path.substring(path.indexOf(ImportUtil.ETS_SEPARATOR));
  }

  /**
   * dynamic import from path
   * @param modulePath
   * @param resultClassName
   * @returns
   */
  public static importFile<T>(modulePath: string, resultClassName: string) {
    return import(modulePath).then((ns: ESObject) => {
      let res: T = new ns[resultClassName]();
      return res;
    }).catch((err: Error) => {
      HMLogger.e('import error, error message is %s', err.message);
      return undefined;
    });
  }

  /**
   * Retrieve the content of ohmUrl
   * eg:@normalized:N&&&entry/src/main/ets/component/live/LiveHome&
   *    =>entry/src/main/ets/component/live/LiveHome
   * @param ohmUrl
   */
  public static getModuleInfoFromOhmUrl(ohmUrl: string): string | undefined {
    let splitRes = ohmUrl.split(ImportUtil.OHM_URL_FIRST_SEPARATOR);
    if (splitRes.length < 2) {
      HMLogger.e('getModuleInfoFromOhmUrl error, ohmUrl is %s', ohmUrl);
      return undefined;
    }
    let res = splitRes[1].split(ImportUtil.OHM_URL_SECOND_SEPARATOR);
    return res[0];
  }

  /**
   * dynamic import from native,use napi_load_module_with_info
   * @param module module
   * @param path path
   * @param moduleInfo bundleName/moduleName,eg:com.example.hm_router/hsp
   * @param className clazzName
   * @returns
   */
  public static nativeImport<T>(modulePath: string, moduleInfo: string, className: string): T | undefined {
    HMLogger.d('[NativeImport] import modulePath is %s,moduleInfo is %s,className is %s', modulePath, moduleInfo,
      className);
    try {
      let res: ESObject = HMRouterNapi.loadModule(modulePath, moduleInfo);
      return new res[className]();
    } catch (error) {
      HMLogger.e(HMError.ERR_DYNAMIC_IMPORT_FAILED, modulePath, moduleInfo, className);
      return undefined;
    }
  }
}