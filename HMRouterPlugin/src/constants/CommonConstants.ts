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

import path from 'path';

export default class HMRouterPluginConstant {
  static readonly ANIMATOR_PREFIX = '__animator__';
  static readonly INTERCEPTOR_PREFIX = '__interceptor__';
  static readonly LIFECYCLE_PREFIX = '__lifecycle__';
  static readonly SERVICE_PREFIX = '__service__';
  static readonly PAGE_URL_PREFIX = '';

  static readonly OBFUSCATION_FILE_NAME = 'hmrouter_obfuscation_rules.txt';

  static readonly VARIABLE_SEPARATOR = '__';
  static readonly PAGE_URL = 'pageUrl';
  static readonly ROUTER_MAP_KEY = 'routerMap';

  static readonly FILE_SEPARATOR = path.sep;
  static readonly DELIMITER = '/';

  static readonly MODULE_ROUTER_MAP_NAME = '$profile:hm_router_map';
  static readonly ROUTER_MAP_NAME = 'hm_router_map.json';
  static readonly TEMP_ROUTER_MAP_PATH = '../../intermediates/router_map';
  static readonly RAWFILE_DIR = 'src/main/resources/rawfile/hm_router_map.json';
  static readonly VIEW_NAME_PREFIX = 'HM';
  static readonly VIEW_NAME_SUFFIX = '.ets';
  static readonly JSON_SUFFIX = '.json';

  static readonly HAP_PLUGIN_ID = 'HAP_HMROUTER_PLUGIN';
  static readonly HSP_PLUGIN_ID = 'HSP_HMROUTER_PLUGIN';
  static readonly HAR_PLUGIN_ID = 'HAR_HMROUTER_PLUGIN';

  static readonly ROUTER_ANNOTATION = 'HMRouter';
  static readonly ANIMATOR_ANNOTATION = 'HMAnimator';
  static readonly INTERCEPTOR_ANNOTATION = 'HMInterceptor';
  static readonly LIFECYCLE_ANNOTATION = 'HMLifecycle';
  static readonly SERVICE_ANNOTATION = 'HMService';

  static readonly CONFIG_FILE_NAME = 'hmrouter_config.json';
  static readonly PARENT_DELIMITER = '../';
  static readonly CURRENT_DELIMITER = './';

  static readonly LINE_BREAK = '\n';
  static readonly KEEP_FILE_NAME = '-keep-file-name';
  static readonly KEEP_PROPERTY_NAME = '-keep-property-name';

  static readonly WILDCARD = '/**';
};
