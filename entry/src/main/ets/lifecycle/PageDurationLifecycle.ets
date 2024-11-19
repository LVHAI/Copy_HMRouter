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

import { HMLifecycleContext, IHMLifecycle } from '@hadss/hmrouter';

export class PageDurationLifecycle implements IHMLifecycle {
  private timeMap: Map<string, number> = new Map();
  onShown(ctx: HMLifecycleContext): void {
    const pageName = ctx.navContext?.pathInfo.name;
    if(pageName) {
      this.timeMap.set(pageName, new Date().getTime());
    }
  }

  onHidden(ctx: HMLifecycleContext): void {
    const pageName = ctx.navContext?.pathInfo.name;
    if(pageName && this.timeMap.has(pageName)) {
      const duration = new Date().getTime() - (this.timeMap.get(pageName) as number);
      this.timeMap.delete(pageName);
      console.log(`Page ${pageName} stay ${duration} ms`);
    }
  }
}