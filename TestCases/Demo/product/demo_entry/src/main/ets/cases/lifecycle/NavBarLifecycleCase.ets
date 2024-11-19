import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'
import { router } from '@kit.ArkUI'

@HMRouter({ pageUrl: PageConstants.NAVBAR_LIFECYCLE })
@Component
export struct AnimatorCases {
  build() {
    Column() {
      Button('NavBar所在Navigation嵌套NavDestination')
        .width('90%')
        .margin({ bottom: 20 })
        .onClick(() => {
          HMRouterMgr.push({
            pageUrl: PageConstants.NAVBAR_LIFECYCLE_IN_NST,
          })
        })
      Button('NavBar所在Navigation嵌套Page')
        .width('90%')
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'cases/lifecycle/NavBarLifecycleInPage'
          })
        })
    }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
  }
}