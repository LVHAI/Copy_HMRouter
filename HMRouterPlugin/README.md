## 编译插件配置

1.修改项目的`hvigor/hvigor-config.json`文件，加入路由编译插件

```json5
{
  "dependencies": {
    "@hadss/hmrouter-plugin": "^1.0.0-rc.7" // 使用npm仓版本号
  },
  // ...其他配置
}
```

2.在模块中引入路由编译插件，修改`hvigorfile.ts`

```typescript
import { hapTasks } from "@ohos/hvigor-ohos-plugin";
import { hapPlugin } from "@hadss/hmrouter-plugin";

export default {
    system: hapTasks,
    plugins: [hapPlugin()], // 使用HMRouter框架中标签的模块均需要配置，与模块类型保持一致
};
```

> 请使用与模块类型一致的插件方法，如果模块是 Har 则使用`harPlugin()`, 模块是 Hsp 则使用`hspPlugin()`

3.项目根目录或者模块目录创建路由编译插件配置文件`hmrouter_config.json`（推荐）

```json5
{
  // 如果不配置则扫描src/main/ets目录，对代码进行全量扫描，如果配置则数组不能为空，建议配置指定目录可缩短编译耗时
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
      "templatePath": "./templates/home_shopping_template.ejs"
    },
    {
      "srcPath": ["**/common/**/*.ets"],
      "templatePath": "./templates/common_template.ejs"
    },
    {
      "srcPath": ["**/live/**/*.ets"],
      "templatePath": "./templates/live_template.ejs"
    }
  ]
}
```

### hmrouter_config.json 配置

`hmrouter_config.json`文件用于配置该插件在编译期的行为

> 配置文件读取规则为 模块 > 工程 > 默认
> 优先使用本模块内的配置，如果没有配置，则找模块目录的上级目录(最多找三层目录，找到则停止)，若找不到则使用默认配置

> 1.0.0-rc.6 版本开始，支持混淆配置`autoObfuscation`
> 1.0.0-rc.7 版本开始，支持自定义模版配置`customPageTemplate`

| 配置项                 | 类型      | 是否必填 | 说明                                                                                                                                     |
|---------------------|---------|------|----------------------------------------------------------------------------------------------------------------------------------------|
| scanDir             | array   | 否    | 指定扫描当前模块路径，支持通配符，缺省值为`"src/main/ets/**"`                                                                                               |
| saveGeneratedFile   | boolean | 否    | 默认为 false，不保留插件自动生成的代码，如果需要保留，需要设置为 true                                                                                               |
| autoObfuscation     | boolean | 否    | 默认为 false，不自动配置混淆规则，只会生成`hmrouter_obfuscation_rules.txt`文件帮助开发者配置混淆规则；如果设置为 true，会自动配置混淆规则，并在编译完成后删除`hmrouter_obfuscation_rules.txt`文件 |
| defaultPageTemplate | string  | 否    | 默认模版路径，相对于hmrouter_config.json文件，例如：`./templates/defaultTemplate.ejs`                                                                  |
| customPageTemplate  | object  | 否    | srcPath为匹配的代码文件路径，支持通配符，templatePath为模版路径，可以实现不同的代码使用不同的模版来生成                                                                          |

## 自定义模板使用

在 `HMRouterPlugin` 中，EJS模板用于生成动态页面或组件，你可以在模板文件中使用 EJS 的语法

> EJS语法可阅读参考[官网链接](https://github.com/mde/ejs)

**模板文件示例：**

```ejs
import { <%= componentName %> } from '<%= importPath %>'

@Builder
export function <%= componentName %>Builder(name: string, param: Object) {
  <%= componentName %>Generated()
}

@Component
export struct <%= componentName %>Generated {
  private pageUrl: string = '<%= pageUrl %>'

  build() {
    NavDestination() {
      <%= componentName %>()
    }
    <% if(dialog){ %>.mode(NavDestinationMode.DIALOG)<% } %>
    .hideTitleBar(true)
  }
}
```

> 模板文件中至少需要包含`NavDestination`组件代码和相对应的`build`函数，缺少会导致编译失败或者页面白屏，插件中会内置一套默认模板，其中包含了**页面展示、生命周期注册、转场动画注册**

### 默认模板介绍

插件默认会根据如下模板来生成`NavDestination`页面代码，如有自定义模板的需求，建议先阅读内置模板的介绍在做更改，书写自定义模板时建议在内置模板基础上添加代码，删除内置模板相关代码可能会导致**编译失败、生命周期生效、转场动画失效等问题**。

**默认模版`viewBuilder.ejs`：**

```ejs
import { <%= componentName %> } from '<%= importPath %>'
import { TemplateService, TranslateOption, ScaleOption, OpacityOption } from '@hadss/hmrouter'

@Builder
export function <%= componentName %>Builder(name: string, param: Object) {
  <%= componentName %>Generated()
}

@Component
export struct <%= componentName %>Generated {
  @State translateOption: TranslateOption = new TranslateOption()
  @State scaleOption: ScaleOption = new ScaleOption()
  @State opacityOption: OpacityOption = new OpacityOption()
  private pageUrl: string = '<%= pageUrl %>'
  private ndId: string = ''
  private navigationId: string = ''

  aboutToAppear(): void {
    this.navigationId = this.queryNavigationInfo()!.navigationId;
    TemplateService.aboutToAppear(this.navigationId, this.pageUrl, <%= dialog %>,
      this.translateOption, this.scaleOption, this.opacityOption)
  }

  aboutToDisappear(): void {
    TemplateService.aboutToDisappear(this.navigationId, this.pageUrl, this.ndId)
  }

  build() {
    NavDestination() {
      <%= componentName %>()
    }
    <% if(dialog){ %>.mode(NavDestinationMode.DIALOG)<% } %>
    .hideTitleBar(true)
    .gesture(PanGesture()
      .onActionStart((event: GestureEvent) => {
        TemplateService.interactiveStart(this.navigationId, this.ndId, event)
      })
      .onActionUpdate((event: GestureEvent) =>{
        TemplateService.interactiveProgress(this.navigationId, this.ndId, event)
      })
      .onActionEnd((event: GestureEvent) =>{
        TemplateService.interactiveFinish(this.navigationId, this.ndId, event)
      })
    )
    .translate(this.translateOption)
    .scale(this.scaleOption)
    .opacity(this.opacityOption.opacity)
    .onAppear(() => {
      TemplateService.onAppear(this.navigationId, this.pageUrl, this.ndId)
    })
    .onDisAppear(() => {
      TemplateService.onDisAppear(this.navigationId, this.pageUrl, this.ndId)
    })
    .onShown(() => {
      TemplateService.onShown(this.navigationId, this.pageUrl, this.ndId)
    })
    .onHidden(() => {
      TemplateService.onHidden(this.navigationId, this.pageUrl, this.ndId)
    })
    .onWillAppear(() => {
      TemplateService.onWillAppear(this.navigationId, this.pageUrl)
    })
    .onWillDisappear(() => {
      TemplateService.onWillDisappear(this.navigationId, this.pageUrl, this.ndId)
    })
    .onWillShow(() => {
      TemplateService.onWillShow(this.navigationId, this.pageUrl, this.ndId)
    })
    .onWillHide(() => {
      TemplateService.onWillHide(this.navigationId, this.pageUrl, this.ndId)
    })
    .onReady((navContext: NavDestinationContext) => {
      this.ndId = navContext.navDestinationId!
      TemplateService.onReady(this.navigationId, this.pageUrl, navContext)
    })
    .onBackPressed(() => {
      return TemplateService.onBackPressed(this.navigationId, this.pageUrl, this.ndId)
    })
  }
}
```

### 模板变量

| 属性                | 描述              |
|-------------------|-----------------|
| pageUrl           | 标签中配置的pageUrl的值 |
| importPath        | 原组件的导入路径        |
| componentName     | 原组件名            |
| dialog            | 是否dialog页面      |
| generatorViewName | 生成的文件名          |

### TemplateService内置模版方法

该类中封装了一系列在模板中需要用到的注册、初始化、事件回调接口

| 接口                         | 参数                                                                                                                                                  | 返回值  | 接口描述                  |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|------|-----------------------|
| static aboutToAppear       | navigationId: string,pageUrl: string, dialog: boolean, translateOption: TranslateOption,   scaleOption: ScaleOption,   opacityOption: OpacityOption | void | 注册接口，用于模板代码中注册动画与生命周期 |
| static aboutToDisappear    | navigationId: string, pageUrl: string, ndId: string                                                                                                 | void | 销毁，用户销毁一个页面的动画与生命周期实例 |
| static onDisAppear         | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onAppear            | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onShown             | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onHidden            | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onWillAppear        | navigationId: string, pageUrl: string                                                                                                               | void | NavDestination生命周期    |
| static onWillDisappear     | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onWillShow          | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onWillHide          | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static onReady             | navigationId: string, pageUrl: string, navContext: NavDestinationContext                                                                            | void | NavDestination生命周期    |
| static onBackPressed       | navigationId: string, pageUrl: string, navId: string                                                                                                | void | NavDestination生命周期    |
| static interactiveStart    | navigationId: string, ndId: string, event: GestureEvent                                                                                             | void | 手势转场动画触发              |
| static interactiveFinish   | navigationId: string, ndId: string, event: GestureEvent                                                                                             | void | 手势转场动画更新              |
| static interactiveProgress | navigationId: string, ndId: string, event: GestureEvent                                                                                             | void | 手势转场动画结束              |

## 依赖版本

最低版本

```text
HarmonyOS NEXT Developer Beta5版本及以上
DevEco Studio 5.0.3.700及以上
hvigor 5.5.1及以上
```

**推荐使用**

```text
HarmonyOS NEXT Beta1版本及以上
DevEco Studio 5.0.3.800及以上
hvigor 5.7.3及以上
```

> 低于DevEco Studio 5.0.3.800(hvigor 5.7.3)可能会导致远程的 HSP 中定义的 HMRouter 标签与路由表失效，会有如下 WARN 日志
>
> ```
> [HMRouterPlugin] Your DevEco Studio version less than 5.0.3.800, may cause remote hsp dependencies get failed
> ```

## HMRouter 使用

详见[@hadss/hmrouter](https://ohpm.openharmony.cn/#/cn/detail/@hadss%2Fhmrouter)
