import { window } from "@kit.ArkUI";
import {NavigationManager} from '../common/NavigationManager'
import {Yibiaopan}from './Yibiaopan'
import {LostPassword} from './LostPassword'



@Entry
@Component
 export struct Login {
 // private pageStack?: NavPathStack;
  @State params: Record<string, Object> = {};
  @State username: string = '';
  @State password: string = '';



  aboutToAppear() {
    console.log('详情页接收到的参数:', JSON.stringify(this.params));
  }

  build() {
NavDestination(){
Stack() {
  Image($r('app.media.loginBac'))
    .borderRadius('30')

  Column() {
    Column({ space: 12 }) {
      Image($r('app.media.gleaf'))
        .width('64vp')
        .borderRadius(15)
        .padding(10)
        .backgroundColor('rgba(19, 236, 91, 0.3)')
      Image($r('app.media.login1'))
        .width('26vp')
        .backgroundColor(Color.White)
        .borderRadius(10)
        .padding(2)
        .position({ x: '100vp', y: '50vp' })
      Text('AgriConnect')
        .fontSize('30vp')
        .fontWeight(FontWeight.Bold)
      Text('智慧农业系统')
        .fontSize('15')
        .fontColor('#64748B')
    }

    Column({ space: 5 }) {
      Column() {
        Column({ space: 3 }) {
          Text('欢迎回来')
            .fontSize('25vp')
            .fontWeight(FontWeight.Bold)
          Text('请登录以管理您的农场')
            .fontColor('#64748B')
        }
        .margin({ top: 40, left: 20 })
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('用户名')
          TextInput({ placeholder: '请输入用户名' })
            .height('50')
            .borderRadius(16)
            .backgroundColor(Color.White)
            .border({
              color: '#E5E7EB',
              width: 1
            })

          Text('密码')
            .padding({ top: 10 })
          TextInput({ placeholder: '请输入至少6位数密码' })
            .type(InputType.Password)
            .height('50')
            .borderRadius(16)
            .backgroundColor(Color.White)
            .border({
              color: '#E5E7EB',
              width: 1
            })
        }
        .margin({ left: 20, right: 20, top: 20 })
        .alignItems(HorizontalAlign.Start)
      }.alignItems(HorizontalAlign.Start)

      Row() {
        Text('忘记密码?')
          .fontColor('#13EC5B')
          .fontSize('16vp')
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            console.log('跳转到忘记密码页');
            NavigationManager.getInstance().push('LostPassword',{from:Login})
          })
      }
      .justifyContent(FlexAlign.End).width('100%').margin({ right: 22, top: 5 })

      Button() {
        Row({ space: 15 }) {
          Text('登录')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .fontSize('20vp')
          Image($r('app.media.arrow'))
            .width(17)

        }
      }
      .margin({ top: 15 })
      .backgroundColor('#13EC5B')
      .width('300vp')
      .height('60vp')
      .shadow({
        radius: 20,
        color: 'rgba(20,100,50,0.3)',
        offsetY: 15
      })
      .onClick(() => {
        NavigationManager.getInstance().push('Yibiaopan',{from:Login })
        console.log('跳转到首页');
      })

    }
    .width('340vp')
    .height('430vp')
    .margin({ top: 25 })
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

    Row() {
      Text('第一次使用AgriConnect?')
        .fontSize('15vp')
        .fontColor('#64748B')
      Text('注册账户')
        .fontColor('#13EC5B')
        .onClick(() => {
          console.log('跳转到注册页');
          NavigationManager.getInstance().push('Register',{from:Login})
        })

    }
    .width('80%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .margin({ top: 45 })

  }
  .margin({ top: 20 })

}

  } .hideTitleBar(true)


   }
  }

