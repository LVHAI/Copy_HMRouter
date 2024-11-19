import {
  HMAnimator,
  HMAnimatorHandle,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';

@HMAnimator({ animatorName: 'ZoomAnimator' })
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

    exitHandle.passiveStart((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 1;
      scaleOption.y = 1;
    }).passiveFinish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 0.7;
      scaleOption.y = 0.7;
    }).passiveOnFinish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      scaleOption.x = 1;
      scaleOption.y = 1;
    });
  }
}