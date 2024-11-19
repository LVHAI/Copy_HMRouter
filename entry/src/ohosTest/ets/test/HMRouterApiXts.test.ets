/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { beforeAll, describe, expect, it } from '@ohos/hypium';
import { ON } from '@kit.TestKit';
import { HMRouterMgr, HMRouterPathCallback, HMRouterPathInfo, IHMLifecycle } from '@hadss/hmrouter';
import { driver, startAbility } from './util/CommonTestUtil';
import { ZoomAnimator } from '../../../main/ets/animation/CustomPageAnimator';
import { LoginStatusInterceptor } from '../../../main/ets/interceptor/LoginStatusInterceptor';
import { WelcomeLifecycle } from '../../../main/ets/lifecycle/WelcomeLifecycle';
import { animatorTransitionBuilder } from '../../../main/ets/component/mine/AnimatorTransition';

const delayTime = 10;
const navigationId = 'mainNavigationId';

export default function HMRouterApiTest() {
  beforeAll(async () => {
    // 启动ability
    await startAbility();
  });

  describe('HMRouterApiTest', () => {
    it('openLog', 0, async () => {
      HMRouterMgr.openLog('DEBUG');
    });

    it('push', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.push(pathInfo1, callback);
      await driver.delayMs(delayTime);
      let navPathStack = HMRouterMgr.getPathStack(navigationId);
      expect(getLastPathName(navPathStack)).assertEqual('myAccount');
      HMRouterMgr.pop();
    });

    it('replace', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.push(pathInfo1);
      HMRouterMgr.replace(pathInfo2, callback);
      await driver.delayMs(delayTime);
      let navPathStack = HMRouterMgr.getPathStack(navigationId);
      expect(navPathStack?.size() === 2).assertTrue();
      expect(getLastPathName(navPathStack)).assertEqual('privacyPage');
      HMRouterMgr.pop();
    });

    it('pop', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.push(pathInfo1, callback);
      await driver.delayMs(delayTime);
      HMRouterMgr.pop(homePathInfo);
      await driver.delayMs(delayTime);
      let navPathStack = HMRouterMgr.getPathStack(navigationId);
      expect(navPathStack?.size() === 1).assertTrue();
      expect(getLastPathName(navPathStack)).assertEqual('HomeContent');
    });

    it('getPathStack', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      let navPathStack = HMRouterMgr.getPathStack(navigationId);
      expect(navPathStack?.size() === 1).assertTrue();
    });

    it('getCurrentParam', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.push(pathInfo1);
      await driver.delayMs(delayTime);
      let param = HMRouterMgr.getCurrentParam() as string;
      expect(param).assertEqual('123');
      HMRouterMgr.pop();
    });

    it('getCurrentLifecycleOwner', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      let lifecycle = HMRouterMgr.getCurrentLifecycleOwner();
      expect(lifecycle !== null).assertTrue();
    });

    it('generatePageLifecycleId', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      let pageLifecycleId = HMRouterMgr.generatePageLifecycleId();
      expect(pageLifecycleId === '1_pages/_Index').assertTrue();
    });

    it('getPageLifecycleById', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      let pageLifecycle = HMRouterMgr.getPageLifecycleById('1_pages/_Index');
      expect(pageLifecycle !== null).assertTrue();
    });

    it('request', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      let result = HMRouterMgr.request('testFunWithReturn');
      expect(result.code === 0).assertTrue();
    });

    it('registerGlobalInterceptor', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.registerGlobalInterceptor({
        interceptor: new LoginStatusInterceptor(),
        interceptorName: 'testLoginStatusInterceptor',
        priority: 9
      });
      let result = HMRouterMgr.unRegisterGlobalInterceptor('testLoginStatusInterceptor');

      expect(result).assertTrue();
    });

    it('registerGlobalLifecycle', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.registerGlobalLifecycle({
        lifecycle: new WelcomeLifecycle(),
        lifecycleName: 'testWelcomeLifecycle',
        priority: 9
      });
      let result = HMRouterMgr.unRegisterGlobalLifecycle('testWelcomeLifecycle');

      expect(result).assertTrue();
    });

    it('registerPageBuilder', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      HMRouterMgr.registerPageBuilder({
        builder: wrapBuilder(animatorTransitionBuilder),
        pageUrl: 'animatorTransition'
      });
      HMRouterMgr.push({
        navigationId: navigationId,
        pageUrl: 'animatorTransition'
      });
      await driver.delayMs(delayTime);
      let navPathStack = HMRouterMgr.getPathStack(navigationId);
      expect(navPathStack?.size() === 2).assertTrue();
      expect(getLastPathName(navPathStack)).assertEqual('animatorTransition');
      HMRouterMgr.pop();
    });

    it('testLifecycle', 0, async () => {
      await driver.assertComponentExist(ON.text('智慧办公'));
      let testLifecycle = new TestLifecycle();
      HMRouterMgr.registerGlobalLifecycle({
        lifecycle: testLifecycle,
        lifecycleName: 'testLifecycle',
        priority: 9
      });
      HMRouterMgr.push(pathInfo1);
      HMRouterMgr.push(pathInfo2);
      await driver.pressBack();
      HMRouterMgr.pop();
      HMRouterMgr.unRegisterGlobalLifecycle('testLifecycle');
    });
  });
}

function getLastPathName(navPathStack: NavPathStack | null) {
  let pathNames = navPathStack?.getAllPathName();
  if(pathNames) {
    return pathNames[pathNames.length-1];
  } else {
    return '';
  }
}

const callback: HMRouterPathCallback = {
  onResult: (popInfo: PopInfo) => {
    console.log('test callback onResult');
  },
  onArrival: () => {
    console.log('test callback onArrival');
  },
  onLost: () => {
    console.log('test callback onLost');
  }
};

const pathInfo1: HMRouterPathInfo = {
  navigationId: navigationId,
  pageUrl: 'myAccount',
  param: '123',
  interceptors: [new LoginStatusInterceptor()],
  animator: new ZoomAnimator(),
  skipAllInterceptor: false
};

const pathInfo2: HMRouterPathInfo = {
  navigationId: navigationId,
  pageUrl: 'privacyPage',
  param: '123',
  interceptors: [new LoginStatusInterceptor()],
  animator: new ZoomAnimator(),
  skipAllInterceptor: false
};

const homePathInfo: HMRouterPathInfo = {
  navigationId: navigationId,
  pageUrl: 'HomeContent',
  param: '123',
  interceptors: [new LoginStatusInterceptor()],
  animator: new ZoomAnimator(),
  skipAllInterceptor: false
};

class TestLifecycle implements IHMLifecycle {
}