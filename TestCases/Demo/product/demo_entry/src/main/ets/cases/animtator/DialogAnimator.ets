import { HMAnimator, HMAnimatorHandle, IHMAnimator, OpacityOption, ScaleOption, TranslateOption } from '@hadss/hmrouter'

/**
 * 透明度动画
 */
@HMAnimator({ animatorName: 'dialogAnimator' })
export class scaleAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 0;
      scaleOption.x = 0.5;
      scaleOption.y = 0.5;
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 1;
      scaleOption.x = 1;
      scaleOption.y = 1;
    });
    enterHandle.duration = 300;
    enterHandle.timeout = 300; // timeout 需要大于等于 duration

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 1;
      scaleOption.x = 1;
      scaleOption.y = 1;
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 0;
      scaleOption.x = 0.5;
      scaleOption.y = 0.5;
    });
    exitHandle.duration = 300;
    exitHandle.timeout = 300; // timeout 需要大于等于 duration
  }
}