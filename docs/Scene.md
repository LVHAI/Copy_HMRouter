# 原生到原生页面跳转场景解决方案

## 一次开发多端部署

`HMRouter`是在`Navigation`上的封装，因此通过`HMNavigation`可以实现`Navigation`的分栏效果。
实现分栏效果，只需要在配置`HMNavigation`时，指定`modifier`的mode为`NavigationMode.Split`即可。
此时`HMNavigation`闭包中的内容为左分栏内容，传入pageUrl为默认右分栏内容。

```extendtypescript
@Component
export struct ShoppingBagContent {

  aboutToAppear(): void {
    modifier.attribute?.mode(NavigationMode.Split);
    modifier.attribute?.navBarWidth('50%');
  }

  build() {
    HMNavigation({
      navigationId: 'shoppingNavigation', options: {
        standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
        modifier: this.modifier
      }
    }) {
      ShoppingBagContentNavBar({ showTabsBtn: this.showTabsBtn })
    }
  }
}

class ShoppingNavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack);
    instance.navBarWidth('100%');
    instance.hideTitleBar(true);
    instance.hideToolBar(true);
  }
}

const modifier: ShoppingNavModifier = new ShoppingNavModifier();
```

### HMNavigation闭包内容监听页面生命周期

当前HMNavigation使用闭包，NavBar跳转到NavDestination页面时，没有自定义生命周期方式处理，可以通过`HMRouterMgr.getCurrentLifecycleOwner().addObserver`方法，添加到NavBar对应生命周期内。

```extendtypescript
@Component
export struct ShoppingBagContentNavBar {
  @Link showTabsBtn: boolean;

  aboutToAppear(): void {
    const lifecycleOwner = HMRouterMgr.getCurrentLifecycleOwner();
    lifecycleOwner?.addObserver?.(HMLifecycleState.onShown, (ctx): void => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onShown');
    })
    lifecycleOwner?.addObserver?.(HMLifecycleState.onHidden, (ctx): void => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onHidden');
    })
    lifecycleOwner?.addObserver?.(HMLifecycleState.onBackPressed, (ctx): boolean => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onBackPressed');
      return false;
    })
    lifecycleOwner?.addObserver?.(HMLifecycleState.onDisAppear, (ctx): void => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onDisAppear');
    })
  }

  build() {
    Row() {
      ShoppingBagView({ showTabsBtn: this.showTabsBtn })
      ShoppingBagDiscounts()
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.tab_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
```
**注意事项**：为了使NavBar通过addObserver注册的回调可以监听到@Entry页面生命周期触发，需要在Page页面中调用HMRouterMgr.generatePageLifecycleId和HMRouterMgr.getPageLifecycleById方法，采用如下述处理方式：  
在@Entry页面初始化时生成pageLifecycleId，在页面对应生命周期内，通过pageLifecycleId触发对应方法。
```extendtypescript
@Entry
@Component
struct Index {
  modifier: MyNavModifier = new MyNavModifier();
  routerState: router.RouterState = router.getState();
  private pageLifecycleId: string = HMRouterMgr.generatePageLifecycleId();

  onPageShow(): void {
    HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onShown();
  }

  onPageHide(): void {
    HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onHidden();
  }

  aboutToDisappear(): void {
    HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onDisAppear();
  }

  onBackPress(): boolean {
    return HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onBackPressed();
  }

  build() {
    Column() {
      HMNavigation({
        navigationId: 'mainNavigationId'
      }) {
        ShoppingBagContentNavBar()
      }
    }
    .height('100%')
    .width('100%')
  }
}
```

## 路由跳转及拦截跳转场景

### 带参的路由跳转\返回

带参的路由跳转\返回是路由中最常见的业务场景，及从pageA带参数跳转到pageB，在pageB获取到pageA的参数，当pageB返回pageA时，将返回值传递给pageA。
结合案例中实例场景：商品详情页的详情弹框，比如衣服选择尺码，选择后返回页面，商品信息跟随返回值变化。

HMRouter实现方案：
1. pageOne声明，通过`HMRouterMgr.push`方法指定跳转路由routerJumpWithParamPageTwo和需要传递的参数对象this.param，同时配置HMRouterPathCallback的onResult方法，接收返回的页面参数。

```extendtypescript
@HMRouter({ pageUrl: 'routerJumpWithParamPageOne' })
@Component
export struct PageOne {
  @State param: string = 'Hello World!'
  build() {
    Column() {
      Column() {
        Button('JumpWithParam')
          .onClick(() => {
            HMRouterMgr.push({ pageUrl: 'routerJumpWithParamPageTwo', param: this.param }, {
              onResult: (popInfo: HMPopInfo) => {
                console.info('==== JumpWithParam popInfo is :', JSON.stringify(popInfo))
              }
            })
          })
      }
    }
  }
}
```

2. pageTwo声明，通过`HMRouterMgr.getCurrentParam()`方法获取传入参数，当页面需要返回时，调用`HMRouterMgr.pop(info : HMRouterPathInfo)`方法返回，需要返回的参数对象this.backParam，返回后发起页面的onResult方法会被触发，业务可在此处进行返回值处理。

```extendtypescript
@HMRouter({ pageUrl: 'routerJumpWithParamPageTwo' })
@Component
export struct PageOne {
  @State backParam: number = 20
  build() {
    Column() {
      Column() {
        Button('getCurrentParam')
          .onClick(() => {
            let newParam = HMRouterMgr.getCurrentParam()
            console.info('==== The parameters of the current page are:',JSON.stringify(newParam))
          })
        Button('PopWithParam')
          .onClick(() => {
            HMRouterMgr.pop({ param: this.backParam })
          })
      }
    }
  }
}
```

### 多级路由跳转，指定页面返回，并携带参数

比如业务中支付的场景，当选择订单（状态待支付）进行支付后，页面跳转到支付页面，支付完成后到达支付成功页面，此时进行路由返回，我们期望是返回到订单页面，并将支付成功状态带回给订单页。注意这里不能返回支付页面，否则使用者无法确认是否需要接续进行支付。跳转路径为 itemListPage -> payPage -> paySuccessPage

```extendtypescript
@HMRouter({ pageUrl: 'itemListPage' })
@Component
export struct PageOne {
  @State param: string = 'Hello World!'
  build() {
    Column() {
      Button('pay')
        .onClick(() => {
          HMRouterMgr.push({ pageUrl: 'payPage', param: this.param }, {
            onResult: (popInfo: HMPopInfo) => {
              console.info('srcPage:'+popInfo.srcPageInfo.name)
            }
          })
        })
    }
  }
}

@HMRouter({ pageUrl: 'paySuccessPage' })
@Component
export struct PageThree {
  @State backParam: number = 20
  build() {
    Column() {
      Button('PopWithParam')
        .onClick(() => {
          HMRouterMgr.pop({ pageUrl: 'itemListPage', param: this.backParam })
        })
    }
  }
}
```

### 在弹窗页面跳转新页面，新页面返回后弹窗不关闭

弹窗隐私协议场景：隐私协议通过弹窗实现，点击具体隐私协议弹窗中的具体协议时，会跳转至协议页面，协议页面返回后隐私协议弹窗仍然存在。
为了实现弹窗不消失的业务场景，我们需要构建一个DIALOG类型的路由页面，通过将HMRouter标签的dialog字段配置成true，即可实现一个DIALOG类型的路由。

> 此类路由特点与DIALOG类型的NavDestinaion保持一致：默认透明，不影响其他NavDestination的生命周期。

```extendtypescript
@HMRouter({ pageUrl: 'privacyDialog', dialog: true })
@Component
export struct PrivacyDialogContent {
  
  build() {
    Column() {
      Button()
        .onClick(() => {
          HMRouterMgr.push({pageUrl: 'privacyItemPage'})
        })
    }
  }
}
```

### 页面返回确认弹窗

当在支付页面返回时，提示消费者支付未完成是否确认返回，如果消费者选择“是”则返回订单页面，否则停留在支付页面。
页面返回弹窗需要使用到拦截器，及从支付页面返回时，通过拦截器将路由跳转拦截，从而实现弹窗提示。

当拦截中需要进行拦截处理时，需要返回HMInterceptorAction.DO_REJECT，将当前此次跳转的拦截和路由动作停止。

1. 申明返回拦截器

由于需要弹窗并额外处理路由，因此此处需要返回HMInterceptorAction.DO_REJECT，终止当前路由动作。

```extendtypescript
@HMInterceptor({ interceptorName: 'backConfirmInterceptor' })
export class BackConfirmInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    let contentNode = new ComponentContent(info.context, wrapBuilder(buildBackConfirmDialog), new Params('abc', info.pathInfo, info.callback));
    info.context.getPromptAction().openCustomDialog(contentNode)
    return HMInterceptorAction.DO_REJECT
  }
}

@Builder
function buildBackConfirmDialog(params: Params) {
  BackConfirmDialog({param : params})
}

@Component
export struct BackConfirmDialog {
  @Require param : Params | null = null;
  build() {
    Column() {
      Text(this.param?.text)
      Row() {
        Button('CANCEL').onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(contentNode);
        })
        Button('BACK').onClick(() => {
          HMRouterMgr.pop(this.param?.pathInfo)
        })
      }
    }
  }
}
```

2. 将拦截器作用在支付页面上

```extendtypescript
@HMRouter({
  pageUrl: 'pagePage',
  interceptors: [
    'backConfirmInterceptor'
  ]
})
@Component
export struct payPage {
  build() {
    Column() {
      Column() {
        Button('back')
          .onClick(() => {
            HMRouterMgr.pop();
          })
      }
    }
  }
}
```

### 符合特定条件时，路由到指定页面

登录校验场景，如从商品详情跳转支付页面时，若未进行登录，则直接跳转到登录页面。
此场景也可以通过拦截器实现，需要在拦截器中判断具体状态已实现具体路由跳转，样例中通过info里面的context进行弹窗，并处理拦截弹窗。

> 此处由于在判断应用未登录时也需要进行路由栈的变化，因此返回HMInterceptorAction.DO_REJECT，停止当前此次跳转的拦截和路由动作。

```extendtypescript
@HMInterceptor({ interceptorName: 'loginInterceptor' })
export class loginInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    if(appStatus.getInstance().isLogin()) {
      return HMInterceptorAction.DO_NEXT
    } else {
      HMRouterMgr.push({pageUrl : 'loginPage'})
      return HMInterceptorAction.DO_REJECT
    }
  }
}
```

### 单例页面跳转

如视频播放场景中，常常会将视频播放页面配置为单例页面，这样就可以避免多个页面配置多个播放器。
对于单例页面，只需要配置HMRouter标签时，将singleton字段配置为true即可。

```extendtypescript
@HMRouter({ pageUrl: 'singletonVideoPage', singleton: true })
@Component
export struct SingletonVideoPage {
  build() {
    Column() {
    }
    .width('100%')
  }
}
```

### 嵌套路由

当存在路由嵌套的场景，HMNavigation嵌套HMNavigation的时候就会产生嵌套路由，当被嵌套的页面需要驱动主路由跳转时，需要在`HMRouterMgr.push({navigationId : 'mainNav', pageUrl : 'HomeContent'})`中指定navigationId进行跳转。
navigationId在声明HMNavigation时指定。

```extendtypescript
@Entry
@Component
struct Index {
  build() {
    Column() {
      HMNavigation({
        navigationId: 'mainNav', homePageUrl: 'HomeContent', options: {
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          modifier: this.modifier
        }
      })
    }
    .height('100%')
    .width('100%')
  }
}

@HMRouter({ pageUrl: 'shoppingBag' })
@Component
export struct ShoppingBagContent {
  
  build() {
    HMNavigation({
      navigationId: 'shoppingNavigation', options: {
        standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
        dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
        modifier: modifier
      }
    }) {
      Row() {
        ShoppingBagView()
        ShoppingBagDiscounts()
        Button('回首页')
          .onClick(()=>{
            HMRouterMgr.push({navigationId: 'mainNav', pageUrl: 'HomeContent'})
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor(ResourceUtil.getCommonBackgroundColor()[0])
    }
  }
}
```

## 生命周期配置使用场景

### 两次返回退出应用

首页退出应用时，第一次返回时提示“再次返回退出应用”，再次返回时应用真正退出

```extendtypescript
@HMLifecycle({ lifecycleName: 'ExitAppLifecycle' })
export class ExitAppLifecycle implements IHMLifecycle {
  lastTime: number = 0;

  onBackPressed(ctx: HMLifecycleContext): boolean {
    let time = new Date().getTime();
    if (time - this.lastTime > 1000) {
      this.lastTime = time;
      ctx.uiContext.getPromptAction().showToast({
        message: '再次返回退出应用',
        duration: 1000,
      });
      return true;
    } else {
      return false;
    }
  }
}

@HMRouter({ pageUrl: 'HomeContent', singleton: true, lifecycle: 'ExitAppLifecycle' })
@Component
export struct HomeContent {
  
}
```

### 页面打点

配置全局生命周期用于页面打点，计算耗时等统计分析

```extendtypescript
@HMLifecycle({ lifecycleName: 'PageDurationLifecycle' })
export class PageDurationLifecycle implements IHMLifecycle {
  private time: number = 0;

  onShown(ctx: HMLifecycleContext): void {
    this.time = new Date().getTime();
  }

  onHidden(ctx: HMLifecycleContext): void {
    const duration = new Date().getTime() - this.time;
    console.log(`Page ${ctx.navContext?.pathInfo.name} stay ${duration}`);
  }
}
```

### 生命周期内初始化组件参数

生命周期实例中可以初始化对象，并且在UI组件中获取做为状态变量

```extendtypescript
@HMLifecycle({lifecycleName: 'exampleLifecycle'})
export class ExampleLifecycle implements IHMLifecycle {
  model: ObservedModel = new ObservedModel();
}

@Observed
export class ObservedModel {
  isLoad: boolean = false;
  bizModel?: Data;
}

@HMRouter({pageUrl:'PageOne', lifecycle:'exampleLifecycle'})
@Component
struct PageOne {
  @State model: ObservedModel | null = (HMRouterMgr.getLifecycleOwner().getLifecycle() as ExampleLifecycle).model;
}
```

### 提前发起网络请求，获取接口数据

在onPrepare生命周期回调中提前发起网络请求，实现网络请求与页面跳转并行化，可以优化页面跳转的响应时延、完成时延

> 对比在aboutToAppear生命周期中发起网络请求，使用onPrepare进行预加载可以优化5-20ms

```extendtypescript
@HMLifecycle({lifecycleName : 'exampleLifecycle'})
export class ExampleLifecycle implements IHMLifecycle {
  model: ObservedModel = new ObservedModel();
  onPrepare(context: HMLifecycleContext): void {
    console.log('onPrepare')
    let task1: taskpool.Task =
      new taskpool.Task(networkRequest, 'https://example.com/request');
    taskpool.execute(task1).then((bizModel) => {
      this.model.bizModel = bizModel as Data;
    });
  }
}
@Concurrent
async function networkRequest(url: string): Promise<BizModel> {
  let body = rcp.getNetworkResponse();
  let model = new BizModel(body);
  return model;
}
@Sendable
export class BizModel {
  property: string;
}
@Observed
export class ObservedModel {
  isLoad: boolean = false;
  bizModel?: Data;
}
@Observed
export class Data {
  property?: string;
}
@HMRouter({ pageUrl: 'pageA' })
@Component
export struct PageA {
  build() {
    Column() {
      Button('push')
        .onClick(() => {
          HMRouterMgr.push({ pageUrl: 'pageB' })
        })
    }
  }
}
@HMRouter({ pageUrl: 'pageB', lifecycle: 'exampleLifecycle' })
@Component
export struct PageB {
  @State model: ObservedModel | null = (HMRouterMgr.getCurrentLifecycleOwner().getLifecycle() as ExampleLifecycle).model;
  build() {
    Text(`${this.model?.bizModel?.property}`)
  }
}
```

### 页面内容保存

在短视频评论场景中，当弹出评论页进行翻阅后停留在某处，此时关闭评论页再打开，评论内容会任然停留在上一次浏览的位置。


```extendtypescript
@Component
export struct CommentInput {
  commentRenderNode: CommentNodeController = new CommentNodeController()

  aboutToAppear(): void {
    this.commentRenderNode.makeNode(this.getUIContext())
    HMRouterMgr.getCurrentLifecycleOwner().addObserver(HMLifecycle.onDisAppear,()=>{
      this.commentRenderNode.dispose()
    })
  }

  build() {
  }

}
```

## 转场动画配置使用场景

### 全局自定义转场

在创建HMNavigation组件时，可以配置全局自定义转场效果，当前提供direction、scale、opacity供开发者配置

```extendtypescript
@Entry
@Component
struct Index {

  build() {
    Column() {
      HMNavigation({
        navigationId: 'mainNavigation', homePageUrl: 'HomeContent', options: {
          standardAnimator: new IHMAnimator.Effect({
            direction: IHMAnimator.Direction.RIGHT_TO_LEFT,
            opacity: { opacity: 0.4 }
          }),
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          modifier: this.modifier
        }
      })
    }
    .height('100%')
    .width('100%')
  }
}
```

### 特定页面支持交互式(跟手)转场

HMRouter提供了交互式(跟手)转场的接入，开发者可轻松实现交互式(跟手)转场效果。

```extendtypescript
@HMAnimator({ animatorName: 'liveInteractiveAnimator' })
export class LiveInteractiveAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption, scaleOption, opacity) => {
      translateOption.x = '100%'
      opacity.opacity = 0.4
    })
    enterHandle.finish((translateOption, scaleOption, opacity) => {
      translateOption.x = '0'
      opacity.opacity = 1
    })
    enterHandle.onFinish((translateOption, scaleOption, opacity) => {
      translateOption.x = '0'
      opacity.opacity = 1
    })

    exitHandle.start((translateOption, scaleOption, opacity) => {
      translateOption.x = '0'
      opacity.opacity = 1
    })
    exitHandle.finish((translateOption, scaleOption, opacity) => {
      translateOption.x = '100%'
      opacity.opacity = 0.4
    })
    exitHandle.onFinish((translateOption, scaleOption, opacity) => {
      translateOption.x = '0'
      opacity.opacity = 0.4
    })
  }

  interactive(handle: HMAnimatorHandle): void {
    handle.actionStart((event: GestureEvent) => {
      if (event.offsetX > 0) {
        HMRouterMgr.pop()
      }
    })
    handle.updateProgress((event, proxy, operation, startOffset) => {
      if (!proxy?.updateTransition || !startOffset) {
        return
      }
      let offset = event.fingerList[0].localX - startOffset;
      if (offset < 0) {
        proxy?.updateTransition(0)
        return;
      }
      let rectWidth = event.target.area.width as number
      let rate = offset / rectWidth
      proxy?.updateTransition(rate)
    })
    handle.actionEnd((event, proxy, operation, startOffset) => {
      if (!startOffset) {
        return
      }
      let rectWidth = event.target.area.width as number
      let rate = Math.abs(event.fingerList[0].localX - startOffset) / rectWidth
      if (rate > 0.4) {
        proxy?.finishTransition()
      } else {
        proxy?.cancelTransition?.()
      }
    })
  }
}

@HMRouter({ pageUrl: 'liveHome', singleton: true, animator: 'liveInteractiveAnimator' })
@Component
export struct LiveHome {
  
}
```

### 根据条件选择不同转场

相同的页面可能在不同表现情况下出现不同的转场效果，常见的有短视频播放时的评论页面弹出时的转场，当播放的是横屏视频时，弹出评论页面，视频是垂直上移；若播放的是竖屏视频，弹出评论页面时，视频是缩放上移；

开发者需要在进行路由跳转时，根据当前视频状态提供不同的转场自定义动画，通过push时的animator属性传入指定转场。

```extendtypescript
@HMRouter({ pageUrl: 'videoPlayPage' })
@Component
export struct VideoPlayPage {
  build() {
    Column() {
      // 通过push方法传入自定义动画，一次性生效。
      Button('评论')
        .width('80%')
        .height(40)
        .margin(10)
        .onClick(() => {
          if (isPortraitViedo()) {
            HMRouterMgr.push({ pageUrl: 'commentsPage', animator: new TranslateAnimator() })
          } else {
            HMRouterMgr.push({ pageUrl: 'commentsPage', animator: new ZoomAnimator() })
          }
        })
    }
  }
}
```

从上面一段代码可以看出，开发者需要自定义两种不同的转场效果，如果此转场动画未被其他组件使用，则可以不需要使用@HMAnimator声明，但是必须实现IHMAnimator接口。由于这里是对出厂动画进行自定义，因此需要实现exitHandle中的接口。

```extendtypescript
export class TranslateAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    exitHandle.start((translateOption: IHMAnimator.TranslateOption, scaleOption: IHMAnimator.ScaleOption,
      opacity: IHMAnimator.OpacityOption) => {
      translateOption.x = 0
      translateOption.y = 0
    })
    exitHandle.finish((translateOption: IHMAnimator.TranslateOption, scaleOption: IHMAnimator.ScaleOption,
      opacity: IHMAnimator.OpacityOption) => {
      translateOption.y = '50%'
      scaleOption.x = '50%'
      opacity.opacity = 0.5
    })
  }
}

export class ZoomAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    // ...
  }
}
```

### 特定页面自定义转场

页面中指定animatorName

```extendtypescript
@HMAnimator({ animatorName: 'liveCommentsAnimator' })
export class liveCommentsAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    // 入场动画
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '100%'
    })
    enterHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '0'
    })
    enterHandle.duration = 500

    // 出场动画
    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '0'
    })
    exitHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '100%'
    })
    exitHandle.duration = 500
  }
}

@HMRouter({ pageUrl: 'liveComments', dialog: true, animator: 'liveCommentsAnimator' })
@Component
export struct LiveComments {
}
```

## 混淆使用场景
当前模块混淆配置为true，编译release包的时候，会开启混淆
``` json
  "buildOptionSet": [
    {
      "name": "release",
      "arkOptions": {
        "obfuscation": {
          "ruleOptions": {
            "enable": true,
            "files": [
              "./obfuscation-rules.txt"
            ]
          }
        }
      }
    },
  ],
```
### 自动配置混淆白名单
在当前模块`hmrouter_config.json`中配置`autoObfuscation`为true，即可自动生成混淆白名单文件，并加入到混淆配置中
```json
{
  "autoObfuscation":true
}
```
### 手动配置混淆白名单
当前模块`hmrouter_config.json`中配置`autoObfuscation`为false，或者不配置，编译插件会自动生成`hmrouter_obfuscation_rules.txt`文件，根据该文件将混淆白名单配置到`obfuscation-rules.txt`中，即可手动配置混淆白名单。也可以根据[HMRouter配置混淆白名单](https://gitee.com/hadss/hmrouter/wikis/HMRouter%E6%B7%B7%E6%B7%86%E9%85%8D%E7%BD%AE)手动配置