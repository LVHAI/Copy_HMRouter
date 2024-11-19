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

import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

/**
 * File operation tool class
 */
export class FileUtil {
  /**
   *  router_map.json Store JSON strings
   */
  static readonly READ_DEFAULT_LENGTH: number = 4096;

  /**
   * write file
   * @param filePath
   * @param content
   * @param create: Do you want to create a new file
   */
  public static writeFile(filePath: string, content: string | ArrayBuffer, create?: boolean) {
    let mode: number;
    if (create !== undefined && create) {
      mode = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE;
    } else {
      mode = fs.OpenMode.READ_WRITE;
    }
    fs.open(filePath, mode).then((file) => {
      fs.write(file.fd, content).catch((err: Error) => {
        console.error('write content to file error,error message is', err);
      }).finally(() => {
        fs.closeSync(file);
      });
    }).catch((err: Error) => {
      console.error('open file error,error message is', err);
    });
  }

  /**
   * Determine whether the file exists
   * @param filePath
   * @returns
   */
  public static fileExist(filePath: string): boolean {
    return fs.accessSync(filePath, fs.AccessModeType.EXIST);
  }

  /**
   * delete file
   * @param filePath
   */
  public static unlinkFile(filePath: string) {
    if (FileUtil.fileExist(filePath)) {
      fs.unlinkSync(filePath);
    }
  }

  /**
   * Read file content
   * @param filePath
   * @returns fileContent
   */
  public static readFile(filePath: string): string {
    let ss = fs.createStreamSync(filePath, 'r+');

    class Option {
      offset: number = 0;
      length: number = FileUtil.READ_DEFAULT_LENGTH;
    }

    let option = new Option();
    let buf = new ArrayBuffer(FileUtil.READ_DEFAULT_LENGTH);

    let read = 0;
    let res = '';
    let decoder = util.TextDecoder.create();
    while ((read = ss.readSync(buf, option)) > 0) {
      res += decoder.decodeWithStream(new Uint8Array(buf, 0, read));
      option.offset += read;
    }
    return res;
  }
}