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

import { beforeAll, describe, it } from '@ohos/hypium';
import { ON } from '@kit.TestKit';
import {
  driver,
  findAndClickComponent,
  findAndClickComponentById,
  pressBack,
  startAbility
} from './util/CommonTestUtil';

async function exitAndReturnHome() {
  // 退出登录
  await findAndClickComponent('我的');
  await findAndClickComponent('小艺');
  await findAndClickComponent('退出登录');
  await findAndClickComponent('退出');
  await driver.assertComponentExist(ON.text('点击登录')); // 校验是否已退出

  // 并返回首页
  await findAndClickComponent('首页');
  await driver.assertComponentExist(ON.text('智慧办公')); // 校验是否跳转到首页
}

export default function HMRouterTest() {
  beforeAll(async () => {
    // 启动ability
    await startAbility();
  });

  describe('HMRouterTest', () => {
    // 登录和退出登录
    it('accountLogin', 0, async () => {
      // 登录
      await findAndClickComponent('我的');
      await findAndClickComponent('点击登录');
      await findAndClickComponent('登录');
      if(!!!AppStorage.get('isPrivacy')) {
        await findAndClickComponent('同意');
        await findAndClickComponent('登录');
      }
      await driver.assertComponentExist(ON.text('小艺')); // 校验是否已登录

      // 切换全局动画
      await findAndClickComponent('转场动画设置');
      await findAndClickComponentById('customAnimationButton');
      await driver.assertComponentExist(ON.text('缩放')); // 校验是否到全局动画页面
      await findAndClickComponent('缩放');
      await findAndClickComponentById('systemAnimationButton');

      await pressBack();
      await exitAndReturnHome();
    });

    // 商品详情页面购买
    it('productDetailPageShopping', 0, async () => {
      // 首页跳转到商品详情
      await findAndClickComponentById('homeLivePicture');

      await driver.assertComponentExist(ON.id('liveHome')); // 校验是否跳转到详情页

      // 直播页面点击
      await findAndClickComponentById('liveHome');
      await findAndClickComponentById('comments');
      await pressBack();
      await pressBack();

      await driver.assertComponentExist(ON.id('liveHome')); // 校验是否跳转到详情页

      // 详情页购买
      await findAndClickComponent('购买');
      await findAndClickComponent('立即支付');

      // 购物登录拦截
      if(!!!AppStorage.get('isLogin')) {
        await driver.assertComponentExist(ON.text('登录')); // 校验是否跳转到登录页
        await findAndClickComponent('登录');
        if(!!!AppStorage.get('isPrivacy')) {
          await findAndClickComponent('同意');
          await findAndClickComponent('登录');
        }
        await findAndClickComponent('立即支付');
      }

      await findAndClickComponent('确认支付');
      await driver.assertComponentExist(ON.text('返回首页')); // 校验是否跳转到支付成功页面

      await findAndClickComponentById('returnButton');
      await driver.assertComponentExist(ON.text('已支付')); // 校验是否跳转到详情支付页面

      await pressBack();
      await pressBack();
      await driver.assertComponentExist(ON.text('智慧办公')); // 校验是否跳转到首页
      await exitAndReturnHome();
    });

    // 购物袋页面购买
    it('shoppingBagShopping', 0, async () => {
      await findAndClickComponent('购物袋');

      // 购物登录拦截
      if(!!!AppStorage.get('isLogin')) {
        await driver.assertComponentExist(ON.text('登录')); // 校验是否跳转到登录页
        await findAndClickComponent('登录');
        if(!!!AppStorage.get('isPrivacy')) {
          await findAndClickComponent('同意');
          await findAndClickComponent('登录');
        }
      }

      await driver.assertComponentExist(ON.id('payWithVoucher')); // 校验是否跳转到购物袋页面

      // 通过购物袋购物
      await findAndClickComponentById('【现货速发】HUAWEI Mate X5 12GB+512GB 幻影紫');
      await findAndClickComponentById('payWithVoucher');
      await pressBack();
      await findAndClickComponent('再看看');
      await findAndClickComponent('确认支付');

      await driver.assertComponentExist(ON.text('返回首页')); // 校验是否跳转到支付成功页面
      await findAndClickComponent('返回首页');
      await driver.assertComponentExist(ON.text('智慧办公')); // 校验是否跳转到首页
      await exitAndReturnHome();
    });
  });
}