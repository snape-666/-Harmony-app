import {NavigationManager} from '../common/NavigationManager'
import {Yibiaopan}  from './Yibiaopan'
import {Equipment}  from './Equipment'
import {Count} from './Count'
import {Rule} from './Rule'
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { CircleShape } from '@kit.ArkUI';



interface SettingItem {
  icon: ResourceStr;       // 图标资源
  title: string;           // 主标题
  status: string;          // 右侧状态文字
  iconBgColor: ResourceColor; // 图标背景色
  page:string
}
interface SettingItem2{
  icon: ResourceStr;       // 图标资源
  title: string;           // 主标题
  status: string;          // 右侧状态文字
  iconBgColor: ResourceColor; // 图标背景色
  page:string
}


@Entry
@Component
export struct Setting {
  @State params: Record<string, Object> = {};
  @State selectedIndex: number = 3;
  @State userName: string = "USER"
  @State userId: string = "notme123456"
  @State avatarUrl: ResourceStr = $r('app.media.user') // 替换为你的头像资源
  @State selectedImageUri: string = '';
  @State settingList: SettingItem[] = [
    {
      icon: $r('app.media.settingicon'),
      title: '网关配置',
      status: '已连接',
      iconBgColor: '#1a22c55e',
      page:'WiFi'
    },
    {
      icon: $r('app.media.auto'),
      title: '自动化规则',
      status: '3个运行中',
      iconBgColor: '#1a22c55e',
      page:'Rule'
    },
    {
      icon: $r('app.media.alarm'),
      title: '通知设置',
      status: '',
      iconBgColor: '#1a22c55e',
      page:'Notification'
    }
  ];
  @State settingList2: SettingItem2[] = [
    {
      icon: $r('app.media.Internet'),
      title: '语言',
      status: '中文(CN)',
      iconBgColor: '#F1F5F9',
      page:'Internet'
    },
    {
      icon: $r('app.media.about'),
      title: '关于',
      status: 'v2.4.0',
      iconBgColor: '#F1F5F9',
      page:'About'
    }
  ];
  build() {
    NavDestination() {
      Row() {
        Text('设 置').fontWeight(FontWeight.Bold).fontSize('20vp')
      }.padding({ bottom: 10 })

      Column({ space: 15 }) {
        Column() {
          Row() {
            // 左侧头像区域
            Stack() {
              // 头像圆形背景
              Circle()
                .width(70)
                .height(70)
                .stroke('#22C55E')
                .strokeWidth(3)
                .fill(Color.White)

              // 头像图片
              Image(this.avatarUrl)
                .width(60)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(30)
                .onClick(() => {

                })


              Image($r("app.media.edit"))
                .width(30)
                .height(30)
                .padding({ left: 7, right: 5 })
                .borderRadius(15)
                .objectFit(ImageFit.Contain)
                .fillColor(Color.White)
                .backgroundColor('#00C853')
                .position({ x: 50, y: 50 })
                .border({
                  width: 3,
                  color: Color.White
                })
            }
            .margin({ right: 32 })

            // 中间用户信息区域
            Column({ space: 5 }) {
              // 用户名
              Text(this.userName)
                .fontSize('25vp')
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)

              // 用户ID
              Text(`ID:${this.userId}`)
                .fontSize('20vp')
                .fontColor("#666666")
                .alignSelf(ItemAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
            .flexGrow(1)

            // 右上角太阳图标（主题切换）
            Image($r("app.media.sun")) // 太阳图标，可替换为SVG
              .width(40)
              .height(40)
              .fillColor("#00C853")
              .margin({ bottom: 40 })
          }
          .padding(15)
          .width("100%")
          .alignItems(VerticalAlign.Center)
        }
        .margin({ top: 15 })
        .backgroundColor(Color.White)
        .width('90%')
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 6
        })

        Text('配置管理').fontColor('#94A3B8').fontWeight(FontWeight.Bold).width('100%')
          .padding({left:15})

        Column(){
          ForEach(this.settingList, (item: SettingItem, index: number) => {
              // 单列表项
              Row({ space:15 }) {
                // 左侧图标+背景
                Image(item.icon)
                  .width(45)
                  .height(45)
                  .objectFit(ImageFit.Contain)
                  .fillColor('#13EC5B')
                  .backgroundColor(item.iconBgColor)
                  .borderRadius(12)
                  .padding(7)

                // 中间标题
                Text(item.title)
                  .fontSize('20vp')
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1E293B')
                  .layoutWeight(1)

                // 右侧状态文字
                if (item.status.length > 0) {
                  Text(item.status)
                    .fontSize(16)
                    .fontColor('#94A3B8')
                    .margin({ right: 0 })
                }

                // 右侧箭头
                Image($r('app.media.next'))
                  .width(16)
                  .height(16)
                  .fillColor('#CBD5E1')
              }
              .padding({left:8,right:8,top:5,bottom:5})
              .width('95%')
              .height('65vp')
              .onClick(() => {
                // 点击事件，可根据index跳转对应页面
                console.log(`点击了第${index + 1}项：${item.title}`);
                NavigationManager.getInstance().push(item.page,{from:Setting})
              })

              // 最后一项不加分隔线
              if (index < this.settingList.length - 1) {
                Divider()
                  .width('95%')
                  .color('#94A3B8')
                  .height(1)
                  .margin(0)
              }

            },
            (item: SettingItem) => item.title)
        }
        .backgroundColor(Color.White)
        .width('92%')
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 6
        })

        Text('通用').fontColor('#94A3B8').fontWeight(FontWeight.Bold).width('100%').padding({left:15})

        Column(){
          ForEach(this.settingList2, (item: SettingItem2, index: number) => {
            // 单列表项
            Row({ space:15 }) {
              // 左侧图标+背景
              Image(item.icon)
                .width(45)
                .height(45)
                .objectFit(ImageFit.Contain)
                .fillColor('#475569')
                .backgroundColor(item.iconBgColor)
                .borderRadius(12)
                .padding(10)

              // 中间标题
              Text(item.title)
                .fontSize('20vp')
                .fontWeight(FontWeight.Medium)
                .fontColor('#1E293B')
                .layoutWeight(1)

              // 右侧状态文字
              if (item.status.length > 0) {
                Text(item.status)
                  .fontSize(16)
                  .fontColor('#94A3B8')

              }

              // 右侧箭头
              Image($r('app.media.next'))
                .width(16)
                .height(16)
                .fillColor('#CBD5E1')
            }
            .padding({left:8,right:8,top:5,bottom:5})
            .width('95%')
            .height('65vp')
            .onClick(() => {
              // 点击事件，可根据index跳转对应页面
              console.log(`点击了第${index + 1}项：${item.title}`);
              NavigationManager.getInstance().push(item.page,{from:Setting})
            })

            // 最后一项不加分隔线
            if (index < this.settingList.length - 1) {
              Divider()
                .width('95%')
                .color('#94A3B8')
                .height(1)
                .margin(0)
            }

          },
            (item: SettingItem) => item.title)
        }
        .backgroundColor(Color.White)
        .width('92%')
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 6
        })

        Row({space:10}){
          Image($r('app.media.allBack'))
            .width('20vp')
          Text('退出登录').fontColor('#EF4444')
        }
        .width('80%')
        .justifyContent(FlexAlign.Center)
        .height('50vp')
        .borderRadius(20)
        .border({
          color:'#FEE2E2',
          width:2
        })
        .onClick(()=>{
          NavigationManager.getInstance().popToName('Login')
        })


      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#80f1f5f9')


      Tabs({ barPosition: BarPosition.End, index: this.selectedIndex }) {
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
        if (index === 0) {
          NavigationManager.getInstance().push('Yibiaopan', { from: Equipment })
        }
        if (index === 1) {
          NavigationManager.getInstance().push('Equipment', { from: Equipment })
        }
        if (index === 2) {
          NavigationManager.getInstance().push('Count', { from: Equipment })
        }

      })
      .animationDuration(0)

    }.hideTitleBar(true)
  }

  @Builder
  tabBarBuilder(itemIndex: number, title: string, img: ResourceStr) {
    Column({ space: 2 }) {
      Image(img)
        .width('30vp')
        .padding(2)
        .fillColor(this.selectedIndex === itemIndex ? '#13EC5B' : '#94A3B8')
      Text(title)
        .fontSize('12vp')
        .fontColor(this.selectedIndex === itemIndex ? '#13EC5B' : '#94A3B8')
    }
    .width('100%')
    .height('50vp')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }





}