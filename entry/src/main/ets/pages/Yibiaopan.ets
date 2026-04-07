import { sendableColorSpaceManager } from '@kit.ArkGraphics2D'
import { StartOptions } from '@kit.AbilityKit'
import {Equipment} from './Equipment'
import {NavigationManager} from '../common/NavigationManager'
import { JSON } from '@kit.ArkTS'

@Entry
@Component
export struct Yibiaopan {
  @State selectedIndex:number=0
  @State params: Record<string, Object> = {};
  cardList=[
    [$r('app.media.o2temper'),'空气温度','24℃','','空气湿度','70%'],
    [$r('app.media.co2'),'二氧化碳浓度','65%'],
    [$r('app.media.sun'),'光照强度','12k lux'],
    [$r('app.media.earthtemper'),'土壤温度','30%','','土壤湿度','40%']
  ]

  aboutToAppear(): void {
    console.log('Yibiaopan接收参数',JSON.stringify(this.params));
  }

  build() {
    NavDestination() {
        Column() {
          Row() {
            Text('')
              .width('30vp')
              .height('30vp')

            Text('智慧农业中心')
              .fontSize('20vp')
              .fontWeight(FontWeight.Bold)
            Stack() {
              Circle()
                .width('32vp')
                .height('32vp')
                .fill('rgba(19, 236, 91, 0.2)')
              Image($r('app.media.galarm'))
                .width('30vp')
                .padding(5)
                .borderRadius(15)
            }
            .onClick(() => {
              console.log('跳转到阈值警报');
              NavigationManager.getInstance().push('Alarm', { from: Yibiaopan })
            })

          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)

          Scroll() {
            Column() {

              Column({ space: 10 }) {
                Row() {
                  Text()
                    .width('12vp')
                    .height('12vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(6)
                  Text('运行状态')
                    .fontColor('#13EC5B')
                    .fontSize('15vp')
                }
                .alignSelf(ItemAlign.Start)
                .margin({ top: 15, left: 20 })
                .width('110vp')
                .height('25vp')
                .borderRadius(20)
                .backgroundColor('#3313ec5b')
                .justifyContent(FlexAlign.SpaceEvenly)

                Row() {
                  Text() {
                    Span('系统状态:').fontWeight(FontWeight.Bold).fontSize('25vp')
                    Span(' 最佳').fontWeight(FontWeight.Bold).fontSize('25vp').fontColor('#13EC5B')
                  }
                }
                .alignSelf(ItemAlign.Start)
                .padding({ left: 20, top: 10 })

                Text('所有自动灌溉与气候系统均以最高效率运行')
                  .fontColor('#64748B')
                  .margin('5vp')

                Row() {
                  Stack({ alignContent: Alignment.Center }) {
                    Circle()
                      .width('40vp')
                      .height('40vp')
                      .fill('#E2E8F0')
                    Image($r('app.media.blackwater'))
                      .align(Alignment.Start)
                      .objectFit(ImageFit.Contain)
                      .width('40vp')
                      .borderRadius(20)
                      .padding(10)
                      .height('40vp')
                      .border({
                        width: 2,
                        color: Color.White
                      })

                    Image($r('app.media.blacksun'))
                      .backgroundColor('#E2E8F0')
                      .objectFit(ImageFit.Contain)
                      .width('40vp')
                      .borderRadius(20)
                      .padding(10)
                      .offset({ x: 30, y: 0 })
                      .border({
                        width: 2,
                        color: Color.White
                      })
                      .borderStyle(BorderStyle.Solid)
                    Image($r('app.media.blackwind'))
                      .backgroundColor('#E2E8F0')
                      .objectFit(ImageFit.Contain)
                      .width('40vp')
                      .borderRadius(20)
                      .padding(10)
                      .offset({ x: 60, y: 0 })
                      .border({
                        width: 2,
                        color: Color.White
                      })
                      .height('40vp')

                  }
                  .width('100%')
                  .align(Alignment.Start).margin({ left: 20 })

                }

              }
              .width('345vp')
              .height('200vp')
              .margin({ top: 10 })
              .borderRadius(24)
              .backgroundColor(Color.White)
              .shadow({
                radius: 10,
                color: 'rgba(0, 0, 0, 0.2)',
                offsetX: 6,
                offsetY: 6
              })
              .border({
                color: '#E8E8E8',
                width: 0.5
              })


              Grid() {
                ForEach(this.cardList, (item: (Resource | string)[]) => {
                  GridItem() {
                    Column() {
                      Row({ space: 20 }) {
                        Column({ space: 10 }) {
                          Image(item[0])
                            .width('20vp')
                          Text(item[1])
                            .fontSize('10vp')
                            .fontColor('#64748B')
                          Text(item[2])
                            .fontSize('20vp')
                            .fontWeight(FontWeight.Bold)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ top: 15 })

                        Column({ space: 10 }) {
                          Text(item[3])
                            .width('20vp')
                            .height('20vp')
                          Text(item[4])
                            .fontSize('10vp')
                            .fontColor('#64748B')
                          Text(item[5])
                            .fontSize('20vp')
                            .fontWeight(FontWeight.Bold)
                        }
                        .margin({ top: 15 })
                      }

                    }
                    .width('160vp')
                    .height('100vp')
                    .borderRadius(24)
                    .backgroundColor(Color.White)
                    .shadow({
                      radius: 10,
                      color: 'rgba(110, 230, 155, 0.3)',
                      offsetX: -15,
                      offsetY: 6
                    })
                    .border({
                      color: '#E8E8E8',
                      width: 0.5
                    })
                  }

                })
              }
              .margin({ top: 20, bottom: 20 })
              .rowsGap(10)
              .columnsGap(10)

              Column({ space: 6 }) {
                Column() {
                  Text('位置概览')
                    .width('100%')
                    .padding({ left: 20, top: 20 })
                  Image($r('app.media.location'))
                    .width('345vp')
                    .padding(15)
                }
                .width('345vp')
                .borderRadius(20)
                .backgroundColor(Color.White)
                .shadow({
                  radius: 10,
                  color: 'rgba(0, 0, 0, 0.2)',
                  offsetX: 6,
                  offsetY: 6
                })
                .border({
                  color: '#E8E8E8',
                  width: 0.5
                })


                Column({ space: 6 }) {
                  Text('实时监控')
                    .width('100%')
                    .padding({ left: 20, top: 20 })
                    .textAlign(TextAlign.Start)
                  Text()
                    .width('300vp')
                    .height('120vp')
                    .backgroundColor('#80f1f5f9')
                    .padding({ top: 10 })
                    .borderRadius(16)
                    .border({
                      color: '#E2E8F0',
                      width: 1
                    })
                }
                .width('345vp')
                .height('180vp')
                .borderRadius(20)
                .backgroundColor(Color.White)
                .shadow({
                  radius: 10,
                  color: 'rgba(0, 0, 0, 0.2)',
                  offsetX: 6,
                  offsetY: 6
                })
                .border({
                  color: '#E8E8E8',
                  width: 0.5
                })

              }

              Column() {
                Text('AI功能')
                  .fontSize('20')
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .padding({ left: 20, top: 20 })
                Row({ space: 10 }) {
                  Image($r('app.media.AI'))
                    .padding(5)
                    .margin({ left: 20 })
                    .width('35vp')
                    .backgroundColor('#3313ec5b')
                    .borderRadius(8)
                    .shadow({
                      radius: 10,
                      color: 'rgba(0, 0, 0, 0.2)',
                      offsetX: 3,
                      offsetY: 3
                    })
                  Column({ space: 2 }) {
                    Text('AI识别').fontWeight(FontWeight.Bold)
                    Text('AI自动识别植物种类').fontColor('#64748B').fontSize('10vp')
                  }
                  .margin({ left: 5 })
                  .alignItems(HorizontalAlign.Start)

                  Blank()
                    .layoutWeight(1)
                  Row() {
                    Text('去体验')
                      .fontSize('12vp')
                      .fontColor('#13EC5B')
                      .fontWeight(FontWeight.Bold)
                    Image($r('app.media.arrow'))
                      .fillColor('#13EC5B')
                      .width('10vp')
                  }
                  .margin({ right: 20 })
                  .padding(7)
                  .backgroundColor('#3313ec5b')
                  .borderRadius(20)
                  .border({
                    color: '#13EC5B',
                    width: 1
                  })
                  .onClick(() => {
                    console.log('跳转到AI识别页面');
                    NavigationManager.getInstance().push('AIidentify')
                  })

                }
                .width('345vp')
                .height('60vp')
                .borderRadius(20)
                .backgroundColor(Color.White)
                .margin({ bottom: 10 })
                .shadow({
                  radius: 10,
                  color: 'rgba(0, 0, 0, 0.2)',
                  offsetX: 6,
                  offsetY: 6
                })
                .border({
                  color: '#E8E8E8',
                  width: 0.5
                })

              }

            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#80f1f5f9')
          .flexShrink(0) //防止被压缩
          .scrollBar(BarState.Off)


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
            if (index === 1) {
              NavigationManager.getInstance().push('Equipment', { from: Yibiaopan })
            }
            if (index === 2) {
              NavigationManager.getInstance().push('Count', { from: Yibiaopan })
            }
            if (index === 3) {
              NavigationManager.getInstance().push('Setting', { from: Yibiaopan })
            }
          })
          .animationDuration(0)
        }

    }.hideTitleBar(true)
  }
  @Builder
  tabBarBuilder(itemIndex:number,title:string,img:ResourceStr,){
    Column({space:2}){
      Image(img)
        .width('30vp')
        .padding(2)
        .fillColor(this.selectedIndex===itemIndex?'#13EC5B':'#94A3B8')
      Text(title)
        .fontSize('12vp')
        .fontColor(this.selectedIndex===itemIndex?'#13EC5B':'#94A3B8')
    }
    .width('100%')
    .height('50vp')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)


}
}


