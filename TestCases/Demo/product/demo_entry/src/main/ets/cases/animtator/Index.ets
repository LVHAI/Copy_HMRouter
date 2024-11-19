import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'
import { OpacityAnimator } from './OnceAnimator'

@HMRouter({ pageUrl: PageConstants.ANIMATOR_CASES })
@Component
export struct AnimatorCases {
  build() {
    Column() {
      Button('一次性动画 push')
        .width('90%')
        .margin({ bottom: 20 })
        .onClick(() => {
          HMRouterMgr.push({
            pageUrl: PageConstants.ANIMATOR_CASES_ONCE_ANIMATOR,
            animator: new OpacityAnimator()
          })
        })
      Button('一次性动画 pop')
        .width('90%')
        .margin({ bottom: 20 })
        .onClick(() => {
          HMRouterMgr.pop({
            animator: new OpacityAnimator()
          })
        })
      Button('一次性动画 replace')
        .width('90%')
        .margin({ bottom: 20 })
        .onClick(() => {
          HMRouterMgr.replace({
            pageUrl: PageConstants.ANIMATOR_CASES_ONCE_ANIMATOR,
            animator: new OpacityAnimator()
          })
        })
      Button('交互式转场动画')
        .width('90%')
        .margin({ bottom: 20 })
        .onClick(() => {
          HMRouterMgr.push({
            pageUrl: PageConstants.ANIMATOR_CASES_INTERACTIVE_ANIMATOR,
          })
        })
      Button('Dialog动画')
        .width('90%')
        .onClick(() => {
          HMRouterMgr.push({
            pageUrl: PageConstants.ANIMATOR_CASES_DIALOG_ANIMATOR
          })
        })
    }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
  }
}