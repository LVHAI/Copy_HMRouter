import {
  HMInterceptor,
  HMInterceptorAction,
  HMInterceptorInfo,
  HMRouter,
  HMRouterMgr,
  IHMInterceptor
} from '@hadss/hmrouter';
import { PageConstants } from '../../constants/PageConstants';

@HMInterceptor({ interceptorName: 'LoginInterceptor' })
export class LoginInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    if (!AppStorage.get('isLogin')) {
      info.context.getPromptAction().showToast({ message: '请先登录' })
      HMRouterMgr.push({ pageUrl: PageConstants.LOGIN_PAGE, param: info.routerPathInfo })
      return HMInterceptorAction.DO_REJECT
    } else {
      return HMInterceptorAction.DO_NEXT
    }
  }
}

@HMRouter({ pageUrl: PageConstants.INTERCEPTOR_CASES, interceptors: ['LoginInterceptor'] })
@Component
export struct InterceptorCases {
  @StorageLink('isLogin') isLogin: boolean = false

  build() {
    Column() {
      Text('当前页面需要登录才能访问').fontSize(32)
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({ message: this.isLogin ? '已登录' : '未登录' })
        })
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
  }
}