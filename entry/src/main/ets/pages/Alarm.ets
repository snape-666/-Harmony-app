import sendableColorSpaceManager from '@ohos.graphics.sendableColorSpaceManager';
import { JSON } from '@kit.ArkTS';
import { NavigationManager } from '../common/NavigationManager'

@Entry
@Component
export struct Alarm {

  @State params: Record<string, Object> = {};
  @State isChecked: boolean = false;
  // 温度
  @State tempMin: number = 18;
  @State tempMax: number = 32;
  readonly tempLimitMin: number = 10;
  readonly tempLimitMax: number = 40;

  // 湿度
  @State humiMin: number = 40;
  @State humiMax: number = 80;
  readonly humiLimitMin: number = 0;
  readonly humiLimitMax: number = 100;

  // CO2
  @State co2Min: number = 300;
  @State co2Max: number = 1200;
  readonly co2LimitMin: number = 0;
  readonly co2LimitMax: number = 2000;

  // 光照
  @State lightMin: number = 5000;
  @State lightMax: number = 25000;
  readonly lightLimitMin: number = 0;
  readonly lightLimitMax: number = 30000;

  // 添加所有 TextInput 的控制器
  private tempMinController: TextInputController = new TextInputController();
  private tempMaxController: TextInputController = new TextInputController();
  private humiMinController: TextInputController = new TextInputController();
  private humiMaxController: TextInputController = new TextInputController();
  private co2MinController: TextInputController = new TextInputController();
  private co2MaxController: TextInputController = new TextInputController();
  private lightMinController: TextInputController = new TextInputController();
  private lightMaxController: TextInputController = new TextInputController();

  aboutToAppear(): void {
    console.log('接收的参数', JSON.stringify(this.params));
  }

  // 清除所有 TextInput 焦点的统一方法
  clearAllFocus() {
    this.tempMinController.stopEditing();
    this.tempMaxController.stopEditing();
    this.humiMinController.stopEditing();
    this.humiMaxController.stopEditing();
    this.co2MinController.stopEditing();
    this.co2MaxController.stopEditing();
    this.lightMinController.stopEditing();
    this.lightMaxController.stopEditing();
  }

  resetAll() {
    // 温度
    this.tempMin = 18;
    this.tempMax = 32;
    // 湿度
    this.humiMin = 40;
    this.humiMax = 80;
    // CO2
    this.co2Min = 300;
    this.co2Max = 1200;
    // 光照
    this.lightMin = 5000;
    this.lightMax = 25000;
    // 开关
    this.isChecked = false;

    console.log("已重置所有参数");
    // 重置后清除焦点
    this.clearAllFocus();
  }

  applyChanges() {
    console.log("温度：" + this.tempMin + "~" + this.tempMax);
    console.log("湿度：" + this.humiMin + "~" + this.humiMax);
    console.log("CO2：" + this.co2Min + "~" + this.co2Max);
    console.log("光照：" + this.lightMin + "~" + this.lightMax);
    console.log("开关：" + this.isChecked);
    //增加数据库逻辑
    // 应用后清除焦点
    this.clearAllFocus();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Stack() {
            Circle()
              .width('30vp')
              .height('30vp')
              .fill('#E2E8F0')
            Image($r('app.media.back'))
              .width('12')
              .onClick(() => {
                console.log('返回')
                NavigationManager.getInstance().pop()
              })

          }
          .margin({ left: 16 })

          Text('阈值警报')
            .fontSize('20vp')
            .fontWeight(FontWeight.Bold)
          Text('')
            .width('30vp')
            .height('30vp')
            .margin({ right: 16 })

        }
        .height('50vp')
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.alarm'))
                .width('20vp')
                .margin(20)
              Column({ space: 10 }) {
                Text('推送通知')
                  .fontWeight(FontWeight.Bold)
                Text('数值超出范围时接收警报')
                  .fontSize('12')
                  .fontColor('#475569')
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Toggle({ type: ToggleType.Switch, isOn: this.isChecked })
                .onChange((isOn: boolean) => {
                  this.isChecked = isOn; // 监听开关变化
                  console.log("开关状态：" + isOn);
                })
                .selectedColor('#13EC5B')
                .margin({ right: 20 })

            }
            .height('70vp')
            .width('95%')
            .borderRadius(20)
            .backgroundColor('#0f13ec5b')
            .border({
              color: '#3313ec5b',
              width: 1
            })
            .margin({top:10})

            Row() {
              Text('传感器参数')
                .fontColor('#94A3B8')
                .fontSize('15vp')
                .margin({ left: 16, top: 15 })
            }
            .alignSelf(ItemAlign.Start)

            // 温度传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#FFEDD5')
                    .borderRadius(18)
                  Image($r('app.media.redtemper'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('温度(℃)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text('24℃')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor('#13EC5B')
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.tempMax, this.tempLimitMin, this.tempLimitMax) -
                      this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.tempMax, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 温度文字
                  Text(`${this.tempMin}${'℃'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.tempMax}${'℃'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.tempMax, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.tempMin.toString(),
                    controller: this.tempMinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.tempLimitMin && num < this.tempMax) {
                        this.tempMin = num
                      }
                    })
                    .onBlur(() => {
                      console.log('温度下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.tempMax.toString(),
                    controller: this.tempMaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.tempLimitMax && num > this.tempMin) {
                        this.tempMax = num
                      }
                    })
                    .onBlur(() => {
                      console.log('温度上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .backgroundColor(Color.White)
            .borderRadius(20)
            .margin({ top: 15 })
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })

            // 湿度传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#DBEAFE')
                    .borderRadius(18)
                  Image($r('app.media.water'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('湿度(%)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text('65%')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor('#13EC5B')
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.humiMax, this.humiLimitMin, this.humiLimitMax) -
                      this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.humiMax, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 湿度文字
                  Text(`${this.humiMin}${'%'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.humiMax}${'%'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.humiMax, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.humiMin.toString(),
                    controller: this.humiMinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.humiLimitMin && num < this.humiMax) {
                        this.humiMin = num
                      }
                    })
                    .onBlur(() => {
                      console.log('湿度下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.humiMax.toString(),
                    controller: this.humiMaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.humiLimitMax && num > this.humiMin) {
                        this.humiMax = num
                      }
                    })
                    .onBlur(() => {
                      console.log('湿度上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .borderRadius(20)
            .margin({ top: 15 })
            .backgroundColor(Color.White)
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })

            // CO2传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#F3E8FF')
                    .borderRadius(18)
                  Image($r('app.media.nco2'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('co2(ppm)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text('412')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor('#13EC5B')
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.co2Max, this.co2LimitMin, this.co2LimitMax) -
                      this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.co2Max, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // CO2文字
                  Text(`${this.co2Min}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.co2Max}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.co2Max, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.co2Min.toString(),
                    controller: this.co2MinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.co2LimitMin && num < this.co2Max) {
                        this.co2Min = num
                      }
                    })
                    .onBlur(() => {
                      console.log('CO2下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.co2Max.toString(),
                    controller: this.co2MaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.co2LimitMax && num > this.co2Min) {
                        this.co2Max = num
                      }
                    })
                    .onBlur(() => {
                      console.log('CO2上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .borderRadius(20)
            .backgroundColor(Color.White)
            .margin({ top: 15})
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })

            // 光照传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#FEF9C3')
                    .borderRadius(18)
                  Image($r('app.media.sun'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('光照(lux)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text('12k')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor('#13EC5B')
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.lightMax, this.lightLimitMin, this.lightLimitMax) -
                      this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.lightMax, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 光照文字
                  Text(`${this.lightMin / 1000}${'k'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.lightMax / 1000}${'k'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.lightMax, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.lightMin.toString(),
                    controller: this.lightMinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.lightLimitMin && num < this.lightMax) {
                        this.lightMin = num
                      }
                    })
                    .onBlur(() => {
                      console.log('光照下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.lightMax.toString(),
                    controller: this.lightMaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.lightLimitMax && num > this.lightMin) {
                        this.lightMax = num
                      }
                    })
                    .onBlur(() => {
                      console.log('光照上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .borderRadius(20)
            .backgroundColor(Color.White)
            .margin({ top: 15,bottom:15 })
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#99f1f5f9')
        .flexShrink(0)
        .scrollBar(BarState.Off)

        Row({ space: 20 }) {
          Button('重置')
            .width('120vp')
            .fontColor('#475569')
            .backgroundColor('#F1F5F9')
            .border({
              color: '#D1D5DB',
              width: 1
            })
            .onClick(() => {
              this.resetAll();
            })

          Button('应用更改')
            .width('180')
            .backgroundColor('#13EC5B')
            .shadow({
              radius: 5,
              color: 'rgba(20,100,50,0.3)',
              offsetY: 6
            })
            .onClick(() => {
              this.applyChanges();
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('60vp')
      }
    }
    .onClick(() => {
      // 点击空白区域时，清除所有 TextInput 的焦点
      this.clearAllFocus();
    })
    .hideTitleBar(true)
  }

  private mapToSlider(move: number, minLimit: number, maxLimit: number): number {
    return ((move - minLimit) / (maxLimit - minLimit)) * 100;
  }
}