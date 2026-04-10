import { NavigationManager } from "../common/NavigationManager";
import { Font } from "@ohos.arkui.UIContext";
import {Rule} from './Rule'

@Entry
@Component
export struct Add {
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
            .padding(12)
            .onClick(() => {
              NavigationManager.getInstance().pop()
            })
          Text('添加设备').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

      Scroll(){
        Column(){
          Row(){
            Text('连接设备').fontColor('#64748B').fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({top:20})
          .padding({left:20})

          this.card()
          this.card()

          Text('智能控制').fontColor('#64748B').fontWeight(FontWeight.Bold).width('100%')
            .margin({top:20,bottom:20}).padding({left:20})

          Column(){

            Row({space:10}){
              Image($r('app.media.shandian'))
                .width(20).fillColor(Color.White)
              Text('自动化规则').fontColor(Color.White).fontWeight(FontWeight.Bold)
                .fontSize('20vp')
            }.margin({top:20}).width('100%').padding({left:15})

            Text('为农作物创建"如果这样,那么这样"的逻辑规则,自动节省水资源和能源')
              .width('90%').fontColor('#b3ffffff')
              .margin({top:10})

           Row({space:7}){
              Text('开始').fontColor(Color.White).fontSize('18vp').fontWeight(FontWeight.Bold)
              Image($r('app.media.add')).fillColor(Color.White).width(13)
            }
            .backgroundColor('#137FEC')
            .padding({left:15,right:15,top:8,bottom:8})
            .borderRadius(20)
            .margin({top:15})
            .onClick(()=>{

            })




          }
          .width('90%')
          .height('160vp')
          .backgroundColor('#2563EB')
          .shadow({
            radius: 10,
            color: '#4d2563eb',
            offsetX: 0,
            offsetY: 10
          })
          .borderRadius(20)
          .margin({top:15})













        }.width('100%').height('100%').justifyContent(FlexAlign.Start)
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
  @Builder
  card(){
    Column(){
      Row(){
        Image($r('app.media.settingicon'))
          .width('45vp')
          .height('45vp')
          .objectFit(ImageFit.Contain)
          .backgroundColor('#2613ec5b')
          .padding(6)
          .borderRadius(10)
        Column({space:5}){
          Text('信号强度').fontSize('13vp').fontColor('#595C5C')
          Image($r('app.media.xinhao'))
            .width(13)
        }


      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(15)

      Column(){
        Text('新设备-1').fontWeight(FontWeight.Bold)
        Text('型号:New Device-T1').fontColor('#595C5C')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({left:20})
      Row(){
        Text('连接新设备').fontColor('#13EC5B').fontWeight(FontWeight.Bold)
        Image($r('app.media.nextArrow'))
          .width(30)
      }
      .width('35%')
      .justifyContent(FlexAlign.Center)

    }
    .width('90%')
    .height('150vp')
    .backgroundColor(Color.White)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })
    .borderRadius(20)
    .margin({top:15})
  }
}