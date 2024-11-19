import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';

@HMRouter({pageUrl: 'test://loginMainPage'})
@Component
export struct MainPage {
  @State message: string = 'login Har MainPage';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold);
        Button('LoginContent').onClick(() => {
          HMRouterMgr.push({pageUrl: 'test://loginContent'});
        });
      }
      .width('100%');
    }
    .height('100%');
  }
}
