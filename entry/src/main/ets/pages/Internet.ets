import { NavigationManager } from "../common/NavigationManager";

interface position{
  x: number;
  y: number;
}

interface DeviceNode {
  id: string;
  name: string;
  icon: ResourceStr;
  iconColor: ResourceColor;
  isOnline: boolean;
  // 设备相对中心的位置百分比 (0-100)
  position: position;
}


@Entry
@Component
export struct Internet {
  @State params:Record<string,Object>={};
  // 2. 设备数据源，可动态增删
  @State deviceList: DeviceNode[] = [
    {
      id: "gateway",
      name: "网关",
      icon: $r('app.media.gateway'),
      iconColor: "#13EC5B",
      isOnline: true,
      position: { x: 60, y: 50 } // 中心位置
    },
    {
      id: "soil-s1",
      name: "Soil-s1",
      icon: $r('app.media.plant'),
      iconColor: "#22C55E",
      isOnline: true,
      position: { x:25, y: 15}
    },
    {
      id: "env-04",
      name: "Env-04",
      icon: $r('app.media.temper'),
      iconColor: "#F59E0B",
      isOnline: true,
      position: { x: 20, y: 70 }
    },
    {
      id: "valve-a2",
      name: "Valve-A2",
      icon: $r('app.media.water'),
      iconColor: "#3B82F6",
      isOnline: true,
      position: { x: 85, y:18}
    },
    {
      id: "drone-x",
      name: "Drone-X",
      icon: $r('app.media.drone'),
      iconColor: "#94A3B8",
      isOnline: false,
      position: { x:85, y: 70}
    }
  ];

  // 3. 计算中心网关位置
  get centerPos(): position {
    return this.deviceList.find(d => d.id === "gateway")?.position || { x: 50, y: 50 };
  }
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
        .margin({top:20})
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Column(){
          // 白色圆角卡片容器

            // 5. 再画所有设备节点（上层）
            ForEach(
              this.deviceList,
              (device: DeviceNode) => {
                Stack(){
                  Circle()
                  .width(device.id === "gateway" ? 60 : 40)
                  .height(device.id === "gateway" ? 60 : 40)
                  .fill(Color.White)



                Image(device.icon)
                  .width(device.id === "gateway" ?60: 30)
                  .height(device.id === "gateway" ? 60 : 30)
                  .objectFit(ImageFit.Contain)
                  .fillColor(device.id === "gateway" ? Color.White : device.iconColor)
                  .padding(device.id === "gateway" ?15: 3)
                  .backgroundColor(device.id === "gateway" ? "#13EC5B" : Color.Transparent)
                  .borderRadius(device.id === "gateway" ?30: 0)
                  .border({
                    color:device.id === "gateway" ? "#13EC5B" : Color.Transparent
                  })
                }
                .position({
                  x: `${device.position.x}%`,
                  y: `${device.position.y}%`
                })
                .translate({
                  x: device.id === "gateway" ? -60 : -20,
                  y: device.id === "gateway" ? -20 : -10
                }) // 居中偏移

                // 设备名称
                Text(device.name)
                  .fontSize(device.id === "gateway" ? 0 : 15) // 网关不显示名称
                  .fontWeight(FontWeight.Medium)
                  .fontColor(device.isOnline ? "#1E293B" : "#94A3B8")
                  .position({
                    x: `${device.position.x}%`,
                    y: `${device.position.y + 12}%`
                  })
                  .translate({ x: -30}) // 文字居中


              },
              (d: DeviceNode) => d.id
            )

        }
        .margin({ top: 20 })
        .width('90%')
        .height('200vp')
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 8
        })

        Text('连接稳定性(24H)').fontColor('#64748B').fontSize('20vp').fontWeight(FontWeight.Bold)
          .width('100%').padding({left:15,top:15})

        Column({space:20}){
            Image($r('app.media.WifiPic')).width('90%')
          Row(){
            Text('00:00AM').fontColor('#94A3B8').fontSize('13vp')
            Text('08:00AM').fontColor('#94A3B8').fontSize('13vp')
            Text('14:00AM').fontColor('#94A3B8').fontSize('13vp')
            Text('20:00AM').fontColor('#94A3B8').fontSize('13vp')
          }
          .width('100%').justifyContent(FlexAlign.SpaceAround)
        }
        .margin({top:20})

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