import {
  HMInterceptor,
  HMInterceptorAction,
  HMInterceptorInfo,
  HMRouter,
  HMRouterMgr,
  IHMInterceptor
} from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'

@HMInterceptor({ interceptorName: 'UpdateParamInterceptor' })
export class UpdateParamInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    info.context.getPromptAction().showToast({ message: '页面跳转传递的参数：' + info.routerPathInfo.param })
    info.routerPathInfo.param = '456456456'
    return HMInterceptorAction.DO_NEXT
  }
}

@HMRouter({ pageUrl: PageConstants.INTERCEPTOR_UPDATE_PARAM, interceptors: ['UpdateParamInterceptor'] })
@Component
export struct InterceptorUpdateParam {
  build() {
    Column() {
      Text('页面参数：' + HMRouterMgr.getCurrentParam())
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
  }
}
