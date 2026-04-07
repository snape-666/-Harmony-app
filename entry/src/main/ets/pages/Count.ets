import { NavigationManager } from "../common/NavigationManager";
import {SearchAll} from './SearchAll'
import {Yibiaopan} from './Yibiaopan'
import {Task} from './Task'
@Entry
@Component
export struct Count {
  @State params:Record<string,Object>={};
  @State selectedIndex: number = 2;
  @State currentIndex:number=0;


  build() {
    NavDestination(){
      Row(){
        Text('').width('40vp').height('40vp')
        Text('农场设备统计').fontWeight(FontWeight.Bold).fontSize('25vp')
        Stack(){
          Circle()
            .width('40vp')
            .height('40vp')
            .fill('#3313ec5b')
          Image($r('app.media.date'))
            .width('40vp')
            .height('40vp')
            .padding(10)
            .onClick(()=>{
              NavigationManager.getInstance().push('Task',{from:Count})
            })
        }

      }.width('100%').justifyContent(FlexAlign.SpaceAround)

      Column() {
          Row() {
            this.item('日', 0)
            this.item('周', 1)
          }
          .width('70%')
          .height('40vp')
          .backgroundColor('#bfe5e6eb')
          .borderRadius(15)
          .margin({top:10})
          .justifyContent(FlexAlign.SpaceAround)
          .alignSelf(ItemAlign.Center)
        Scroll(){
            Column() {
              if (this.currentIndex === 0) {
                this.dayPage()
              } else {
                this.weekPage()
              }
            }
            .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')
        .flexShrink(0)
        .scrollBar(BarState.Off)

      }.layoutWeight(1)






      Tabs({ barPosition: BarPosition.End,index:this.selectedIndex }) {
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
          NavigationManager.getInstance().push('Yibiaopan', { from: Count})
        }
        if (index === 1) {
          NavigationManager.getInstance().push('Equipment', { from: Count })
        }
        if (index === 3) {
          NavigationManager.getInstance().push('Setting', { from: Count })
        }
      })
      .animationDuration(0)
    }.hideTitleBar(true)
  }
  @Builder
  item(title: string, index: number) {
    Text(title)
      .fontSize(16)
      .fontColor(this.currentIndex === index ? '#13EC5B' : '#666')
      .fontWeight(FontWeight.Medium)
      // 选中 = 白色圆角背景
      .backgroundColor(this.currentIndex === index ? '#fff' : 'transparent')
      .borderRadius(12)
      .padding({ left:50, right: 50, top: 7, bottom: 7 })
      // 点击切换
      .onClick(() => {
        this.currentIndex = index;
      })
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
  cardList(img:string,backColor:string,title:string,area:string,date:string,time:string){
    Row(){
      Image($r(img)).width('40vp').height('40vp')
        .backgroundColor(backColor)
        .padding(6)
        .objectFit(ImageFit.Contain)
        .borderRadius(10)
        .margin({left:15,right:15})
      Column(){
        Text(title).fontWeight(FontWeight.Bold).fontSize('15vp')
        Text(area).fontSize('10vp').fontColor('#64748B')
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Column(){
        Text(date).fontWeight(FontWeight.Bold).fontSize('13vp')
        Text(time).fontSize('10vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
      }.margin({right:15})

    }
    .width('95%')
    .height('60vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({bottom:10})
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })

  }
@Builder
  dayPage(){
    Column() {
      Row() {
        Column() {
          Row({ space: 5 }) {
            Image($r('app.media.redtemper'))
              .width('12vp')
            Text('温度趋势').fontColor('#64748B').fontSize('15vp').fontWeight(FontWeight.Bold)
          }

          Text('24℃').fontWeight(FontWeight.Bold).fontSize('20vp')
        }
        .alignItems(HorizontalAlign.Start)

        Text('+2.4%')
          .fontSize('10vp')
          .fontColor('#16A34A')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#DCFCE7')
          .borderRadius(25)
          .padding(6)

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: 20, right: 20 })

      Column() {
        Image($r('app.media.line1')).width('98%')
          .padding({ left: 20 })

        Row() {
          Text('00:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('06:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('12:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('18:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('23:59').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)

      }.width('100%')
      .height('100vp')

    }
    .padding(0)
    .margin({ top: 20 })
    .width('95%')
    .height('180vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })

    Row({ space: 10 }) {
      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.water')).width('10vp')
            Text('湿度趋势').fontSize('12vp').fontColor('#64748B')
          }

          Text('62%').fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        Image($r('app.media.line2'))
          .width('100%')
          .height('50vp')
          .padding({ left: 10 })

        Text('-1.2%趋势')
          .fontColor('#EF4444')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.co2')).width('10vp')
            Text('co2水平').fontSize('12vp').fontColor('#64748B')
          }

          Text('412ppm').fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        Image($r('app.media.line3'))
          .width('80%')
          .height('50vp')

        Text('最佳')
          .fontColor('#22C55E')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

    }
    .width('96%')
    .height('120vp')
    .margin({ top: 10, bottom: 10 })

    Row() {
      Text('历史预警').fontSize('15vp').fontWeight(FontWeight.Bold)
      Text('查看全部').fontColor('#137FEC').fontSize('15vp').fontWeight(FontWeight.Bold)
        .onClick(() => {
          NavigationManager.getInstance().push('SearchAll', { from: Count })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(10)

    this.cardList('app.media.redAlarm', '#FEE2E2', '高温预警', '温室B区-4号扇区', '今天', '14:20')
    this.cardList('app.media.shandian', '#FFEDD5', '传感器连接信号低', '主田节点#08', '今天', '09:45')
    this.cardList('app.media.success', '#1a22c55e', 'co2校准成功', '系统自动任务', '昨天', '22:00')


  }

  @Builder
  weekPage(){
    Column() {
      Row() {
        Column() {
          Row({ space: 5 }) {
            Image($r('app.media.redtemper'))
              .width('12vp')
            Text('温度趋势').fontColor('#64748B').fontSize('15vp').fontWeight(FontWeight.Bold)
          }

          Text('24℃').fontWeight(FontWeight.Bold).fontSize('20vp')
        }
        .alignItems(HorizontalAlign.Start)

        Text('+2.4%')
          .fontSize('10vp')
          .fontColor('#16A34A')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#DCFCE7')
          .borderRadius(25)
          .padding(6)

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: 20, right: 20 })

      Column() {
        Image($r('app.media.line1')).width('98%')
          .padding({ left: 20 })

        Row() {
          Text('周一').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('周二').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('周三').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('周四').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('周五').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('周六').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('周日').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)

      }.width('100%')
      .height('100vp')

    }
    .padding(0)
    .margin({ top: 20 })
    .width('95%')
    .height('180vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })

    Row({ space: 10 }) {
      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.water')).width('10vp')
            Text('湿度趋势').fontSize('12vp').fontColor('#64748B')
          }

          Text('62%').fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        Image($r('app.media.line2'))
          .width('100%')
          .height('50vp')
          .padding({ left: 10 })

        Text('-1.2%趋势')
          .fontColor('#EF4444')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.co2')).width('10vp')
            Text('co2水平').fontSize('12vp').fontColor('#64748B')
          }

          Text('412ppm').fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        Image($r('app.media.line3'))
          .width('80%')
          .height('50vp')

        Text('最佳')
          .fontColor('#22C55E')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

    }
    .width('96%')
    .height('120vp')
    .margin({ top: 10, bottom: 10 })

    Row() {
      Text('历史预警').fontSize('15vp').fontWeight(FontWeight.Bold)
      Text('查看全部').fontColor('#137FEC').fontSize('15vp').fontWeight(FontWeight.Bold)
        .onClick(() => {
          NavigationManager.getInstance().push('SearchAll', { from: Count })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(10)

    this.cardList('app.media.redAlarm', '#FEE2E2', '高温预警', '温室B区-4号扇区', '今天', '14:20')
    this.cardList('app.media.shandian', '#FFEDD5', '传感器连接信号低', '主田节点#08', '今天', '09:45')
    this.cardList('app.media.success', '#1a22c55e', 'co2校准成功', '系统自动任务', '昨天', '22:00')


  }

}


