import { NavigationManager } from "../common/NavigationManager";
import {NewTask} from './NewTask'



interface CalendarDay {
  day: number;
  isCurrentMonth: boolean;
}
interface CardItem{
  icon:string;
  title:string;
  content:string;
  isOn:boolean;
}

@Entry
@Component
export struct Task {
  @State params:Record<string,Object>={};
  @State currentYear: number = 2026;
  @State currentMonth: number = 4; // 4月
  @State selectedDay: number = 5; // 选中5号

  @State cardList:CardItem[]=[
    {icon:'app.media.water',title:'早上六点进行灌溉',content:'温室A区',isOn:false},
    {icon:'app.media.sun',title:'上午十点打开灯光增强模式',content:'培育托盘·亮度80%',isOn:false},
    {icon:'app.media.gleaf',title:'下午两点混合营养液',content:'水培系统B·氮磷钾溶液',isOn:false}
  ];

  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六'];

  // 计算当月日期数组（包含上个月/下个月的灰显日期）
  getCalendarDays(): CalendarDay[] {
    const firstDay = new Date(this.currentYear, this.currentMonth - 1, 1);
    const lastDay = new Date(this.currentYear, this.currentMonth, 0);
    const daysInMonth = lastDay.getDate();
    const firstDayWeek = firstDay.getDay(); // 当月1号是周几（0=周日）
    // 补上个月的日期
    const prevMonthLastDay = new Date(this.currentYear, this.currentMonth - 1, 0).getDate();
    let days:CalendarDay[]=[]
    for (let i = 0; i < firstDayWeek; i++) {
      days.push({day: prevMonthLastDay - firstDayWeek + i + 1, isCurrentMonth: false});
    }

    // 当月日期
    for (let i = 1; i <= daysInMonth; i++) {
      days.push({day: i, isCurrentMonth: true});
    }

    // 补下个月的日期（凑满6行）
    const remaining = 42 - days.length;
    for (let i = 1; i <= remaining; i++) {
      days.push({day: i, isCurrentMonth: false});
    }

    return days;
  }

  build() {
    NavDestination(){
      Column(){
        Row() {
          Image($r('app.media.back'))
            .backgroundColor('#E2E8F0')
            .width('40vp')
            .height('40vp')
            .borderRadius(20)
            .padding(12)
            .onClick(()=>{
              NavigationManager.getInstance().pop()
            })
          Text('任务安排表').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceAround)

        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('<')
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 20, left: 15 })
                  .onClick(() => {
                    // 上个月
                    if (this.currentMonth === 1) {
                      this.currentYear--;
                      this.currentMonth = 12;
                    } else {
                      this.currentMonth--;
                    }
                  })

                Text(`${this.currentMonth}月 ${this.currentYear}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 20 })

                Text('>')
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 20, right: 15 })
                  .onClick(() => {
                    // 下个月
                    if (this.currentMonth === 12) {
                      this.currentYear++;
                      this.currentMonth = 1;
                    } else {
                      this.currentMonth++;
                    }
                  })
              }
              .width('90%')
              .margin({ bottom: 16 })

              // 星期标题
              Row() {
                ForEach(this.weekDays, (day: string) => {
                  Text(day)
                    .fontSize(14)
                    .fontColor('#94A3B8')
                    .flexGrow(1)
                    .textAlign(TextAlign.Center)

                })
              }
              .width('90%')
              .margin({ bottom: 8 })

              // 日期网格
              Grid() {
                ForEach(this.getCalendarDays(), (item: CalendarDay) => {
                  GridItem() {
                    Text(item.day === 0 ? '' : item.day.toString())
                      .fontSize('18vp')
                      .fontColor(item.isCurrentMonth ? '#1E293B' : '#CBD5E1')
                      .fontWeight(FontWeight.Medium)
                      .width('40vp')
                      .height('40vp')
                      .textAlign(TextAlign.Center)
                      // 选中样式：绿色圆形
                      .backgroundColor(
                        item.isCurrentMonth && item.day === this.selectedDay ? '#13EC5B' : Color.Transparent
                      )
                      .borderRadius(25)
                      .shadow({
                        radius: 20,
                        color: item.isCurrentMonth && item.day === this.selectedDay
                          ? '#4d13ec5b'
                          : Color.Transparent,
                        offsetX: 0,
                        offsetY: 25
                      })

                      .fontColor(
                        item.isCurrentMonth && item.day === this.selectedDay ? Color.White :
                          (item.isCurrentMonth ? '#1E293B' : '#CBD5E1')
                      )
                      .onClick(() => {
                        if (item.isCurrentMonth) {
                          this.selectedDay = item.day;
                        }
                      })
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
              .rowsGap(8)
              .columnsGap(8)
              .width('90%')
              .height('auto')

            }
            .margin({top:15})
            .padding(3)
            .width('95%')
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({
              radius: 15,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 8
            })

            Row(){
              Text('今日任务').fontWeight(FontWeight.Bold).fontSize('20vp')
              Text('3待定').fontColor('#13EC5B').fontSize('15vp').fontWeight(FontWeight.Bold)
                .backgroundColor('#1a13ec5b')
                .padding({left:17,right:17,top:8,bottom:8})
                .borderRadius(17)
            }
            .width('100%')
            .padding({top:20,left:20,right:20,bottom:15})
            .justifyContent(FlexAlign.SpaceBetween)

            ForEach(this.cardList,(item:CardItem,index:number)=>{
              Row() {
                Image($r(item.icon))
                  .width('45vp')
                  .height('45vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor(
                      item.icon === 'app.media.water' ? '#EFF6FF' :
                      item.icon === 'app.media.sun' ? '#FFFBEB' :
                      item.icon === 'app.media.gleaf' ? '#F0FDF4' : '#3300ffbf')
                  .padding(10)
                  .borderRadius(12)
                  .margin({ left: 13 })
                Column() {
                  Text(item.title).fontWeight(FontWeight.Bold).fontSize('17vp')
                  Text(item.content).fontColor('#94A3B8').fontSize('13vp')
                }
                .width('60%')
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 10 })

                Blank()
                Toggle({
                  type: ToggleType.Switch,
                  isOn: item.isOn
                })
                  .margin({ right: 15 })
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((isOn: boolean) => {
                    this.cardList[index].isOn= isOn;
                    console.log('第${index+1}个卡片开关：', isOn);
                  })


              }
              .width('96%')
              .height('75vp')
              .borderRadius(20)
              .backgroundColor(Color.White)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })
            })

            Row(){
              Image($r('app.media.add'))
                .fillColor(Color.White)
                .width('50vp')
                .height('50vp')
                .padding(15)
                .backgroundColor('#13EC5B')
                .borderRadius(20)
                .shadow({
                  radius:25,
                  color:'#4d13ec5b',
                  offsetX:0,
                  offsetY:30
                })
                .onClick(()=>{
                  NavigationManager.getInstance().push('NewTask',{from:Task})
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .padding(15)


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