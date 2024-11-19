import { HMRouter } from '@hadss/hmrouter';

@HMRouter({ pageUrl: "test://mineMainPage" })
@Component
export struct MainPage {
  @State message: string = 'mine Har MainPage';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
