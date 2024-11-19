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

export type AnalyzerResultLike =
  HMRouterResult
    | HMAnimatorResult
    | HMInterceptorResult
    | HMLifecycleResult
    | HMServiceResult;

export interface BaseAnalyzeResult {
  name?: string; // 类名
  module?: string; // 模块名
  annotation?: string; // 注解
  pageSourceFile?: string; // 文件资源路径
}

export interface HMRouterResult extends BaseAnalyzeResult {
  pageUrl?: any; // 跳转路径
  dialog?: boolean; // 是否弹窗
  singleton?: boolean; // 是否单例
  interceptors?: string[]; // 拦截器
  animator?: string; // 动画
  lifecycle?: string; // 生命周期
}

export interface HMAnimatorResult extends BaseAnalyzeResult {
  animatorName?: string; // 动画名称
}

export interface HMInterceptorResult extends BaseAnalyzeResult {
  interceptorName?: string; // 拦截器名称
  priority?: number; // 优先级
  global?: boolean; // 是否全局
}

export interface HMLifecycleResult extends BaseAnalyzeResult {
  lifecycleName?: string; // 生命周期名称
  priority?: number; // 优先级
  global?: boolean; // 是否全局
}

export interface HMServiceResult extends BaseAnalyzeResult {
  serviceName?: string; // 服务名称
  functionName?: string; // 函数名称
  singleton?: boolean; // 是否单例
}

export class TemplateModel {
  pageUrl: string;
  importPath: string;
  componentName: string;
  dialog: boolean;
  generatorViewName: string;

  constructor(pageUrl: string, importPath: string, componentName: string, dialog: boolean, generatorViewName: string) {
    this.pageUrl = pageUrl;
    this.importPath = importPath;
    this.componentName = componentName;
    this.dialog = dialog;
    this.generatorViewName = generatorViewName;
  }
}

export class RouterInfo {
  name: string;
  pageSourceFile: string;
  buildFunction: string;
  customData: AnalyzerResultLike;

  constructor(name: string, pageSourceFile: string, buildFunction: string, data: AnalyzerResultLike = {}) {
    this.name = name;
    this.pageSourceFile = pageSourceFile;
    this.buildFunction = buildFunction;
    this.customData = data;
  }
}
