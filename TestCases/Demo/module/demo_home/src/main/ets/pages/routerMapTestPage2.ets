@Builder
export function PageTwoBuilder(name: string, param: Object) {
  RouterMapTestPage2()
}

@Component
export struct RouterMapTestPage2 {
  @State message: string = 'routerMapTestPage2';

  build() {
    NavDestination() {
      Row() {
        Column({ space: 8 }) {
          Text(this.message)
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
      }
      .height('100%')
    }
  }
}