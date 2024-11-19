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

export class PayConstants {
  /**
   * Pay card text1.
   */
  static readonly PAY_CARD_TEXT1: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CARD_TEXT1'));
  /**
   * Pay card text2.
   */
  static readonly PAY_CARD_TEXT2: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CARD_TEXT2'));
  /**
   * Pay card text3.
   */
  static readonly PAY_CARD_TEXT3: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CARD_TEXT3'));
  /**
   * Pay card text2.
   */
  static readonly PAY_CARD_BUTTON: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CARD_BUTTON'));
  /**
   * Pay cancel title.
   */
  static readonly PAY_CANCEL_TITLE: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CANCEL_TITLE'));
  /**
   * Pay cancel content.
   */
  static readonly PAY_CANCEL_CONTENT: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CANCEL_CONTENT'));
  /**
   * Pay cancel button1.
   */
  static readonly PAY_CANCEL_BUTTON1: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CANCEL_SEE'));
  /**
   * Pay cancel button2.
   */
  static readonly PAY_CANCEL_BUTTON2: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_CANCEL_CONFIRM'));
  /**
   * Pay success title.
   */
  static readonly PAY_SUCCESS_TITLE: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_SUCCESS_TITLE'));
  /**
   * Pay success text.
   */
  static readonly PAY_SUCCESS_TEXT: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_SUCCESS_TEXT'));
  /**
   * Pay success button text.
   */
  static readonly PAY_SUCCESS_BUTTON: string = getContext(this).resourceManager.getStringSync($r('app.string.PAY_SUCCESS_BUTTON'));
}