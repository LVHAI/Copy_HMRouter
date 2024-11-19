import {
  HMAnimator,
  HMAnimatorHandle,
  HMRouter,
  HMRouterMgr,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';

@HMAnimator({ animatorName: 'DialogOpacityAnimator' })
export class DialogAnimator implements IHMAnimator {
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
    })
  }
}

@HMRouter({ pageUrl: 'har://DialogMaskCaseOne', dialog: true, animator: 'DialogOpacityAnimator' })
@Component
export struct DialogMaskCaseOne {
  build() {
    Column() {
      Button('关闭弹窗')
        .width('90%')
        .onClick(() => {
          HMRouterMgr.pop()
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('50%')
    .height('50%')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .position({ x: '50%', y: '50%' })
    .markAnchor({ x: '50%', y: '50%' })
  }
}