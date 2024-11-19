import { HMRouter, HMRouterPathCallback, HMRouterPathInfo } from '@hadss/hmrouter';
import { PageConstants } from '../constants/PageConstants';
import { MainPageListItemComponent } from '../components/ListItemComponent';

interface MainPageListItem {
  pathInfo: HMRouterPathInfo
  callback?: HMRouterPathCallback
  description: string
}

@HMRouter({ pageUrl: PageConstants.MAIN_PAGE })
@Component
export struct MainPage {
  @StorageLink('isLogin') isLogin: boolean = false
  @State pageList: MainPageListItem[] = [{
    pathInfo: { pageUrl: PageConstants.PAGE_A },
    description: '本案例演示页面多次跳转后，返回指定页面时携带参数场景'
  }, {
    pathInfo: { pageUrl: PageConstants.INTERCEPTOR_CASES },
    description: '本案例演示使用HMInterceptor拦截器拦截页面跳转，并重定向到登录页面'
  }, {
    pathInfo: { pageUrl: PageConstants.INTERCEPTOR_UPDATE_PARAM, param: '123123123' },
    description: '本案例演示使用HMInterceptor拦截器修改页面传递的参数'
  }, {
    pathInfo: { pageUrl: PageConstants.LIFECYCLE_CASES },
    description: '本案例演示使用HMLifecycle生命周期获取提前请求页面参数并与页面UI关联'
  }, {
    pathInfo: { pageUrl: PageConstants.BACK_PRESSED_CASES },
    description: '本案例演示使用HMLifecycle生命周期拦截页面返回，两次返回退出页面场景'
  }, {
    pathInfo: { pageUrl: PageConstants.ADD_OBSERVER_CASES },
    description: '本案例演示使用addObserver注册生命周期，并调用页面方法'
  }, {
    pathInfo: { pageUrl: PageConstants.NAVBAR_LIFECYCLE },
    description: '本案例演示navbar内容使用addObserver注册生命周期，并调用页面方法'
  }, {
    pathInfo: { pageUrl: PageConstants.ANIMATOR_CASES },
    description: '本案例演示使用HMAnimator设置页面转场动画'
  }, {
    pathInfo: { pageUrl: 'test://HspMainPage' },
    description: '本案例演示跳转到Hsp模块的页面'
  }, {
    pathInfo: { pageUrl: PageConstants.MAP_CASE },
    description: '本案例演示地图使用'
  }, {
    pathInfo: { pageUrl: PageConstants.LIST_CASE },
    description: '本案例演示页面中存在列表时，绑定手势动画的场景'
  }, {
    pathInfo: { pageUrl: 'har://DialogMaskCaseOne' },
    description: '本案例演示使用自定义模板定义带蒙层的弹窗页面实现缩放弹出效果'
  }, {
    pathInfo: { pageUrl: 'har://DialogMaskCaseTwo' },
    description: '本案例演示使用自定义模板定义带蒙层的弹窗页面实现底部弹出效果'
  }]

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