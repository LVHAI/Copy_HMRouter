import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'
import { OpacityAnimator } from './OnceAnimator'

@HMRouter({ pageUrl: PageConstants.ANIMATOR_CASES_ONCE_ANIMATOR })
@Component
export struct OnceAnimatorPage {
  build() {
    Column() {
      Button('一次性动画 pop')
        .width('90%')
        .onClick(() => {
          HMRouterMgr.pop({
            animator: new OpacityAnimator()
          })
        })
    }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
    .backgroundColor(Color.Red)
  }
}