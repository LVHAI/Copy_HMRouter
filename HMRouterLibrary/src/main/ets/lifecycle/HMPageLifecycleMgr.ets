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

import { router } from '@kit.ArkUI';
import { HMPageLifecycle } from './HMPageLifecycle';

export class HMPageLifecycleMgr {
  private static instance: HMPageLifecycleMgr = new HMPageLifecycleMgr();
  private pageLifecycleMap: Map<string, HMPageLifecycle> = new Map();

  static getInstance() {
    return HMPageLifecycleMgr.instance;
  }

  /**
   * Create a page lifecycle instance
   * @returns pageLifecycleId
   */
  createPageLifecycle(): string {
    const routerInfo = router.getState();
    const pageLifecycleId = `${routerInfo.index}_${routerInfo.path}_${routerInfo.name}`;
    const pageLifecycleInstance = new HMPageLifecycle(routerInfo);
    this.pageLifecycleMap.set(pageLifecycleId, pageLifecycleInstance);
    return pageLifecycleId;
  }

  /**
   * Get page lifecycle instance
   * @returns
   */
  getPageLifecycle(pageLifecycleId: string): HMPageLifecycle | undefined {
    return this.pageLifecycleMap.get(pageLifecycleId);
  }
}