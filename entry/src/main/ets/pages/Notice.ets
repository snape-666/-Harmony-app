import { NavigationManager } from "../common/NavigationManager";
import { GlobalStateService, NotifyState } from "../service/GlobalStateService";
import { common, Want } from "@kit.AbilityKit";
import { promptAction } from "@kit.ArkUI";


@Entry
@Component
export struct Notice {
  @State params:Record<string,Object>={};
  private globalService = GlobalStateService.getInstance();
  @State notifySystem: boolean = true;
  @State notifyBanner: boolean = true;
  @State notifyMode: 'sound' | 'vibrate' | 'silent' = 'sound';
  aboutToAppear() {
    // 从全局读取通知配置
    const globalState = this.globalService.getState();
    this.notifySystem = globalState.notifyConfig.notifySystem;
    this.notifyBanner = globalState.notifyConfig.notifyBanner;
    this.notifyMode = globalState.notifyConfig.notifyMode;
  }

  // 保存通知设置到全局
  private saveNotifyConfig(): void {
    const newConfig: NotifyState = {
      notifySystem: this.notifySystem,
      notifyBanner: this.notifyBanner,
      notifyMode: this.notifyMode
    };
    this.globalService.updateState({ "notifyConfig": newConfig });
  }

  // 跳转到系统通知设置页面
  private async openSystemNotificationSettings(): Promise<void> {
    try {
      const context: Context | undefined = this.getUIContext().getHostContext();
      if (!context) {
        throw new Error('获取Context失败');
      }

      // 打开应用详情页，用户可在详情页手动开启通知
      const want: Want = {
        bundleName: context.applicationInfo.name,
        abilityName: 'com.example.application.MainAbility'
      };

      await (context as common.UIAbilityContext).startAbility(want);

    } catch (err) {
      console.error('打开设置失败:', JSON.stringify(err));
      promptAction.openToast({
        message: "请手动前往系统设置开启通知",
        duration: 2000
      });
    }
  }

  // 单选按钮构建器
  @Builder
  private RadioItem(img:string,title: string, mode: 'sound' | 'vibrate' | 'silent') {
    Row({space:15}) {
      Image($r(img))
        .width('40vp')
        .backgroundColor('#1a13ec5b')
        .padding(10)
        .borderRadius(10)
      Text(title)
        .fontSize(16)
        .layoutWeight(1)
        .fontWeight(FontWeight.Bold)

      Circle({ width: 20, height: 20 })
        .strokeWidth(2)
        .stroke( '#ccc')
        .fill(this.notifyMode === mode ? '#13EC5B' : '#fff')
    }
    .padding({top:2,bottom:2})
    .width('100%')
    .onClick(() => {
      this.notifyMode = mode;
      this.saveNotifyConfig();
    });
  }
  build() {
    NavDestination() {
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
          Text('消息通知').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

        Column() {
          Text("未打开APP时")
            .fontWeight(FontWeight.Bold)
            .fontSize('15vp')
            .width('100%')
            .padding({ left: 15, top: 15, bottom: 10 });

            // 系统通知开关
            Row({space:15}) {
              Image($r('app.media.alarm'))
                .width('40vp')
                .backgroundColor('#1a13ec5b')
                .padding(10)
                .borderRadius(10)
              Text("系统消息通知")
                .fontSize(16)
                .layoutWeight(1)
                .fontWeight(FontWeight.Bold)

              Toggle({ type: ToggleType.Switch, isOn: this.notifySystem })
                .selectedColor('#13EC5B')
                .onChange((value) => {
                  this.notifySystem = value;
                  this.openSystemNotificationSettings();
                  this.saveNotifyConfig();
                });
            }
            .margin({bottom:10})
            .padding(15)
            .width('95%')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius:20,
            color:'rgba(0,0,0,0.1)',
            offsetX:15,
            offsetY:15
          })


            Divider().margin({ left: 15 });

            // 分组标题
            Text("打开APP时")
              .fontWeight(FontWeight.Bold)
              .fontSize('15vp')
              .width('100%')
              .padding({ left: 15, top: 15, bottom: 10 });

            // APP内横幅开关
            Row({space:15}) {
              Image($r('app.media.topNotified'))
                .width('40vp')
                .backgroundColor('#1a13ec5b')
                .padding(10)
                .borderRadius(10)
              Text("APP内消息横幅")
                .fontSize(16)
                .layoutWeight(1)
                .fontWeight(FontWeight.Bold)

              Toggle({ type: ToggleType.Switch, isOn: this.notifyBanner })
                .selectedColor('#13EC5B')
                .onChange((value) => {
                  this.notifyBanner = value;
                  this.saveNotifyConfig();
                });
            }
            .margin({bottom:10})
            .padding(15)
            .width('95%')
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({
              radius:20,
              color:'rgba(0,0,0,0.1)',
              offsetX:15,
              offsetY:15
            })


            // 分组标题
            Text("提醒方式")
              .fontWeight(FontWeight.Bold)
              .fontSize('15vp')
              .width('100%')
              .padding({ left: 15, top: 15, bottom: 10 });

          Column(){
              // 单选列表
              this.RadioItem('app.media.laud1',"声音", "sound");
              Divider().margin({top:5,bottom:5}).height(1)
              this.RadioItem('app.media.laud2',"振动", "vibrate");
              Divider().margin({top:5,bottom:5}).height(1)
              this.RadioItem('app.media.laud3',"静音", "silent");
            }
          .margin({bottom:10})
          .padding(15)
          .width('95%')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius:20,
            color:'rgba(0,0,0,0.1)',
            offsetX:15,
            offsetY:15
          })



          Blank()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#f2f2f2')

      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    }.hideTitleBar(true)
  }
}