import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { ZoomAnimator } from '../animators/ZoomAnimator';
import PageConstants from '../constants/PageConstants';

@HMRouter({ pageUrl: PageConstants.TEST_PAGE_ONE })
@Component
export struct Index {
  @State message: string = 'MainPage';
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    Row() {
      Column({ space: 8 }) {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold);
        Button('Login').onClick(() => {
          HMRouterMgr.push({ pageUrl: 'test://loginMainPage' });
        });
        Button('Mine').onClick(() => {
          HMRouterMgr.push({ pageUrl: 'test://mineMainPage' });
        });

        Button('#IAQCCF').onClick(() => {
          HMRouterMgr.push({ pageUrl: 'test://loginMainPage', animator: new ZoomAnimator() });
        });

        Button('pageOne').onClick(() => {
          this.pageInfos.pushPath({ name: 'pageOne' });
        });

        Button('pageTwo').onClick(() => {
          this.pageInfos.pushPath({ name: 'pageTwo' });
        });

        Navigation(this.pageInfos)
          .width('100%').layoutWeight(1).border({ width: 1 });
      }
      .width('100%');
    }
    .height('100%');
  }
}