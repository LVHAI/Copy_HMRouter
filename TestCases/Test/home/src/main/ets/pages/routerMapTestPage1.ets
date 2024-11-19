@Builder
export function pageOneBuilder(name: string, param: Object) {
  RouterMapTestPage1();
}

@Component
export struct RouterMapTestPage1 {
  @State message: string = 'routerMapTestPage1';

  build() {
    NavDestination() {
      Row() {
        Column({space: 8}) {
          Text(this.message)
            .fontSize(50)
            .fontWeight(FontWeight.Bold);
        }
        .width('100%');
      }
      .height('100%');
    };
  }
}