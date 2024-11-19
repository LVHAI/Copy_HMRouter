import { HMRouter } from '@hadss/hmrouter';
import { PageConstants } from './constants/PageConstants';

@HMRouter({ pageUrl: "aaa" })
@Component
export struct MainPage {
  build() {
    Column() {
      Text('开发者场景案例').width('100%').fontSize(32).textAlign(TextAlign.Center).margin({ bottom: 16 })
    }.width('100%').height('100%')
  }
}

@HMRouter({ pageUrl: "bbb" })
@Component
export struct MainPage {
  build() {
    Column() {
      Text('开发者场景案例').width('100%').fontSize(32).textAlign(TextAlign.Center).margin({ bottom: 16 })
    }.width('100%').height('100%')
  }
}