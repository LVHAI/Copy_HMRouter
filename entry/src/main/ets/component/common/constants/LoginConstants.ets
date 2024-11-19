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

export class LoginConstants {
  /**
   * Login title.
   */
  static readonly LOGIN_TEXT: string = getContext(this).resourceManager.getStringSync($r('app.string.LOGIN_TITLE'));
  /**
   * Login TextInput placeholder1.
   */
  static readonly LOGIN_PLACEHOLDER1: string =
    getContext(this).resourceManager.getStringSync($r('app.string.LOGIN_PLACEHOLDER1'));
  /**
   * Login TextInput placeholder2.
   */
  static readonly LOGIN_PLACEHOLDER2: string =
    getContext(this).resourceManager.getStringSync($r('app.string.LOGIN_PLACEHOLDER2'));
  /**
   * Login TextInput1 text.
   */
  static readonly LOGIN_INPUT_TEXT: string =
    getContext(this).resourceManager.getStringSync($r('app.string.LOGIN_INPUT_TEXT'));
  /**
   * Login button.
   */
  static readonly LOGIN_BUTTON: string = getContext(this).resourceManager.getStringSync($r('app.string.LOGIN_BUTTON'));
  /**
   * Login show toast.
   */
  static readonly LOGIN_TOAST: string = getContext(this).resourceManager.getStringSync($r('app.string.LOGIN_TOAST'));
  /**
   * Privacy dialog title.
   */
  static readonly PRIVACY_DIALOG_TITLE: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TITLE'));
  /**
   * Privacy dialog text1.
   */
  static readonly PRIVACY_DIALOG_TEXT1: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT1'));
  /**
   * Privacy dialog text2.
   */
  static readonly PRIVACY_DIALOG_TEXT2: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT2'));
  /**
   * Privacy dialog text3.
   */
  static readonly PRIVACY_DIALOG_TEXT3: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT3'));
  /**
   * Privacy dialog text4.
   */
  static readonly PRIVACY_DIALOG_TEXT4: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_TEXT4'));
  /**
   * Privacy dialog left button.
   */
  static readonly PRIVACY_DIALOG_LEFT_BUTTON: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_LEFT_BUTTON'));
  /**
   * Privacy dialog right button.
   */
  static readonly PRIVACY_DIALOG_RIGHT_BUTTON: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DIALOG_RIGHT_BUTTON'));
  /**
   * Privacy detail title.
   */
  static readonly PRIVACY_DETAIL_TITLE: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TITLE'));
  /**
   * Privacy detail text1.
   */
  static readonly PRIVACY_DETAIL_TEXT1: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT1'));
  /**
   * Privacy detail text2.
   */
  static readonly PRIVACY_DETAIL_TEXT2: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT2'));
  /**
   * Privacy detail text3.
   */
  static readonly PRIVACY_DETAIL_TEXT3: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT3'));
  /**
   * Privacy detail text4.
   */
  static readonly PRIVACY_DETAIL_TEXT4: string =
    getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_TEXT4'));
  /**
   * Privacy detail content.
   */
  static readonly PRIVACY_DETAIL_INFO: string[] =
    [getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT1')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT2')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT3')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT4')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT5')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT6')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT7')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT8')),
      getContext(this).resourceManager.getStringSync($r('app.string.PRIVACY_DETAIL_ITEM_TEXT9'))];
}