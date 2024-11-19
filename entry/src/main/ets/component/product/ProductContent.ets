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

import { HMRouter } from '@hadss/hmrouter';
import { PageConstant } from '../../constant/PageConstant';
import { DetailConstants } from '../common/constants/DetailConstants';
import { ProductInfo, ProductPicture } from './elements/ProductDetail';
import { ProductMsg, ProductUtilView } from './elements/ProductUtilView';

@HMRouter({pageUrl: PageConstant.PRODUCT_CONTENT})
@Component
export struct ProductContent {
  @State product: ProductMsg =
    new ProductMsg(DetailConstants.COLOR_SELECT_NAME_LIST[0], DetailConstants.CAPACITY_SELECT_NAME_LIST[0],
      DetailConstants.PRODUCT_PRICE_NAMES[1]);

  build() {
    Column() {
      Scroll() {
        Column() {
          ProductPicture()
            .margin({bottom: 70});
          ProductInfo({product: this.product});
        };
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1);

      ProductUtilView({product: this.product});
    }
    .padding({top: 0})
    .height('100%')
    .width('100%')
    .layoutWeight(1);
  }
}