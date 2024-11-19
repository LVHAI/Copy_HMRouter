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

export class HMDefaultGlobalAnimator {
  static STANDARD_ANIMATOR: IHMAnimator.Effect = new IHMAnimator.Effect({
    direction: IHMAnimator.Direction.RIGHT_TO_LEFT,
    opacity: { opacity: 0.5 }
  });
  static DIALOG_ANIMATOR: IHMAnimator.Effect = new IHMAnimator.Effect({
    scale: {
      centerX: '50%',
      centerY: '50%',
      x: 0.5,
      y: 0.5
    },
    opacity: { opacity: 0.2 }
  });
}