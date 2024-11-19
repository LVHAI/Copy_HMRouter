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
import { expect } from 'chai';
import { HMRouterPluginConfig } from '../src/HMRouterPluginConfig';
import { AnalyzerController } from '../src/HMRouterAnalyzer';
import { AnalyzerResultLike, HMServiceResult } from '../src/common/PluginModel';
import HMFileUtil from '../src/utils/FileUtil';
import HMRouterPluginConstant from '../src/constants/CommonConstants';
import ObfuscationUtil from '../src/utils/ObfuscationUtil';
import { HMRouterHvigorPlugin } from '../src/HMRouterHvigorPlugin';

interface RouterInfo {
  name: string;
  pageSourceFile: string;
  buildFunction: string;
  customData: AnalyzerResultLike;
}

describe('Normal', () => {
  it('Router config parse', () => {
    let params = {
      scanDir: ['src/main/ets/components', 'src/main/ets/interceptors'],
      builderDir: 'src/main/ets/_hm_generated',
    };
    let config: HMRouterPluginConfig = new HMRouterPluginConfig('testModule', '/workspace/entry/', '', params);
    expect(config.scanDir[0]).to.have.eq('src/main/ets/components');
    expect(config.scanDir[1]).to.have.eq('src/main/ets/interceptors');
    expect(config.builderDir).to.have.eq('src/main/ets/_hm_generated');
    expect(config.getBuilderDir()).to.have.eq('/workspace/entry/src/main/ets/_hm_generated');
    expect(config.getBuilderFilePath('MainPage-10086')).to.have.eq('src/main/ets/_hm_generated/MainPage-10086.ets');
    expect(config.getModuleRouterMapFilePath('router_map')).to.have.eq(
      '/workspace/entry/src/main/resources/base/profile/router_map.json'
    );
    expect(config.getGeneratedFilePath('MainPage-10086')).to.have.eq(
      '/workspace/entry/src/main/ets/_hm_generated/MainPage-10086.ets'
    );
    expect(config.getRawFilePath()).to.have.eq('/workspace/entry/src/main/resources/rawfile/hm_router_map.json');
    expect(config.getRelativeBuilderPath('src/main/ets/components/MainPage.ets')).to.have.eq(
      '../components/MainPage.ets'
    );
    expect(config.getRelativeSourcePath('/workspace/entry/src/main/ets/components/MainPage.ets')).to.have.eq(
      'src/main/ets/components/MainPage.ets'
    );
    expect(config.getRouterMapDir()).to.have.eq('/workspace/entry/src/main/resources/base/profile/hm_router_map.json');
    expect(config.getScanPath('src/main/ets/interceptors')).to.have.eq('/workspace/entry/src/main/ets/interceptors');
    expect(config.getDefaultTplFilePath()).to.have.contain('HMRouterPlugin/viewBuilder.ejs');
  });
});

describe('analyzeFile with AnalyzerController', () => {
  let controller: AnalyzerController;
  let config: HMRouterPluginConfig;

  beforeEach(() => {
    config = new HMRouterPluginConfig('testModule', HMFileUtil.pathResolve(__dirname, './cases'), '', {});
    controller = new AnalyzerController();
  });

  it('should correctly parse a valid file and return a Set', () => {
    const filePath = path.resolve(config.modulePath, 'MainPage.ets');
    controller.analyzeFile(filePath, config);
    const resultSet = controller.getAnalyzeResultSet();
    // 验证返回结果是一个 Set
    expect(resultSet).to.be.instanceOf(Set);
    // 验证 Set 中包含解析后的数据
    expect(Array.from(resultSet)).to.deep.include({
      annotation: 'HMRouter',
      name: 'MainPage',
      pageUrl: 'mainPage',
      pageSourceFile: filePath,
    });
  });

  it('should throw an error for an empty file path', () => {
    // 测试空字符串场景
    const filePath = path.resolve(config.modulePath, 'EmptyCase.ets');
    expect(() => controller.analyzeFile(filePath, config)).to.throw('constant value cannot be an empty string');
  });

  it('should throw an error if multiple @HMRouter decorators are found', () => {
    // 测试一个文件中存在多个 @HMRouter 装饰器的场景
    const filePath = path.resolve(config.modulePath, 'MultipleCase.ets');
    expect(() => controller.analyzeFile(filePath, config)).to.throw(
      'File:' + filePath + ' exists more than one @HMRouter annotation'
    );
  });

  it('should throw an error if @HMRouter decorator is used on a component containing NavDestination', () => {
    // 测试使用 @HMRouter 装饰器修饰的组件内包含 NavDestination 的场景
    const filePath = path.resolve(config.modulePath, 'ErrorDecoration.ets');
    expect(() => controller.analyzeFile(filePath, config)).to.throw(
      'NavDestination is not allowed in HMRouter, filePath:' + filePath
    );
  });
});

describe('buildObfuscatedStrings', () => {
  let buildObfuscatedStrings = ObfuscationUtil.buildObfuscatedStrings;

  it('should correctly build obfuscated strings from routerMap', () => {
    const routerMap: RouterInfo[] = [
      {
        pageSourceFile: 'src/pages/Home.ts',
        name: '__Home',
        buildFunction: '',
        customData: { name: 'HomeComponent' },
      },
      {
        pageSourceFile: 'src/pages/About.ts',
        name: '__service__About',
        buildFunction: '',
        customData: {
          functionName: 'getAboutData',
          name: 'About',
        } as HMServiceResult,
      },
    ];

    const expectedString =
      HMRouterPluginConstant.KEEP_FILE_NAME +
      HMRouterPluginConstant.LINE_BREAK +
      [
        HMRouterPluginConstant.CURRENT_DELIMITER + 'src/pages/Home.ts',
        HMRouterPluginConstant.CURRENT_DELIMITER + 'src/pages/About.ts',
        HMRouterPluginConstant.KEEP_PROPERTY_NAME,
        'HomeComponent',
        'About',
        'getAboutData',
      ].join(HMRouterPluginConstant.LINE_BREAK);

    const result = buildObfuscatedStrings(routerMap);

    expect(result).to.equal(expectedString);
  });

  it('should return only unique values in srcPathArr, classNameArr, and functionName', () => {
    const routerMap: RouterInfo[] = [
      {
        pageSourceFile: 'src/pages/Home.ts',
        name: '__Home',
        buildFunction: '',
        customData: { name: 'HomeComponent' },
      },
      {
        pageSourceFile: 'src/pages/Home.ts', // 重复路径
        name: '__Home',
        buildFunction: '',
        customData: { name: 'HomeComponent' },
      },
      {
        pageSourceFile: 'src/pages/About.ts',
        name: '__service__About',
        buildFunction: '',
        customData: {
          functionName: 'getAboutData',
          name: 'About',
        } as HMServiceResult,
      },
    ];

    const expectedString =
      HMRouterPluginConstant.KEEP_FILE_NAME +
      HMRouterPluginConstant.LINE_BREAK +
      [
        HMRouterPluginConstant.CURRENT_DELIMITER + 'src/pages/Home.ts',
        HMRouterPluginConstant.CURRENT_DELIMITER + 'src/pages/About.ts',
        HMRouterPluginConstant.KEEP_PROPERTY_NAME,
        'HomeComponent',
        'About',
        'getAboutData',
      ].join(HMRouterPluginConstant.LINE_BREAK);
    const result = buildObfuscatedStrings(routerMap);
    expect(result).to.equal(expectedString);
    expect(result.split(HMRouterPluginConstant.LINE_BREAK)).to.have.lengthOf(7); // 验证长度
  });

  it('should return the correct string when some fields are empty', () => {
    const routerMap: RouterInfo[] = [
      {
        pageSourceFile: '',
        name: '__Home',
        buildFunction: '',
        customData: { name: '' },
      },
      {
        pageSourceFile: 'src/pages/About.ts',
        name: '__service__About',
        buildFunction: '',
        customData: {
          functionName: 'getAboutData',
          name: 'About',
        } as HMServiceResult,
      },
    ];

    const expectedString =
      HMRouterPluginConstant.KEEP_FILE_NAME +
      HMRouterPluginConstant.LINE_BREAK +
      [
        './',
        HMRouterPluginConstant.CURRENT_DELIMITER + 'src/pages/About.ts',
        HMRouterPluginConstant.KEEP_PROPERTY_NAME,
        '',
        'About',
        'getAboutData',
      ].join(HMRouterPluginConstant.LINE_BREAK);
    const result = buildObfuscatedStrings(routerMap);
    expect(result).to.equal(expectedString);
  });

  it('should return only the KEEP_PROPERTY_NAME if routerMap is empty', () => {
    const routerMap: RouterInfo[] = [];
    const expectedString =
      HMRouterPluginConstant.KEEP_FILE_NAME +
      HMRouterPluginConstant.LINE_BREAK +
      HMRouterPluginConstant.KEEP_PROPERTY_NAME;
    const result = buildObfuscatedStrings(routerMap);
    expect(result).to.equal(expectedString);
  });
});

describe('should return resolved template path for matched Home file', () => {
  let plugin: HMRouterHvigorPlugin;
  let config: HMRouterPluginConfig;
  beforeEach(() => {
    config = new HMRouterPluginConfig(
      'testModule',
      HMFileUtil.pathResolve(__dirname, './cases'),
      HMFileUtil.pathResolve(__dirname, './cases'),
      {
        defaultPageTemplate: 'templates/default_template.tpl',
        customPageTemplate: [
          {
            srcPath: ['**/component/Home/**/*.ets'],
            templatePath: 'templates/home_shopping_template.tpl',
          },
          {
            srcPath: ['**/common/**/*.ets'],
            templatePath: 'templates/common_template.tpl',
          },
          {
            srcPath: ['**/live/**/*.ets'],
            templatePath: 'templates/live_template.tpl',
          },
        ],
      }
    );
    plugin = new HMRouterHvigorPlugin(config);
  });

  it('should return resolved template path for matched Home file', () => {
    const result = plugin.matchedPath(
      '/workspace/entry//HMRouter/entry/src/main/ets/component/Home/Categories.ets',
      plugin.config.customPageTemplate,
      plugin.config.getDefaultTplFilePath()
    );
    expect(result).to.equal(HMFileUtil.pathResolve(config.modulePath, 'templates/home_shopping_template.tpl'));
  });

  it('should return resolved template path for matched common file', () => {
    const result = plugin.matchedPath(
      '/workspace/entry//HMRouter/entry/src/main/ets/component/common/ButtonTabs.ets',
      plugin.config.customPageTemplate,
      plugin.config.getDefaultTplFilePath()
    );
    expect(result).to.equal(HMFileUtil.pathResolve(config.modulePath, 'templates/common_template.tpl'));
  });

  it('should return resolved template path for matched live file', () => {
    const result = plugin.matchedPath(
      '/workspace/entry//HMRouter/entry/src/main/ets/component/live/Live.ets',
      plugin.config.customPageTemplate,
      plugin.config.getDefaultTplFilePath()
    );
    expect(result).to.equal(HMFileUtil.pathResolve(config.modulePath, 'templates/live_template.tpl'));
  });

  it('should return default template path for unmatched file', () => {
    const result = plugin.matchedPath(
      '/workspace/entry//HMRouter/entry/src/main/ets/unknown/UnknownFile.ets',
      plugin.config.customPageTemplate,
      plugin.config.getDefaultTplFilePath()
    );
    expect(result).to.equal(plugin.config.getDefaultTplFilePath());
  });

  it('should return default template path for unsupported file type', () => {
    const result = plugin.matchedPath(
      '/workspace/entry//HMRouter/entry/src/main/ets/component/Home/UnsupportedFile.txt',
      plugin.config.customPageTemplate,
      plugin.config.getDefaultTplFilePath()
    );
    expect(result).to.equal(plugin.config.getDefaultTplFilePath());
  });

  it('should return resolved template path for multiple matches but take first', () => {
    const result = plugin.matchedPath(
      '/HMRouter/entry/src/main/ets/component/Home/ExtraCategories.ets',
      [
        ...plugin.config.customPageTemplate,
        {
          srcPath: ['**/component/Home/**/*.ets'],
          templatePath: 'templates/another_home_template',
        },
      ],
      plugin.config.getDefaultTplFilePath()
    );
    expect(result).to.equal(HMFileUtil.pathResolve(config.modulePath, 'templates/home_shopping_template.tpl'));
  });
});
