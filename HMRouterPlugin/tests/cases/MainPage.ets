import { HMRouter, HMRouterPathCallback, HMRouterPathInfo } from '@hadss/hmrouter';
import { PageConstants } from './constants/PageConstants';
import { MainPageListItemComponent } from '../components/ListItemComponent';

@HMRouter({ pageUrl: PageConstants.MAIN_PAGE })
@Component
export struct MainPage {
  @StorageLink('isLogin') isLogin: boolean = false

  aboutToAppear(): void {
    AppStorage.setOrCreate('isLogin', false)
  }

  build() {
    Column() {
      Text('开发者场景案例').width('100%').fontSize(32).textAlign(TextAlign.Center).margin({ bottom: 16 })
      Text('当前登录状态：' + this.isLogin ? '已登录' : '未登录').width('100%').textAlign(TextAlign.Center)
      List({ space: 8 }) {
        ForEach(this.pageList, (item: MainPageListItem) => {
          ListItem() {
            MainPageListItemComponent({
              pathInfo: item.pathInfo,
              callback: item.callback!,
              description: item.description
            })
          }
        }, (item: MainPageListItem) => item.pathInfo.pageUrl)
      }.width('100%').height('100%').layoutWeight(1)
    }.width('100%').height('100%')
  }
}