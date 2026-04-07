import { NavigationManager } from '../common/NavigationManager'
import { Yibiaopan } from './Yibiaopan'
import { Add } from './Add'
import {Lrrigate} from './Lrrigate'



@Entry
@Component
export struct Equipment {
  @State params: Record<string, Object> = {};
  @State selectedIndex: number = 1;
  @State isChecked1: boolean = false;
  @State isChecked2: boolean = false;
  @State currentLED: number = 75;
  @State currentPour: number = 500;
  @State isInputEnable: boolean = true;

  // 添加 TextInput 的控制器
  private textInputController: TextInputController = new TextInputController();

  aboutToAppear(): void {
    console.log('接收的数据',JSON.stringify(this.params));
  }
  build() {
    NavDestination() {
      Stack() {
        Column() {
          Row() {
            Row({ space: 10 }) {
              Image($r('app.media.ON'))
                .width('20vp')
              Text('ON')
                .fontSize('20vp')
                .fontColor('#13EC5B')
                .fontWeight(FontWeight.Bold)

            }
            .backgroundColor('#1a13ec5b')
            .padding(6)
            .borderRadius(25)
            .border({
              color: '#3313ec5b',
              width: 2
            })
            .margin({ left: 10 })

            Text('设备管理')
              .fontWeight(FontWeight.Bold)
              .fontSize('25vp')
              .position({ x: '50%' })
              .translate({ x: '-50%' })
              .margin({ top: 6 })

            Image($r('app.media.add'))
              .width('36vp')
              .padding(7)
              .backgroundColor('#3313ec5b')
              .borderRadius(18)
              .margin({ right: 20 })
              .onClick(() => {
                console.log('跳转到添加设备页面');
                NavigationManager.getInstance().push('Add', { from: Equipment })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Scroll() {
            Column() {
              Row({ space: 20 }) {
                this.rowCard('app.media.electric', '用电量', '124', 'kWh')
                this.rowCard('app.media.water', '用水量', '1450', 'L')
              }.margin({top:10})

              Text('控制中心')
                .fontWeight(FontWeight.Bold)
                .fontSize('20vp')
                .width('100%')
                .padding({ left: 20, top: 20, bottom: 20 })
              Row() {
                Image($r('app.media.water'))
                  .fillColor('#13EC5B')
                  .width('45vp')
                  .height('45vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(12)
                  .margin({ left: 16 })
                Column() {
                  Text('智能水阀').fontWeight(FontWeight.Bold).fontSize('18vp')
                  Text('状态:运行中').fontColor('#13EC5B').fontSize('13vp')
                }
                .margin({ left: 20 })

                Blank()
                Image($r('app.media.next'))
                  .width('32vp')
                  .height('32vp')
                  .borderRadius(16)
                  .padding(8)
                  .backgroundColor('#3313ec5b')
                  .objectFit(ImageFit.Contain)
                  .margin({ right: 16 })
                  .onClick(()=>{
                    NavigationManager.getInstance().push('Lrrigate',{from:Equipment})
                  })

              }
              .width('95%')
              .height('75vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Row() {
                Image($r('app.media.fans'))
                  .fillColor('#13EC5B')
                  .width('45vp')
                  .height('45vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(12)
                  .margin({ left: 16 })
                Column() {
                  Text('高效水泵').fontWeight(FontWeight.Bold).fontSize('18vp')
                  Row({ space: 20 }) {
                    Text('功率:450w').fontColor('#94A3B8').fontSize('13vp')
                    Text('流量:12L/M').fontColor('#94A3B8').fontSize('13vp')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 20 })

                Blank()
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.isChecked1
                })
                  .margin({ right: 15 })
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((isOn: boolean) => {
                    this.isChecked1 = isOn;
                    console.log('开关：', isOn);
                  })

              }
              .width('95%')
              .height('75vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Column() {
                Row() {
                  Image($r('app.media.sun'))
                    .fillColor('#13EC5B')
                    .width('45vp')
                    .height('45vp')
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#3313ec5b')
                    .padding(10)
                    .borderRadius(12)
                    .margin({ left: 16 })
                  Column() {
                    Text('LED补光灯').fontWeight(FontWeight.Bold).fontSize('18vp')
                    Text(`亮度:${this.currentLED}%`).fontSize('13vp').fontColor('#94A3B8')

                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 20 })

                  Blank()
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.isChecked2
                  })
                    .margin({ right: 15 })
                    .width('48vp')
                    .height('30vp')
                    .selectedColor('#13EC5B')
                    .onChange((isOn: boolean) => {
                      this.isChecked2 = isOn;
                      console.log('开关：', isOn);
                    })
                }
                .width('100%')
                .margin({ top: 15 })

                Slider({
                  value: this.currentLED,
                  min: 0,
                  max: 100,
                  step: 1
                })
                  .width('90%')
                  .height(8)
                  .backgroundColor('#E2E8F0')
                  .trackColor('#E2E8F0')
                  .selectedColor('#E2E8F0')
                  .blockColor('#13EC5B')
                  .blockBorderColor(Color.White)
                  .blockBorderWidth(3)
                  .borderRadius(16)
                  .onChange((value: number) => {
                    this.currentLED = value;
                  })
                  .margin({ top: 10, bottom: 10 })
                Row() {
                  Text('0%').fontColor('#94A3B8').fontSize('12vp').fontWeight(FontWeight.Bold)
                  Blank()
                  Text('100%').fontColor('#94A3B8').fontSize('12vp').fontWeight(FontWeight.Bold)
                }
                .width('90%')
              }
              .width('95%')
              .height('110vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Column() {
                Row() {
                  Image($r('app.media.tongji'))
                    .width('22vp')
                    .fillColor('#13EC5B')
                    .margin({ left: 5, right: 10 })
                  Text('目标灌溉量')
                    .fontWeight(FontWeight.Bold).fontSize('18vp')
                  Blank()

                  TextInput({
                    text: this.currentPour.toString(),
                    controller: this.textInputController  // 绑定控制器
                  })
                    .type(InputType.Number)
                    .fontSize('15vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#13EC5B')
                    .width('60vp')
                    .padding({ left: 12, right: 12 })
                    .backgroundColor('#3313ec5b')
                    .borderRadius(20)
                    .onChange((val) => {
                      let num = Number(val);
                      if (!isNaN(num) && num >= 0 && num <= 1000) {
                        this.currentPour = num;
                      }
                      this.isInputEnable = false;
                      setTimeout(() => {
                        this.isInputEnable = true;
                      }, 10);
                    })
                    // 添加失去焦点事件
                    .onBlur(() => {
                      console.log('TextInput失去焦点，当前值:', this.currentPour);
                    })

                }.width('90%')
                .margin({ top: 15 })

                Slider({
                  value: this.currentPour,
                  min: 0,
                  max: 1000,
                  step: 1
                })
                  .width('90%')
                  .height(8)
                  .backgroundColor('#E2E8F0')
                  .trackColor('#E2E8F0')
                  .selectedColor('#E2E8F0')
                  .blockColor('#13EC5B')
                  .blockBorderColor(Color.White)
                  .blockBorderWidth(3)
                  .borderRadius(16)
                  .onChange((value: number) => {
                    this.currentPour = value;
                  })
                  .margin({ top: 15 })

                Row() {
                  Text('0L')
                    .fontSize('12vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#94A3B8')
                  Blank()
                  Text('1000L')
                    .fontSize('12vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#94A3B8')
                }
                .width('90%')
                .margin({ top: 10 })

              }
              .width('95%')
              .height('110vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Row({space:10}) {
                this.endCard('app.media.xinhao','信号','强(85%)')
                this.endCard('app.media.battery','电量','95%')

              }



            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#80f1f5f9')
          .flexShrink(0)
          .scrollBar(BarState.Off)

          Tabs({ barPosition: BarPosition.End ,index:this.selectedIndex}) {
            TabContent() {
              Text('仪表盘')
            }
            .tabBar(this.tabBarBuilder(0, '仪表盘', $r('app.media.yibiaopan')))
            .onClick(() => {
              this.selectedIndex = 0;
            })

            TabContent() {
              Text('设备')
            }
            .tabBar(this.tabBarBuilder(1, '设备', $r('app.media.shebei')))
            .onClick(() => {
              this.selectedIndex = 1;
            })

            TabContent() {
              Text('统计')
            }
            .tabBar(this.tabBarBuilder(2, '统计', $r('app.media.tongji')))
            .onClick(() => {
              this.selectedIndex = 2
            })

            TabContent() {
              Text('设置内容')
            }
            .tabBar(this.tabBarBuilder(3, '设置', $r('app.media.setting')))
            .onClick(() => {
              this.selectedIndex = 3;
            })

          }
          .backgroundColor(Color.White)
          .height('50vp')
          .width('100%')
          .onChange((index: number) => {
            this.selectedIndex = index;
            if (index === 0) {
              NavigationManager.getInstance().push('Yibiaopan', { from: Equipment })
            }
            if (index === 2) {
              NavigationManager.getInstance().push('Count', { from: Equipment })
            }
            if (index === 3) {
              NavigationManager.getInstance().push('Setting', { from: Equipment })
            }
          })
          .animationDuration(0)

        }
      }
      .onClick(() => {
        // 点击空白区域时，清除 TextInput 的焦点
        this.textInputController.stopEditing();
        this.isInputEnable = false;
        setTimeout(() => {
          this.isInputEnable = true;
        }, 20);
      })
    }.hideTitleBar(true)
  }
  @Builder
  endCard(img:string,title:string,text:string){
    Row({space:15}) {
      Image($r(img))
        .width('20vp')
        .margin({left:20})
      Column(){
        Text(title).fontWeight(FontWeight.Bold).fontColor('#64748B')
        Text(text).fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Start)

    }
    .width('165vp')
    .height('80vp')
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 16 })
  }

  @Builder
  tabBarBuilder(itemIndex: number, title: string, img: ResourceStr) {
    Column({ space: 2 }) {
      Image(img)
        .width('30vp')
        .padding(2)
        .fillColor(this.selectedIndex === itemIndex ? '#13EC5B' : '#94A3B8')
      Text(title)
        .fontSize('12vp')
        .fontColor(this.selectedIndex === itemIndex ? '#13EC5B' : '#94A3B8')
    }
    .width('100%')
    .height('50vp')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  rowCard(img: string, title: string, num: string, unit: string) {
    Column() {
      Row({ space: 7 }) {
        Image($r(img))
          .width('20vp')
        Text(title)
          .fontSize('16vp')
          .fontColor('#64748B')
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding({ left: 20, top: 20 })

      Row({ space: 6 }) {
        Text(num)
          .fontWeight(FontWeight.Bold)
          .fontSize('20vp')
        Text(unit)
          .fontColor('#94A3B8')
          .fontSize('15vp')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 20, top: 15 })
    }
    .width('160vp')
    .height('100vp')
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 6
    })
  }
}