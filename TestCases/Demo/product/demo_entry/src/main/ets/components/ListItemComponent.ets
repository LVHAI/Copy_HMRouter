import { HMRouterMgr, HMRouterPathCallback, HMRouterPathInfo } from '@hadss/hmrouter'

@ComponentV2
export struct MainPageListItemComponent {
  @Param @Require pathInfo: HMRouterPathInfo
  @Param callback: HMRouterPathCallback = {}
  @Param @Require description: string

  build() {
    Column({ space: 4 }) {
      Text(this.description).fontSize(14).fontColor('#adb5bd')
      Button('push to: ' + this.pathInfo.pageUrl,
        { controlSize: ControlSize.SMALL, buttonStyle: ButtonStyleMode.TEXTUAL })
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          HMRouterMgr.push(this.pathInfo, this.callback)
        })
    }.alignItems(HorizontalAlign.Start).width('100%').padding({ left: 8, right: 8 })
  }
}