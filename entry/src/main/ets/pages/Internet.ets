import { NavigationManager } from "../common/NavigationManager";

@Entry
@Component
export struct Internet {
  @State params:Record<string,Object>={};
  build() {
    NavDestination(){
      Column(){
        Row() {
          Image($r('app.media.back'))
            .backgroundColor('#E2E8F0')
            .width('40vp')
            .height('40vp')
            .borderRadius(20)
            .padding(9)
            .onClick(()=>{
              NavigationManager.getInstance().pop()
            })
          Text('网关中心').fontSize('25vp').fontWeight(FontWeight.Bold)
          Image($r('app.media.new'))
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceAround)
        .onClick(()=>{
          console.log('刷新页面')
        })

      Column(){

          Column() {
            Column(){
              Row({space:5}) {
                Circle()
                  .width(10)
                  .height(10)
                  .fill('#22C55E')
                Text('在线').fontColor('#22C55E')

              }
              Text('智能中心-X1').fontSize('25vp').fontWeight(FontWeight.Bold)
              Text('运行时间:14d 06h 22m').fontColor('#64748B')
            }
            .width('100%')
            .padding({top:15,left:15})
            .alignItems(HorizontalAlign.Start)

            Row({space:15}){
                this.card('app.media.Wifi','信号','-42dBm')
                this.card('app.media.spelling','延迟','12ms')
            }
          }
          .margin({top:15})
          .width('90%')
          .backgroundColor('#1a22c55e')
        .border({
          color:'#3322c55e',
          width:1
        })
        .borderRadius(20)

        Row(){
          Text('网络布局').fontWeight(FontWeight.Bold).fontSize('18vp')
          Text('3个设备已连接').fontColor('#94A3B8').fontWeight(FontWeight.Bold).fontSize('15vp')
        }
        .padding({left:15,right:15})
        .margin({top:15})
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Column(){

        }

      }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')


        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }.hideTitleBar(true)
  }
  @Builder
  card(img:string,title:string,detail:string){
    Row({space:10}){
      Image($r(img))
        .width('30vp')
      Column(){
        Text(title).fontSize('13vp').fontColor('#64748B').fontWeight(FontWeight.Bold)
        Text(detail).fontSize('18vp').fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({left:7})
    .width('42%')
    .height('60vp')
    .borderRadius(15)
    .margin({ top: 15, bottom: 15 })
    .backgroundColor(Color.White)
  }
}