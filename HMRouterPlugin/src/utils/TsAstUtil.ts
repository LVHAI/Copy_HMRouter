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

import { Expression, Project, ScriptTarget, SourceFile, SyntaxKind } from 'ts-morph';
import { FileUtil } from '@ohos/hvigor';
import { Logger, PluginError } from '../common/Logger';

export let project: Project | null = null;

export const importVariableCache: Map<string, string> = new Map();

export class TsAstUtil {
  // 获取SourceFile
  static getSourceFile(filePath: string): SourceFile | null {
    if (!FileUtil.exist(filePath)) {
      return null;
    }

    if (!project) {
      project = new Project({
        compilerOptions: { target: ScriptTarget.ES2021 }
      });
    }
    return project!.addSourceFileAtPath(filePath);
  }

  static clearProject() {
    project = null;
  }

  // 解析常量的结果
  static parseConstantValue(sourceFile: SourceFile, variableName: string, propertyName?: string): string {
    let result: string | Expression;
    // 判断是否有propertyName来决定是constant还是object
    if (propertyName) {
      // object
      let classInstance = sourceFile.getClasses().filter((classes) => {
        return classes.getName() === variableName;
      });
      if (classInstance.length === 0) {
        throw new Error(`Unknown class '${variableName}'`);
      }
      let property = classInstance[0].getProperties().filter((properties) => {
        return properties.getName() === propertyName;
      });
      if (property.length === 0) {
        throw new Error(`Unknown property '${propertyName}'`);
      }
      result = property[0].getInitializer()!;
    } else {
      // constant
      let constant = sourceFile.getVariableDeclarations().filter(declaration => {
        return declaration.getName() === variableName;
      })[0];
      if (!constant) {
        throw new Error(`Unknown constant '${variableName}'`);
      }
      result = constant.getInitializer()!;
    }
    if (result.getKind() !== SyntaxKind.StringLiteral) {
      Logger.error(PluginError.ERR_INVALID_STRING_VALUE, variableName);
      throw new Error('Invalid constant value');
    }
    return result.asKind(SyntaxKind.StringLiteral)?.getLiteralValue()!;
  }
}