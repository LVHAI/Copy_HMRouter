import {
  HMAnimator,
  HMAnimatorHandle,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';

@HMAnimator({ animatorName: 'FadeAnimator' })
export class FadeAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 0
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 1
    });

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 1
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      opacityOption.opacity = 0
    });
  }
}