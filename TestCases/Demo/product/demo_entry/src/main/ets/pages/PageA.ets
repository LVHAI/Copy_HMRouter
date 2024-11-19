import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { PageConstants } from '../constants/PageConstants';

@HMRouter({ pageUrl: PageConstants.PAGE_A })
@ComponentV2
export struct PageA {
  message: string = 'PageA'

  build() {
    Column() {
      Text(this.message).fontSize(50)
      Button('push to PageB').onClick(() => {
        HMRouterMgr.push({ pageUrl: PageConstants.PAGE_B }, {
          onResult: (popInfo) => {
            this.getUIContext().getPromptAction().showToast({ message: popInfo.result as string })
          }
        })
      })
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}