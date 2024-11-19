import { HMRouter } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'

@HMRouter({ pageUrl: PageConstants.ANIMATOR_CASES_INTERACTIVE_ANIMATOR, animator: 'interactiveAnimator' })
@Component
export struct InteractiveAnimatorPage {
  build() {
    Column() {
      Text('交互式转场动画，可以通过手势处理')
    }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
    .backgroundColor(Color.Red)
  }
}