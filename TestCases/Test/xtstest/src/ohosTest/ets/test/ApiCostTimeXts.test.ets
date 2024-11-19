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
import { HMDefaultGlobalAnimator, HMRouterMgr } from '@hadss/hmrouter';
import { builderPageBuilder } from '../../../main/ets/pages/testpage/BuilderPage';
import { driver, startAbility, XtsTestIHMInterceptor, XtsTestIHMLifecycle } from './CommonTestUtil';
import { ON } from '@kit.TestKit';

/**
 * API耗时XTS用例
 */
export default function ApiCostTimeXtsTest() {
  describe('ApiCostTimeXtsTest', () => {
    beforeAll(async () => {
      // 启动ability
      await startAbility()
      await driver.findComponent(ON.text('HomePage'))
    })

    it('assertOpenLogCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.openLog', () => {
        HMRouterMgr.openLog('DEBUG')
      })).assertFalse()
    })

    it('assertPushCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.push', () => {
        HMRouterMgr.push({
          pageUrl: 'xtsTestOnePage'
        })
      })).assertFalse()
    })

    it('assertReplaceCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.replace', () => {
        HMRouterMgr.replace({
          pageUrl: 'xtsTestTwoPage'
        })
      })).assertFalse()
    })

    it('assertPopCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.pop', () => {
        HMRouterMgr.pop()
      })).assertFalse()
    })

    it('assertGetPathStackCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.getPathStack', () => {
        HMRouterMgr.getPathStack('xtsTestNavigationId')
      })).assertFalse()
    })

    it('assertGetCurrentParamCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.getCurrentParam', () => {
        HMRouterMgr.getCurrentParam()
      })).assertFalse()
    })

    it('assertGetCurrentLifecycleCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.getCurrentLifecycle', () => {
        HMRouterMgr.getCurrentLifecycleOwner()
      })).assertFalse()
    })

    it('assertRegisterGlobalInterceptorCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.registerGlobalInterceptor', () => {
        HMRouterMgr.registerGlobalInterceptor({
          interceptor: new XtsTestIHMInterceptor(),
          interceptorName: 'xtsTestIHMInterceptor',
          priority: 8
        })
      })).assertFalse()
    })

    it('assertUnRegisterGlobalInterceptorCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.unRegisterGlobalInterceptor', () => {
        HMRouterMgr.unRegisterGlobalInterceptor('xtsTestIHMInterceptor')
      })).assertFalse()
    })

    it('assertRegisterGlobalLifecycleCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.registerGlobalLifecycle', () => {
        HMRouterMgr.registerGlobalLifecycle({
          lifecycle: new XtsTestIHMLifecycle(),
          lifecycleName: 'xtsTestIHMLifecycle',
          priority: 8
        })
      })).assertFalse()
    })

    it('assertUnRegisterGlobalLifecycleCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.unRegisterGlobalLifecycle', () => {
        HMRouterMgr.unRegisterGlobalLifecycle('xtsTestIHMLifecycle')
      })).assertFalse()
    })

    it('assertRegisterGlobalAnimatorCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.registerGlobalAnimator', () => {
        HMRouterMgr.registerGlobalAnimator('xtsTestNavigationId', 'standard',
          HMDefaultGlobalAnimator.STANDARD_ANIMATOR.toAnimator())
      })).assertFalse()
    })

    it('assertUnRegisterGlobalAnimatorCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.unRegisterGlobalAnimator', () => {
        HMRouterMgr.unRegisterGlobalAnimator('xtsTestNavigationId', 'standard')
      })).assertFalse()
    })

    it('assertRegisterPageBuilderCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.registerPageBuilder', () => {
        HMRouterMgr.registerPageBuilder({
          builder: wrapBuilder(builderPageBuilder),
          pageUrl: 'animatorTransition'
        })
      })).assertFalse()
    })

    it('assertRequestCostTime', 0, () => {
      expect(isOverTime('HMRouterMgr.request', () => {
        HMRouterMgr.request('testFunWithReturn');
      }, 1.5)).assertFalse()
    })
  })
}

// 超时门限5ms
const costTimeThread = 5;

// 测试次数
const iteratorTimes = 2000;

function isOverTime(funcName: string, func: () => void, costTimeThreshold: number = costTimeThread): boolean {
  let startTime = new Date().getTime();
  for (let index = 0; index < iteratorTimes; index++) {
    func();
  }
  let costAvgTime = (new Date().getTime() - startTime) / iteratorTimes;
  console.log(`Test api avg cost time, ${funcName}: ${costAvgTime} ms`)
  return isFloatGreaterPrecision(costAvgTime, costTimeThreshold);
}

function isFloatGreaterPrecision(left: number, right: number, precision = 0.000001): boolean {
  return left - right > precision;
}