// entry/src/main/ets/pages/AIAssistantPage.ets
import  PlantIdService, { DiagnosisResult } from '../service/PlantIdService';
import { ImageUtils } from '../common/ImageUtils';
import { promptAction } from '@kit.ArkUI';
import camera from '@ohos.multimedia.camera';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { image } from '@kit.ImageKit';
import { NavigationManager } from '../common/NavigationManager';

@Entry
@Component
export struct AIidentify {
  @State params:Record<string,Object>={};
  @State selectedImage: PixelMap | null = null;
  @State isAnalyzing: boolean = false;
  @State analysisResult: string = '';
  @State diseaseName: string = '';
  @State treatmentAdvice: string = '';

  // 选择图片
  async selectImage() {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const pickerResult = await photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      });

      if (pickerResult.photoUris.length > 0) {
        const uri = pickerResult.photoUris[0];
        const imageSource = image.createImageSource(uri);
        const pixelMap = await imageSource.createPixelMap();

        // 压缩图片
        const compressed = await ImageUtils.compressImage(pixelMap);
        this.selectedImage = compressed;
        this.isAnalyzing = true;


        // 开始分析
        await this.analyzeWithPlantId(compressed);
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
  }

  // 调用Plant.id分析
  async analyzeWithPlantId(pixelMap: image.PixelMap) {
    console.info('收到的 PixelMap:', pixelMap);
    this.isAnalyzing = true;
    console.info('isAnalyzing 设置为 true');
    try {
      // 转换图片为Base64
      const base64 = await ImageUtils.pixelMapToBase64(pixelMap);

      // 调用Plant.id API
      const result = await PlantIdService.analyzeHealth(base64);

      if (result) {
        this.parseResult(result);
      } else {
        this.analysisResult = '识别失败，请重试';
      }
    } catch (error) {
      console.error('分析异常:', error);
      this.analysisResult = '网络错误，请检查网络连接';
    } finally {
      this.isAnalyzing = false;
    }
  }

  // 解析API返回结果
  private parseResult(result:DiagnosisResult) {
      if (result.isHealthy){
        this.diseaseName = '健康作物';
        this.treatmentAdvice = '您的作物看起来健康状况良好，继续保持当前管理方式。';
        this.analysisResult = '✅ 作物健康状态良好，未检测到明显病虫害。';
      } else {
        this.diseaseName = result.diseaseName;
        this.treatmentAdvice = `【病害描述】${result.diseaseDescription}\n\n【治疗方案】${result.treatmentAdvice}\n\n【发病原因】${result.cause}`;
        this.analysisResult = `⚠️ 检测到：${this.diseaseName}（置信度：${(result.confidence * 100).toFixed(1)}%）`;
      }


    // 如果有植物识别结果
    if (result.plantName && result.plantName !== '未知') {
      console.log(`识别植物: ${result.plantName}`);
    }
  }

  build() {
   NavDestination(){
     Column() {
       Row() {
         Image($r('app.media.back'))
           .backgroundColor('#E2E8F0')
           .width('40vp')
           .height('40vp')
           .borderRadius(20)
           .padding(12)
           .onClick(() => {
             NavigationManager.getInstance().pop()
           })
         Text('AI识图').fontSize('25vp').fontWeight(FontWeight.Bold)
         Text('')
           .width('40vp')
           .height('40vp')
       }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

       Column(){
       // 图片预览区域
       Stack() {
         if (this.selectedImage) {
           Image(this.selectedImage)
             .width('100%')
             .height(280)
             .objectFit(ImageFit.Contain)
         } else {
           Column() {
             Image($r('sys.media.ohos_ic_public_camera'))
               .width(60)
               .height(60)
               .fillColor('#94a3b8')
             Text('从相册选择图片进行预览')
               .fontSize(14)
               .fontColor('#94a3b8')
           }
           .width('100%')
           .height(280)
           .justifyContent(FlexAlign.Center)
           .alignItems(HorizontalAlign.Center)
           .backgroundColor(Color.White)
          // .backgroundColor('#f1f5f9')
         }

         if (this.isAnalyzing) {
           Column() {
             LoadingProgress()
               .width(48)
               .height(48)
               .color('#13EC5B')
             Text('AI正在分析中...')
               .fontSize(14)
               .fontColor('#ffffff')
           }
           .width('100%')
           .height('100%')
           .backgroundColor('rgba(0,0,0,0.6)')
         }
       }
       .borderRadius(16)

       // 操作按钮
       Row({ space: 16 }) {
         Button('选择图片')
           .height(44)
           .layoutWeight(1)
           .backgroundColor('#3b82f6')
           .onClick(() => {
             this.selectImage();
             console.log('当前 isAnalyzing 状态:', this.isAnalyzing);
           })
       }
       .width('100%')
       .padding({ top: 16 })

       // 分析结果
       if (this.analysisResult) {
         Column() {
           Text('🔬 AI诊断结果')
             .fontSize(18)
             .fontWeight(FontWeight.Bold)

           Text(this.analysisResult)
             .fontSize(16)
             .fontColor(this.diseaseName === '健康作物' ? '#13EC5B' : '#ef4444')
             .margin({ top: 8 })

           if (this.treatmentAdvice) {
             Text('🛠️ 处理建议')
               .fontSize(16)
               .fontWeight(FontWeight.Medium)
               .margin({ top: 16 })

             Text(this.treatmentAdvice)
               .fontSize(14)
               .fontColor('#475569')
               .lineHeight(20)
               .margin({ top: 8 })
           }
         }
         .width('100%')
         .padding(16)
         .backgroundColor('#ffffff')
         .borderRadius(16)
         .margin({ top: 16 })
       }


     } .width('100%')
       .layoutWeight(1)
       .padding(16)
       .backgroundColor('#f8fafc')
       .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
     }

   }.hideTitleBar(true)
  }
}