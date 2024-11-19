# HMRouter简介

HMRouter作为HarmonyOS的页面跳转场景解决方案，聚焦解决应用内原生页面的跳转逻辑。

HMRouter底层对系统Navigation进行封装，集成了Navigation、NavDestination、NavPathStack的系统能力，提供了可复用的路由拦截、页面生命周期、自定义转场动画，并且在跳转传参、额外的生命周期、服务型路由方面对系统能力进行了扩展。

目的是让开发者在开发过程中无需关注Navigation、NavDestination容器组件的相关细节及模板代码，屏蔽跳转时的判断逻辑，降低拦截器、自定义转场动画实现复杂度，更好的进行模块间解耦。

# 特性

- 基于注解声明路由信息
- 注解中页面路径支持使用字符串常量定义
- 支持Har、Hsp、Hap
- 支持Navigation路由栈嵌套
- 支持服务型路由
- 支持路由拦截器（包含全局拦截、单页面拦截、跳转时一次性拦截）
- 支持生命周期回调（包含全局生命周期、单页面生命周期、跳转时一次性生命周期、NavBar生命周期）
- 内置转场动画（页面、Dialog），可配置方向、透明度、缩放，支持交互式转场动画，同时支持配置某个页面的转场动画、跳转时的一次性动画
- 支持Dialog类型页面、支持单例页面
- 支持混淆自动配置
- 支持自定义模版

# 依赖版本

HarmonyOS NEXT Developer Beta5及以上

> 手机版本：NEXT.0.0.60及以上

# 下载安装

使用ohpm安装依赖

```shell
ohpm install @hadss/hmrouter
```

或者按需在模块中配置运行时依赖，修改`oh-package.json5`

```json5
{
  "dependencies": {
    "@hadss/hmrouter": "^1.0.0-rc.6"
  }
}
```

# 使用配置

## 编译插件配置

1.修改项目的`hvigor/hvigor-config.json`文件，加入路由编译插件

```json5
{
  "dependencies": {
    "@hadss/hmrouter-plugin": "^1.0.0-rc.7"
    // 使用npm仓版本号
  },
  // ...其他配置
}
```

2.在模块中引入路由编译插件，修改`hvigorfile.ts`

```typescript
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { hapPlugin } from '@hadss/hmrouter-plugin';

export default {
  system: hapTasks,
  plugins: [hapPlugin()] // 使用HMRouter标签的模块均需要配置，与模块类型保持一致
}
```

> 如果模块是Har则使用`harPlugin()`, 模块是Hsp则使用`hspPlugin()`

3.在项目根目录创建路由编译插件配置文件`hmrouter_config.json`（可选）

```json5
{
  // 如果不配置则扫描src/main/ets/**目录，对代码进行全量扫描，如果配置则数组不能为空，建议配置指定目录可缩短编译耗时
  "scanDir": [
    "src/main/ets/components/**",
    "src/main/ets/interceptors/**"
  ],
  // 默认为false，调试排除错误时可以改成true，不删除编译产物
  "saveGeneratedFile": false,
  // 默认为false，不自动配置混淆规则，只会生成hmrouter_obfuscation_rules.txt文件帮助开发者配置混淆文件；如果设置为true，会自动配置混淆规则，并删除hmrouter_obfuscation_rules.txt文件
  "autoObfuscation": false,
  // 默认模板文件，不配置时使用插件内置模板
  "defaultPageTemplate": "./templates/defaultTemplate.ejs",
  // 特殊页面模版文件，匹配原则支持文件通配符
  "customPageTemplate": [
    {
      "srcPath": ["**/component/Home/**/*.ets"],
      "templatePath": "templates/home_shopping_template.ejs"
    },
    {
      "srcPath": ["**/common/**/*.ets"],
      "templatePath": "templates/common_template.ejs"
    },
    {
      "srcPath": ["**/live/**/*.ets"],
      "templatePath": "templates/live_template.ejs"
    }
  ]  
}
```

> 配置文件读取规则为 模块 > 工程 > 默认
> 优先使用本模块内的配置，如果没有配置，则找模块目录的上级目录(最多找三层目录，找到则停止)，若找不到则使用默认配置

## 工程配置

由于拦截器、生命周期和自定义转场动画会在运行时动态创建实例，因此需要进行如下配置，使得HMRouter路由框架可以动态导入项目中的模块

1.在工程目录下的`build-profile.json5`中，配置`useNormalizedOHMUrl`属性为true

```json5
{
  "app": {
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "5.0.0(12)",
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "useNormalizedOHMUrl": true
          }
        }
      }
    ],
    // ...其他配置
  }
}
```

2.在`oh-package.json5`中配置对Har和Hsp的依赖，这里需要注意**依赖的模块名称需要与模块的moduleName保持一致**。

详见官网文档：[动态import实现方案介绍](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-dynamic-import-V5#动态import实现方案介绍)
中的**备注**部分

```json5
{
  "dependencies": {
    "AppHar": "file:../AppHar",
    // AppHar库可以正确动态创建拦截器、生命周期和自定义转场动画对象
    "@app/har": "file:../AppHar"
    // 错误使用方式，无法动态创建对象
  }
}
```

# 快速开始

## 在UIAbility或者启动框架AppStartup中初始化路由框架

```extendtypescript
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HMRouterMgr.init({
      context: this.context
    })
  }
}
```

使用启动框架请查看：[如何在启动框架中初始化HMRouter](https://gitee.com/hadss/hmrouter/wikis/如何在启动框架中初始化HMRouter)

## 定义路由入口

```extendtypescript
@Entry
@Component
export struct Index {
  modifier: NavModifier = new NavModifier();

  build() {
    // @Entry中需要再套一层容器组件,Column或者Stack
    Column(){
      // 使用HMNavigation容器
      HMNavigation({
        navigationId: 'mainNavigation', options: {
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          modifier: this.modifier
        }
      }) {
        Row() {
          HomeBar()
          HomeView()
        }
        .width('100%')
        .height('100%')
      }
    }
    .height('100%')
    .width('100%')
  }
}

class NavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack);
    instance.navBarWidth('100%');
    instance.hideTitleBar(true);
    instance.hideToolBar(true);
  }
}
```

## 定义拦截器

```extendtypescript
@HMInterceptor({ interceptorName: 'JumpInfoInterceptor', global: true })
export class JumpInfoInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    let connectionInfo: string = info.type === 'push' ? 'jump to' : 'back to';
    console.log(`${info.srcName} ${connectionInfo} ${info.targetName}`)
    return HMInterceptorAction.DO_NEXT;
  }
}
```

## 定义生命周期

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

## 自定义转场动画

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
```

## 路由跳转使用

定义页面PageB，绑定生命周期及自定义转场动画

```extendtypescript
@HMRouter({ pageUrl: 'pageB', lifecycle: 'pageLifecycle', animator: 'pageAnimator' })
@Component
export struct PageB {
  // 获取生命周期中定义的状态变量
  @State model: ObservedModel | null = (HMRouterMgr.getCurrentLifecycleOwner().getLifecycle() as PageLifecycle).model
  @State param: Object = HMRouterMgr.getCurrentParam()

  build() {
    Text(`${this.model?.property}`)
    Text(`${this.param?.msg}`)
  }
}
```

定义页面PageA，并执行路由跳转至PageB

```extendtypescript
const PAGE_URL: string = 'pageA'

@HMRouter({ pageUrl: PAGE_URL })
@Component
export struct PageA {

build() {
  Column() {
    Button('Push')
      .onClick(() => {
        HMRouterMgr.push({ pageUrl: 'pageB' })
        HMRouterMgr.request({ fromPage: 'PageA', toPage: 'PageB' })
      })
  }
}
}
```

## 服务路由使用

```extendtypescript
export class CustomService {
  @HMService({ serviceName: 'testConsole' })
  testConsole(): void {
    console.log('调用服务 testConsole')
  }

  @HMService({ serviceName: 'testFunWithReturn' })
  testFunWithReturn(param1: string, param2: string): string {
    return `调用服务 testFunWithReturn:${param1} ${param2}`
  }

  @HMService({ serviceName: 'testAsyncFun', singleton: true })
  async asyncFunction(): Promise<string> {
    return new Promise((resolve) => {
      resolve('调用异步服务 testAsyncFun')
    })
  }
}

@HMRouter({ pageUrl: 'test://MainPage' })
@Component
export struct Index {

build() {
  Row() {
    Column({ space: 8 }) {
      Button('service').onClick(() => {
        HMRouterMgr.request('testConsole')
        console.log(HMRouterMgr.request('testFunWithReturn', 'home', 'service').data)
        HMRouterMgr.request('testAsyncFun').data.then((res: string) => console.log(res))
      })
    }
    .width('100%')
  }
  .height('100%')
}
}
```

> 当前不支持同时和其他注解混用，也不支持静态方法

```extendtypescript
// 不支持类与类方法同时添加 @HM* 装饰器
@HMLifecycle({ serviceName: 'lifecycleName' })
export class CustomServiceErr1 {
  @HMService({ serviceName: 'testConsole' }) // 类已经添加 @HMLifecycle 装饰器，@HMService 无法识别
  testConsole(): void {
    console.log('调用服务 testConsole')
  }
}

// 不支持在静态方法上添加 @HMService 装饰器
export class CustomServiceErr2 {
  @HMService({ serviceName: 'testConsole' }) // 静态方法添加 @HMService 装饰器，调用时会报错
  static testConsole(): void {
    console.log('调用服务 testConsole')
  }
}
```

# 混淆配置说明

`@hadss/hmrouter-plugin(1.0.0-rc.6)`版本之后HMRouter支持混淆自动配置白名单

开发者在`build-profile.json5`中配置混淆选项enable为true(开启混淆)，如下所示，并且在当前模块`hmrouter_config.json`中配置`autoObfuscation`为true(默认为false)。HMRouter会自动生成HMRouter必须的白名单配置。将其保存在当前模块`hmrouter_obfuscation_rules.txt`文件中，并在编译阶段将该文件自动加入到混淆配置文件`files`列表中，实现混淆自动配置效果。

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

```json
{
  "saveGeneratedFile": true,
  "autoObfuscation":true
}
```

> 如果将`autoObfuscation`改为false，则只会生成混淆规则文件，但不会自动修改模块的混淆配置。
> 开发者需要自行将生成的混淆文件`hmrouter_obfuscation_rules.txt`文件加入到混淆配置文件`files`列表中。

HMRouter手动配置混淆请参考[HMRouter混淆配置](https://gitee.com/hadss/hmrouter/wikis/HMRouter%E6%B7%B7%E6%B7%86%E9%85%8D%E7%BD%AE)

# HMRouter标签的使用规则

## 路由标签@HMRouter

`@HMRouter(pageUrl, dialog, singleton, interceptors, lifecycle, animator)`
标签使用在自定义组件`struct`上，且该自定义组件需要添加`export`关键字

- pageUrl: string, 用来表示NavDestination，必填
  
  > 支持使用本文件或者本模块定义的常量，或者Class中定义的静态变量
- dialog: boolean, 是否是Dialog类型页面，非必填，默认为false
- singleton: boolean, 是否是单例页面，单例页面即表示在一个HMNavigation容器中，只有一个此页面，非必填，默认为false
- interceptors: string[], `@HMInterceptor`标记的拦截器名称列表，非必填
- lifecycle: string, `@HMLifecycle`标记的生命周期处理实例，非必填
- animator: string, `@HMAnimator`标记的自定义转场实例，非必填

示例：

```extendtypescript
// pageUrl配置支持常量，或者class的静态属性，仅在编译期起作用
@HMRouter({ pageUrl: 'pageOne', interceptors: ['LoginInterceptor'], lifecycle: 'pageLifecycle', animator: 'pageAnimator' })
@Component
export struct PageOne {
  
  build() {
  }
}

// constants.ets
export class Constants{
  static readonly PAGE: string = 'pageTwo'
}

@HMRouter({ pageUrl: Constants.PAGE})
@Component
export struct PageOne {

  build() {
  }
}
```

## 拦截器标签 @HMInterceptor

标记在实现了`IHMInterceptor`的对象上，声明此对象为一个拦截器

- interceptorName: string, 拦截器名称，必填
- priority: number, 拦截器优先级，数字越大优先级越高，非必填，默认为9；
- global: boolean, 是否为全局拦截器，当配置为true时，所有跳转均过此拦截器；默认为false，当为false时需要配置在@HMRouter的interceptors中才生效。

**执行时机：**

在路由栈发生变化前，转场动画发生前进行回调。

**拦截器执行顺序：**

1. 按照优先级顺序执行，不区分自定义或者全局拦截器，优先级相同时先执行@HMRouter中定义的自定义拦截器
2. 当优先级一致时，先执行srcPage>targetPage>global

> srcPage表示跳转发起页面。
>
> targetPage表示跳转结束时展示的页面。

示例：

```extendtypescript
@HMInterceptor({
  priority: 9,
  interceptorName: 'LoginInterceptor'
})
export class LoginInterceptor implements IHMInterceptor {
  handle(info: HMInterceptorInfo): HMInterceptorAction {
    if (isLogin) {
      // 跳转下一个拦截器处理
      return HMInterceptorAction.DO_NEXT;
    } else {
      HMRouterMgr.push({
        pageUrl: 'loginPage',
        param: { targetUrl: info.targetName },
        skipAllInterceptor: true
      })
      // 拦截结束，不再执行下一个拦截器，不再执行相关转场和路由栈操作
      return HMInterceptorAction.DO_REJECT;
    }
  }
}
```

## 生命周期标签 @HMLifecycle

`@HMLifecycle(lifecycleName, priority, global)`

标记在实现了IHMLifecycle的对象上，声明此对象为一个自定义生命周期处理器

- lifecycleName: string, 自定义生命周期处理器名称，必填
- priority: number, 生命周期优先级，数字越大优先级越高，非必填，默认为9；
- global: boolean, 是否为全局生命周期，当配置为true时，所有页面生命周期事件会转发到此对象；默认为false

**生命周期触发顺序：**

按照优先级顺序触发，不区分自定义或者全局生命周期，优先级相同时先执行@HMRouter中定义的自定义生命周期

示例：

```extendtypescript
@HMLifecycle({ lifecycleName: 'exampleLifecycle' })
export class ExampleLifecycle implements IHMLifecycle {
}
```

## 转场动画标签 @HMAnimator

标记在实现了IHMAnimator的对象上，声明此对象为一个自定义转场动画对象

- animatorName: string, 自定义动画名称，必填。

示例：

```extendtypescript
@HMAnimator({ animatorName: 'exampleAnimator' })
export class ExampleAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
  }
}
```

## 服务标签 @HMService

标记在类的方法上，声明此方法为一个服务

- serviceName: string，服务名称，必填。
- singleton: boolean，是否是单例，非必填，默认为false

示例：

```extendtypescript
export class ExampleClass {
  @HMService({ serviceName: 'ExampleService', singleton: true })
  exampleFun(params: string): void {
  }
}
```

# HMRouter接口和属性列表

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/docs/Reference.md)

# 编译插件使用说明

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/HMRouterPlugin/README.md)

# 自定义模板使用说明

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/docs/CustomTemplate.md)

# 原生到原生页面跳转场景解决方案

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/docs/Scene.md)

# FAQ

[查看详情](https://gitee.com/hadss/hmrouter/blob/master/docs/FAQ.md)

# 原理介绍

[查看详情](https://developer.huawei.com/consumer/cn/forum/topic/0207153170697988820?fid=0109140870620153026)

# 贡献代码

使用过程中发现任何问题都可以提 [issue](https://gitee.com/hadss/hmrouter/issues) ，当然，也非常欢迎发 [PR](https://gitee.com/hadss/hmrouter/pulls) 共建。

# 开源协议

本项目基于 [Apache License 2.0](https://gitee.com/hadss/hmrouter/blob/master/LICENSE) ，请自由地享受和参与开源。
