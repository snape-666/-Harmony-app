import { JSON } from "@kit.ArkTS";
import {NavigationManager} from '../common/NavigationManager'

@Entry
@Component
export struct Register {
  @State params:Record<string,Object>={};

  aboutToAppear(): void {
    console.log('传入参数',JSON.stringify(this.params));
  }
  build() {
 NavDestination() {
  Stack() {
    Image($r('app.media.loginBac'))
      .borderRadius('30')

    Column() {
      Column( ) {
       Column({space:3}){
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
              Text('欢迎注册智慧农场!')
                .fontSize('25vp')
                .fontWeight(FontWeight.Bold)
            }
            .margin({ top:20, left: 20 })
            .alignItems(HorizontalAlign.Start)

            Column({ space: 5 }) {
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
              Text('确认密码')
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
              Text('邮箱')
                .padding({ top: 10 })
              TextInput({ placeholder: '输入您的邮箱地址' })

                .height('50')
                .borderRadius(16)
                .backgroundColor(Color.White)
                .border({
                  color: '#E5E7EB',
                  width: 1
                })
              Text('验证码')
                .padding({ top: 10 })
              TextInput({ placeholder: '请输入验证码' })
                .height('50')
                .borderRadius(16)
                .backgroundColor(Color.White)
                .border({
                  color: '#E5E7EB',
                  width: 1
                })

            }
            .margin({ left: 20, right: 20, top: 10 })
            .alignItems(HorizontalAlign.Start)
          }.alignItems(HorizontalAlign.Start)


          Button() {
            Row({ space: 15 }) {
              Text('注册')
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Black)
                .fontSize('20vp')
              Image($r('app.media.arrow'))
                .width(17)

            }
          }
          .margin({ top: 20})
          .backgroundColor('#13EC5B')
          .width('300vp')
          .height('50vp')
          .shadow({
            radius: 20,
            color: 'rgba(20,100,50,0.3)',
            offsetY: 15
          })
          .onClick(() => {
            console.log('跳转到登录页面');
            NavigationManager.getInstance().pop()
          })

        }
        .width('340vp')
        .height('590vp')
        .margin({ top:10})
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


      }
      .height('100%')

    }
    .margin({bottom:30})
  }

}
.hideTitleBar(true)

  }
}