import { HMLifecycle, HMLifecycleContext, HMRouter, IHMLifecycle } from '@hadss/hmrouter';
import { PageConstants } from '../../constants/PageConstants';

@HMLifecycle({ lifecycleName: 'BackPressLifecycle' })
export class BackPressLifecycle implements IHMLifecycle {
  private lastTime: number = 0

  onBackPressed(ctx: HMLifecycleContext): boolean {
    let time = Date.now()
    if (time - this.lastTime > 1000) {
      ctx.uiContext.getPromptAction().showToast({ message: '再次返回退出页面', duration: 1000 })
      this.lastTime = time
      return true
    } else {
      return false
    }
  }
}

@HMRouter({ pageUrl: PageConstants.BACK_PRESSED_CASES, lifecycle: 'BackPressLifecycle' })
@ComponentV2
export struct BackPressCases {
  build() {
    Column() {
      Text('当前页面需要两次返回才能退出').fontSize(28)
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}