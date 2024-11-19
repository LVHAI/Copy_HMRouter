import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { PageConstants } from '../constants/PageConstants';

@HMRouter({ pageUrl: PageConstants.PAGE_C })
@ComponentV2
export struct PageA {
  message: string = 'PageC'

  build() {
    Column() {
      Text(this.message).fontSize(50)
      Button('push to PageD').onClick(() => {
        HMRouterMgr.push({ pageUrl: PageConstants.PAGE_D })
      })
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}