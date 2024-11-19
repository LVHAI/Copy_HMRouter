# HMRouter接口和属性列表

## HMNavigation, 路由容器组件

| 参数               | 说明                                                      |
|------------------|---------------------------------------------------------|
| navigationId     | 需要开发者指定，并确保全局唯一，否则运行时输出报错日志                             |
| homePageUrl      | 需要与@HMRouter(pageUrl）中的pageUrl一致，表示HMNavigation默认加载的页面。 |
| navigationOption | 指定该HMNavigation的全局参数选项NavigationOption，保留可扩展性。          |

### HMNavigationOption

| 参数                                                | 说明               |
|---------------------------------------------------|------------------|
| modifier:AttributeUpdater<NavigationAttribute>    | Navigation动态属性设置 |
| standardAnimator:IHMAnimator.Effect               | 页面全局动画配置         |
| dialogAnimator:IHMAnimator.Effect                 | 弹窗全局动画配置         |
| title : NavTitle                                  | 系统Title设置        |
| menus: Array<NavigationMenuItem> \| CustomBuilder | 系统Menu设置         |
| toolbar: Array<ToolbarItem> \| CustomBuilder      | 系统Toolbar设置      |
| systemBarStyle: Optional<SystemBarStyle>          | 系统SystemBar设置    |

## HMRouterMgr类

核心类，提供初始化方法，日志使能方法，路由能力

| 接口                                 | 参数                                                                     | 返回值               | 接口描述                                                                                                                       |
|------------------------------------|------------------------------------------------------------------------|-------------------|----------------------------------------------------------------------------------------------------------------------------|
| static init                        | config: HMRouterConfig                                                 | void              | 初始化HMRouter，采用多线程初始化，将标签里面的页面与拦截器、转场动画、生命周期的映射加载到内存                                                                        |
| static openLog                     | level : 'DEBUG'\|'INFO'                                                | void              | 使能HMRouter日志。level为info时，表示打开Info日志，level为debug时，表示打开info和debug日志。论述是否调用openLog，warnning和error日志均正常打印。                     |
| static push                        | pathInfo: HMRouterPathInfo, callback: HMRouterPathCallback             | void              | 实现路由跳转，提供跳转回调                                                                                                              |
| static replace                     | pathInfo: HMRouterPathInfo, callback: HMRouterPathCallback             | void              | 实现路由跳转，提供跳转回调                                                                                                              |
| static pop                         | pathInfo: HMRouterPathInfo?, skipedLayerNumber?: number                | void              | 实现路由返回, skipedLayerNumber返回是跳跃的页面层数，默认为0（表示返回上级页面，1表示跳过一级页面返回，即同时两个页面出栈），以HMRouterPathInfo.pageUrl为首选，skipedLayerNumber为次选 |
| static getPathStack                | navigationId: string                                                   | NavPathStack      | 根据navigationId获取对应的路由栈，如果没有就生成一个。HMRouter中需要保存navigationId与路由栈映射关系。                                                        |
| static getCurrentParam             |                                                                        | Object            | 获取当前页面路由参数                                                                                                                 |
| static getCurrentLifecycleOwner    |                                                                        | IHMLifecycleOwner | 获取当前页面的生命周期托管者实例                                                                                                           |
| static registerGlobalInterceptor   | interceptor: IHMInterceptor                                            | void              | 注册全局拦截器，interceptor对象包含IHMInterceptor、interceptorName、priority；等同于@HMInterceptor申明全局拦截器                                    |
| static unRegisterGlobalInterceptor | interceptorName                                                        | boolean           | 注销全局拦截器，参数为拦截器名称，返回是否注销成功                                                                                                  |
| static registerGlobalLifecycle     | lifecycle: IHMLifecycle                                                | void              | 注册全局生命周期，lifecycle对象包含IHMLifecycle、lifecycleName、priority；等同于@HMLifecycle申明全局生命周期                                          |
| static unRegisterGlobalLifecycle   | lifecycleName                                                          | boolean           | 注销全局生命周期，参数为生命周期名称，返回是否注销成功                                                                                                |
| static registerGlobalAnimator      | navigationId: string, key: 'standard'\|'dialog', animator: IHMAnimator | void              | 注册全局动画，key为路由页面类型，standard时注册动画针对标准路由页面生效，dialog时注册动画针对dialog类型路由页面生效                                                      |
| static unRegisterGlobalAnimator    | navigationId: string, key: 'standard'\|'dialog'                        | boolean           | 注销全局动画，key为路由页面类型，standard为普通路由页面，dialog为弹窗类型路由页面                                                                          |
| static registerPageBuilder         | HMPageInstance                                                         | boolean           | 动态注册路由信息，等同于@HMRouter申明                                                                                                    |
| static generatePageLifecycleId     |                                                                        | string            | 生成页面生命管理实例唯一标识                                                                                                             |
| static getPageLifecycleById        | pageLifecycleId                                                        | HMPageLifecycle   | 页面生命周期实例                                                                                                                   |
| static request                     | serviceName, ...args: Object[]                                         | HMServiceResp     | 调用@HMService声明的服务                                                                                                          |

### HMRouterConfig类

初始化配置

| 参数                         | 说明                          |
|----------------------------|-----------------------------|
| context:UIAbilityContext   | UIAbility上下文，用于初始化时读取路由配置信息 |
| initWithTaskPool?: boolean | 是否使用taskpool进行多线程初始化，默认为开启  |

### HMRouterPathInfo类

路由参数，用于路由跳转/返回参数。

| 参数                   | 说明                                                                                                                     |
|----------------------|------------------------------------------------------------------------------------------------------------------------|
| navigationId?        | 根页面名称，对应的是Navigation的名称/ID，当navigationId为null时，表示为对最近一次navigation组件内进行路由跳转。                                            |
| pageUrl?             | 路由页面名称，对应的是NavDestination的名称，@HMRouter(pageUrl, dialog, interceptor, animator, lifecycle)中的pageUrl，push时必须传入，否则会打印错误日志 |
| param?               | 传递的参数，当调用push时表示传递给下页面的参数对象，当调用pop时表示回传给上一页面的返回参数对象。                                                                   |
| animator?            | 自定义动画，传入使用此自定义动画执行转场，不再使用原先定义的转场。如果为false时，则不触发动画                                                                      |
| interceptors?        | 自定义拦截器，最高优先级执行。                                                                                                        |
| lifecycle?           | 自定义生命周期，最高优先级执行。                                                                                                       |
| skipAllInterceptors? | 是否跳过所有拦截器，boolean类型                                                                                                    |

### HMRouterPathCallback类

提供路由完成回调

| 参数        | 说明                     |
|-----------|------------------------|
| onResult  | 页面返回回调，回调参数类型HMPopInfo |
| onArrival | 目标页面跳转完成回调             |
| onLost    | 目标页面找不到回调              |

> onResult回调可以在每次返回该页面时触发

### HMPopInfo类

| 参数          | 说明                       |
|-------------|--------------------------|
| srcPageInfo | name:返回的源页面，param: 源页面参数 |
| info        | 系统NavPathInfo对象          |
| result      | 返回携带的参数                  |

### HMPageInstance类

用于动态注册路由信息

| 参数                | 说明                                             |
|-------------------|------------------------------------------------|
| builder           | 路由页面内容，需要使用NavDestination组件包裹，WrappedBuilder类型 |
| pageUrl           | 路由页面名称， 同@HMRouter pageUrl                     |
| interceptorArray? | 页面对应拦截器，同@HMRouter interceptors                |
| singleton?        | 页面是否单例，同@HMRouter singleton                    |

### HMPageLifecycle类

@Entry页面生命周期管理类

| 方法            | 说明                    |
|---------------|-----------------------|
| onDisAppear   | 页面销毁时触发，绑定页面销毁时回调     |
| onShown       | 页面显示时触发，绑定页面显示时回调     |
| onHidden      | 页面隐藏时触发，绑定页面隐藏时回调     |
| onBackPressed | 页面侧滑返回时触发，绑定页面侧滑返回时回调 |

## IHMInterceptor, 拦截器接口

拦截器接口，所有`@HMInterceptor`申明的拦截器需要实现此接口。

| 接口     | 参数                | 返回值                 | 接口描述                        |
|--------|-------------------|---------------------|-----------------------------|
| handle | HMInterceptorInfo | HMInterceptorAction | 执行时机：在路由栈发生变化前进行回调，转场动画发生前。 |

### HMInterceptorInfo类

拦截器获取到的数据对象，包含如下信息

| 参数                 | 说明                                                                   |
|--------------------|----------------------------------------------------------------------|
| srcName            | 发起页面名称                                                               |
| targetName         | 目标页面名称                                                               |
| isSrc              | 是否是发起页面                                                              |
| type               | 路由跳转类型，push，replace，pop                                              |
| routerPathInfo     | 路由跳转信息，HMRouterPathInfo                                              |
| routerPathCallback | 路由跳转回调，HMRouterPathCallback                                          |
| context            | UIContext，用来对UI界面进行操作，系统提供，每个navigationId对应一个UIContext，在路由跳转时提供给拦截器。 |

### HMInterceptorAction枚举

handle方法返回值，表示此拦截器完成后的下一步动作。

| 参数            | 说明                              | 
|---------------|---------------------------------|
| DO_NEXT       | 继续执行下一个拦截器。                     |
| DO_REJECT     | 停止执行下一个拦截器，并且不执行路由跳转动画，不执行路由栈操作 |
| DO_TRANSITION | 跳过后续拦截器，直接执行路由转场动画，执行路由栈操作      |

## IHMLifecycle, 自定义生命周期接口

自定义生命周期接口，所有`@HMLifecycle`申明的自定义生命周期处理器需要实现此接口。

| 接口              | 参数                      | 返回值     | 接口描述                                           |
|-----------------|-------------------------|---------|------------------------------------------------|
| onPrepare       | ctx: HMLifecycleContext | void    | 触发时机：在拦截器执行后，路由栈真正push前触发                      |
| onAppear        | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onAppear`事件中触发回调。        |
| onDisAppear     | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onDisAppear`事件中触发回调。     |
| onShown         | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onShown`事件中触发回调。         |
| onHidden        | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onHidden`事件中触发回调。        |
| onWillAppear    | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onWillAppear`事件中触发回调。    |
| onWillDisappear | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onWillDisappear`事件中触发回调。 |
| onWillShow      | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onWillShow`事件中触发回调。      |
| onWillHide      | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onWillHide`事件中触发回调。      |
| onReady         | ctx: HMLifecycleContext | void    | 触发时机：在NavDestination的`onReady`事件中触发回调。         |
| onBackPressed   | ctx: HMLifecycleContext | boolean | 触发时机：在NavDestination的`onBackPressed`事件中触发回调    |

### HMLifecycleContext类

提供context扩展

> onWillAppear声明周期回调中无法获取到navContext

| 参数         | 说明                         |
|------------|----------------------------|
| uiContext  | 提供UIContext上下文             |
| navContext | 提供NavDestinationContext上下文 |

### IHMLifecycleOwner接口

生命周期托管者实例

| 接口           | 参数                                                                            | 返回值                       | 描述 ｜            |
|--------------|-------------------------------------------------------------------------------|---------------------------|-----------------|
| getLifecycle |                                                                               | IHMLifecycle \| undefined | 获取开发者定义的生命周期实例  |
| addObserver  | state:HMLifecycleState,callback: (ctx: HMLifecycleContext) => boolean \| void | void                      | 注册观察者跟随指定生命周期触发 |

> 由于addObserver添加生命周期观察的时机，可能在方法调用前相关的生命周期已回调结束，需要开发者注意注册观察者的时机

## IHMAnimator, 自定义转场动画接口

自定义动画接口，所有`@HMAnimator`申明的自定义动画需要实现此接口，当页面指定了自定义动效的页面将不在执行HMNavigation中指定的默认动效

| 接口          | 参数                                                          | 返回值  | 接口描述             |
|-------------|-------------------------------------------------------------|------|------------------|
| effect      | enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle | void | 声明入场和出场动画的定义     |
| interactive | handle: HMAnimatorHandle                                    | void | 跟手转场（可交互式转场）动画定义 |

### HMAnimatorHandle类

动画处理器

| 参数              | 说明                   |
|-----------------|----------------------|
| start           | 定义组件在动画开始前的状态        |
| finish          | 定义组件在动画结束后的状态        |
| onFinish        | 定义组件在动画结束后保持的最终状态    |
| passiveStart    | 定义组件被动触发动画开始前的状态     |
| passiveFinish   | 定义组件被动触发动画结束后的状态     |
| passiveOnFinish | 定义组件被动触发动画结束后保持的最终状态 |
| timeout         | 定义动画超时时间             |
| curve           | 动画曲线                 |
| duration        | 动画持续时间               |
| interactive     | 是否可交互式转场             |
| actionStart     | 手势触发的回调              |
| updateProgress  | 更新转场进度的回调            |
| actionEnd       | 手势结束的回调              |

### IHMAnimator.Effect类

内置转场动画定义

| 构造函数         | 说明                               |
|--------------|----------------------------------|
| effectOption | IHMAnimator.EffectOptions 动画参数定义 |

| 函数         | 说明          |
|------------|-------------|
| toAnimator | 转换成内置转场动画对象 |

### IHMAnimator.EffectOptions 类

| 参数        | 说明       |
|-----------|----------|
| direction | 转场方向定义   |
| opacity   | 透明度初始值定义 |
| scale     | 缩放初始值定义  |

# 错误码

| 错误类型                       | 错误码      | 错误信息                                                  | 说明                                  |
|----------------------------|----------|-------------------------------------------------------|-------------------------------------|
| ERR_DUPLICATE_NAME         | 40000001 | 重复的pageUrl、拦截器、生命周期、动画、服务 - {pageUrl}                 | 编译时若pageUrl重复，编译报错，并终止编译            |
| ERR_WRONG_DECORATION       | 40000002 | @HMRouter修饰的组件不能包含NavDestination - {filePath}         | 编译时若出现相同的组件（拦截器、转场、生命周期），则编译报错，终止编译 |
| ERR_REPEAT_ANNOTATION      | 40000003 | 文件 {filePath} 中存在多个HMRouter注解                         |                                     |
| ERR_ERROR_CONFIG           | 40000004 | moduleContext is null 请检查插件的hvigorfile配置 - {filePath} |                                     |
| ERR_WRONG_PLUGIN_METHOD    | 40000005 | {variableName} 常量值不能为空字符串                             |                                     |
| ERR_INVALID_STRING_VALUE   | 40000006 | {variableName} 无效的字符串常量值                              |                                     |
| ERR_INIT_FRAMEWORK         | 40001001 | 框架初始化失败                                               |                                     |
| ERR_INIT_COMPONENT         | 40001002 | {componentType} - {name} 初始化失败                        |                                     |
| ERR_INIT_NOT_READY         | 40001003 | 框架初始化未完成                                              | HMRouterMgr未初始化时，调用HMRouter接口报错     |
| ERR_PUSH_INVALID           | 40002001 | 跳转失败, 无效页面 - {pageUrl}                                |                                     |
| ERR_PUSH_SYS               | 40002002 | 跳转失败, 系统错误 - {sysErrorCode} - {sysErrorMsg}           |                                     |
| ERR_POP_INVALID            | 40002003 | 出栈失败, 无效页面 - {pageUrl}                                |                                     |
| ERR_POP_SYS                | 40002004 | 出栈失败, 系统错误 - {sysErrorCode} - {sysErrorMsg}           |                                     |
| ERR_REPLACE_INVALID        | 40002005 | 替换失败, 无效页面 - {pageUrl}                                |                                     |
| ERR_REPLACE_SYS            | 40002006 | 替换失败, 系统错误 - {sysErrorCode} - {sysErrorMsg}           |                                     |
| ERR_PARAM_REQUIRED         | 40003001 | {paramName} 参数缺失                                      |                                     |
| ERR_PARAM_ILLEGAL          | 40003002 | 传入参数非法 - {paramName}: {paramValue}                    |                                     |
| ERR_COMPONENT_GET_FAILED   | 40005001 | {componentType} - {name}获取失败                          |                                     |
| ERR_COMPONENT_NOT_EXIST    | 40005002 | {componentType} - {name} 不存在                          |                                     |
| ERR_COMPONENT_PROCESS      | 40005003 | {componentType} - {name} 执行失败 - {msg}                 |                                     |
| ERR_INTERNAL               | 40005004 | 内部错误 - {msg}                                          |                                     |
| ERR_SERVICE_NOT_EXIST      | 40005005 | 服务 {name} 不存在                                         |                                     |
| ERR_SERVICE_IMPORT_FAILED  | 40005006 | 服务 {name} 加载失败，内部错误                                   |                                     |
| ERR_SERVICE_EXECUTE_FAILED | 40005007 | 服务 {name} 执行失败                                        |                                     |
| ERR_DYNAMIC_IMPORT_FAILED  | 40005008 | 动态加载失败-{modulePath} {moduleInfo} {className }         | 动态加载失败                              |