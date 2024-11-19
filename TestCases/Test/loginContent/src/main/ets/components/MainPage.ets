import { HMRouter } from '@hadss/hmrouter';

@HMRouter({pageUrl: 'test://loginContent'})
@Component
export struct MainPage {
  @State message: string = 'har in har loginContent';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold);
      }
      .width('100%');
    }
    .height('100%');
  }
}
