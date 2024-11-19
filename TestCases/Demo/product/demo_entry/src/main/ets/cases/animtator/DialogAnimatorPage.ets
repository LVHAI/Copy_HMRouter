import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'
import { OpacityAnimator } from './OnceAnimator'

@HMRouter({ pageUrl: PageConstants.ANIMATOR_CASES_DIALOG_ANIMATOR, animator: 'dialogAnimator', dialog: true })
@Component
export struct DialogAnimatorPage {
  build() {
    Column() {
      Button('关闭弹窗')
        .width('90%')
        .onClick(() => {
          HMRouterMgr.pop()
        })
    }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('50%').height('50%')
    .position({
      x: '50%',
      y: '50%'
    })
    .markAnchor({
      x: '50%',
      y: '50%'
    })
    .backgroundColor(Color.Red)
  }
}