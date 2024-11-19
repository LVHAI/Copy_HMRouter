import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { PageConstants } from '../constants/PageConstants';

@HMRouter({ pageUrl: PageConstants.PAGE_B })
@ComponentV2
export struct PageA {
  message: string = 'PageB'

  build() {
    Column() {
      Text(this.message).fontSize(50)
      Button('push to PageC').onClick(() => {
        HMRouterMgr.push({ pageUrl: PageConstants.PAGE_C })
      })
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}