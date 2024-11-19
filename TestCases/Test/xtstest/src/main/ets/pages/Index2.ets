@Entry
@Component
struct Index2 {
  @State message: string = 'Index2';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Index2HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}