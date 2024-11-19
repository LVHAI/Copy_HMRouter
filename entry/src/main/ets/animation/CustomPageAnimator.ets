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

import {
  HMAnimator,
  HMAnimatorHandle,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';

/**
 * 自定义缩放动画
 */
@HMAnimator({ animatorName: 'zoomAnimator' })
export class ZoomAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 0.5;
      scaleOption.y = 0.5;
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 1;
      scaleOption.y = 1;
    });

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 1;
      scaleOption.y = 1;
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 0.5;
      scaleOption.y = 0.5;
    });
  }
}