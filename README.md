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

# 版本信息

当前最新版本

| 名称                                                                             | 类型   | 版本号        |
|--------------------------------------------------------------------------------|------|------------|
| [@hadss/hmrouter](https://ohpm.openharmony.cn/#/cn/detail/@hadss%2Fhmrouter)   | 运行时库 | 1.0.0-rc.6 |
| [@hadss/hmrouter-plugin](https://www.npmjs.com/package/@hadss/hmrouter-plugin) | 编译插件 | 1.0.0-rc.7 |

# HMRouter使用说明

[查看详情](HMRouterLibrary/README.md)

# 编译插件使用说明

[查看详情](HMRouterPlugin/README.md)

# 自定义模版使用说明

[查看详情](docs/CustomTemplate.md)

# 原生到原生页面跳转场景解决方案

[查看详情](docs/Scene.md)

# Sample介绍

本项目包含[Sample示例代码](https://gitee.com/harmonyos_samples/HMRouter)，通过购物App展示`HMRouter`在页面跳转场景中的使用

Sample覆盖了[原生到原生页面跳转场景解决方案](#原生到原生页面跳转场景解决方案)所列出的所有场景，供开发者参考

# 更多示例

[查看详情](TestCases/Demo)

# FAQ

[查看详情](docs/FAQ.md)

# 原理介绍

[查看详情](https://developer.huawei.com/consumer/cn/forum/topic/0207153170697988820?fid=0109140870620153026)

# 贡献代码

使用过程中发现任何问题都可以提 [Issue](https://gitee.com/hadss/hmrouter/issues) ，当然，也非常欢迎发 [PullRequest](https://gitee.com/hadss/hmrouter/pulls) 共建。

# 开源协议

本项目基于 [Apache License 2.0](LICENSE) ，请自由地享受和参与开源。