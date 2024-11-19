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

import { IHMAnimator } from '../api/IHMAnimator';
import {
  OpacityOption as ObservedOpacityOption,
  ScaleOption as ObservedScaleOption,
  TranslateOption as ObservedTranslateOption
} from '../template/AnimatorModel';
import { HMAnimatorHandle } from './HMAnimatorHandle';

export class BuiltInAnimator implements IHMAnimator {
  direction: IHMAnimator.Direction | undefined;
  opacity?: ObservedOpacityOption;
  scale?: ObservedScaleOption;

  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      opacityOption.opacity = this.opacity?.opacity ? this.opacity.opacity : 1;
      if (this.scale) {
        if (this.scale?.x === 0) {
          scaleOption.x = 0;
        } else {
          scaleOption.x = this.scale?.x ? this.scale.x : scaleOption.x;
        }
        if (this.scale?.y === 0) {
          scaleOption.y = 0;
        } else {
          scaleOption.y = this.scale?.y ? this.scale.y : scaleOption.y;
        }
        if (this.scale?.centerX === 0) {
          scaleOption.centerX = 0;
        } else {
          scaleOption.centerX = this.scale?.centerX ? this.scale.centerX : scaleOption.centerX;
        }
        if (this.scale?.centerY === 0) {
          scaleOption.centerY = 0;
        } else {
          scaleOption.centerY = this.scale?.centerY ? this.scale.centerY : scaleOption.centerY;
        }
      }
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = '100%';
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = '-100%';
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = '100%';
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = '-100%';
      }
    });
    enterHandle.finish((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = 0;
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = 0;
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = 0;
      }
      scaleOption.x = 1;
      scaleOption.y = 1;
      opacityOption.opacity = 1;
    });
    enterHandle.passiveStart((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      opacityOption.opacity = this.opacity?.opacity ? this.opacity.opacity : 1;
      if (this.scale) {
        if (this.scale?.x === 0) {
          scaleOption.x = 0;
        } else {
          scaleOption.x = this.scale?.x ? this.scale.x : scaleOption.x;
        }
        if (this.scale?.y === 0) {
          scaleOption.y = 0;
        } else {
          scaleOption.y = this.scale?.y ? this.scale.y : scaleOption.y;
        }
        if (this.scale?.centerX === 0) {
          scaleOption.centerX = 0;
        } else {
          scaleOption.centerX = this.scale?.centerX ? this.scale.centerX : scaleOption.centerX;
        }
        if (this.scale?.centerY === 0) {
          scaleOption.centerY = 0;
        } else {
          scaleOption.centerY = this.scale?.centerY ? this.scale.centerY : scaleOption.centerY;
        }
      }
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = -100;
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = 100;
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = -100;
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = 100;
      }
    });
    enterHandle.passiveFinish((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = 0;
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = 0;
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = 0;
      }
      scaleOption.x = 1;
      scaleOption.y = 1;
      opacityOption.opacity = 1;
    });
    exitHandle.start((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = 0;
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = 0;
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = 0;
      }
      scaleOption.x = 1;
      scaleOption.y = 1;
      opacityOption.opacity = 1;
    });
    exitHandle.finish((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      opacityOption.opacity = this.opacity?.opacity ? this.opacity.opacity : 1;
      if (this.scale) {
        if (this.scale?.x === 0) {
          scaleOption.x = 0;
        } else {
          scaleOption.x = this.scale?.x ? this.scale.x : scaleOption.x;
        }
        if (this.scale?.y === 0) {
          scaleOption.y = 0;
        } else {
          scaleOption.y = this.scale?.y ? this.scale.y : scaleOption.y;
        }
        if (this.scale?.centerX === 0) {
          scaleOption.centerX = 0;
        } else {
          scaleOption.centerX = this.scale?.centerX ? this.scale.centerX : scaleOption.centerX;
        }
        if (this.scale?.centerY === 0) {
          scaleOption.centerY = 0;
        } else {
          scaleOption.centerY = this.scale?.centerY ? this.scale.centerY : scaleOption.centerY;
        }
      }
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = '100%';
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = '-100%';
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = '100%';
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = '-100%';
      }
    });
    exitHandle.passiveStart((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = 0;
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = 0;
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = 0;
      }
      scaleOption.x = 1;
      scaleOption.y = 1;
      opacityOption.opacity = 1;
    });
    exitHandle.passiveFinish((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      opacityOption.opacity = this.opacity?.opacity ? this.opacity.opacity : 1;
      if (this.scale) {
        if (this.scale?.x === 0) {
          scaleOption.x = 0;
        } else {
          scaleOption.x = this.scale?.x ? this.scale.x : scaleOption.x;
        }
        if (this.scale?.y === 0) {
          scaleOption.y = 0;
        } else {
          scaleOption.y = this.scale?.y ? this.scale.y : scaleOption.y;
        }
        if (this.scale?.centerX === 0) {
          scaleOption.centerX = 0;
        } else {
          scaleOption.centerX = this.scale?.centerX ? this.scale.centerX : scaleOption.centerX;
        }
        if (this.scale?.centerY === 0) {
          scaleOption.centerY = 0;
        } else {
          scaleOption.centerY = this.scale?.centerY ? this.scale.centerY : scaleOption.centerY;
        }
      }
      if (this.direction === IHMAnimator.Direction.RIGHT_TO_LEFT) {
        translateOption.x = -100;
      } else if (this.direction === IHMAnimator.Direction.LEFT_TO_RIGHT) {
        translateOption.x = 100;
      } else if (this.direction === undefined) {
        translateOption.x = 0;
        translateOption.y = 0;
      } else if (this.direction === IHMAnimator.Direction.BOTTOM_TO_TOP) {
        translateOption.y = -100;
      } else if (this.direction === IHMAnimator.Direction.TOP_TO_BOTTOM) {
        translateOption.y = 100;
      }
    });

    exitHandle.passiveOnFinish((translateOption: ObservedTranslateOption, scaleOption: ObservedScaleOption,
      opacityOption: ObservedOpacityOption) => {
      translateOption.x = 0;
      translateOption.y = 0;
      scaleOption.x = 1;
      scaleOption.y = 1;
      scaleOption.centerX = '50%';
      scaleOption.centerY = '50%';
      opacityOption.opacity = 1;
    });
  }
}

