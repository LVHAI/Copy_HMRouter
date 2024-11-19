import { HMRouter, HMRouterMgr, HMRouterPathInfo } from '@hadss/hmrouter';
import { PageConstants } from '../../constants/PageConstants';

@HMRouter({ pageUrl: PageConstants.LOGIN_PAGE })
@ComponentV2
export struct LoginPage {
  @Local username: string = ''
  @Local password: string = ''

  build() {
    Column({ space: 8 }) {
      TextInput({ text: $$this.username, placeholder: '请输入用户名' }).type(InputType.USER_NAME).id('username')
      TextInput({ text: $$this.password, placeholder: '请输入密码' }).type(InputType.NEW_PASSWORD).id('password')
      Button('登录', { type: ButtonType.Capsule }).width('100%').onClick(() => {
        if (!this.username) {
          this.getUIContext().getPromptAction().showToast({ message: '请输入用户名' })
          focusControl.requestFocus('username')
          return
        }
        if (!this.username) {
          this.getUIContext().getPromptAction().showToast({ message: '请输入密码' })
          focusControl.requestFocus('password')
          return
        }
        AppStorage.set('isLogin', true)

        // 注意这里跳转需要使用replace,否则用户还能会到登录页面
        HMRouterMgr.replace(HMRouterMgr.getCurrentParam() as HMRouterPathInfo)
      })
    }.justifyContent(FlexAlign.Center).width('100%').height('100%').padding({ left: 8, right: 8 })
  }
}