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

import { HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from './constants/BreakpointConstants';
import { CommonConstants } from './constants/CommonConstants';
import { HomeConstants } from './constants/HomeConstants'
import { ResourceUtil } from './utils/ResourceUtil';
import { FooterTab, FooterTabViewModel } from '../viewmodel/FooterTabViewModel';

@Component
export struct ButtonTabs {
  private static readonly homeContentPageIndex = 0;
  private static readonly shoppingBagPageIndex = 3;
  private static readonly myAccountPageIndex = 4;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('currentPage') currentPage: string = 'HomeContent';
  private tabList: FooterTab[] = new FooterTabViewModel().getTabList();

  build() {
    Flex({justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center}) {
      ForEach(this.tabList, (item: FooterTab, index: number) => {
        Button({type: ButtonType.Normal}) {
          Column() {
            Image(this.convertPageToButton(this.currentPage) === item.getName() ? item.getIconSelected() :
            item.getIcon())
              .width(ResourceUtil.getCommonImgSize()[0])
              .height(ResourceUtil.getCommonImgSize()[0]);
            Text(item.getName())
              .fontSize($r('app.float.tab_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontColor(this.convertPageToButton(this.currentPage) === item.getName() ?
              $r('app.color.button_tabs_font_color_selected') : $r('app.color.button_tabs_font_color'))
              .margin({top: $r('app.float.tab_top_margin')})
              .opacity(CommonConstants.TEXT_OPACITY[1]);
          }
        }
        .width('20%')
        .height(50)
        .backgroundColor($r('app.color.tab_background_color'))
        .onClick(() => {
          if(index === ButtonTabs.homeContentPageIndex && this.currentPage !== 'HomeContent') {
            HMRouterMgr.pop({pageUrl: 'HomeContent', navigationId: 'mainNavigationId', animator: false});
          }
          if(index === ButtonTabs.shoppingBagPageIndex && this.currentPage !== 'shoppingBag') {
            if(this.currentPage === 'HomeContent') {
              HMRouterMgr.push({
                pageUrl: 'shoppingBag',
                navigationId: 'mainNavigationId',
                animator: false
              });
            } else {
              HMRouterMgr.replace({
                pageUrl: 'shoppingBag',
                navigationId: 'mainNavigationId',
                animator: false
              });
            }
          }
          if(index === ButtonTabs.myAccountPageIndex && this.currentPage !== 'myAccount') {
            if(this.currentPage === 'HomeContent') {
              HMRouterMgr.push({pageUrl: 'myAccount', navigationId: 'mainNavigationId', animator: false});
            } else {
              HMRouterMgr.replace({
                pageUrl: 'myAccount',
                navigationId: 'mainNavigationId',
                animator: false
              });
            }
          }
        });
      }, (item: FooterTab) => item.getName());
    }
    .width('100%');
  }

  convertPageToButton(page: string): string {
    const buttonMap: Map<string, string> = new Map([
      ['HomeContent', HomeConstants.FOOTER_TOPIC_LIST[0]],
      ['shoppingBag', HomeConstants.FOOTER_TOPIC_LIST[3]],
      ['myAccount', HomeConstants.FOOTER_TOPIC_LIST[4]]
    ]);

    return buttonMap.get(page) || '';
  }
}