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

import { FileUtil } from '@ohos/hvigor';
import fs, { Dirent, ObjectEncodingOptions, PathLike } from 'fs';

export default class HMFileUtil extends FileUtil {
  static rmSync(path: fs.PathLike, options?: fs.RmOptions) {
    return fs.rmSync(path, options);
  }

  static unlinkSync(path: fs.PathLike) {
    return fs.unlinkSync(path);
  }

  static readdirSync(path: PathLike,
    options: ObjectEncodingOptions & {withFileTypes: true; recursive?: boolean | undefined}): Dirent[] {
    return fs.readdirSync(path, options);
  }
};