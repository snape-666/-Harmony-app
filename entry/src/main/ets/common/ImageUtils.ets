// entry/src/main/ets/common/ImageUtils.ets
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import util from '@ohos.util';

// 图片压缩配置类型
export interface CompressOptions {
  maxWidth: number;
  quality: number;
}

// 默认压缩配置
const DEFAULT_OPTIONS: CompressOptions = {
  maxWidth: 1024,
  quality: 80
};

export class ImageUtils {
  /**
   * 将PixelMap转换为Base64字符串
   */
  static async pixelMapToBase64(pixelMap: image.PixelMap, quality: number = 90): Promise<string> {
    try {
      const imagePackerApi = image.createImagePacker();

      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: quality
      };

      const data: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      imagePackerApi.release();

      // 将 ArrayBuffer 转换为 Uint8Array
      const uint8Array = new Uint8Array(data);
      return ImageUtils.uint8ArrayToBase64(uint8Array);
    } catch (error) {
      console.error('PixelMap转Base64失败:', error);
      return '';
    }
  }

  /**
   * Uint8Array 转 Base64
   */
  private static uint8ArrayToBase64(uint8Array: Uint8Array): string {
    const base64Helper = new util.Base64Helper();
    return base64Helper.encodeToStringSync(uint8Array);
  }

  /**
   * 从URI读取图片并转换为PixelMap
   */
  static async uriToPixelMap(uri: string): Promise<image.PixelMap | null> {
    try {
      const imageSource = image.createImageSource(uri);
      const pixelMap = await imageSource.createPixelMap();
      imageSource.release();
      return pixelMap;
    } catch (error) {
      console.error('URI转PixelMap失败:', error);
      return null;
    }
  }

  /**
   * 从URI读取图片并转换为Base64
   */
  static async uriToBase64(uri: string): Promise<string> {
    try {
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(uri);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      // 将 ArrayBuffer 转换为 Uint8Array
      const uint8Array = new Uint8Array(buffer);
      const base64Helper = new util.Base64Helper();
      return base64Helper.encodeToStringSync(uint8Array);
    } catch (error) {
      console.error('URI转Base64失败:', error);
      return '';
    }
  }

  /**
   * 压缩图片
   */
  static async compressImage(pixelMap: image.PixelMap, quality: number = 80): Promise<image.PixelMap> {
    try {
      const imagePackerApi = image.createImagePacker();

      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: quality
      };

      const compressedData = await imagePackerApi.packing(pixelMap, packOpts);
      imagePackerApi.release();

      const imageSource = image.createImageSource(compressedData);
      const compressedPixelMap = await imageSource.createPixelMap();
      imageSource.release();

      return compressedPixelMap;
    } catch (error) {
      console.error('图片压缩失败:', error);
      return pixelMap;
    }
  }

  /**
   * 缩放图片
   */
  static async scalePixelMap(pixelMap: image.PixelMap, scaleX: number, scaleY: number): Promise<image.PixelMap> {
    try {
      await pixelMap.scale(scaleX, scaleY);
      return pixelMap;
    } catch (error) {
      console.error('图片缩放失败:', error);
      return pixelMap;
    }
  }

  /**
   * 获取图片信息
   */
  static async getImageInfo(pixelMap: image.PixelMap): Promise<image.ImageInfo | null> {
    try {
      return await pixelMap.getImageInfo();
    } catch (error) {
      console.error('获取图片信息失败:', error);
      return null;
    }
  }
}