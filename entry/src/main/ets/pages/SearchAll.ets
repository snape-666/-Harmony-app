import {NavigationManager} from '../common/NavigationManager'


@Entry
@Component
export struct SearchAll {
  @State params: Record<string, Object> = {};
  @State currentIndex: number = 0
  private tabNames: string[] = ['所有', '严重', '警告', '成功']

  build() {
    NavDestination() {
      Column() {
        Row(){
          Image($r('app.media.back'))
            .width('40vp')
            .height('40vp')
            .borderRadius(20)
            .padding(13)
            .backgroundColor('#80e2e8f0')
            .onClick(()=>{
              NavigationManager.getInstance().pop()
            })
          Text('历史警报')
            .fontWeight(FontWeight.Bold)
            .fontSize('20vp')
          Text('')
            .width('40vp')
            .height('40vp')

        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({left:20,right:20})
        .backgroundColor(Color.White)
        .height('50vp')
        .width('100%')

      Tabs({ index: this.currentIndex }) {
        TabContent() {
          Scroll() {
          Column() {
            Text('今天')
              .fontSize('18vp')
              .fontColor('#64748B')
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .padding(20)

            this.cardItem('严重', '高湿度阈值', 'A区湿度达到85%,自动通风系统启动', '10:45AM')
            this.cardItem('警告', '低水箱水位', '主水库蓄水量为15%,计划晚上10点进行补水', '08:20AM')
            Text('昨天')
              .fontSize('18vp')
              .fontColor('#64748B')
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .padding(20)
            this.cardItem('成功', '灌溉周期结束', '所有12个区域的灌溉工作均已顺利完成,土壤湿度处于最佳状态', '06:00AM')

          }
          .height('100%')
          .justifyContent(FlexAlign.Start)
        }.layoutWeight(1)
        }.tabBar(this.CustomTabBar(0))

        TabContent() {
          Scroll(){
            Column(){
              this.cardItem('严重','高湿度阈值','A区湿度达到85%,自动通风系统启动','10:45AM')
            }
            .margin({top:10})
            .height('100%')
            .justifyContent(FlexAlign.Start)
          }.layoutWeight(1)
        }
        .tabBar(this.CustomTabBar(1))

        TabContent() {
         Scroll(){
           Column(){
             this.cardItem('警告','低水箱水位','主水库蓄水量为15%,计划晚上10点进行补水','08:20AM')
           }
           .margin({top:10})
           .height('100%')
           .justifyContent(FlexAlign.Start)
         }.layoutWeight(1)
        }
        .tabBar(this.CustomTabBar(2))

        TabContent() {
         Scroll(){
           Column(){
             this.cardItem('成功', '灌溉周期结束', '所有12个区域的灌溉工作均已顺利完成,土壤湿度处于最佳状态', '06:00AM')
           }
           .margin({top:10})
           .height('100%')
           .justifyContent(FlexAlign.Start)
         }.layoutWeight(1)
        }
        .tabBar(this.CustomTabBar(3))
      }
      .clip(false)
      .barWidth('90%')
      .barHeight('40vp')
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .animationDuration(0)
      .margin({top:20})
      .barBackgroundColor('##00000000')
      .barMode(BarMode.Fixed)


      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')
    }.hideTitleBar(true)
  }
  @Builder CustomTabBar(index: number) {
    Text(this.tabNames[index])
      .fontSize('20vp')
      .fontColor(this.currentIndex === index ? '#13EC5B' : '#64748B')
      .fontWeight(this.currentIndex === index ? 600 : 400)
      .width('100%')
      .height('30vp')
      .textAlign(TextAlign.Center)
      .border({
          width: {bottom:3},
          color: this.currentIndex === index ? '#13EC5B' : '#E2E8F0'
      })

  }

@Builder
  cardItem(text1:string,text2:string,text3:string,time:string){
    Row() {
      Image(text1 === '严重' ? $r('app.media.redAlarm') : text1 === '警告' ? $r('app.media.orangeAlarm') : $r('app.media.success'))
        .width('50vp')
        .height('50vp')
        .objectFit(ImageFit.Contain)
        .padding(10)
        .backgroundColor(text1 === '严重' ? '#FEE2E2' : text1 === '警告' ? '#FFEDD5' : '#D1FAE5')
        .borderRadius(10)
        .margin({right:15,top:15,bottom:15})
      Column({space:3}){
        Row(){
          Text(text1).fontColor(text1 === '严重' ? '#DC2626' : text1 === '警告' ? '#EA580C' : '#059669').fontWeight(FontWeight.Bold).fontSize('15vp')
          Blank()
          Text(time).fontColor('#94A3B8').fontSize('12vp').fontWeight(FontWeight.Bold)
        }
        .width('75%')
        Text(text2).fontWeight(FontWeight.Bold).fontSize('18vp')
        Text(text3).fontColor('#475569').fontSize('13vp')
          .width('75%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({top:15,bottom:20})


    }
    .padding({left:15})
    .width('95%')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.2)',
      offsetX: 0,
      offsetY: 0
    })
    .margin({bottom:15})
  }
}