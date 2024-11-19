/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hvigor, HvigorNode } from '@ohos/hvigor';
import {
  OhosAppContext,
  OhosHapContext,
  OhosHarContext,
  OhosHspContext,
  OhosPluginId,
  Target
} from '@ohos/hvigor-ohos-plugin';
import { ModuleBuildProfile } from '@ohos/hvigor-ohos-plugin/src/options/build/module-build-profile';
import { HMRouterPluginConfig } from './HMRouterPluginConfig';
import { HMRouterHvigorPlugin } from './HMRouterHvigorPlugin';
import { Logger } from './common/Logger';
import { RouterInfo } from './common/PluginModel';
import HMRouterPluginConstant from './constants/CommonConstants';
import TaskConstants from './constants/TaskConstants';
import HMFileUtil from './utils/FileUtil';
import ObfuscationUtil from './utils/ObfuscationUtil';

/**
 * HMRouterPluginHandle类，用于处理HMRouter插件
 */
export class HMRouterPluginHandle {
  public readonly config: HMRouterPluginConfig;
  private readonly node: HvigorNode;
  private readonly moduleContext: OhosHapContext | OhosHarContext | OhosHspContext;
  private readonly appContext: OhosAppContext;
  private readonly plugin: HMRouterHvigorPlugin;

  // 构造函数，初始化节点、模块上下文、配置和插件
  constructor(node: HvigorNode, moduleContext: OhosHapContext | OhosHarContext | OhosHspContext) {
    this.node = node;
    this.moduleContext = moduleContext;
    this.config = this.readConfig();
    this.appContext = this.node.getParentNode()?.getContext(OhosPluginId.OHOS_APP_PLUGIN);
    this.plugin = new HMRouterHvigorPlugin(this.config);
  }

  // 启动插件
  start() {
    Logger.info(
      `Exec ${this.moduleContext.getModuleType()}Plugin..., node:${this.node.getNodeName()}, nodePath:${this.node.getNodePath()}`
    );
    this.moduleContext.targets((target: Target) => {
      const targetName = target.getTargetName();
      this.node.registerTask({
        name: targetName + TaskConstants.PLUGIN_TASK,
        run: () => {
          this.taskExec();
        },
        dependencies: [targetName + TaskConstants.PRE_BUILD],
        postDependencies: [targetName + TaskConstants.MERGE_PROFILE]
      });
      this.node.registerTask({
        name: targetName + TaskConstants.COPY_ROUTER_MAP_TASK,
        run: () => {
          this.copyRouterMapToRawFileTask(target.getBuildTargetOutputPath(), targetName);
          this.writeHspModuleName();
        },
        dependencies: [targetName + TaskConstants.PROCESS_ROUTER_MAP],
        postDependencies: [targetName + TaskConstants.PROCESS_RESOURCE]
      });
      this.node.registerTask({
        name: targetName + TaskConstants.GENERATE_OBFUSCATION_TASK,
        run: () => {
          this.generateObfuscationFileTask(this.moduleContext.getBuildProfileOpt());
        },
        dependencies: [targetName + TaskConstants.PLUGIN_TASK],
        postDependencies: [targetName + TaskConstants.MERGE_PROFILE]
      });
    });
  }

  // 生成混淆配置文件
  private generateObfuscationFileTask(buildProfileOpt: ModuleBuildProfile.ModuleBuildOpt) {
    if (!this.isEnableObfuscation(buildProfileOpt)) {
      Logger.info(
        'This compilation does not turn on code obfuscation, skip hmrouter_obfuscation_rules.txt file generation');
      return;
    }
    let obfuscationFilePath = HMFileUtil.pathResolve(this.config.modulePath,
      HMRouterPluginConstant.OBFUSCATION_FILE_NAME);
    HMFileUtil.ensureFileSync(obfuscationFilePath);
    HMFileUtil.writeFileSync(obfuscationFilePath, ObfuscationUtil.buildObfuscatedStrings(this.plugin.routerMap));
    Logger.info('Generate obfuscation rule file successfully, filePath:', obfuscationFilePath);
  }

  // 判断当前的buildModel是否开启了混淆配置
  private isEnableObfuscation(buildProfileOpt: ModuleBuildProfile.ModuleBuildOpt): boolean {
    let currentBuildMode = this.appContext.getBuildMode();
    // 根据混淆配置决定是否要注册混淆配置任务
    let buildOption = buildProfileOpt.buildOptionSet?.find((item) => {
      return item.name == currentBuildMode;
    });
    if (buildOption) {
      let ruleOptions = this.ensureNestedObject(buildOption, ['arkOptions', 'obfuscation', 'ruleOptions']);
      // 自动写入混淆文件并且开启了混淆
      if (this.config.autoObfuscation && ruleOptions.enable) {
        // 构建对象
        let files = this.ensureNestedObject(buildOption, ['arkOptions', 'obfuscation', 'ruleOptions', 'files']);
        let obfuscationFilePath = HMRouterPluginConstant.CURRENT_DELIMITER +
        HMRouterPluginConstant.OBFUSCATION_FILE_NAME;
        if (typeof files === 'string') {
          ruleOptions.files = [files, obfuscationFilePath];
        } else {
          files.push(obfuscationFilePath);
        }
        this.moduleContext.setBuildProfileOpt(buildProfileOpt);
      }
      return ruleOptions.enable;
    } else {
      return false;
    }
  }

  // 拷贝routerMap到raw文件
  private copyRouterMapToRawFileTask(buildOutputPath: string, targetName: string) {
    let routerMapFilePath = HMFileUtil.pathResolve(
      buildOutputPath,
      HMRouterPluginConstant.TEMP_ROUTER_MAP_PATH,
      targetName,
      HMRouterPluginConstant.ROUTER_MAP_NAME
    );
    let rawFilePath = this.config.getRawFilePath();
    HMFileUtil.ensureFileSync(rawFilePath);
    HMFileUtil.copyFileSync(routerMapFilePath, rawFilePath);
  }

  // rawFile的routerMap添加hsp包模块名
  private writeHspModuleName() {
    if (this.node.getAllPluginIds().includes(OhosPluginId.OHOS_HAP_PLUGIN)) {
      let rawFilePath = this.config.getRawFilePath();
      let rawFileRouterMap = JSON.parse(HMFileUtil.readFileSync(rawFilePath).toString());
      rawFileRouterMap.hspModuleNames = [];
      hvigor.getAllNodes().forEach((node: HvigorNode) => {
        let pluginIds = node.getAllPluginIds();
        if (pluginIds.includes(OhosPluginId.OHOS_HSP_PLUGIN)) {
          let packageJson: any = HMFileUtil.readJson5(HMFileUtil.pathResolve(node.getNodePath(), 'oh-package.json5'));
          rawFileRouterMap.hspModuleNames.push(packageJson.name);
        }
        try {
          pluginIds.forEach((id: string) => {
            let context = node.getContext(id);
            let signedHspObj = context.getOhpmRemoteHspDependencyInfo(true);
            let remoteHspObj = context.getOhpmRemoteHspDependencyInfo(false);
            for (const key in signedHspObj) {
              rawFileRouterMap.hspModuleNames.push(signedHspObj[key].name);
            }
            for (const key in remoteHspObj) {
              rawFileRouterMap.hspModuleNames.push(remoteHspObj[key].name);
            }
          });
        } catch (error) {
          Logger.warn('Your DevEco Studio version less than 5.0.3.800, may cause remote hsp dependencies get failed');
        }
      });
      rawFileRouterMap.hspModuleNames = [...new Set(rawFileRouterMap.hspModuleNames)];
      HMFileUtil.writeFileSync(rawFilePath, JSON.stringify(rawFileRouterMap));
    }
  }

  // 执行任务
  private taskExec() {
    let startTime = Date.now();
    Logger.info(this.node.getNodeName() + ': HMRouterPluginTask start');
    // 分析注解
    this.plugin.analyzeAnnotation();
    // 更新module.json
    this.updateModuleJsonOpt();
    // 更新profile
    this.updateBuildProfileOpt();
    let endTime = Date.now();
    Logger.info(this.config.moduleName + ': HMRouterPluginTask end');
    Logger.info(this.config.moduleName + ': HMRouterPluginTask cost: ' + (endTime - startTime) + ' ms');
  }

  // 更新module.json
  private updateModuleJsonOpt() {
    // 获取模块的json配置
    const moduleJsonOpt = this.moduleContext.getModuleJsonOpt();
    // 如果模块的json配置中有routerMap
    if (moduleJsonOpt.module.routerMap) {
      // 获取routerMap的文件名
      let routerMapFileName = moduleJsonOpt.module.routerMap.split(':')[1];
      // 获取routerMap的文件路径
      let routerMapFilePath = this.config.getModuleRouterMapFilePath(routerMapFileName);
      // 读取routerMap的json文件
      let routerMapObj = HMFileUtil.readJson5(routerMapFilePath);
      // 将routerMap添加到plugin的routerMap中
      this.plugin.routerMap.unshift(
        ...((routerMapObj as any)[HMRouterPluginConstant.ROUTER_MAP_KEY] as Array<RouterInfo>));
    }
    // 生成routerMap
    this.plugin.generateRouterMap();
    // 将routerMap的名称设置为MODULE_ROUTER_MAP_NAME
    moduleJsonOpt.module.routerMap = HMRouterPluginConstant.MODULE_ROUTER_MAP_NAME;
    // 将修改后的moduleJsonOpt设置到moduleContext中
    this.moduleContext.setModuleJsonOpt(moduleJsonOpt);
  }

  // 更新build-profile配置
  private updateBuildProfileOpt() {
    // 获取构建配置选项
    const buildProfileOpt = this.moduleContext.getBuildProfileOpt();
    // 初始化 arkOptions 和 runtimeOnly 配置
    let sources = this.ensureNestedObject(buildProfileOpt, ['buildOption', 'arkOptions', 'runtimeOnly', 'sources']);
    if (!Array.isArray(sources)) {
      buildProfileOpt.buildOption!.arkOptions!.runtimeOnly!.sources = [];
    }
    // 将路由信息推送到构建配置选项中
    this.pushRouterInfo(buildProfileOpt, this.plugin.routerMap);
    // 将构建配置选项设置到moduleContext中
    this.moduleContext.setBuildProfileOpt(buildProfileOpt);
  }

  // 将路由信息添加到 buildProfileOpt 中
  private pushRouterInfo(buildProfileOpt: any, routerMap: Array<RouterInfo>) {
    const sources = buildProfileOpt.buildOption.arkOptions.runtimeOnly.sources;
    routerMap.forEach((item: RouterInfo) => {
      const name = item.name;
      if (
        name.includes(HMRouterPluginConstant.LIFECYCLE_PREFIX) ||
        name.includes(HMRouterPluginConstant.INTERCEPTOR_PREFIX) ||
        name.includes(HMRouterPluginConstant.ANIMATOR_PREFIX) ||
        name.includes(HMRouterPluginConstant.SERVICE_PREFIX)
      ) {
        sources.push(HMRouterPluginConstant.CURRENT_DELIMITER + item.pageSourceFile);
      }
    });
  }

  // 读取配置
  private readConfig(): HMRouterPluginConfig {
    let levels = 0;
    let configParam = {};
    let configFilePath = '';
    while (levels < 4) {
      configFilePath = HMFileUtil.pathResolve(
        this.node.getNodePath(),
        HMRouterPluginConstant.PARENT_DELIMITER.repeat(levels) + HMRouterPluginConstant.CONFIG_FILE_NAME
      );
      if (HMFileUtil.exist(configFilePath)) {
        configParam = HMFileUtil.readJson5(configFilePath);
        break;
      }
      levels++;
    }
    let configDir = configFilePath.split(HMRouterPluginConstant.FILE_SEPARATOR).slice(0, -1)
      .join(HMRouterPluginConstant.FILE_SEPARATOR);
    return new HMRouterPluginConfig(this.node.getNodeName(), this.node.getNodePath(), configDir, configParam);
  }

  // 构建嵌套对象
  private ensureNestedObject(obj: any, path: string[]): any {
    return path.reduce((acc, key) => {
      if (!acc[key]) {
        acc[key] = {};
      }
      return acc[key];
    }, obj);
  }
}
