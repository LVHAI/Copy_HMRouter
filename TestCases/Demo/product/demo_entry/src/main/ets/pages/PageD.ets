import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { PageConstants } from '../constants/PageConstants';

@HMRouter({ pageUrl: PageConstants.PAGE_D })
@ComponentV2
export struct PageA {
  message: string = 'PageD'

  build() {
    Column() {
      Text(this.message).fontSize(50)
      Button('pop to PageA').onClick(() => {
        HMRouterMgr.pop({ pageUrl: PageConstants.PAGE_A, param: 'this is PageD param' })
      })
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}