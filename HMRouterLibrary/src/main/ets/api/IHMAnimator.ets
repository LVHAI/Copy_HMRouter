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
import { BuiltInAnimator } from '../animator/BuiltInAnimator';
import { HMAnimatorHandle } from '../animator/HMAnimatorHandle';
import {
  OpacityOption as ObservedOpacityOption,
  ScaleOption as ObservedScaleOption,
} from '../template/AnimatorModel';

export interface IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void;

  interactive?(handle: HMAnimatorHandle): void;
}

export namespace IHMAnimator {
  export interface EffectOptions {
    direction?: IHMAnimator.Direction;
    opacity?: IHMAnimator.OpacityOption;
    scale?: IHMAnimator.ScaleOption;
  }

  export interface TranslateOption {
    x?: number | string;
    y?: number | string;
    z?: number | string;
  }

  export interface ScaleOption {
    x?: number;
    y?: number;
    centerX?: number | string;
    centerY?: number | string;
  }

  export interface OpacityOption {
    opacity?: number;
  }

  export enum Direction {
    RIGHT_TO_LEFT,
    LEFT_TO_RIGHT,
    BOTTOM_TO_TOP,
    TOP_TO_BOTTOM
  }

  export class Effect {
    effectOption: IHMAnimator.EffectOptions;

    constructor(effectOption: IHMAnimator.EffectOptions) {
      this.effectOption = effectOption;
    }

    toAnimator(): IHMAnimator {
      let animator: BuiltInAnimator = new BuiltInAnimator();
      if (this.effectOption.scale) {
        animator.scale = this.effectOption.scale as ObservedScaleOption;
      }
      if (this.effectOption.opacity) {
        animator.opacity = this.effectOption.opacity as ObservedOpacityOption;
      }
      animator.direction = this.effectOption.direction;
      return animator;
    }
  }
}