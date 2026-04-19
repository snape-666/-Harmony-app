// entry/src/main/ets/pages/AIAssistantPage.ets
import PlantIdService, { DiagnosisResult } from '../service/PlantIdService';
import { ImageUtils } from '../common/ImageUtils';
import { promptAction, display } from '@kit.ArkUI';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { NavigationManager } from '../common/NavigationManager';
import { AITalk } from './AITalk'

@Component
struct DraggableFloatBall {
  // [修改] 删除所有拖拽相关的状态变量，只保留球大小
  @State ballSize: number = 48;

  build() {
    // [修改] 移除 if (this.isReady) 判断，直接渲染
    Row() {
      Image($r('app.media.robot'))
        .width(this.ballSize - 8)
        .height(this.ballSize - 8)
        .fillColor(Color.Black)
        .padding(5)
    }
    .width(this.ballSize)
    .height(this.ballSize)
    .borderRadius(this.ballSize / 2)
    .backgroundColor('#13EC5B')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .shadow({
      radius: 12,
      color: 'rgba(19, 236, 91, 0.5)',
      offsetX: 0,
      offsetY: 4
    })
    // [修改] 固定在右上角 (x: 屏幕宽度-球大小-边距, y: 顶部边距)
    // 注意：这里使用 vp 单位，320 是靠右的位置，你可以根据需要调整
    .position({ x: 310, y: 60 })
    // [修改] 添加强制顶层，防止被遮挡
    .zIndex(999)
    // [修改] 删除整个 PanGesture 拖拽手势代码块
    .onClick(() => {
      promptAction.openToast({
        message: 'AI助手',
        duration: 1500
      });
    NavigationManager.getInstance().push('AITalk',{from:AIidentify})
    })
  }

  // [修改] 删除 private snapToEdge() 贴边方法
}

@Entry
@Component
export struct AIidentify {
  @State params: Record<string, Object> = {};
  @State selectedImage: PixelMap | null = null;
  @State isAnalyzing: boolean = false;
  @State analysisResult: string = '';
  @State diseaseName: string = '';
  @State treatmentAdvice: string = '';
  @State plantDisplayName: string = '';
  @State showFloatBall: boolean = true;

  // 选择图片
  async selectImage() {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const pickerResult = await photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      });

      if (pickerResult.photoUris.length > 0) {
        const uri = pickerResult.photoUris[0];
        const pixelMap = await ImageUtils.uriToPixelMap(uri);
        if (!pixelMap) {
          this.analysisResult = '图片读取失败，请重试';
          promptAction.openToast({ message: '图片读取失败，请重试', duration: 2000 });
          return;
        }

        this.analysisResult = '';
        this.diseaseName = '';
        this.treatmentAdvice = '';
        this.plantDisplayName = '';
        this.selectedImage = pixelMap;

        const compressed = await ImageUtils.compressImage(pixelMap);
        this.isAnalyzing = true;

        await this.analyzeWithPlantId(compressed);
      } else {
        promptAction.openToast({ message: '未选择图片', duration: 1500 });
      }
    } catch (error) {
      console.error('选择图片失败:', error);
      this.analysisResult = '选择图片失败，请检查权限后重试';
      try {
        promptAction.openToast({ message: '选择图片失败，请检查权限后重试', duration: 2000 });
      } catch {
        // ignore
      }
    }
  }

  async analyzeWithPlantId(pixelMap: PixelMap) {
    console.info('收到的 PixelMap:', pixelMap);
    this.isAnalyzing = true;
    try {
      const base64 = await ImageUtils.pixelMapToBase64(pixelMap);
      if (!base64) {
        this.analysisResult = '图片编码失败，请重试';
        promptAction.openToast({ message: '图片编码失败，请重试', duration: 2000 });
        return;
      }
      const result = await PlantIdService.analyzeHealth(base64);

      if (result) {
        this.parseResult(result);
        try {
          promptAction.openToast({ message: '分析完成', duration: 2000 });
        } catch {
          // ignore
        }
      } else {
        this.analysisResult = '识别失败，请重试';
        try {
          promptAction.openToast({ message: '识别失败，请重试', duration: 2000 });
        } catch {
          // ignore
        }
      }
    } catch (error) {
      console.error('分析异常:', error);
      this.analysisResult = '网络错误，请检查网络连接';
      try {
        promptAction.openToast({ message: '网络错误，请检查网络连接', duration: 2000 });
      } catch {
        // ignore
      }
    } finally {
      this.isAnalyzing = false;
    }
  }

  private parseResult(result: DiagnosisResult) {
    if (result.isHealthy) {
      this.diseaseName = '健康作物';
      this.treatmentAdvice = '您的作物看起来健康状况良好，继续保持当前管理方式。';
      this.analysisResult = '✅ 作物健康状态良好，未检测到明显病虫害。';
    } else {
      this.diseaseName = result.diseaseName;
      this.treatmentAdvice =
        `【病害描述】${result.diseaseDescription}\n\n【治疗方案】${result.treatmentAdvice}\n\n【发病原因】${result.cause}`;
      this.analysisResult =
        `⚠️ 检测到：${this.diseaseName}（置信度：${(result.confidence * 100).toFixed(1)}%）`;
    }

    this.plantDisplayName =
      (result.plantName && result.plantName !== '未知') ? result.plantName : '';
  }

  build() {
    Stack() {
      NavDestination() {
        Stack(){
        Column() {
          Row() {
            Image($r('app.media.back'))
              .backgroundColor('#E2E8F0')
              .width('40vp')
              .height('40vp')
              .borderRadius(20)
              .padding(12)
              .onClick(() => {
                NavigationManager.getInstance().pop();
              })
            Text('AI识图').fontSize('25vp').fontWeight(FontWeight.Bold)
            Text('')
              .width('40vp')
              .height('40vp')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 15, right: 15 })

          Scroll() {
            Column() {
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

              Row({ space: 16 }) {
                Button('选择图片')
                  .height(44)
                  .layoutWeight(1)
                  .backgroundColor('#3b82f6')
                  .onClick(() => {
                    this.selectImage();
                  })
              }
              .width('100%')
              .padding({ top: 16 })

              if (this.analysisResult) {
                Column() {
                  Text('🔬 AI诊断结果')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)

                  if (this.plantDisplayName) {
                    Text(`植物：${this.plantDisplayName}`)
                      .fontSize(15)
                      .fontColor('#334155')
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 8 })
                  }

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
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 24 })
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#f8fafc')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          if (this.showFloatBall) {
            DraggableFloatBall()
          }
      }
      }
      .hideTitleBar(true)

    }
    .width('100%')
    .height('100%')
  }
}