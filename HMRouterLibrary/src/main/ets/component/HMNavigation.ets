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

import { AttributeUpdater } from '@kit.ArkUI';
import { HMRouterMgr } from '../api/HMRouterMgr';
import { IHMAnimator } from '../api/IHMAnimator';
import { HMNavCustomTransition } from '../animator/HMNavCustomTransition';
import { HMRouterMgrService } from '../router/HMRouterMgrService';
import { HMNavBarLifecycleMgr } from '../lifecycle/HMNavBarLifecycleMgr';
import { HMNavPathStack } from '../router/HMNavPathStack';
import { IHMRouterStore } from '../store/IHMRouterStore';
import { hmRouterStore } from '../store/RouterStoreFactory';
import { NavBarLifecycleKey } from '../lifecycle/interface/NavBarLifecycleKey';

@Component
export struct HMNavigation {
  @Require navigationId: string = '';
  homePageUrl?: string;
  options?: HMNavigationOption;
  hmRouterStore: IHMRouterStore = hmRouterStore;
  @BuilderParam closer: () => void = this.closerBuilder;
  private hmRouterMgrService: HMRouterMgrService = HMRouterMgrService.getInstance();
  private pageStack?: HMNavPathStack;
  private customTransition?: HMNavCustomTransition;
  private hideNavBar?: boolean;
  private navigationKey?: NavBarLifecycleKey;
  private navbarLifecycleMgr: HMNavBarLifecycleMgr = HMNavBarLifecycleMgr.getInstance();

  @Builder
  closerBuilder() {
  }

  @Builder
  dynamicPageBuilder(name: string) {
    this.hmRouterStore.getHMPageInfo(name)?.builder?.builder();
  }

  aboutToAppear(): void {
    if (this.closer === this.closerBuilder) {
      this.hideNavBar = true;
    } else {
      this.hideNavBar = false;
    }
    this.pageStack =
      this.hmRouterMgrService.createPathStack(this.navigationId, this.hideNavBar, this.getUIContext());

    if (this.options?.standardAnimator) {
      HMRouterMgr.registerGlobalAnimator(this.navigationId, 'standard', this.options?.standardAnimator.toAnimator());
    }
    if (this.options?.dialogAnimator) {
      HMRouterMgr.registerGlobalAnimator(this.navigationId, 'dialog', this.options?.dialogAnimator.toAnimator());
    }
    this.customTransition = HMNavCustomTransition.getInstance(this.navigationId, this.hideNavBar);
  }

  onDidBuild(): void {
    // 通过pageStack生成navigationKey，需要等pageStack和Navigation建立绑定关系之后，确定路由嵌套关系
    this.navigationKey = this.navbarLifecycleMgr.generateNavBarLifecycleKey(this.pageStack!);
  }

  aboutToDisappear(): void {
    this.navbarLifecycleMgr.deleteNavBarLifecycle(this.navigationKey!);
    this.hmRouterMgrService.deletePathStack(this.pageStack!);
    HMNavCustomTransition.destroyInstance(this.navigationId);
    HMRouterMgr.unRegisterGlobalAnimator(this.navigationId, 'standard');
    HMRouterMgr.unRegisterGlobalAnimator(this.navigationId, 'dialog');
  }

  build() {
    Navigation(this.pageStack) {
      this.closer();
    }
    .id(this.navigationId)
    .hideNavBar(this.hideNavBar)
    .attributeModifier(this.options?.modifier)
    .title(this.options?.title?.titleValue instanceof WrappedBuilder ?
    this.options.title.titleValue.builder :
      this.options?.title?.titleValue,
      this.options?.title?.titleOptions)
    .menus(this.options?.menus instanceof WrappedBuilder ? this.options?.menus.builder : this.options?.menus)
    .toolbarConfiguration(
      this.options?.toolbar instanceof WrappedBuilder ? // 是否为自定义builder
      this.options.toolbar.builder :
        this.options?.toolbar
    )
    .systemBarStyle(this.options?.systemBarStyle)
    .navDestination(this.dynamicPageBuilder)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return this.customTransition?.getCustomAnimation(from, to, operation);
    })
    .onAppear(() => {
      if (this.homePageUrl) {
        HMRouterMgr.getPathStack(this.navigationId)?.pushPath({ name: this.homePageUrl });
      }
    });
  }
}

interface NavTitle {
  titleValue: ResourceStr | WrappedBuilder<[]> | NavigationCommonTitle | NavigationCustomTitle;
  titleOptions?: NavigationTitleOptions;
}

export class HMNavigationOption {
  modifier?: AttributeUpdater<NavigationAttribute>;
  standardAnimator?: IHMAnimator.Effect;
  dialogAnimator?: IHMAnimator.Effect;
  title?: NavTitle;
  menus?: Array<NavigationMenuItem> | WrappedBuilder<[]>;
  toolbar?: Array<ToolbarItem> | WrappedBuilder<[]>;
  toolbarOptions?: NavigationToolbarOptions;
  systemBarStyle?: Optional<SystemBarStyle>;
}