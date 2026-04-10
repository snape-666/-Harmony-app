import { NavigationManager } from '../common/NavigationManager';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct AIidentify {
  @State params: Record<string, Object> = {};
  private cameraManager: camera.CameraManager = camera.getCameraManager(getContext(this));
  @State previewSurfaceId: string = '';
  private cameraInput: camera.CameraInput | null = null;
  private previewOutput: camera.PreviewOutput | null = null;
  private photoOutput: camera.PhotoOutput | null = null;
  private session: camera.PhotoSession | null = null;
  @State showPreview: boolean = true;
  @State capturedImage: PixelMap | null = null;
  @State showResult: boolean = false;
  private mXComponentController: XComponentController = new XComponentController();
  private currentCameraDevice: camera.CameraDevice | null = null; // 新增：保存当前相机设备
  aboutToAppear() {
    // 初始化相机
    this.initCamera();
  }

  async initCamera() {
    try {
      // 1. 创建拍照会话
      this.session = this.cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;

      // 2. 获取后置摄像头
      const cameras = this.cameraManager.getSupportedCameras();
      const backCamera = cameras.find((cam: camera.CameraDevice) =>
      cam.cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK
      );

      if (!backCamera) {
        console.error('未找到后置摄像头');
        return;
      }
      // 保存 CameraDevice 对象，后续直接用
      this.currentCameraDevice = backCamera;
      // 3. 创建相机输入
      this.cameraInput = this.cameraManager.createCameraInput(backCamera);
      await this.cameraInput.open();

      // 4. 创建预览输出
      this.previewOutput = this.cameraManager.createPreviewOutput(this.previewSurfaceId);

      // 5. 获取设备能力并创建拍照输出（新API）
      const outputCapability = this.cameraManager.getSupportedOutputCapability(
        backCamera,  //直接用你前面获取到的同一个设备对象
        camera.SceneMode.NORMAL_PHOTO
      );

      const photoProfiles = outputCapability.photoProfiles;
      if (photoProfiles && photoProfiles.length > 0) {
        this.photoOutput = this.cameraManager.createPhotoOutput(photoProfiles[0]);

        // 注册拍照回调
        this.photoOutput.on('photoAvailable', (err: BusinessError, photo: camera.Photo) => {
          if (err) {
            console.error('照片生成失败:', err);
            return;
          }
          this.handlePhotoData(photo);
        });
      }

      // 6. 配置会话
      if (this.cameraInput && this.previewOutput && this.photoOutput) {
        this.session.addInput(this.cameraInput);
        this.session.addOutput(this.previewOutput);
        this.session.addOutput(this.photoOutput);

        // 7. 提交配置
        await this.session.commitConfig();
        await this.session.start();
      }

    } catch (error) {
      console.error('相机初始化失败:', error);
    }
  }

  // 处理拍照数据
  async handlePhotoData(photo: camera.Photo) {
    try {
      const imageObj = photo.main;
      const component = await imageObj.getComponent(image.ComponentType.JPEG);

      if (component.byteBuffer) {
        const pixelMap = await image.createPixelMap(component.byteBuffer, {
          size: imageObj.size,
          pixelFormat: image.PixelMapFormat.RGBA_8888
        });

        this.capturedImage = pixelMap;
        this.showPreview = false;
        this.showResult = true;
        await this.session?.stop();
      }

      imageObj.release();
    } catch (error) {
      console.error('处理照片数据失败:', error);
    }
  }

  // 拍照
  async takePhoto() {
    if (!this.photoOutput) return;

    try {
      const photoSettings: camera.PhotoCaptureSetting = {
        quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
        rotation: camera.ImageRotation.ROTATION_0,
        mirror: false
      };

      await this.photoOutput.capture(photoSettings);
    } catch (error) {
      console.error('拍照失败:', error);
    }
  }

  // 切换前后摄像头
  async switchCamera() {
    // 可以后续实现
    console.info('切换摄像头功能待实现');
  }

  // 返回重拍
  async retakePhoto() {
    this.capturedImage = null;
    this.showPreview = true;
    this.showResult = false;
    await this.session?.start();
  }

  // 跳转到识图结果页
  goToRecognition() {
    if (this.capturedImage) {
      NavigationManager.getInstance().push('AIResult', {
        from: 'AIidentify',
        imageData: this.capturedImage
      });
    }
  }

  // 返回上一页
  goBack() {
    NavigationManager.getInstance().pop();
  }

  build() {
    NavDestination() {
     Column(){
       Stack() {
         if (this.showPreview) {
           // 相机预览界面
           Column() {
             // 预览区域
             XComponent({
               type: XComponentType.SURFACE,
               controller: this.mXComponentController
             })
               .width('100%')
               .height('100%')
               .onLoad(() => {
                 this.previewSurfaceId = 'cameraPreview';
               })
           }
           .width('100%')
           .height('100%')

           // 顶部控制栏
           Column() {
             Row() {
               // 返回按钮
               Button() {
                 Image($r('app.media.back'))
                   .width(24)
                   .height(24)
                   .fillColor(Color.White)
               }
               .width(40)
               .height(40)
               .backgroundColor('#66000000')
               .borderRadius(20)
               .onClick(() => this.goBack())

               Blank()

               // 切换摄像头按钮
               Button() {
                 Image($r('app.media.new'))
                   .width(24)
                   .height(24)
                   .fillColor(Color.White)
               }
               .width(40)
               .height(40)
               .backgroundColor('#66000000')
               .borderRadius(20)
               .onClick(() => this.switchCamera())
             }
             .width('100%')
             .padding({ left: 20, right: 20, top: 40 })

             Blank()

             // 底部控制栏
             Row() {
               Blank()

               // 拍照按钮
               Button() {
                 Circle()
                   .width(70)
                   .height(70)
                   .fill(Color.White)
                   .stroke(Color.Gray)
                   .strokeWidth(3)
               }
               .width(80)
               .height(80)
               .backgroundColor(Color.Transparent)
               .onClick(() => this.takePhoto())

               Blank()
             }
             .width('100%')
             .padding({ bottom: 40 })
           }
           .width('100%')
           .height('100%')

         } else if (this.showResult && this.capturedImage) {
           // 拍照预览界面
           Column() {
             // 图片预览
             Image(this.capturedImage)
               .width('100%')
               .layoutWeight(1)
               .objectFit(ImageFit.Contain)
               .backgroundColor(Color.Black)

             // 底部操作栏
             Row() {
               Button('重拍')
                 .width('45%')
                 .height(50)
                 .fontSize(18)
                 .backgroundColor('#FFE0E0E0')
                 .onClick(() => this.retakePhoto())

               Button('使用照片')
                 .width('45%')
                 .height(50)
                 .fontSize(18)
                 .backgroundColor('#FF007AFF')
                 .fontColor(Color.White)
                 .onClick(() => this.goToRecognition())
             }
             .width('100%')
             .padding(20)
             .justifyContent(FlexAlign.SpaceEvenly)
             .backgroundColor(Color.White)
           }
           .width('100%')
           .height('100%')
           .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
         }

       }
       .width('100%')
       .height('100%')
       .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
     }
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  aboutToDisappear() {
    // 释放相机资源
    this.session?.stop();
    this.session?.release();
    this.cameraInput?.close();
  }
}