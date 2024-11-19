import { HMLifecycle, HMLifecycleContext, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { PageConstants } from '../../constants/PageConstants';

@HMLifecycle({ lifecycleName: 'CasesLifecycle' })
@ObservedV2
export class CasesLifecycle implements IHMLifecycle {
  @Trace isRequestFinished: boolean = false

  onPrepare(ctx: HMLifecycleContext): void {
    setTimeout(() => {
      ctx.uiContext.getPromptAction().showToast({ message: '数据请求成功' })
      this.isRequestFinished = true
    }, 5000)
  }
}

@HMRouter({ pageUrl: PageConstants.LIFECYCLE_CASES, lifecycle: 'CasesLifecycle' })
@ComponentV2
export struct LifecycleCases {
  @Local viewModel: CasesLifecycle = HMRouterMgr.getCurrentLifecycleOwner()?.getLifecycle() as CasesLifecycle

  build() {
    Stack() {
      Column() {
        Button('popToHomePage').onClick(() => {
          HMRouterMgr.pop()
        })
      }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')

      if (!this.viewModel.isRequestFinished) {
        Column() {
          Column() {
            LoadingProgress().width(40).height(40)
            Text('玩命加载中...')
          }
          .width(100)
          .height(100)
          .backgroundColor(Color.White)
          .borderRadius(5)
          .justifyContent(FlexAlign.Center)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height('100%')
        .backgroundColor('#30000000')
        .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
      }
    }
  }
}