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

import path from 'path';
import micromatch from 'micromatch';
import ejs from 'ejs';
import {
AnalyzerResultLike,
HMAnimatorResult,
HMInterceptorResult,
HMLifecycleResult,
HMRouterResult,
HMServiceResult,
RouterInfo,
TemplateModel
} from './common/PluginModel';
import { Logger, PluginError } from './common/Logger';
import HMRouterPluginConstant from './constants/CommonConstants';
import HMFileUtil from './utils/FileUtil';
import { CustomPageTemplateImpl, HMRouterPluginConfig } from './HMRouterPluginConfig';
import { AnalyzerController } from './HMRouterAnalyzer';

// 定义HMRouterHvigorPlugin类
export class HMRouterHvigorPlugin {
  config: HMRouterPluginConfig;
  routerMap: RouterInfo[] = [];
  private scanFiles: string[] = [];
  private analyzerController: AnalyzerController = new AnalyzerController();

  constructor(config: HMRouterPluginConfig) {
    this.config = config;
  }

  analyzeAnnotation() {
    this.config.scanDir.forEach((dir) => {
      const scanPath = this.config.getScanPath(dir);
      this.scanFiles.push(...this.getAbsolutePaths(this.config.modulePath, scanPath));
    });
    Logger.info(`Scanned ${this.scanFiles.length} files`, this.scanFiles);
    this.scanFiles.forEach((filePath) => {
      if (filePath.endsWith(HMRouterPluginConstant.VIEW_NAME_SUFFIX)) {
        this.analyzerController.analyzeFile(filePath, this.config);
      }
    });
    // 分析结束后，构造routerMap
    this.analyzerController.getAnalyzeResultSet().forEach((analyzerResult) => {
      this.pushRouterInfo(analyzerResult);
    });
  }

  // 生成路由表文件
  generateRouterMap() {
    let set = new Set<string>();
    this.routerMap.forEach((item) => {
      // 判断路由名称是否重复
      if (set.has(item.name)) {
        Logger.error(PluginError.ERR_DUPLICATE_NAME, item.name);
        throw new Error(`Route page name: ${item.name} is duplicated`);
      } else {
        set.add(item.name);
      }
    });
    let routerMap = {
      routerMap: this.routerMap.map((item) => {
        // 删除注解
        if (item.customData && item.customData.annotation) {
          delete item.customData.annotation;
          delete item.customData.pageSourceFile;
        }
        return item;
      })
    };

    // 获取路由映射文件路径
    const routerMapJsonStr = JSON.stringify(routerMap, null, 2);
    const routerMapFilePath = this.config.getRouterMapDir();
    // 确保文件存在
    HMFileUtil.ensureFileSync(routerMapFilePath);
    HMFileUtil.writeFileSync(routerMapFilePath, routerMapJsonStr);
    Logger.info(`hm_router_map.json has been generated in ${routerMapFilePath}`);
  }

  // 执行路径匹配
  matchedPath(filePath: string, customPageTemplate: CustomPageTemplateImpl[], defaultTplFilePath: string): string {
    for (const template of customPageTemplate) {
      if (micromatch.isMatch(filePath, template.srcPath)) {
        return HMFileUtil.pathResolve(this.config.configDir, template.templatePath);
      }
    }
    // 如果没有匹配上任何规则，使用默认值
    return defaultTplFilePath;
  }

  // 推送路由信息
  pushRouterInfo(analyzeResult: AnalyzerResultLike) {
    let pageSourceFile = this.config.getRelativeSourcePath(analyzeResult.pageSourceFile!)
      .replaceAll(HMRouterPluginConstant.FILE_SEPARATOR, HMRouterPluginConstant.DELIMITER);
    // 判断注解类型
    switch (analyzeResult.annotation) {
      case HMRouterPluginConstant.ROUTER_ANNOTATION:
        let generatorFilePath = this.generateBuilder(analyzeResult, pageSourceFile,
          this.matchedPath(pageSourceFile, this.config.customPageTemplate, this.config.getDefaultTplFilePath()));
        let pageUrl = (analyzeResult as HMRouterResult).pageUrl;
        this.routerMap.push(new RouterInfo(pageUrl, generatorFilePath, analyzeResult.name + 'Builder', analyzeResult));
        break;
      case HMRouterPluginConstant.ANIMATOR_ANNOTATION:
        let animatorName = HMRouterPluginConstant.ANIMATOR_PREFIX + (analyzeResult as HMAnimatorResult).animatorName;
        this.routerMap.push(new RouterInfo(animatorName, pageSourceFile, '', analyzeResult));
        break;
      case HMRouterPluginConstant.INTERCEPTOR_ANNOTATION:
        let interceptorName =
          HMRouterPluginConstant.INTERCEPTOR_PREFIX + (analyzeResult as HMInterceptorResult).interceptorName;
        this.routerMap.push(new RouterInfo(interceptorName, pageSourceFile, '', analyzeResult));
        break;
      case HMRouterPluginConstant.LIFECYCLE_ANNOTATION:
        let lifecycleName =
          HMRouterPluginConstant.LIFECYCLE_PREFIX + (analyzeResult as HMLifecycleResult).lifecycleName;
        this.routerMap.push(new RouterInfo(lifecycleName, pageSourceFile, '', analyzeResult));
        break;
      case HMRouterPluginConstant.SERVICE_ANNOTATION:
        let serviceName = HMRouterPluginConstant.SERVICE_PREFIX + (analyzeResult as HMServiceResult).serviceName;
        this.routerMap.push(new RouterInfo(serviceName, pageSourceFile, '', analyzeResult));
        break;
    }
  }

  /**
   * 根据分析结果和相应的模板路径生成模板代码，并返回生成文件的路径
   * @param analyzeResult 分析结果
   * @param pageSourceFile 源文件路径
   * @param tempFilePath 模板路径
   * @returns 生成文件的路径
   */
  generateBuilder(analyzeResult: HMRouterResult, pageSourceFile: string, tempFilePath: string) {
    // 获取导入路径
    let importPath = this.config
      .getRelativeBuilderPath(pageSourceFile)
      .replaceAll(HMRouterPluginConstant.FILE_SEPARATOR, HMRouterPluginConstant.DELIMITER)
      .replaceAll(HMRouterPluginConstant.VIEW_NAME_SUFFIX, '');
    // 生成视图名称
    let generatorViewName =
      HMRouterPluginConstant.VIEW_NAME_PREFIX + analyzeResult.name + this.stringToHashCode(analyzeResult.pageUrl!);
    // 创建模板模型
    const templateModel: TemplateModel = new TemplateModel(
      analyzeResult.pageUrl, importPath, analyzeResult.name!,
      !!analyzeResult.dialog, generatorViewName
    );
    // 生成模板字符串
    const tpl = HMFileUtil.readFileSync(tempFilePath).toString();
    const templateStr = ejs.render(tpl, templateModel);
    // 获取生成文件路径
    const generatorFilePath = this.config.getGeneratedFilePath(templateModel.generatorViewName);
    HMFileUtil.ensureFileSync(generatorFilePath);
    HMFileUtil.writeFileSync(generatorFilePath, templateStr);
    Logger.info(`Builder ${templateModel.generatorViewName}.ets has been generated in ${generatorFilePath}`);
    // 返回生成文件路径和组件名称
    return this.config.getBuilderFilePath(templateModel.generatorViewName);
  }

  /**
   * 根据传入的路径通配符返回匹配的绝对路径列表
   * @param baseDir 根目录
   * @param globPattern 通配符模式
   * @returns 匹配的绝对路径数组
   */
  getAbsolutePaths(baseDir: string, globPattern: string): string[] {
    const allFiles = this.getAllFiles(baseDir);
    const matchedFiles = micromatch(allFiles, globPattern);
    // 将匹配的文件转换为绝对路径
    return matchedFiles.map(file => HMFileUtil.pathResolve(baseDir, file));
  }

  /**
   * 递归获取目录下所有文件
   * @param dir 根目录
   * @returns 文件路径数组
   */
  getAllFiles(dir: string): string[] {
    let files: string[] = [];
    const items = HMFileUtil.readdirSync(dir, {withFileTypes: true});
    for (const item of items) {
      const fullPath = path.join(dir, item.name);
      if (item.isDirectory()) {
        files = files.concat(this.getAllFiles(fullPath));
      } else {
        files.push(fullPath);
      }
    }
    return files;
  }

  /**
   * 递归获取目录下所有文件
   * @param str 需要转义的字符串
   * @returns 转化后的hash值
   */
  stringToHashCode(str: string): number {
    let hash = 0;
    if (str.length === 0) {
      return hash;
    }
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash |= 0; // 转换为32位整数
    }
    return hash;
  }
}
