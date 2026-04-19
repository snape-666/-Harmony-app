import { NavigationManager } from "../common/NavigationManager";

@Entry
@Component
export struct AllHistory {
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
          Text('灌溉历史').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceAround)


        Scroll(){
          Column(){
            this.cardList('app.media.gwater','自动灌溉','昨天,08:30AM-2.2L','成功')
            this.cardList('app.media.put','手动增压','两天前,04:15PM-0.5L','成功' )
          }
          .align(Alignment.TopStart)
          .height('100%')
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')
        .flexShrink(0)

        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }.hideTitleBar(true)
  }
  @Builder
  cardList(img:string,title:string,time:string,state:string){
    Row(){
      Image($r(img))
        .width('46vp')
        .height('46vp')
        .borderRadius(23)
        .objectFit(ImageFit.Contain)
        .padding(12)
        .backgroundColor('#1a22c55e')
        .margin({right:15})
      Column(){
        Text(title).fontWeight(FontWeight.Bold).fontSize('20vp')
        Text(time).fontColor('#64748B').fontSize('13vp')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text(state).fontColor('#22C55E').fontWeight(FontWeight.Bold).fontSize('13vp')
        .backgroundColor('#1a22c55e').padding(7).borderRadius(12)
    }
    .width('95%')
    .height('70vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius:50,
      color: '#3313ec5b',
      offsetX: 0,
      offsetY: 0
    })
    .padding({left:15,right:15})
    .margin({top:20})

  }
}