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

@HMAnimator({ animatorName: 'DialogBottomToTopAnimator' })
export class DialogAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '100%'
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '0'
    });

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '0'
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '100%'
    })
  }
}

@HMRouter({ pageUrl: 'har://DialogMaskCaseTwo', dialog: true, animator: 'DialogBottomToTopAnimator' })
@Component
export struct DialogMaskCaseTwo {
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
    .width('100%')
    .height('70%')
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .borderRadius({ topLeft: 20, topRight: 20 })
  }
}