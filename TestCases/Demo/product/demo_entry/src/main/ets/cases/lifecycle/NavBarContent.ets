import { HMLifecycleState, HMRouterMgr } from '@hadss/hmrouter';
import { PageConstants } from '../../constants/PageConstants';

@Component
export struct NavBarContent {
  private navigationId: string = ''

  aboutToAppear(): void {
    const owner = HMRouterMgr.getCurrentLifecycleOwner();
    owner?.addObserver(HMLifecycleState.onShown, (ctx) => {
      ctx.uiContext.getPromptAction().showToast({
        message: HMLifecycleState.onShown
      })
    })
    owner?.addObserver(HMLifecycleState.onHidden, (ctx) => {
      ctx.uiContext.getPromptAction().showToast({
        message: HMLifecycleState.onHidden
      })

    })
    owner?.addObserver(HMLifecycleState.onBackPressed, (ctx) => {
      ctx.uiContext.getPromptAction().showToast({
        message: HMLifecycleState.onBackPressed
      })
      return false;
    })
    owner?.addObserver(HMLifecycleState.onDisAppear, (ctx) => {
      ctx.uiContext.getPromptAction().showToast({
        message: HMLifecycleState.onDisAppear
      })
    })
  }

  build() {
    Column() {
      Text('子NavBar显示内容')
        .fontSize(20)
      Button('子NavBar跳转下一页')
        .width('90%')
        .onClick(() => {
          HMRouterMgr.push({
            navigationId: this.navigationId,
            pageUrl: PageConstants.PAGE_A
          })
        })
    }
  }
}