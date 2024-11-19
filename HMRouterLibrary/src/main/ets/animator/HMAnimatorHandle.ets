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

import { OpacityOption, ScaleOption, TranslateOption } from '../template/AnimatorModel';

export class HMAnimatorHandle {
  translateOption?: TranslateOption;
  scaleOption?: ScaleOption;
  opacityOption?: OpacityOption;
  startCallback?: AnimatorCallback;
  finishCallback?: AnimatorCallback;
  onFinishCallback?: AnimatorCallback;
  passiveStartCallback?: AnimatorCallback;
  passiveFinishCallback?: AnimatorCallback;
  passiveOnFinishCallback?: AnimatorCallback;
  timeout?: number;
  duration: number = 250;
  curve: Curve | string | ICurve = Curve.EaseIn;
  interactive: boolean = false;
  operation?: NavigationOperation;
  proxy?: NavigationTransitionProxy;
  startOffset?: number;
  actionStartCallback?: (event: GestureEvent) => void;
  updateProgressCallback?: InteractiveCallback;
  actionEndCallback?: InteractiveCallback;

  constructor(translateOption?: TranslateOption, scaleOption?: ScaleOption, opacityOption?: OpacityOption) {
    this.translateOption = translateOption;
    this.scaleOption = scaleOption;
    this.opacityOption = opacityOption;
  }

  /**
   * custom transition start callback
   * define translate/scale/opacity setting of beginning state
   * @param callback
   * @returns
   */
  start(callback: AnimatorCallback): HMAnimatorHandle {
    this.startCallback = callback;
    return this;
  }

  /**
   * custom transition finish callback
   * define translate/scale/opacity setting of ending state
   * @param callback
   * @returns
   */
  finish(callback: AnimatorCallback): HMAnimatorHandle {
    this.finishCallback = callback;
    return this;
  }

  /**
   * custom transition onFinish callback
   * define translate/scale/opacity setting after ending state
   * @param callback
   * @returns
   */
  onFinish(callback: AnimatorCallback): HMAnimatorHandle {
    this.onFinishCallback = callback;
    return this;
  }

  doStart(): void | undefined {
    return this.startCallback?.(this.translateOption!, this.scaleOption!, this.opacityOption!);
  }

  doFinish(): void | undefined {
    return this.finishCallback?.(this.translateOption!, this.scaleOption!, this.opacityOption!);
  }

  doOnFinish(): void | undefined {
    return this.onFinishCallback?.(this.translateOption!, this.scaleOption!, this.opacityOption!);
  }

  /**
   * custom transition of passive triggered start callback
   * @param callback
   * @returns
   */
  passiveStart(callback: AnimatorCallback): HMAnimatorHandle {
    this.passiveStartCallback = callback;
    return this;
  }

  /**
   * custom transition of passive triggered finish callback
   * @param callback
   * @returns
   */
  passiveFinish(callback: AnimatorCallback): HMAnimatorHandle {
    this.passiveFinishCallback = callback;
    return this;
  }

  /**
   * custom transition of passive triggered onFinish callback
   * @param callback
   * @returns
   */
  passiveOnFinish(callback: AnimatorCallback): HMAnimatorHandle {
    this.passiveOnFinishCallback = callback;
    return this;
  }

  doPassiveStart(): void | undefined {
    return this.passiveStartCallback?.(this.translateOption!, this.scaleOption!, this.opacityOption!);
  }

  doPassiveFinish(): void | undefined {
    return this.passiveFinishCallback?.(this.translateOption!, this.scaleOption!, this.opacityOption!);
  }

  doPassiveOnFinish(): void | undefined {
    return this.passiveOnFinishCallback?.(this.translateOption!, this.scaleOption!, this.opacityOption!);
  }

  /**
   * interactive transition of gesture triggered start callback
   * @param callback
   */
  actionStart(callback: (event: GestureEvent) => void) {
    this.actionStartCallback = callback;
  }

  doActionStart(event: GestureEvent) {
    this.actionStartCallback?.(event);
    if (event.fingerList[0]) {
      this.startOffset = event.fingerList[0].localX;
    }
    this.interactive = true;
  }

  /**
   * interactive transition of gesture triggered update progress callback
   * @param callback
   */
  updateProgress(callback: InteractiveCallback) {
    this.updateProgressCallback = callback;
  }

  doUpdateProgress(event: GestureEvent) {
    this.updateProgressCallback?.(event, this.proxy, this.operation, this.startOffset);
  }

  /**
   * interactive transition of gesture triggered end callback
   * @param callback
   */
  actionEnd(callback: InteractiveCallback) {
    this.actionEndCallback = callback;
  }

  doActionEnd(event: GestureEvent) {
    this.interactive = false;
    this.actionEndCallback?.(event, this.proxy, this.operation, this.startOffset);
  }

  recoverState() {
    this.proxy = undefined;
    this.operation = undefined;
    this.startOffset = undefined;
    this.interactive = false;
  }
}

export type AnimatorCallback = (translateOption: TranslateOption, scaleOption: ScaleOption,
  opacityOption: OpacityOption) => void | undefined;

type InteractiveCallback = (event: GestureEvent, proxy: NavigationTransitionProxy | undefined,
  operation: NavigationOperation | undefined, startOffset?: number) => void;