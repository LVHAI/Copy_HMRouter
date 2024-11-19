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

import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI';
import {
  HMAnimator,
  HMAnimatorHandle,
  HMRouterMgr,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';
import { CommonConstants } from '../common/constants/CommonConstants';
import { LiveCommentsModel, LiveCommentsProduct } from '../viewmodel/LiveCommentsModel';
import { LiveCommentFooter } from './LiveCommentFooter';

@HMAnimator({animatorName: 'liveCommentsAnimator'})
export class LiveCommentsAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    // entry animation
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '100%';
    });
    enterHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '0';
    });
    enterHandle.duration = 500;

    // exit animation
    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '0';
    });
    exitHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.y = '100%';
    });
    exitHandle.duration = 500;
  }
}

@Component
export struct CommentInput {
  @StorageLink('changeVideoHeight') videoHeight: string | number = CommonConstants.FULL_PERCENT;
  commentRenderNode: CommentNodeController = new CommentNodeController();

  aboutToAppear(): void {
    console.log('make node');
    this.commentRenderNode.makeNode(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.commentRenderNode.dispose();
  }

  build() {
    Row() {
      Text($r('app.string.comment_placeholder'))
        .fontColor($r('app.color.comment_input_text_font_color_1'))
        .fontSize($r('app.float.comment_font_size'))
        .borderRadius('50%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.comment_background_color'))
        .padding({left: 15, top: 11, bottom: 11})
        .margin({right: 16});

      Image($r('app.media.icon_share'))
        .width(24)
        .height(24)
        .margin({right: 16});

      Image($r('app.media.icon_comments'))
        .width(24)
        .height(24)
        .margin({right: 16})
        .onClick(() => {
          HMRouterMgr.push({
            navigationId: this.queryNavigationInfo()?.navigationId,
            pageUrl: 'liveComments',
            param: {
              commentRenderNode: this.commentRenderNode
            },
            animator: new LiveCommentsAnimator()
          }, {
            onArrival: () => {
              console.log('Jump successful');
            },
            onResult: (paramInfo: PopInfo) => {
              this.videoHeight = paramInfo.result as string;
            }
          });
          this.videoHeight = '30%';
        })
        .id('comments');

      Image($r('app.media.icon_like'))
        .width(24)
        .height(24)
        .margin({right: 16});

      Image($r('app.media.icon_cart'))
        .width(45)
        .height(45)
        .margin({right: 16});

    }
    .backgroundColor($r('app.color.comment_input_background_color'))
    .width(CommonConstants.FULL_PERCENT)
    .height(50)
    .padding({
      left: 10,
      right: 10
    })
    .margin({
      top: 10
    });
  }
}

@Builder
function buildComment(liveComments: LiveCommentsProduct[]) {
  Column() {
    List({space: 16}) {
      ForEach(liveComments, (item: LiveCommentsProduct) => {
        ListItem() {
          Row() {
            Image(item.getAvatar())
              .width(50)
              .margin({left: 10});
            Column() {
              Text(item.getUserName())
                .fontColor($r('app.color.comment_input_text_font_color_2'));
              Text(item.getCommentContent());
            }.alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({left: 10});

            Column() {
              Image(item.getLikeIcon())
                .width(10)
                .margin({bottom: 5});
              Text(`${item.getLikeNum()}`)
                .fontColor($r('app.color.comment_input_text_font_color_2'));
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .width('10%');
          };
        };
      }, (item: LiveCommentsProduct, index: number) => JSON.stringify(item) + index);
    }.width('100%').height('auto').layoutWeight(1);

    LiveCommentFooter();
  }.height('100%');
}

export class CommentNodeController extends NodeController {
  commentList: BuilderNode<[LiveCommentsProduct[]]> | null = null;
  commentListData: LiveCommentsProduct[] = new LiveCommentsModel().getLiveCommentsList();
  constructor() {
    super();
  }

  makeNode(context: UIContext): FrameNode | null {
    if(this.commentList === null) {
      this.nodeBuild(context);
    }
    return this.commentList!.getFrameNode();
  }

  nodeBuild(context: UIContext) {
    this.commentList = new BuilderNode(context);
    if(this.commentList !== null) {
      this.commentList.build(wrapBuilder<[LiveCommentsProduct[]]>(buildComment), this.commentListData);
    }
  }

  dispose() {
    if(this.commentList !== null) {
      this.commentList.dispose();
    }
  }
}