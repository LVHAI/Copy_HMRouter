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

import {
ClassDeclaration,
Decorator,
Expression,
MethodDeclaration,
PropertyAccessExpression,
PropertyAssignment,
SourceFile,
SyntaxKind
} from 'ts-morph';
import { AnalyzerResultLike, HMRouterResult, HMServiceResult } from './common/PluginModel';
import { Logger, PluginError } from './common/Logger';
import HMRouterPluginConstant from './constants/CommonConstants';
import { importVariableCache, project, TsAstUtil } from './utils/TsAstUtil';
import HMFileUtil from './utils/FileUtil';
import { HMRouterPluginConfig } from './HMRouterPluginConfig';

export class AnalyzerController {
  private analyzeResult: Set<AnalyzerResultLike> = new Set();

  analyzeFile(sourceFilePath: string, config: HMRouterPluginConfig) {
    let analyzerService = new AnalyzerService(sourceFilePath, config);
    analyzerService.start();
    analyzerService.getResult().forEach(item => {
      item.pageSourceFile = sourceFilePath;
      this.analyzeResult.add(item);
    });
    this.parsePageUrl();
  }

  // 解析常量类型的pageUrl
  parsePageUrl() {
    this.analyzeResult.forEach((item) => {
      if (item.annotation !== 'HMRouter') {
        return;
      }
      let pageUrl = (item as HMRouterResult).pageUrl;
      if (pageUrl.type === 'constant') {
        pageUrl =
          TsAstUtil.parseConstantValue(project!.addSourceFileAtPath(pageUrl.variableFilePath), pageUrl.variableName);
      } else if (pageUrl.type === 'object') {
        pageUrl = TsAstUtil.parseConstantValue(project!.addSourceFileAtPath(pageUrl.variableFilePath),
          pageUrl.variableName, pageUrl.propertyName);
      }
      if (pageUrl === '') {
        Logger.error(PluginError.ERR_NOT_EMPTY_STRING);
        throw new Error('constant value cannot be an empty string');
      }
      (item as HMRouterResult).pageUrl = pageUrl;
    });
  }

  getAnalyzeResultSet() {
    return this.analyzeResult;
  }
}

class AnalyzerService {
  private readonly sourceFilePath: string;
  private sourceFile: SourceFile;
  private config: HMRouterPluginConfig;
  private analyzerResultSet: Set<AnalyzerResultLike> = new Set();
  private importMap: Map<string, string[]> = new Map();

  constructor(sourceFilePath: string, config: HMRouterPluginConfig) {
    this.sourceFilePath = sourceFilePath;
    this.sourceFile = TsAstUtil.getSourceFile(sourceFilePath)!;
    this.config = config;
  }

  // 启动分析器
  start() {
    // 解析Import变量
    this.analyzeImport();
    // 解析HMRouter标签
    this.analyzeRouter();
    // 解析生命周期，动画，拦截器，服务路由标签
    this.analyzeComponent();
    // 逐行解析判断HMRouter修饰的组件是否包含NavDestination
    this.parseFileByLineOrder();
  }

  // 获取分析结果
  getResult() {
    // 判断是否存在多个HMRouter注解
    let HMRouterNum = 0;
    this.analyzerResultSet.forEach((analyzerResult: AnalyzerResultLike) => {
      if (analyzerResult.annotation === HMRouterPluginConstant.ROUTER_ANNOTATION) {
        HMRouterNum++;
      }
    });
    if (HMRouterNum > 1) {
      Logger.error(PluginError.ERR_REPEAT_ANNOTATION, this.sourceFilePath);
      throw new Error(`File:${this.sourceFilePath} exists more than one @HMRouter annotation`);
    }
    return this.analyzerResultSet;
  }

  // 解析Import
  private analyzeImport() {
    this.sourceFile.getImportDeclarations().forEach(importDeclaration => {
      // 获取导入模块的路径
      const moduleSpecifier = importDeclaration.getModuleSpecifierValue();
      const namedImports = importDeclaration.getNamedImports().map(namedImport => namedImport.getName());
      const defaultImport = importDeclaration.getDefaultImport()?.getText();
      const namespaceImport = importDeclaration.getNamespaceImport()?.getText();
      // 创建一个数组来存储所有导入的变量名
      const importNames: string[] = [];
      // 添加命名导入
      if (namedImports.length > 0) {
        importNames.push(...namedImports);
      }
      // 添加默认导入
      if (defaultImport) {
        importNames.push(defaultImport);
      }
      // 添加命名空间导入
      if (namespaceImport) {
        importNames.push(namespaceImport);
      }
      // 将路径和对应的变量名存入 Map 中
      if (importNames.length > 0) {
        let variableFilePath = HMFileUtil.pathResolve(this.config.modulePath, moduleSpecifier);
        importNames.forEach((item) => {
          if (HMFileUtil.exist(variableFilePath)) {
            importVariableCache.set(variableFilePath + HMRouterPluginConstant.VARIABLE_SEPARATOR + item, '');
          }
        });
        // 单个文件的缓存一次
        this.importMap.set(moduleSpecifier, importNames);
      }
    });
  }

  // 分析页面路由
  private analyzeRouter() {
    // 获取文件中所有的ExpressionStatement得到struct关键字后面的组件名
    let viewNameArr = this.sourceFile.getChildrenOfKind(SyntaxKind.ExpressionStatement).map((node) => {
      return node.getText();
    }).filter((text) => {
      return text != 'struct';
    });

    // 获取文件中缺失声明获取HMRouter标签并解析参数
    this.sourceFile.getChildrenOfKind(SyntaxKind.MissingDeclaration).forEach((node, index) => {
      // 解析缺失声明的装饰器
      node.getChildrenOfKind(SyntaxKind.Decorator).forEach((decorator) => {
        this.addToResultSet(decorator, viewNameArr[index]);
      });
    });
  }

  // 逐行解析代码
  private parseFileByLineOrder() {
    // 1. 获取所有顶层语句（statement）
    const statements = this.sourceFile.getStatements();
    // 2. 按代码中的位置（起始位置）进行排序
    const sortedStatements = statements.sort((a, b) => a.getStart() - b.getStart());
    let HMRouterExists: boolean = false;
    // 3. 逐行解析
    sortedStatements.forEach(statement => {
      // 识别到缺失声明，并且是否有HMRouter
      if (statement.getKind() === SyntaxKind.MissingDeclaration && statement.getText().includes('HMRouter')) {
        HMRouterExists = true;
      }
      // 逐行解析时如果HMRouter紧挨着的代码块
      if (statement.getKind() === SyntaxKind.Block && HMRouterExists) {
        // 判断完成重制状态
        HMRouterExists = false;
        statement.getDescendantsOfKind(SyntaxKind.Identifier).forEach((node) => {
          if (node.getText() === 'NavDestination') {
            Logger.error(PluginError.ERR_WRONG_DECORATION);
            throw new Error('NavDestination is not allowed in HMRouter, filePath:' + this.sourceFilePath);
          }
        });
      }
    });
  }

  // 分析组件
  private analyzeComponent() {
    // 获取文件内所有的class
    this.sourceFile.getClasses().forEach((cls: ClassDeclaration) => {
      // 获取class的所有装饰器并解析
      cls.getDecorators().forEach((decorator: Decorator) => {
        if (this.config.annotation.includes(decorator.getName())) {
          this.addToResultSet(decorator, cls.getName()!);
        }
      });
      // 获取class中所有的方法，并解析方法的HMService标签
      cls.getMethods().forEach((method: MethodDeclaration) => {
        method.getDecorators().forEach((decorator: Decorator) => {
          let serviceResult = this.addToResultSet(decorator, cls.getName()!) as HMServiceResult;
          serviceResult.functionName = method.getName();
        });
      });
    });
  }

  // 添加结果到分析Set中
  private addToResultSet(decorator: Decorator, componentName: string) {
    let decoratorResult = this.parseDecorator(decorator);
    decoratorResult.name = componentName;
    // 添加到解析结果中
    if (decoratorResult.annotation) {
      this.analyzerResultSet.add(decoratorResult);
    }
    return decoratorResult;
  }

  // 解析装饰器
  private parseDecorator(decorator: Decorator): AnalyzerResultLike {
    let decoratorResult: AnalyzerResultLike = {};
    let decoratorName = decorator.getName();
    // 是否为框架提供的标签
    if (this.config.annotation.includes(decoratorName)) {
      decoratorResult.annotation = decoratorName;
      let args: AnalyzerResultLike = this.parseDecoratorArguments(decorator);
      // 对象赋值
      Object.assign(decoratorResult, args);
    }
    return decoratorResult;
  }

  // 解析装饰器参数
  private parseDecoratorArguments(decorator: Decorator): AnalyzerResultLike {
    let argResult: AnalyzerResultLike = {};
    decorator.getArguments().map(arg => {
      const objLiteral = arg.asKind(SyntaxKind.ObjectLiteralExpression);
      if (objLiteral) {
        objLiteral.getProperties().forEach((prop) => {
          let propertyName = (prop as PropertyAssignment).getName();
          let propertyValue = propertyName === HMRouterPluginConstant.PAGE_URL ?
          this.parsePageUrlValue((prop as PropertyAssignment).getInitializer()!) :
          this.parsePropertyValue((prop as PropertyAssignment).getInitializer()!);
          Reflect.set(argResult, propertyName, propertyValue);
        });
      }
    });
    return argResult;
  }

  // 针对PageUrl特殊处理
  private parsePageUrlValue(value: Expression): any {
    switch (value.getKind()) {
      case SyntaxKind.Identifier:
        // 常量值
        return {
          type: 'constant',
          variableName: value.getText(),
          variableFilePath: this.getVariableFilePath(value.getText())
        };
      case SyntaxKind.PropertyAccessExpression:
        // 静态变量值
        return {
          type: 'object',
          variableName: (value as PropertyAccessExpression).getExpression().getText(),
          propertyName: (value as PropertyAccessExpression)?.getName(),
          variableFilePath: this.getVariableFilePath((value as PropertyAccessExpression)?.getExpression().getText())
        };
      default:
        return this.parsePropertyValue(value);
    }
  }

  // 获取属性的真实值
  private parsePropertyValue(value: Expression): any {
    let propertyValue;
    switch (value.getKind()) {
      case SyntaxKind.StringLiteral:
        propertyValue = value.asKind(SyntaxKind.StringLiteral)?.getLiteralValue();
        break;
      case SyntaxKind.TrueKeyword:
        propertyValue = true;
        break;
      case SyntaxKind.FalseKeyword:
        propertyValue = false;
        break;
      case SyntaxKind.ArrayLiteralExpression:
        propertyValue = value.asKind(SyntaxKind.ArrayLiteralExpression)?.getElements()
          .map(item => item.asKind(SyntaxKind.StringLiteral)?.getLiteralValue());
        break;
    }
    return propertyValue;
  }

  // 获取当前变量所在的文件路径
  private getVariableFilePath(variableName: string): string {
    let classesNames = this.sourceFile.getClasses().map((classes) => {
      return classes.getName()!;
    });
    let variableNames = this.sourceFile.getVariableDeclarations().map((variableDeclaration) => {
      return variableDeclaration.getName();
    });
    if (classesNames.includes(variableName) || variableNames.includes(variableName)) {
      return this.sourceFilePath;
    } else {
      let filePath = '';
      this.importMap.forEach((value, key) => {
        if (value.includes(variableName)) {
          filePath =
            HMFileUtil.pathResolve(this.sourceFilePath.split(HMRouterPluginConstant.FILE_SEPARATOR).slice(0, -1)
              .join(HMRouterPluginConstant.FILE_SEPARATOR), key) + HMRouterPluginConstant.VIEW_NAME_SUFFIX;
        }
      });
      return filePath;
    }
  }
}