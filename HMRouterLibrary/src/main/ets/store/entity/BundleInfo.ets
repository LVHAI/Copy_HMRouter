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
import { collections } from '@kit.ArkTS';
import { HMComponent } from './HMComponent';

export class BundleInfo {
  routerMap: Array<RouterItem> = new Array();
  hspModuleNames: Set<string> = new Set();
}


/**
 * RouterItem
 */
export class RouterItem {
  /**
   * name
   */
  name: string = '';
  /**
   * pageSourceFile
   */
  pageSourceFile: string = '';
  /**
   * buildFunction
   */
  buildFunction: string = '';
  /**
   * customData
   */
  customData: ESObject;
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
}

/**
 * HMStoreTempInfo
 */
export interface HMStoreTempInfo {
  hmComponentInfos: collections.Array<HMComponent>;
  installTime: number;
  updateTime: number;
}