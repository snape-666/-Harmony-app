import { NavigationManager } from "../common/NavigationManager";
import { TaskService } from "../service/TaskService";
import {NewTask} from './NewTask'
import { http } from '@kit.NetworkKit';


interface CalendarDay {
  day: number;
  isCurrentMonth: boolean;
}
interface CardItem{
  id: string;
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

  @State cardList:CardItem[]=[];
  @State pendingCount: number = 0;
  private taskService: TaskService = TaskService.getInstance();
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  // 传感器日期数据
  @State sensorDate: string = '';
  @State isLoading: boolean = true;
  aboutToAppear(): void {
    // 加载今日任务
    this.loadTodayTasks();
    // ✅ 改为与手机系统时间绑定
    const now = new Date();
    this.currentYear = now.getFullYear();
    this.currentMonth = now.getMonth() + 1;
    this.selectedDay = now.getDate();

  }

  aboutToDisappear(): void {
    this.taskService.stopScheduler();
  }

  // 获取传感器接口的日期
  async fetchSensorDate(): Promise<void> {
    try {
      const url = 'https://guet-farm.netlify.app/.netlify/functions/getData';
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const outerData = JSON.parse(response.result as string) as Record<string, Object>;
        if (outerData.success && outerData.data) {
          // 获取最新的日期
          const dates = Object.keys(outerData.data as Record<string, Object>);
          if (dates.length > 0) {
            const latestDate = dates.sort().reverse()[0];
            this.sensorDate = latestDate;
            // 解析日期并更新日历选中
            const dateParts = latestDate.split('-');
            if (dateParts.length >= 3) {
              const year = parseInt(dateParts[0]);
              const month = parseInt(dateParts[1]);
              const day = parseInt(dateParts[2]);
              this.currentYear = year;
              this.currentMonth = month;
              this.selectedDay = day;
              console.log(`传感器日期: ${this.sensorDate}, 日历已更新`);
            }
          }
        }
      }
      httpRequest.destroy();
    } catch (error) {
      console.error('获取传感器日期失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  // 根据类别获取图标
  private getIconByCategory(category: string): string {
    switch (category) {
      case '灌溉': return 'app.media.water';
      case '照明': return 'app.media.sun';
      case '营养素': return 'app.media.gleaf';
      default: return 'app.media.others';
    }
  }

  // 格式化时间显示
  private formatTime(time24: string): string {
    const GeneratedDestructArray_1 = time24.split(':');
    const hour = GeneratedDestructArray_1[0];
    const minute = GeneratedDestructArray_1[1];
    let hourNum = parseInt(hour);
    let period = '上午';
    if (hourNum >= 12) {
      period = '下午';
      if (hourNum > 12) hourNum -= 12;
    }
    if (hourNum === 0) {
      hourNum = 12;
      period = '上午';
    }
    return `${period}${hourNum}:${minute}`;
  }

  // 完成任务
  async completeTask(taskId: string, index: number): Promise<void> {
    const success = await this.taskService.completeTask(taskId);
    if (success) {
      this.cardList.splice(index, 1);
      this.pendingCount = this.taskService.getPendingCount();
      console.log(`任务完成: ${taskId}`);
    }
  }
  // 加载今日任务
  loadTodayTasks(): void {
    const todayTasks = this.taskService.getTodayTasks();
    this.pendingCount = this.taskService.getPendingCount();

    this.cardList = todayTasks.map(task => ({
      id: task.id,
      icon: this.getIconByCategory(task.category),
      title: `${this.formatTime(task.time)} ${task.name}`,
      content: task.description || task.category,
      isOn: false
    }as CardItem));
  }

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
              Text(`${this.pendingCount}待定`).fontColor('#13EC5B').fontSize('15vp').fontWeight(FontWeight.Bold)
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
                    if (isOn) {
                      this.completeTask(item.id, index);
                    }
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
        .align(Alignment.TopStart)





        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }.hideTitleBar(true)
  }

}