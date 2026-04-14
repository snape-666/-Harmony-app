import { Font } from "@ohos.arkui.UIContext";
import {NavigationManager} from '../common/NavigationManager'
import {AllHistory} from './AllHistory'
@Entry
@Component
export struct Lrrigate {
  @State progress: number=70;
  @State params:Record<string,Object>={};
  @State isOn: boolean = false;
  build() {
   NavDestination(){
     Column() {
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
         Text('灌溉助手').fontSize('25vp').fontWeight(FontWeight.Bold)
         Text('')
           .width('40vp')
           .height('40vp')
       }.width('100%').justifyContent(FlexAlign.SpaceAround)

       Scroll() {
         Column() {
           Column() {
           Row() {
             Text('智能水阀')
               .fontSize('20vp')
               .fontWeight(FontWeight.Bold)
               .fontColor('#13EC5B')
             Blank()
             Toggle({
               type: ToggleType.Switch,
               isOn: this.isOn
             })
               .selectedColor('#13EC5B')
               .switchPointColor(Color.White)
               .onChange((newState: boolean) => {
                 this.isOn = newState;
                 console.log('开关状态：', newState);
               })
               .width('50vp')
               .height('30vp')
           }.width('100%').padding({ left: 20, right: 20, top: 10 })

           Row({ space: 10 }) {
             Text('2.5L').fontWeight(FontWeight.Bold).fontSize('33vp')
             Row() {
               Image($r('app.media.up')).width('15vp')
               Text('15%对比昨天').fontColor('#22C55E')
             }
           }.width('100%').justifyContent(FlexAlign.Start).padding({ left: 20, top: 10 })

           Text('基于85%的土壤湿度\n以及即将出现的晴朗天气预报').fontSize('13vp').fontColor('#64748B')
             .width('100%').padding(15)
         }
         .margin({top:10})
         .width('95%')
         .height('150vp')
         .backgroundColor(Color.White)
         .borderRadius(20)
         .shadow({
           radius: 100,
           color: '#3313ec5b',
           offsetX: 0,
           offsetY: 0
         })

         Row() {
           Text('实时灌溉').fontSize('20vp').fontWeight(FontWeight.Bold)
           Text('区域A-12').fontColor('#22C55E').fontWeight(FontWeight.Bold).fontSize('15vp')
         }
         .width('100%')
           .justifyContent(FlexAlign.SpaceBetween)
           .padding({left:20,right:20,top:20})

         Column(){
             Row(){
               Text('进展').fontColor('#64748B').fontWeight(FontWeight.Bold)
               Text('1.6L/2.5L').fontWeight(FontWeight.Bold)
             }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(15)

           // 进度条容器
           Stack() {
             // 灰色底
             Row().width('100%').height(10).backgroundColor('#E5E7EB').borderRadius(5)

             // 绿色进度
             Row()
               .width(`${this.progress}%`)
               .height(10)
               .backgroundColor('#22C55E')
               .borderRadius(5)
           }
           .alignContent(Alignment.TopStart)
           .width('90%')

           Text('预计还剩4分钟完成').fontColor('#22C55E').fontSize('12vp')
             .width('100%')
             .padding({left:20,top:15})
         }
         .width('95%')
         .height('100vp')
         .backgroundColor(Color.White)
         .borderRadius(20)
         .shadow({
           radius: 100,
           color: '#3313ec5b',
           offsetX: 0,
           offsetY: 0
         })
           .margin({top:20})

           Row(){
             Text('土壤湿度水平').fontSize('20vp').fontWeight(FontWeight.Bold)
             Text('过去24H').fontColor('#22C55E').fontWeight(FontWeight.Bold).fontSize('13vp')
               .backgroundColor('#3322c55e')
               .borderRadius(15).padding(5)
           }
           .width('100%').justifyContent(FlexAlign.SpaceBetween)
           .padding({top:15,left:15,right:15})

           Column(){
             Image($r('app.media.Lrrigateco2')).width('90%').margin({top:15,bottom:10})
             Row(){
               Text('00:00').fontSize('12vp').fontColor('#94A3B8')
               Text('08:00').fontSize('12vp').fontColor('#94A3B8')
               Text('12:00').fontSize('12vp').fontColor('#94A3B8')
               Text('16:00').fontSize('12vp').fontColor('#94A3B8')
               Text('22:00').fontSize('12vp').fontColor('#94A3B8')
             }
             .width('100%')
             .justifyContent(FlexAlign.SpaceAround)
           }
           .width('95%')
           .height('140vp')
           .backgroundColor(Color.White)
           .borderRadius(20)
           .shadow({
             radius: 100,
             color: '#3313ec5b',
             offsetX: 0,
             offsetY: 0
           })
           .margin({top:20,bottom:20})

           Row(){
             Text('最近历史').fontWeight(FontWeight.Bold).fontSize('20vp')
             Text('查看全部').fontWeight(FontWeight.Bold).fontColor('#22C55E')
               .fontSize('18vp')
               .onClick(()=>{
                 NavigationManager.getInstance().push('AllHistory',{from:Lrrigate})
               })

           }
           .width('100%')
           .justifyContent(FlexAlign.SpaceBetween)
           .padding({left:15,right:15})

           this.cardList('app.media.gwater','自动灌溉','昨天,08:30AM-2.2L','成功')
           this.cardList('app.media.put','手动增压','两天前,04:15PM-0.5L','成功' )





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
      radius: 100,
      color: '#3313ec5b',
      offsetX: 0,
      offsetY: 0
    })
    .padding({left:15,right:15})
    .margin({top:20})

  }


}