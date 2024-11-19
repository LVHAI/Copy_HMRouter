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

import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import {
  HMAnimator,
  HMAnimatorHandle,
  HMLifecycle,
  HMLifecycleContext,
  HMRouter,
  HMRouterMgr,
  IHMAnimator,
  IHMLifecycle,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BreakpointType } from '../common/utils/BreakpointType';
import { Live } from './Live';
import { PageConstant } from '../../constant/PageConstant';

@Observed
export class VideoSrc {
  src: string | Resource;
  constructor(src: string | Resource) {
    this.src = src;
  }
}

@HMLifecycle({lifecycleName: 'liveHomeLifecycle'})
export class LiveHomeLifecycle implements IHMLifecycle {
  videoSrc: VideoSrc = new VideoSrc($rawfile('camera-ais.mp4'));
  onPrepare(): void {
    this.videoSrc.src = $rawfile('camera-ais.mp4');
    let param = HMRouterMgr.getCurrentParam();
    if(param) {
      this.videoSrc.src = $rawfile(param as string);
    }
  }

  onShown(ctx: HMLifecycleContext): void {
    window.getLastWindow(getContext(this), (err, data) => {
      if(err.code > 0) {
        console.error(`${err.code} ${err.message}`);
        return;
      }
      data.setWindowSystemBarProperties({
        statusBarContentColor: Color.White.toString()
      });
    });
  }

  onHidden(ctx: HMLifecycleContext): void {
    window.getLastWindow(getContext(this), (err, data) => {
      if(err.code > 0) {
        console.error(`${err.code} ${err.message}`);
        return;
      }
      data.setWindowSystemBarProperties({
        statusBarContentColor: Color.Black.toString()
      });
    });
  }
}

@HMAnimator({animatorName: 'liveInteractiveAnimator'})
export class LiveInteractiveAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '100%';
      opacityOption.opacity = 0.4;
    });
    enterHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0';
      opacityOption.opacity = 1;
    });
    enterHandle.onFinish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0';
      opacityOption.opacity = 1;
    });

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0';
      opacityOption.opacity = 1;
    });
    exitHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '100%';
      opacityOption.opacity = 0.4;
    });
    exitHandle.onFinish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0';
      opacityOption.opacity = 0.4;
    });
  }

  interactive(handle: HMAnimatorHandle): void {
    handle.actionStart((event: GestureEvent) => {
      if(event.offsetX > 0) {
        HMRouterMgr.pop();
      }
    });
    handle.updateProgress((event, proxy, operation, startOffset) => {
      if(!proxy?.updateTransition || !startOffset) {
        return;
      }
      let offset = 0;
      if(event.fingerList[0]) {
        offset = event.fingerList[0].localX - startOffset;
      }
      if(offset < 0) {
        proxy?.updateTransition(0);
        return;
      }
      let rectWidth = event.target.area.width as number;
      let rate = offset / rectWidth;
      proxy?.updateTransition(rate);
    });
    handle.actionEnd((event, proxy, operation, startOffset) => {
      if(!startOffset) {
        return;
      }
      let rectWidth = event.target.area.width as number;
      let rate = 0;
      if(event.fingerList[0]) {
        rate = (event.fingerList[0].localX - startOffset) / rectWidth;
      }
      if(rate > 0.4) {
        proxy?.finishTransition();
      } else {
        proxy?.cancelTransition?.();
      }
    });
  }
}

@HMRouter({
  pageUrl: PageConstant.LIVE_HOME,
  singleton: true,
  animator: 'liveInteractiveAnimator',
  lifecycle: 'liveHomeLifecycle'
})
@Component
export struct LiveHome {
  @State isMoreDetail: boolean = false;
  @State detailType: string = CommonConstants.BIND_SHEET_PAGE_TYPES[0];
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('changeVideoHeight') videoHeight: string | number = CommonConstants.FULL_PERCENT;

  aboutToAppear(): void {
    window.getLastWindow(getContext(this), (err, win) => {
      win.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
    });
  }

  build() {
    Column() {
      Live({
        currentBreakpoint: this.isMoreDetail ? new BreakpointType(BreakpointConstants.BREAKPOINT_SM,
          BreakpointConstants.BREAKPOINT_SM, BreakpointConstants.BREAKPOINT_MD).getValue(this.currentBreakpoint) :
        this.currentBreakpoint,
        detailType: $detailType,
        isMoreDetail: $isMoreDetail
      });
    }
    .height('100%')
    .width('100%');
  }
}