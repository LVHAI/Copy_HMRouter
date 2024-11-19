import { HMLifecycleState, HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'

@HMRouter({ pageUrl: PageConstants.ADD_OBSERVER_CASES })
@ComponentV2
export struct AddObserverCases {
  @Local backPressCount: number = 0

  aboutToAppear(): void {
    HMRouterMgr.getCurrentLifecycleOwner()?.addObserver(HMLifecycleState.onBackPressed, () => {
      this.showToast()
      this.backPressCount++
      return true
    })
  }

  // 组件内定义的方法
  showToast() {
    this.getUIContext().getPromptAction().showToast({ message: '组件内定义的弹窗方法' })
  }

  build() {
    Column({ space: 8 }) {
      Text('展示组件内方法拿到生命周期中调用').fontSize(20)
      Text('返回试试').fontSize(24)
      Text('返回次数' + this.backPressCount).fontSize(24)
      Button('pop to main page').onClick(() => {
        HMRouterMgr.pop({ pageUrl: PageConstants.MAIN_PAGE })
      })
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}