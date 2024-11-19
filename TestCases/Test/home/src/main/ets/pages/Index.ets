import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';

@HMRouter({pageUrl: 'test://MainPage'})
@Component
export struct Index {
  @State message: string = 'MainPage';
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    Row() {
      Column({space: 8}) {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold);
        Button('Login').onClick(() => {
          HMRouterMgr.push({pageUrl: 'test://loginMainPage'});
        });
        Button('Mine').onClick(() => {
          HMRouterMgr.push({pageUrl: 'test://mineMainPage'});
        });

        Button('pageOne').onClick(() => {
          this.pageInfos.pushPath({name: 'pageOne'});
        });

        Button('pageTwo').onClick(() => {
          this.pageInfos.pushPath({name: 'pageTwo'});
        });

        Button('service').onClick(() => {
          console.log(HMRouterMgr.request('testFunWithReturn', 'home', 'service').data);
        });

        Navigation(this.pageInfos)
          .width('100%').layoutWeight(1).border({width: 1});
      }
      .width('100%');
    }
    .height('100%');
  }
}