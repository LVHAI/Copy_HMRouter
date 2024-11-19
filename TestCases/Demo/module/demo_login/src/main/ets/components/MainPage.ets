import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { FadeAnimator } from '../animator/ZoomAnimator2';

@HMRouter({ pageUrl: 'test://loginMainPage' })
@Component
export struct MainPage {
  @State message: string = 'login Har MainPage';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button('LoginContent').onClick(() => {
          HMRouterMgr.push({ pageUrl: 'test://loginContent' })
        })
        Button('pop').onClick(() => {
          HMRouterMgr.pop({ animator: new FadeAnimator() })
        })
      }
      .width('100%')
    }.backgroundColor(Color.Pink).height('100%')
  }
}
