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
import HMFileUtil from './utils/FileUtil';
import HMRouterPluginConstant from './constants/CommonConstants';
import ConfigConstants from './constants/ConfigConstants';

export class HMRouterPluginConfig {
  moduleName: string;
  modulePath: string;
  configDir: string;
  scanDir: string[];
  routerMapDir: string;
  builderDir: string;
  annotation: string[];
  defaultPageTemplate: string;
  customPageTemplate: CustomPageTemplateImpl[];
  saveGeneratedFile: boolean;
  autoObfuscation: boolean;

  constructor(moduleName: string, modulePath: string, configDir: string, param: HMRouterPluginConfigParam) {
    this.moduleName = moduleName;
    this.modulePath = modulePath;
    this.configDir = configDir;
    this.scanDir = param.scanDir ? [...new Set(param.scanDir)] : [ConfigConstants.DEFAULT_SCAN_DIR];
    this.routerMapDir = param.routerMapDir ? param.routerMapDir : ConfigConstants.DEFAULT_ROUTER_MAP_DIR;
    this.builderDir = param.builderDir ? param.builderDir : ConfigConstants.DEFAULT_BUILD_DIR;
    this.annotation = [
      ConfigConstants.ROUTER_ANNOTATION,
      ConfigConstants.ANIMATOR_ANNOTATION,
      ConfigConstants.INTERCEPTOR_ANNOTATION,
      ConfigConstants.LIFECYCLE_ANNOTATION,
      ConfigConstants.SERVICE_ANNOTATION
    ];
    this.defaultPageTemplate =
      param.defaultPageTemplate ? param.defaultPageTemplate : ConfigConstants.DEFAULT_BUILD_TPL;
    this.customPageTemplate = param.customPageTemplate ? param.customPageTemplate : [];
    this.saveGeneratedFile = !!param.saveGeneratedFile;
    this.autoObfuscation = !!param.autoObfuscation;
    this.checkCorrectFolder();
  }

  private checkCorrectFolder() {
    this.scanDir = this.scanDir.map((item) => {
      let filePath = HMFileUtil.pathResolve(this.modulePath, item);
      if (HMFileUtil.exist(filePath) && HMFileUtil.isDictionary(filePath)) {
        return item + HMRouterPluginConstant.WILDCARD;
      }
      return item;
    });

    this.customPageTemplate.forEach((item) => {
      item.srcPath = item.srcPath.map((path) => {
        let filePath = HMFileUtil.pathResolve(this.modulePath, path);
        if (HMFileUtil.exist(filePath) && HMFileUtil.isDictionary(filePath)) {
          return item + HMRouterPluginConstant.WILDCARD;
        }
        return path;
      });
    });
  }

  getScanPath(dir: string) {
    return HMFileUtil.pathResolve(this.modulePath, dir);
  }

  getRelativeSourcePath(filePath: string) {
    return path.relative(this.modulePath, filePath);
  }

  getRelativeBuilderPath(filePath: string) {
    return path.relative(this.builderDir, filePath);
  }

  getGeneratedFilePath(generatorViewName: string) {
    return HMFileUtil.pathResolve(
      this.modulePath,
      this.builderDir,
      generatorViewName + HMRouterPluginConstant.VIEW_NAME_SUFFIX
    );
  }

  getBuilderDir() {
    return HMFileUtil.pathResolve(this.modulePath, this.builderDir);
  }

  getBuilderFilePath(generatorViewName: string) {
    return path.join(this.builderDir, generatorViewName + HMRouterPluginConstant.VIEW_NAME_SUFFIX);
  }

  getRouterMapDir() {
    return HMFileUtil.pathResolve(this.modulePath, this.routerMapDir, HMRouterPluginConstant.ROUTER_MAP_NAME);
  }

  getModuleRouterMapFilePath(routerMapFileName: string) {
    return HMFileUtil.pathResolve(
      this.modulePath,
      this.routerMapDir,
      routerMapFileName + HMRouterPluginConstant.JSON_SUFFIX
    );
  }

  getRawFilePath() {
    return HMFileUtil.pathResolve(this.modulePath, HMRouterPluginConstant.RAWFILE_DIR);
  }

  getDefaultTplFilePath() {
    let templateFilePath = HMFileUtil.pathResolve(this.configDir, this.defaultPageTemplate);
    if (HMFileUtil.exist(templateFilePath)) {
      return templateFilePath;
    }
    return HMFileUtil.pathResolve(__dirname, HMRouterPluginConstant.PARENT_DELIMITER + this.defaultPageTemplate);
  }

  getObfuscationFilePath() {
    return HMFileUtil.pathResolve(this.modulePath, HMRouterPluginConstant.OBFUSCATION_FILE_NAME);
  }
}

export interface HMRouterPluginConfigParam {
  scanDir?: string[];
  routerMapDir?: string;
  builderDir?: string;
  autoObfuscation?: boolean;
  saveGeneratedFile?: boolean;
  defaultPageTemplate?: string;
  customPageTemplate?: CustomPageTemplateImpl[];
}

export interface CustomPageTemplateImpl {
  srcPath: string[];
  templatePath: string;
}
