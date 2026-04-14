import { NavigationManager } from '../common/NavigationManager';
interface LogItem{
  content:string;
  time:string;
  dotColor:string;
}

@Entry
@Component
export struct Rule {
  @State params: Record<string, Object> = {};
  @State isCheck1: boolean = false;
  @State isCheck2: boolean = false;
  @State isCheck3: boolean = false;
@State logList:LogItem[]=[
  { content: "自动灌溉系统启动", time: "14:20 PM", dotColor: "#3B82F6" },
  { content: "自动灌溉终止", time: "14:35 PM", dotColor: "#3B82F6" },
  { content: "B区域检测到活动", time: "11:04 AM", dotColor: "#F59E0B" },
];

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
          Text('自动化规则').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

        Scroll() {
          Column() {
            Row() {
              Text('自动行为').fontColor('#64748B')
              Text('3个运行中').fontColor('#13EC5B')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(20)

            Column({ space: 15 }) {
              Row({ space: 10 }) {
                Image($r('app.media.autowater'))
                  .width('40vp')
                  .height('40vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(10)
                Column() {
                  Text('自动灌溉').fontWeight(FontWeight.Bold)
                  Text('智能水资源管理').fontColor('#64748B').fontSize('12vp')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.isCheck1 })
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((value) => {
                    this.isCheck1 = value;
                  })
              }
              .width('100%')
              .margin({ top: 15 })
              .padding({ left: 15, right: 15 })

              Column({ space: 3 }) {
                Text() {
                  Span('条件').fontColor(this.isCheck1 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('土壤含水量<30%').fontSize('12vp')
                }

                Text() {
                  Span('行为:').fontColor(this.isCheck1 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('开启水泵运行15分钟').fontSize('12vp')
                }
              }
              .width('90%')
              .height('50vp')
              .backgroundColor(this.isCheck1 ? '#0d13ec5b' : '#F1F5F9')
              .padding(10)
              .borderRadius(10)
              .border({
                width: 1,
                color: this.isCheck1 ? '#3313ec5b' : '#F1F5F9'

              })
              .alignItems(HorizontalAlign.Start)

            }
            .padding({ bottom: 15 })
            .width('90%')
            .backgroundColor(Color.White)
            .shadow({
              radius: 15,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 8
            })
            .borderRadius(20)
            .margin({ top: 15 })

            Column({ space: 15 }) {
              Row({ space: 10 }) {
                Image($r('app.media.moon'))
                  .width('40vp')
                  .height('40vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(10)
                Column() {
                  Text('夜间照明').fontWeight(FontWeight.Bold)
                  Text('安全与导航').fontColor('#64748B').fontSize('12vp')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.isCheck2})
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((value) => {
                    this.isCheck2= value;
                  })
              }
              .width('100%')
              .margin({ top: 15 })
              .padding({ left: 15, right: 15 })

              Column({ space: 3 }) {
                Text() {
                  Span('条件').fontColor(this.isCheck2 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('环境光<20lux').fontSize('12vp')
                }

                Text() {
                  Span('行为:').fontColor(this.isCheck2? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('开启路灯并将亮度调到50%').fontSize('12vp')
                }
              }
              .width('90%')
              .height('50vp')
              .backgroundColor(this.isCheck2? '#0d13ec5b' : '#F1F5F9')
              .padding(10)
              .borderRadius(10)
              .border({
                width: 1,
                color: this.isCheck2 ? '#3313ec5b' : '#F1F5F9'

              })
              .alignItems(HorizontalAlign.Start)

            }
            .padding({ bottom: 15 })
            .width('90%')
            .backgroundColor(Color.White)
            .shadow({
              radius: 15,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 8
            })
            .borderRadius(20)
            .margin({ top: 15 })

            Column({ space: 15 }) {
              Row({ space: 10 }) {
                Image($r('app.media.autotemp'))
                  .width('40vp')
                  .height('40vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(10)
                Column() {
                  Text('温室通风口').fontWeight(FontWeight.Bold)
                  Text('气候控制').fontColor('#64748B').fontSize('12vp')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.isCheck3 })
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((value) => {
                    this.isCheck3= value;
                  })
              }
              .width('100%')
              .margin({ top: 15 })
              .padding({ left: 15, right: 15 })

              Column({ space: 3 }) {
                Text() {
                  Span('条件').fontColor(this.isCheck3 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('室内温度>32℃').fontSize('12vp')
                }

                Text() {
                  Span('行为:').fontColor(this.isCheck3 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('打开窗户通风口').fontSize('12vp')
                }
              }
              .width('90%')
              .height('50vp')
              .backgroundColor(this.isCheck3 ? '#0d13ec5b' : '#F1F5F9')
              .padding(10)
              .borderRadius(10)
              .border({
                width: 1,
                color: this.isCheck3 ? '#3313ec5b' : '#F1F5F9'

              })
              .alignItems(HorizontalAlign.Start)

            }
            .padding({ bottom: 15 })
            .width('90%')
            .backgroundColor(Color.White)
            .shadow({
              radius: 15,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 8
            })
            .borderRadius(20)
            .margin({ top: 15 })

            Text('近期事件').fontColor('#64748B').width('100%').padding(15)
            Column(){
              // 标题 + 查看全部
              Row() {
                Text("活动日志")
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor("#1E293B")

                Blank()

                // 查看全部（可点击跳转）
                Text("查看全部")
                  .fontSize(15)
                  .fontColor("#13EC5B")
                  .onClick(() => {
                    console.log("点击查看全部日志");

                  })
              }
              .width("95%")
              .margin({ top: 15, bottom: 10 })

              // 分割线
              Divider().width("95%").color("#94A3B8")

              // 日志列表
              Column({ space: 0 }) {
                ForEach(this.logList, (item:LogItem) => {
                  Row({ space: 12 }) {
                    // 左侧彩色圆点
                    Circle()
                      .width(10)
                      .height(10)
                      .fill(item.dotColor)

                    // 内容
                    Text(item.content)
                      .fontSize(15)
                      .fontColor("#333")
                      .layoutWeight(1)

                    // 时间
                    Text(item.time)
                      .fontSize(13)
                      .fontColor("#9CA3AF")
                  }
                  .width("95%")
                  .padding({ top: 14, bottom: 14 })

                  // 分割线
                  Divider().width("95%").color("#94A3B8")
                })
              }
              .margin({ top: 5 })

            }
            .width('90%')
            .backgroundColor(Color.White)
            .shadow({
              radius: 15,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 8
            })
            .borderRadius(20)
            .margin({ top: 15 })









          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')
        .flexShrink(0)
        .scrollBar(BarState.Off)

        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }.hideTitleBar(true)
  }
}