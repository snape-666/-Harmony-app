import { webview } from '@kit.ArkWeb';
import { promptAction } from '@kit.ArkUI';
import { NavigationManager } from '../common/NavigationManager';

@Entry
@Component
export struct Monitor {
  @State params:Record<string,Object>={};
  @State isConnected: boolean = false;
  @State isLoading: boolean = true;
  private webController: webview.WebviewController = new webview.WebviewController();
  @State refreshKey: number = 0;
  @State isError: boolean = false;
  private refreshTimer: number = -1;
  private readonly VIDEO_URL: string = 'http://172.16.12.51/video';

  aboutToAppear() {
    // 页面加载时自动连接
    this.isConnected = true;
    this.isLoading = true;
    console.log('监控页面打开，连接:', this.VIDEO_URL);
    // 启动定时刷新，每50ms刷新一次图片
    this.refreshTimer = setInterval(() => {
      if (!this.isError) {
        this.refreshKey++;
      }
    }, 100); // 50ms ≈ 20帧/秒
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
    // 页面销毁时清理
    this.webController = new webview.WebviewController();
  }

  build() {
    NavDestination(){
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.back'))
            .width('20vp')
            .height('20vp')
            .onClick(() => {
              NavigationManager.getInstance().pop();
            })

          Text('实时监控')
            .fontSize('22vp')
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

       Image($r('app.media.new'))
         .width('26vp')
         .height('26vp')
         .onClick(() => {
           this.refreshKey++;
           this.isError = false;
           promptAction.openToast({
             message: '重新加载',
             duration: 1000
           });
         })
        }
        .width('100%')
        .height('56vp')
        .padding({ left: 16, right: 16 })
        .backgroundColor('#ffffff')
Column() {
  if (this.isConnected) {
    Web({
      src: this.VIDEO_URL,
      controller: this.webController
    })
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#000000')
      .javaScriptAccess(true)
      .fileAccess(false)
      .onlineImageAccess(true)
      .domStorageAccess(true)
      .zoomAccess(true)
      .overviewModeAccess(false)  // 禁用概览模式，允许自由缩放
      .initialScale(100)  // 初始缩放100%
      .onPageEnd(() => {
        console.log('视频加载成功');
        promptAction.openToast({
          message: '监控已连接',
          duration: 1500
        });
      })
      .onErrorReceive(() => {
        console.error('视频加载失败:');
        promptAction.openToast({
          message: '连接失败，请检查摄像头',
          duration: 2000
        });
      })
  } else {
    // 加载中
    Column() {
      LoadingProgress()
        .width('48vp')
        .height('48vp')
        .color('#13EC5B')
      Text('正在连接摄像头...')
        .fontSize('14vp')
        .fontColor('#64748B')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
.width('100%')
.layoutWeight(1)  // ✅ 占满剩余空间
.backgroundColor('#000000')
.clip(true)  // ✅ 裁剪超出部分

        // 控制说明
        Row() {
          Text('双指可缩放画面 | 拖动可移动视角')
            .fontSize('12vp')
            .fontColor('#94A3B8')
        }
        .width('100%')
        .height('36vp')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f1f5f9')

        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }.width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }.hideTitleBar(true)
  }
}