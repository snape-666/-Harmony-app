import { NavigationManager } from "../common/NavigationManager";
import { Font } from "@ohos.arkui.UIContext";
import { TaskService } from "../service/TaskService";
import { promptAction } from "@kit.ArkUI";

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
  @State taskDescription: string = '';
  @State selectedCategory: string = '灌溉';
  @State selectedHour: number = 6;
  @State selectedMinute: number = 0;
  @State showTimePicker: boolean = false;  // 控制时间选择器弹窗显示
  @State period: string = '上午';
  @State selectedDay: string[] = ['周一', '周二', '周三', '周四', '周五'];
  @State desc: string = '';
  @State repeatMode: string = 'weekly'; // "weekly" 或 "once"
  @State taskList: TaskItem[] = [];
  private taskService: TaskService = TaskService.getInstance();
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

  // 获取当前日期对应的星期几
  private getCurrentWeekdayFromDate(): string {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[new Date().getDay()];
  }
  // 根据日历选中日期自动设置星期
  private autoSelectWeekday(): void {
    // 从 params 获取选中的日期（如果从日历页面传入）
    if (this.params['selectedDate']) {
      // 如果有传入日期，解析并选中对应星期
    }
  }
  aboutToAppear(): void {
    // 自动选中当前星期（可根据需要调整）
    this.autoSelectWeekday();
  }
  // 创建任务
  async createTask(): Promise<void> {
    if (!this.taskName.trim()) {
      promptAction.openToast({ message: '请输入任务名称', duration: 2000 });
      return;
    }

    try {
      const newTask = await this.taskService.addTask(
        this.taskName,
        this.taskDescription,
        this.selectedCategory,
        this.selectedHour,
        this.selectedMinute,
        this.period,
        this.repeatMode,
        this.selectedDay
      );

      console.log('任务创建成功:', newTask);
      promptAction.showToast({ message: '任务创建成功', duration: 1500 });

      // 返回上一页
      NavigationManager.getInstance().pop();
    } catch (error) {
      console.error('创建任务失败:', error);
      promptAction.openToast({ message: '创建任务失败', duration: 2000 });
    }
  }

  // 切换重复模式
  setRepeatMode(mode: string): void {
    this.repeatMode = mode;
    if (mode === 'once') {
      // 仅一次模式：清空周次选择，只选中当前星期
      const currentWeekday = this.getCurrentWeekdayFromDate();
      this.selectedDay = [currentWeekday];
    }
  }

  // 切换周次选中
  toggleWeekDay(day: string): void {
    if (this.repeatMode === 'once') return; // 仅一次模式不可修改周次

    if (this.selectedDay.includes(day)) {
      this.selectedDay = this.selectedDay.filter(d => d !== day);
    } else {
      this.selectedDay = [...this.selectedDay, day];
    }
  }


  // ✅ 新增：时间选择器确认回调
  private onTimePickerConfirm = (hour: number, minute: number): void => {
    this.selectedHour = hour;
    this.selectedMinute = minute;
    console.log(`时间已更新: ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`);
  }
  // ✅ 新增：时间选择器数据源
  private hourList: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  private minuteList: number[] =   [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59];
  // 需要为每个 List 创建 Scroller
  private hourScroller: Scroller = new Scroller();
  private minuteScroller: Scroller = new Scroller();
  // 获取当前居中项的索引
  private getCenterItemIndex(scroller: Scroller): number {
    // 获取当前滚动偏移量
    const offset = scroller.currentOffset();
    if (!offset) {
      return -1;
    }
    // 每个item高度60，列表高度180，中心位置在90
    const centerOffset = 90;
    const itemHeight = 60;
    // 计算当前居中项的索引
    const index = Math.round((offset.yOffset + centerOffset) / itemHeight);
    return index;
  }
  build() {
    NavDestination() {
      Column(){
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

        Scroll(){
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

                Text('描述').fontColor('#747777').fontSize('15vp')
                  .width('100%').padding(15)
                TextInput({ placeholder: '请输入任务描述' })
                  .width('90%')
                  .height('50vp')
                  .borderRadius(25)
                  .backgroundColor('#b3dfe3e2')
                  .onChange((v) => this.taskDescription = v)
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
                Text('激活时间').fontColor('#747777').fontSize('15vp').fontWeight(FontWeight.Bold)
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
                      .fontSize('15vp')
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.period === "上午" ? '#CDFFD4' : '#2C2F2F')
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
                      .fontSize('15vp')
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.period === "下午" ? '#CDFFD4' : '#2C2F2F')
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

                Row() {
                  Text('重复模式').fontSize('12vp').fontColor('#747777').fontWeight(FontWeight.Bold)
                  Text() {
                    Span('每周').fontColor('#13EC5B').fontSize('12vp').fontWeight(FontWeight.Bold)
                      .onClick(() =>
                        this.setRepeatMode('weekly')
                      )
                    Span('/').fontColor('#13EC5B').fontSize('13vp').fontWeight(FontWeight.Bold)
                    Span('仅一次').fontColor('#13EC5B').fontSize('12vp').fontWeight(FontWeight.Bold)
                      .onClick(() =>this.setRepeatMode('once') )
                  }
                }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15, top: 10 })

                //周次选择
                Row() {
                  Grid() {
                    ForEach(this.weekList, (day: string) => {
                      GridItem() {
                        Text(day)
                          .width('35vp')
                          .height('35vp')
                          .fontSize('12vp')
                          .fontWeight(FontWeight.Bold)
                          .padding(5)
                          .borderRadius(20)
                          .fontColor(this.selectedDay.includes(day) ? '#CDFFD4' : '#595C5C')
                          .backgroundColor(this.selectedDay.includes(day) ? '#13EC5B' : '#DFE3E2')
                          .opacity(this.repeatMode === 'once' ? 0.5 : 1)
                          .onClick(() => {
                            if (this.repeatMode !== 'once') {
                              this.toggleWeekDay(day);
                            }
                          })
                      }
                    })

                  }
                  .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
                  .columnsGap(8)
                  .width('100%')
                  .height(40);
                }
                .padding({ left: 10, right: 10 })
                .margin({ top: 15 })
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

              // ✅ 修改：将内嵌的时间选择器改为弹窗条件渲染
              if (this.showTimePicker) {
                // 半透明遮罩层
                Column()
                  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
                  .width('100%')
                  .height('200%')
                  .backgroundColor('rgba(0, 0, 0, 0.5)')
                  .position({ x: 0, y: 0 })
                  .onClick(() => {
                    this.showTimePicker = false;
                  })
                  .zIndex(666)


                // 时间选择器卡片（居中显示）
                Column() {
                  // 顶部两行文字
                  Text('安排任务')
                    .fontSize('16vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#13EC5B')
                    .margin({ top: 20 })
                    .width('100%')
                    .padding({ left: 20 })
                  Text('选择时间')
                    .fontSize('20vp')
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 5, bottom: 10 })
                    .width('100%')
                    .padding({ left: 20 })

                  // 时间选择器
                  Stack({ alignContent: Alignment.Center }) {
                    Row()
                      .width("90%")
                      .height(60)
                      .backgroundColor("#F5F5F5")
                      .borderRadius(8);

                    Row({ space: 6 }) {
                      // 小时列表（1-12）
                      List({ scroller: this.hourScroller }) {
                        ForEach(this.hourList, (hour: number, index: number) => {
                          ListItem() {
                            Text(hour.toString().padStart(2, "0"))
                              .fontSize(this.selectedHour === hour ? 48 : 32)
                              //  .margin({bottom:10,top:10})
                              .fontColor(this.selectedHour === hour ? "#13EC5B" : "#999")
                              .fontWeight(FontWeight.Bold)
                              .textAlign(TextAlign.Center)
                          }.width('100%')
                          .height(60)
                        }, (hour: number, index: number) => `${index}_${hour}`) //  稳定的 key
                      }
                      .width("45%")
                      .height(180)
                      .alignListItem(ListItemAlign.Center)
                      .scrollBar(BarState.Off)
                      .scrollSnapAlign(ScrollSnapAlign.CENTER)
                      .onScrollStop(() => {
                        const offset = this.hourScroller.currentOffset();
                        if (offset) {
                          const itemHeight = 60;
                          const listHeight = 180;
                          // 计算列表中心位置对应的偏移量
                          const centerPosition = offset.yOffset + listHeight / 2;
                          // 计算中心位置对应的索引
                          const selectedIndex = Math.floor(centerPosition / itemHeight);
                          if (selectedIndex >= 0 && selectedIndex < this.hourList.length) {
                            this.selectedHour = this.hourList[selectedIndex];
                            console.log(`小时选中: ${this.selectedHour}, 索引: ${selectedIndex}`);
                          }
                        }
                      })

                      Text(":")
                        .fontSize(48)
                        .fontColor("#999")
                        .fontWeight(FontWeight.Bold);

                      // 分钟列表（0-59）
                      List({ scroller: this.minuteScroller }) {
                        ForEach(this.minuteList, (minute: number, index: number) => {
                          ListItem() {
                            Text(minute.toString().padStart(2, "0"))
                              .fontSize(this.selectedMinute === minute ? 48 : 32)
                              .fontColor(this.selectedMinute === minute ? "#13EC5B" : "#999")
                              // .margin({top:10,bottom:10})
                              .fontWeight(FontWeight.Bold)
                              .textAlign(TextAlign.Center)
                          }.width('100%')
                          .height(60)
                        }, (minute: number, index: number) => `${index}_${minute}`)
                      }
                      .width("45%")
                      .height(180)
                      .alignListItem(ListItemAlign.Center)
                      .scrollSnapAlign(ScrollSnapAlign.CENTER)
                      .scrollBar(BarState.Off)
                      .onScrollStop(() => {
                        const offset = this.minuteScroller.currentOffset();
                        if (offset) {
                          const itemHeight = 60;
                          const listHeight = 180;
                          // 计算列表中心位置对应的偏移量
                          const centerPosition = offset.yOffset + listHeight / 2;
                          // 计算中心位置对应的索引
                          const selectedIndex = Math.floor(centerPosition / itemHeight);
                          if (selectedIndex >= 0 && selectedIndex < this.minuteList.length) {
                            this.selectedMinute = this.minuteList[selectedIndex];
                            console.log(`分钟选中: ${this.selectedMinute}, 索引: ${selectedIndex}`);
                          }
                        }
                      })
                    }
                  }
                  .padding({ bottom: 20 });

                  // 底部按钮
                  Row({ space: 16 }) {
                    Button("取消")
                      .width("45%")
                      .height('50vp')
                      .backgroundColor("#DFE3E2")
                      .fontColor("#2C2F2F")
                      .borderRadius(25)
                      .onClick(() => {
                        this.showTimePicker = false;
                      });

                    Button("确认")
                      .width("45%")
                      .height(50)
                      .backgroundColor("#13EC5B")
                      .fontColor(Color.White)
                      .borderRadius(25)
                      .onClick(() => {
                        this.onTimePickerConfirm(this.selectedHour, this.selectedMinute);
                        this.showTimePicker = false;
                      });
                  }
                  .padding({ left: 24, right: 24, bottom: 24 })
                  .margin({ top: 15, bottom: 20 })
                }
                .width("80%")
                .backgroundColor("#F8FFF8")
                .borderRadius(24)
                .position({ x: '10%', y: '25%' })
                .zIndex(999)
              }

              Button('创建任务')
                .width('50%')
                .margin({ top: 20 })
                .backgroundColor('#13EC5B')
                .shadow({
                  radius: 20,
                  color: 'rgba(0, 0, 0, 0.2)',
                  offsetX: 0,
                  offsetY: 10
                })
                .onClick(() => {
                  this.createTask();
                  console.log('创建任务');
                })
                .zIndex(999)

            }
            .width('100%')
            .layoutWeight(1)
            .backgroundColor('#80f1f5f9')
        }
        .align(Alignment.TopStart)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }.height('100%').width('100%')
    }.hideTitleBar(true)
  }
}