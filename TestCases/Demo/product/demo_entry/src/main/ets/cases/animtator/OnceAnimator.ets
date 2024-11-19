import { HMAnimatorHandle, IHMAnimator, OpacityOption, ScaleOption, TranslateOption } from '@hadss/hmrouter'

/**
 * 透明度动画
 */
export class OpacityAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 0;
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 1;
    });
    enterHandle.duration = 300;
    enterHandle.timeout = 300; // timeout 需要大于等于 duration

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 1;
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 0;
    });
    exitHandle.duration = 300;
    exitHandle.timeout = 300; // timeout 需要大于等于 duration
  }
}