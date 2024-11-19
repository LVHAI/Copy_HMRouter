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

export class HMRouterConst {
  static readonly ANIMATOR_PREFIX = '__animator__';
  static readonly INTERCEPTOR_PREFIX = '__interceptor__';
  static readonly LIFECYCLE_PREFIX = '__lifecycle__';
  static readonly SERVICE_PREFIX = '__service__';
  static readonly PAGE_URL_PREFIX = '';
  /**
   * router_map.json data.data存放json字符串
   */
  static readonly HM_ROUTER_MAP_JSON_DATA_NAME = 'data';
  static readonly FILE_SEPARATOR = '/';
  static readonly HM_ROUTER_TEMP_JSON_DATA_FILE = 'hm_temp_json_file.json';
  /**
   * 默认优先级
   */
  static readonly HM_ROUTER_INTERCEPTOR_DEFAULT_PRIORITY = 9;
  static readonly HM_ROUTER_LIFECYCLE_DEFAULT_PRIORITY = 9;
  static readonly HM_ROUTER_ANNOTATION_GLOBAL_DEFAULT_VALUE: boolean = false;
  static readonly HM_ROUTER_MAP_KEY_SEPARATOR = '-';
  static readonly HM_ROUTER_DEFAULT_LIFECYCLE_NAME = 'hm_router_default_lifecycle';
  static readonly MODULE_INFO_SEPARATOR = '/';
  static readonly METADATA_HM_ROUTER_KEY = 'router_map';
  static readonly HM_ROUTER_MAP_FILE_NAME = 'hm_router_map.json';
  /**
   * HMRouterAnnotationHandler
   */
  static readonly HM_ROUTER_INTERCEPTOR_NAME = 'interceptorName';
  static readonly HM_ROUTER_ANNOTATION_NAME = 'name';
  static readonly HM_ROUTER_ANNOTATION_PRIORITY = 'priority';
  static readonly HM_ROUTER_ANNOTATION_GLOBAL = 'global';
  static readonly HM_ROUTER_LIFECYCLE_NAME = 'lifecycleName';
  static readonly HM_ROUTER_ANIMATOR_NAME = 'animatorName';
  /**
   * page info
   */
  static readonly HM_ROUTER_PAGE_INTERCEPTORS = 'interceptors';
  static readonly HM_ROUTER_PAGE_LIFECYCLE = 'lifecycle';
  static readonly HM_ROUTER_PAGE_ANIMATOR = 'animator';
  static readonly HM_ROUTER_PAGE_SINGLETON = 'singleton';
  static readonly HM_ROUTER_PAGE_DIALOG = 'dialog';
  /**
   *HMRouterService
   */
  static readonly HM_ROUTER_SERVICE_NAME = 'serviceName';
  static readonly HM_ROUTER_SERVICE_FUNCTION = 'functionName';
  static readonly HM_ROUTER_SERVICE_SINGLETON = 'singleton';
  static readonly HM_ROUTER_SERVICE_CLASS = 'name';
  /**
   * Animator
   */
  static readonly NAV_MODE_DIALOG = 'dialog';
  static readonly NAV_MODE_STANDARD = 'standard';
}