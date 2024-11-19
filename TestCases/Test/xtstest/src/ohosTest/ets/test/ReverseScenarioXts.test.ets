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
import { HMRouterMgr } from '@hadss/hmrouter';
import { driver, startAbility } from './CommonTestUtil';
import { ON } from '@kit.TestKit';
import { router } from '@kit.ArkUI';

/**
 * 逆向场景XTS用例
 */
export default function ReverseScenarioXtsTest() {
  describe('ReverseScenarioXtsTest', () => {
    beforeAll(async () => {
      // 启动ability
      await startAbility()
      await driver.findComponent(ON.text('HomePage'))
    })

    // ERR_PUSH_INVALID 40002001
    it('assertPushWithErrorPageUrl', 0, async () => {
      let result = true;
      HMRouterMgr.push({
        pageUrl: 'xxxx'
      }, {
        onLost: () => {
          console.log('Test reverse scenario, push page don\'t exist')
          result = false;
        }
      })
      await driver.delayMs(10);
      expect(result).assertFalse()
    })

    // ERR_PARAM_ILLEGAL 40003002
    it('assertPushWithErrorNavigationId', 0, () => {
      HMRouterMgr.push({
        navigationId: 'xxx',
        pageUrl: 'xtsTestOnePage'
      })
    })

    // ERR_REPLACE_INVALID 40002005
    it('assertReplaceWithErrorPageUrl', 0, async () => {
      let result = true;
      HMRouterMgr.replace({
        pageUrl: 'xxxx'
      }, {
        onLost: () => {
          console.log('Test reverse scenario, replace page don\'t exist')
          result = false;
        }
      })
      await driver.delayMs(10);
      expect(result).assertFalse()
    })

    // ERR_PARAM_ILLEGAL 40003002
    it('assertReplaceWithErrorNavigationId', 0, () => {
      HMRouterMgr.push({
        navigationId: 'xxx',
        pageUrl: 'xtsTestOnePage'
      })
    })

    // ERR_POP_INVALID 40002003
    it('assertPopWithErrorPageUrl', 0, () => {
      HMRouterMgr.pop({
        pageUrl: 'xxxx'
      })
    })

    // ERR_PARAM_ILLEGAL 40003002
    it('assertPopWithErrorNavigationId', 0, () => {
      HMRouterMgr.pop({
        navigationId: 'xxx',
        pageUrl: 'xtsTestOnePage'
      })
    })

    it('assertGetPathStackWithErrorNavigationId', 0, () => {
      let pathStack = HMRouterMgr.getPathStack('xxx')
      expect(pathStack === null || pathStack === undefined).assertTrue()
    })

    it('assertGetCurrentParamWithNoParam', 0, () => {
      let param = HMRouterMgr.getCurrentParam()
      expect(param === null || param === undefined).assertTrue()
    })

    it('assertGetCurrentParamWithNoLifecycle', 0, async () => {
      await router.replaceUrl({
        url: 'pages/Index2'
      });
      await driver.findComponent(ON.text('Index2'));
      let lifecycle = HMRouterMgr.getCurrentLifecycleOwner();
      expect(lifecycle === null || lifecycle == undefined).assertTrue();
    })

    it('assertUnRegisterGlobalInterceptorWithErrorName', 0, () => {
      expect(HMRouterMgr.unRegisterGlobalInterceptor('xxx') === false).assertTrue()
    })

    it('assertUnRegisterGlobalAnimatorWithErrorNavigationId', 0, () => {
      expect(HMRouterMgr.unRegisterGlobalAnimator('xxx', 'standard') === false).assertTrue()
    })

    it('assertRequestWithErrorName', 0, () => {
      expect(HMRouterMgr.request('xxxxx').code === 4001).assertTrue();
    })

    it('assertRequestWithErrorService', 0, () => {
      expect(HMRouterMgr.request('testFunWithError').code === 4002).assertTrue();
    })
  })
}