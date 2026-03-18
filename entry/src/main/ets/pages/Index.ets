interface swiperItem{
  id:number,
  height:string,
}

@Entry
@Component

struct Index {
  @Builder
  ThreeIcon(img:string,text:string,positionX:string,positionY:string ){
    Row({space:'5vp'}){
      Image($r(img))
        .width('18vp')
        .backgroundColor(Color.Transparent)
        .objectFit(ImageFit.Contain)
      Text(text)
        .fontWeight(FontWeight.Bold)
        .fontSize('16vp')
        .fontColor(Color.Black)
    }
    .backgroundColor('rgba(255,255,255,0.5)')
    .border({
      width:1,
      color: 'rgba(150,150,150,0.3)',
      radius:'20vp'
    })
    .padding('12vp')
    .position({x:positionX,y:positionY})
    .shadow({
      radius:10,
      color:'rgba(200,200,200,0.3)',
      offsetY:6
    })
  }
  @State currentIndex:number=0;
  private swiperData:swiperItem[]=[
    {id:1,height:'600vp'},
    {id:2,height:'550vp'}
  ];
  build() {
   Column() {
     Swiper() {
       Column({ space: 20 }) {

         Row() {
           Text(' ')
             .fontSize(20)
             .padding(20)
             .width('80vp')

           Text('智慧农业')
             .fontWeight(FontWeight.Bolder)
             .fontSize(20)


           Text('跳过')
             .fontColor('#13EC5B')
             .fontSize(20)
             .fontWeight(FontWeight.Bolder)
             .padding(20)

         }
         .justifyContent(FlexAlign.SpaceBetween)
         .width('100%')
         .height(72)


         Image($r('app.media.FirstBac'))
           .width('290vp')
           .alignSelf(ItemAlign.Center)
           .borderRadius(25)
           .clip(true)
           .shadow({
             radius: 15,
             color: 'rgba(0, 0, 0, 0.3)',
             offsetY: 10

           })


         Text() {
           Span('欢迎来到\n').fontSize(36).fontWeight(FontWeight.Bold)
           Span('智慧农业').fontColor('#13EC5B').fontSize(36).fontWeight(FontWeight.Bold)
         }
         .padding({ top: 50 })

         Text() {
           Span('体验自然与科技的融合\n').fontSize(18)
           Span('通过手机精准管理您的农场').fontSize(18)
         }
         .textAlign(TextAlign.Center)
       }

       Column({space:20}){
         Row() {
           Text(' ')
             .fontSize(20)
             .padding(20)
             .width('80vp')

           Text('智慧农业')
             .fontWeight(FontWeight.Bolder)
             .fontSize(20)


           Text('跳过')
             .fontColor('#13EC5B')
             .fontSize(20)
             .fontWeight(FontWeight.Bolder)
             .padding(20)

         }
         .justifyContent(FlexAlign.SpaceBetween)
         .width('100%')
         .height(72)

  Image($r('app.media.swipe2'))
    .width('250vp')
    .alignSelf(ItemAlign.Center)
    .borderRadius(25)
    .clip(true)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.3)',
      offsetY: 10
    })
         if (this.currentIndex=1){
           this.ThreeIcon('app.media.temper','24℃','220vp','100vp')
           this.ThreeIcon('app.media.sun','850lx','250vp','200vp')
           this.ThreeIcon('app.media.bluewater','65%','40vp','270vp')
         }

         Text('精准监测')
           .fontSize('30vp')
           .fontWeight(FontWeight.Bold)
           .padding({top:2})
         .textAlign(TextAlign.Center)
         Text('实时掌握作物状况,全天候守护您的农场')

       }

       Column({space:20}){
         Text('智慧农业')
           .fontWeight(FontWeight.Bold)
           .fontSize(30)

         Column(){

         }
         .width('300vp')
         .height('350vp')
         .backgroundColor('#13EC5B')
       }
     }
     .width('100%')
     .height('550vp')

     .indicator(true)

       Button(){
         Row({space:15}) {
           Text('下一步')
             .fontWeight(FontWeight.Bold)
             .fontColor(Color.Black)
             .fontSize('20vp')
            Image($r('app.media.arrow'))
            .width(17)

         }
       }
       .backgroundColor('#13EC5B')
       .width('300vp')
       .height('60vp')
       .shadow({
         radius:20,
         color:'rgba(20,100,50,0.3)',
         offsetY:15
       })
if (this.currentIndex=1){
     Text('返回上一页')
       .margin({top:30})
       .fontColor('#64748B')


}



     }


  }
}


