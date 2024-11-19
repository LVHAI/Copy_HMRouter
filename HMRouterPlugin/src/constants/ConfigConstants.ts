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

export default class ConfigConstants {
  static readonly DEFAULT_SCAN_DIR = 'src/main/ets/**';
  static readonly DEFAULT_ROUTER_MAP_DIR = 'src/main/resources/base/profile';
  static readonly DEFAULT_BUILD_DIR = 'src/main/ets/generated';
  static readonly DEFAULT_BUILD_TPL = 'viewBuilder.ejs';
  static readonly ROUTER_ANNOTATION = 'HMRouter';
  static readonly ANIMATOR_ANNOTATION = 'HMAnimator';
  static readonly INTERCEPTOR_ANNOTATION = 'HMInterceptor';
  static readonly LIFECYCLE_ANNOTATION = 'HMLifecycle';
  static readonly SERVICE_ANNOTATION = 'HMService';
};