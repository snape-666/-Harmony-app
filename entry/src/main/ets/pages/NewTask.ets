import { NavigationManager } from "../common/NavigationManager";
import { Font } from "@ohos.arkui.UIContext";

interface TaskItem{
  id:string;
  name:string;
  category:string;
  time:string;
  period:string;
  repeatDays:string[];
  desc:string;
  isOn:boolean
}
@Entry
@Component
export struct NewTask {
  @State params: Record<string, Object> = {};
  @State taskName: string = '';
  @State selectedCategory: string = '灌溉';
  @State selectedHour: number = 6;
  @State selectedMinute: number = 0;
  @State showTimePicker: boolean = false;
  @State period: string = '上午';
  @State selectedDay: string[] = ['周一', '周二', '周三', '周四', '周五'];
  @State desc: string = '';
  @State taskList: TaskItem[] = [];
  private categories: string[] = ['灌溉', '照明', '营养素', '其他']
  private weekList:string[]=['周一','周二','周三','周四','周五','周六','周日']
  private getImageResource(category: string): Resource {
    switch (category) {
      case '灌溉':
        return $r('app.media.gwater') // 灌溉图标
      case '照明':
        return $r('app.media.sun') // 照明图标
      case '营养素':
        return $r('app.media.gleaf') // 营养素图标
      case '其他':
        return $r('app.media.others') // 其他图标
      default:
        return $r('app.media.redAlarm')
    }
  }

  private getCategoryColor(category: string): string {
    switch (category) {
      case '灌溉':
        return '#2563EB' // 蓝色
      case '照明':
        return '#D97706' // 橙色/黄色
      case '营养素':
        return '#16A34A' // 绿色
      case '其他':
        return '#2C2F2F' // 紫色
      default:
        return '#DC2626'
    }
  }

  private getBackground(category: string): string {
    switch (category) {
      case '灌溉':
        return '#332563eb'
      case '照明':
        return '#33d97706'
      case '营养素':
        return '#3316a34a'
      case '其他':
        return '#3300ffbf'
      default:
        return '#FEE2E2'

    }
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
          Text('新任务').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

        Column() {


          Column() {
            Text('任务名称').fontColor('#747777').fontSize('15vp')
              .width('100%').padding(15)
            TextInput({ placeholder: '请输入任务名称' })
              .width('90%')
              .height('50vp')
              .borderRadius(25)
              .backgroundColor('#b3dfe3e2')
              .onChange((v) => this.taskName = v)
              .margin({ bottom: 20 })

          }
          .width('95%')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 15,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 8
          })
          .margin({ top: 10 })

          Column() {
            Text('执行类别').fontColor('#747777').fontSize('15vp').width('100%').padding(15)
            Grid() {
              ForEach(this.categories, (item: string) => {
                GridItem() {
                  Row({ space: 10 }) {
                    Image(this.getImageResource(item))
                      .width('20vp')
                      .height('20vp')
                      .objectFit(ImageFit.Contain)
                      .fillColor(this.getCategoryColor(item))
                    Text(item).fontColor('#2C2F2F')
                  }
                  .padding({ left: 20 })
                  .borderRadius(8)
                  .width('70%')
                  .height('55vp')
                  .backgroundColor(this.selectedCategory === item ? this.getBackground(item) : '#DFE3E2')
                  .onClick(() => {
                    this.selectedCategory = item
                  })
                }

              }, (item: string) => item)
            }
            .margin({ bottom: 15 })
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .rowsGap(10)
            .width('100%')
            .height('130vp')

          }
          .width('95%')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 15,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 8
          })
          .margin({ top: 15 })
          .padding({ left: 10, right: 10 })

          Column() {
            Text('激活时间').fontColor('#747777').fontSize('15vp')
            Row({ space: 10 }) {
              Column() {
                Text(this.selectedHour.toString().padStart(2, '0')).fontWeight(FontWeight.Bold).fontSize('50vp')
                Text('时').fontColor('#747777').fontSize('10vp')
              }

              Text(':').fontWeight(FontWeight.Bold).fontColor('#D9DEDD').fontSize('40vp')
              Column() {
                Text(this.selectedMinute.toString().padStart(2, '0')).fontWeight(FontWeight.Bold).fontSize('50vp')
                Text('分').fontColor('#747777').fontSize('10vp')
              }

              Blank()
              Column({ space: 10 }) {
                Text('上午')
                  .fontSize('10vp')
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#CDFFD4')
                  .padding({
                    left: 13,
                    right: 13,
                    top: 6,
                    bottom: 6
                  })
                  .borderRadius(20)
                  .backgroundColor(this.period === "上午" ? '#13EC5B' : '#DFE3E2')
                  .onClick(() => {
                    this.period = '上午'
                  })
                Text('下午')
                  .fontSize('10vp')
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2C2F2F')
                  .padding({
                    left: 13,
                    right: 13,
                    top: 6,
                    bottom: 6
                  })
                  .borderRadius(20)
                  .backgroundColor(this.period === "下午" ? '#13EC5B' : '#DFE3E2')
                  .onClick(() => this.period = "下午")
              }

            }
            .margin({ top: 7 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 20, right: 20 })

            Row() {
              Text('更改时间')
                .fontSize('12vp')
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#DFE3E2')
                .padding({
                  left: 15,
                  right: 15,
                  top: 8,
                  bottom: 8
                })
                .borderRadius(18)
                .onClick(() => {
                  this.showTimePicker = true
                })
            }
            .margin({ top: 10, left: 39 })
            .width('100%')

            if (this.showTimePicker) {
              TimePicker()
            }

            Row() {
              Text('重复模式').fontSize('12vp').fontColor('#747777').fontWeight(FontWeight.Bold)
              Text() {
                Span('每周').fontColor('#13EC5B').fontSize('12vp').fontWeight(FontWeight.Bold)
                  .onClick(() => {

                  })
                Span('/').fontColor('#13EC5B').fontSize('13vp').fontWeight(FontWeight.Bold)
                Span('仅一次').fontColor('#13EC5B').fontSize('12vp').fontWeight(FontWeight.Bold)
                  .onClick(() => {

                  })
              }
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15, top: 10 })
            Row(){
              Grid(){
                ForEach(this.weekList,(day:string)=>{
                  GridItem(){
                    Text(day)
                      .width('35vp')
                      .height('35vp')
                      .fontSize('12vp')
                      .fontWeight(FontWeight.Bold)
                      .padding(5)
                      .borderRadius(20)
                      .fontColor(this.selectedDay.includes(day)?'#CDFFD4':'#595C5C')
                      .backgroundColor(this.selectedDay.includes(day) ? '#13EC5B' : '#DFE3E2')
                  }
                })

              }
              .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
              .columnsGap(8)
              .width('100%')
              .height(40);
            }
            .padding({left:10,right:10})
            .margin({top:15})
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .margin({ top: 15 })
          .padding({ top: 15, bottom: 15 })
          .width('95%')
          .height('250vp')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 15,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 8
          })






          Button('创建任务')
            .width('50%')
            .margin({top:20})
            .backgroundColor('#13EC5B')
            .shadow({
              radius:20,
              color:'rgba(0, 0, 0, 0.2)',
              offsetX:0,
              offsetY:10

            })
            .onClick(() => {
              console.log('创建任务');
          })

        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')

        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }.hideTitleBar(true)
  }
}