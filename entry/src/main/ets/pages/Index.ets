import {Login} from './Login';
import {NavigationManager} from '../common/NavigationManager';
import { Yibiaopan } from './Yibiaopan';
import {Alarm} from './Alarm';
import { Register } from './Register';
import {LostPassword} from './LostPassword'
import {Equipment} from './Equipment'
import {Add} from './Add'
import {Count} from './Count'
import {SearchAll} from './SearchAll'
import {Lrrigate} from './Lrrigate'
import {AllHistory} from './AllHistory'
import {Task} from './Task'
import {NewTask} from './NewTask'
import {Rule} from './Rule'
import {Setting} from './Setting'
import {Internet} from './Internet'






interface swiperItem{
  id:number,
  height:string,
}
@Builder
function  ThreeIcon(img:string,text:string,positionX:string,positionY:string ){
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
  .padding(12)
  .position({x:positionX,y:positionY})
  .shadow({
    radius:10,
    color:'rgba(200,200,200,0.3)',
    offsetY:6
  })
}

@Builder
function WelcomeCard(img:string,){
  Row() {
    Column({space:10}){
      Image($r(img))
        .width('25vp')
      Text()
        .backgroundColor('#E2E8F0')
        .width('120vp')
        .height('8vp')
        .borderRadius(20)

    }
  }
  .backgroundColor(Color.White)
  .width('140vp')
  .height('120vp')
  .borderRadius(19)
  .justifyContent(FlexAlign.Center)
}

@Entry
@Component
export struct Index {
  @State navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    NavigationManager.getInstance().setNavPathStack(this.navPathStack);
  }

  @State currentIndex:number=0;
  private swiperData:swiperItem[]=[
    {id:1,height:'600vp'},
    {id:2,height:'550vp'},
    {id:3,height:'550vp'}

  ];


  build() {
    Navigation(this.navPathStack) {
      Column() {
        Swiper() {
          this.swiperPage1()
          this.swiperPage2()
          this.swiperPage3()
        }
        .width('100%')
        .index(this.currentIndex)
        .indicator(true)
        .autoPlay(false)
        .loop(false)
        .onChange((index: number) => {
          this.currentIndex = index;
        })

        Button() {
          Row({ space: 15 }) {
            Text(this.currentIndex == 2 ? '立即体验' : '下一步')
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
          radius: 20,
          color: 'rgba(20,100,50,0.3)',
          offsetY: 15
        })
        .onClick(() => {
          if (this.currentIndex < 2) {
            this.currentIndex++;
            console.log('跳转到下一页');
          } else {
           NavigationManager.getInstance().push('Login',{from:Index})
            console.log('跳转到登录界面');
          }
        })

        if (this.currentIndex == 1 || this.currentIndex == 2) {
          Text('返回上一页')
            .margin({ top: 30 })
            .fontColor('#64748B')
            .onClick(() => {
              if (this.currentIndex > 0) {
               this.currentIndex--;
                console.log('返回上一页');
              } else {
                console.log('索引错误');
              }

            })
        }

      }
    }

    .navDestination(this.pageMap)
    .hideTitleBar(true)

  }
  @Builder
  swiperPage1() {
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
          .onClick(()=>{
            this.navPathStack.pushPath({name:'Login'});
            console.log('跳到登录页');
          })

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
    .height(this.swiperData[0].height)
  }
  @Builder
  swiperPage2(){
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
          .onClick(()=>{
            this.navPathStack.pushPath({name:'Login'})
            console.log('跳到登录页');
          })

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
      if (this.currentIndex===1){
        ThreeIcon('app.media.temper','24℃','220vp','100vp')
        ThreeIcon('app.media.sun','850lx','250vp','200vp')
        ThreeIcon('app.media.blue water','65%','40vp','270vp')
      }

      Text('精准监测')
        .fontSize('30vp')
        .fontWeight(FontWeight.Bold)
        .padding({top:2})
        .textAlign(TextAlign.Center)
      Text('实时掌握作物状况,全天候守护您的农场')
        .fontSize('18vp')
        .padding(20)
    }
    .height(this.swiperData[1].height)
  }
  @Builder
  swiperPage3(){
    Column({space:20}){
      Text('智慧农业')
        .fontWeight(FontWeight.Bold)
        .fontSize(30)

      Column(){
        Text()
          .backgroundColor(Color.White)
          .width('180vp')
          .height('40vp')
          .borderRadius(20)
          .margin({top:15,bottom:15,left:15})
          .alignSelf(ItemAlign.Start)

        Column({space:15}){
          Grid(){
            GridItem() {
              WelcomeCard('app.media.water')
            }
            GridItem(){
              WelcomeCard('app.media.slighter')
            }

          }
          .columnsGap('14vp')

          Row({space:10}){
            Text()
              .backgroundColor('rgba(255, 255, 255, 0.5)')
              .width('120vp')
              .height('15vp')
              .borderRadius(20)
            Text()
              .width('30vp')
              .height('30vp')
              .borderRadius('15vp')
              .backgroundColor(Color.White)
          }
          .backgroundColor('#13EC5B')
          .borderRadius(20)
          .width('300vp')
          .height('100vp')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(20)
          .shadow({
            radius: 10,
            color: 'rgba(20,200,50,0.3)',
            offsetY: 20
          })

        }

        Column({space:20}){
          Text('智能控制')
            .fontSize('36vp')
            .fontWeight(FontWeight.Bold)
          Text('随时随地实现农场自动化\n  一键管理灌溉与照明')
            .fontSize('18vp')
            .textAlign(TextAlign.Center)

        }
        .padding({top:30})



      }
      .width('330vp')
      .height('333vp')
      .backgroundColor('#E8F9EF')
      .borderRadius(20)
      .shadow({
        radius: 8,
        color: 'rgba(19, 236, 91, 0.3)',
        offsetY: 4
      })
      Image($r('app.media.robot'))
        .width('70vp')
        .padding(10)
        .backgroundColor('#13EC5B')
        .borderRadius('35vp')
        .position({x:280,y:50})
        .shadow({
          radius:20,
          color:'rgba(20,100,50,0.3)',
          offsetY:15
        })
    }
    .height(this.swiperData[2].height)
  }
  @Builder
  pageMap(name:string,param:ESObject){
    if (name==='Login'){
      Login({params:param})
    }
    else if (name==='Yibiaopan') {
      Yibiaopan({params:param})
    }
    else if (name==='Alarm') {
      Alarm({params:param})
    }
    else if (name==='LostPassword') {
      LostPassword({params:param})
    }
    else if (name==='Register') {
      Register({params:param})
    }
    else if (name==='Equipment') {
      Equipment({params:param})
    }
    else if (name==='Add') {
      Add({params:param})
    }
    else if (name==='Count') {
      Count({params:param})
    }
    else if (name==='SearchAll') {
      SearchAll({params:param})
    }
    else if (name==='Lrrigate') {
      Lrrigate({params:param})
    }
    else if (name==='AllHistory') {
      AllHistory({params:param})
    }
    else if (name==='Task') {
      Task({params:param})
    }
    else if (name==='NewTask') {
      NewTask({params:param})
    }
    else if (name==='Rule') {
      Rule({params:param})
    }
    else if (name==='Setting') {
      Setting({params:param})
    }
    else if (name==='Internet') {
      Internet({params:param})
    }


  }
}


