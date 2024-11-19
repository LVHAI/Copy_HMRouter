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

import { hvigor, HvigorNode, HvigorPlugin } from '@ohos/hvigor';
import { OhosHapContext, OhosHarContext, OhosHspContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { Logger, PluginError } from './common/Logger';
import HMRouterPluginConstant from './constants/CommonConstants';
import { TsAstUtil } from './utils/TsAstUtil';
import HMFileUtil from './utils/FileUtil';
import { HMRouterPluginHandle } from './HMRouterPluginHandle';

// HMRouterPluginMgr类，用于管理HMRouterPluginHandle实例
class HMRouterPluginMgr {
  // HMRouterPluginHandle实例集合
  hmRouterPluginSet: Set<HMRouterPluginHandle> = new Set();

  // 构造函数，在hvigor节点评估后启动所有HMRouterPluginHandle实例，在hvigor构建完成后删除生成的文件
  constructor() {
    hvigor.nodesEvaluated(() => {
      this.hmRouterPluginSet.forEach((pluginHandle) => {
        pluginHandle.start();
      });
    });
    hvigor.buildFinished(() => {
      Logger.info('buildFinished deleteFile exec...');
      this.hmRouterPluginSet.forEach((pluginHandle) => {
        // 如果saveGeneratedFile为true，跳过删除
        if (pluginHandle.config.saveGeneratedFile) {
          Logger.info(pluginHandle.config.moduleName + ' saveGeneratedFile is true, skip deleting');
          return;
        }
        this.deleteRouterMapFile(pluginHandle);
        this.deleteRawFile(pluginHandle);
        this.deleteGeneratorFile(pluginHandle);
        if (pluginHandle.config.autoObfuscation) {
          this.deleteObfuscationFile(pluginHandle);
        }
      });
      HMRouterPluginMgrInstance = null;
      TsAstUtil.clearProject();
    });
  }

  // 注册HMRouterPluginHandle实例
  registerHMRouterPlugin(node: HvigorNode, pluginId: string) {
    // 获取节点上下文
    const moduleContext = node.getContext(pluginId) as OhosHapContext | OhosHarContext | OhosHspContext;
    // 如果节点上下文为空，抛出错误
    if (!moduleContext) {
      Logger.error(PluginError.ERR_ERROR_CONFIG, node.getNodePath());
      throw new Error('moduleContext is null');
    }
    // 创建HMRouterPluginHandle实例
    let pluginHandle = new HMRouterPluginHandle(node, moduleContext);
    // 如果插件ID为OHOS_HAP_PLUGIN，设置模块名称
    if (pluginId === OhosPluginId.OHOS_HAP_PLUGIN) {
      let packageJson: any = HMFileUtil.readJson5(HMFileUtil.pathResolve(node.getNodePath(), 'oh-package.json5'));
      pluginHandle.config.moduleName = packageJson.name;
    }
    // 将HMRouterPluginHandle实例添加到集合中
    this.hmRouterPluginSet.add(pluginHandle);
  }

  // 删除生成的builder文件
  private deleteGeneratorFile(pluginHandle: HMRouterPluginHandle) {
    // 获取builderDirPath路径
    let builderDirPath = pluginHandle.config.getBuilderDir();
    // 如果路径存在，删除builder目录
    if (HMFileUtil.exist(builderDirPath)) {
      HMFileUtil.rmSync(builderDirPath, {
        recursive: true
      });
      Logger.info(pluginHandle.config.modulePath + ' delete builder dir');
    }
  }

  // 删除hm_router_map文件
  private deleteRouterMapFile(pluginHandle: HMRouterPluginHandle) {
    let routerMapDirPath = pluginHandle.config.getRouterMapDir();
    // 如果路径存在，删除hm_router_map.json文件
    if (HMFileUtil.exist(routerMapDirPath)) {
      HMFileUtil.unlinkSync(routerMapDirPath);
      Logger.info(routerMapDirPath + ' delete hm_router_map.json');
    }
  }

  // 删除rawFile中的routerMap目录
  private deleteRawFile(pluginHandle: HMRouterPluginHandle) {
    let rawFilePath = pluginHandle.config.getRawFilePath();
    if (HMFileUtil.exist(rawFilePath)) {
      HMFileUtil.unlinkSync(rawFilePath);
      Logger.info(pluginHandle.config.modulePath + ' delete rawfile hm_router_map.json');
    }
  }

  // 删除混淆配置文件
  private deleteObfuscationFile(pluginHandle: HMRouterPluginHandle) {
    let obfuscationFilePath = pluginHandle.config.getObfuscationFilePath();
    if (HMFileUtil.exist(obfuscationFilePath)) {
      HMFileUtil.unlinkSync(obfuscationFilePath);
      Logger.info(pluginHandle.config.modulePath + ' delete obfuscation hmrouter_obfuscation_rules.txt');
    }
  }
}

// HMRouterPluginMgr实例
let HMRouterPluginMgrInstance: HMRouterPluginMgr | null = null;

// hap插件
export function hapPlugin(): HvigorPlugin {
  return {
    pluginId: HMRouterPluginConstant.HAP_PLUGIN_ID,
    apply(node: HvigorNode) {
      // 如果HMRouterPluginMgr实例为空，创建新的实例
      if (!HMRouterPluginMgrInstance) {
        HMRouterPluginMgrInstance = new HMRouterPluginMgr();
      }
      // 注册HMRouterPluginHandle实例
      HMRouterPluginMgrInstance.registerHMRouterPlugin(node, OhosPluginId.OHOS_HAP_PLUGIN);
    }
  };
}

// hsp插件
export function hspPlugin(): HvigorPlugin {
  return {
    pluginId: HMRouterPluginConstant.HSP_PLUGIN_ID,
    apply(node: HvigorNode) {
      // 如果HMRouterPluginMgr实例为空，创建新的实例
      if (!HMRouterPluginMgrInstance) {
        HMRouterPluginMgrInstance = new HMRouterPluginMgr();
      }
      // 注册HMRouterPluginHandle实例
      HMRouterPluginMgrInstance.registerHMRouterPlugin(node, OhosPluginId.OHOS_HSP_PLUGIN);
    }
  };
}

// har插件
export function harPlugin(): HvigorPlugin {
  return {
    pluginId: HMRouterPluginConstant.HAR_PLUGIN_ID,
    apply(node: HvigorNode) {
      // 如果HMRouterPluginMgr实例为空，创建新的实例
      if (!HMRouterPluginMgrInstance) {
        HMRouterPluginMgrInstance = new HMRouterPluginMgr();
      }
      // 注册HMRouterPluginHandle实例
      HMRouterPluginMgrInstance.registerHMRouterPlugin(node, OhosPluginId.OHOS_HAR_PLUGIN);
    }
  };
}
