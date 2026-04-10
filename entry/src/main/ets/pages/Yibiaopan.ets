import { sendableColorSpaceManager } from '@kit.ArkGraphics2D'
import { StartOptions } from '@kit.AbilityKit'
import {Equipment} from './Equipment'
import {NavigationManager} from '../common/NavigationManager'
import { JSON } from '@kit.ArkTS'
import {AIidentify} from './AIidentify'
import { http } from '@kit.NetworkKit'

// 定义传感器数据类型
interface SensorData {
  air_humidity: string;      // 空气湿度
  soil_humidity: string;     // 土壤湿度
  soil_temperature: string;  // 土壤温度
  air_temperature: string;   // 空气温度
  light: string;             // 光照强度
  co2: string;               // 二氧化碳浓度
  date: string;              // 日期
  time: string;              // 时间
}
// 定义API响应类型
interface ApiResponse {
  success: boolean;
  count: number;
  data: Record<string, SensorData>;
}
// 定义卡片数据类型
interface CardData {
  icon: ResourceStr;
  title: string;
  value: string;
  unit: string;
  subTitle?: string;
  subValue?: string;
}
@Entry
@Component
export struct Yibiaopan {

  @State selectedIndex:number=0
  @State params: Record<string, Object> = {};
  // 传感器数据状态
  @State airTemperature: string = '--';
  @State airHumidity: string = '--';
  @State co2: string = '--';
  @State light: string = '--';
  @State soilTemperature: string = '--';
  @State soilHumidity: string = '--';
  @State systemStatus: string = '最佳';
  @State statusMessage: string = '所有自动灌溉与气候系统均以最高效率运行';
  @State color: string='#13EC5B'
  @State lastUpdateTime: string = '';
  @State isLoading: boolean = true;
  @State loginUsername: string = '';
  // 历史数据列表（用于显示最新数据）
  @State sensorDataList: SensorData[] = [];

  private readonly API_URL: string = 'https://guet-farm.netlify.app/.netlify/functions/getData';
  private refreshTimer?: number;
  @State cardList: CardData[] = [
    { icon: $r('app.media.o2temper'), title: '空气温度', value: '--', unit: ' ', subTitle: '空气湿度', subValue: '--' },
    { icon: $r('app.media.co2'), title: 'co2浓度', value: '--', unit: ' ', subTitle: ' ', subValue: '' },
    { icon: $r('app.media.sun'), title: '光照强度', value: '--', unit: '      ', subTitle: '      ', subValue: '      ' },
    { icon: $r('app.media.earthtemper'), title: '土壤温度', value: '--', unit: ' ', subTitle: '土壤湿度', subValue: '--' }
  ];
  private static hasShownToast: boolean = false;
  @State isFirstLoad: boolean = !Yibiaopan.hasShownToast;


  aboutToAppear(): void {
    console.log('Yibiaopan接收参数',JSON.stringify(this.params));
    this.loginUsername = this.params['username'] as string || '';
    console.log('Yibiaopan接收到的用户名:', this.loginUsername);
    this.fetchSensorData();
    // 每30秒自动刷新数据
    this.startAutoRefresh();
  }
  aboutToDisappear(): void {
    // 清除定时器
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
  }

  // 显示Toast提示
  showToast(message: string) {
    try {
      this.getUIContext().getPromptAction().openToast({
        message: message,
        duration: 2000,
        bottom: 100
      });
    } catch (error) {
      console.log('提示:', message);
    }
  }

  // 开始自动刷新
  startAutoRefresh() {
    this.refreshTimer = setInterval(() => {
      this.fetchSensorData();
    }, 30000); // 30秒刷新一次
  }

  // 获取传感器数据
  async fetchSensorData() {
    try {
      console.log('开始获取传感器数据...');
      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(this.API_URL, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 30000,
        readTimeout: 30000
      });

      console.log('响应状态码:', response.responseCode);
      console.log('原始响应:', response.result);

      if (response.responseCode === 200) {
        // 第一次解析：获取外层数据
        const outerResult = JSON.parse(response.result as string) as ApiResponse;
        console.log('解析后的数据:', JSON.stringify(outerResult));

        if (outerResult.success && outerResult.data) {
          // 获取所有数据点
          const dataPoints = Object.values(outerResult.data);
          this.sensorDataList = dataPoints;

          // 获取最新的一条数据（最后一条）
          const latestData = dataPoints[dataPoints.length - 1];

          if (latestData) {
            this.updateUIWithData(latestData);
            this.lastUpdateTime = `${latestData.date} ${latestData.time}`;
            if (!Yibiaopan.hasShownToast) {
              this.showToast('数据更新成功');
              Yibiaopan.hasShownToast = true;
            }
          } else {
            console.warn('没有找到传感器数据');
            this.showToast('暂无传感器数据');
          }
        } else {
          console.warn('接口返回失败:', outerResult);
          this.showToast('获取数据失败');
        }
      } else {
        console.error('请求失败，状态码:', response.responseCode);
        this.showToast(`请求失败，状态码：${response.responseCode}`);
      }

      httpRequest.destroy();
    } catch (error) {
      console.error('获取传感器数据失败:', error);
      this.showToast('网络连接失败，请检查网络');
    } finally {
      this.isLoading = false;
    }
  }

  // 更新UI显示
  updateUIWithData(data: SensorData) {
    // 空气温度
    this.airTemperature = data.air_temperature || '--';
    // 空气湿度
    this.airHumidity = data.air_humidity || '--';
    // 二氧化碳浓度
    this.co2 = data.co2 || '--';
    // 光照强度
    this.light = data.light || '--';
    // 土壤温度
    this.soilTemperature = data.soil_temperature || '--';
    // 土壤湿度
    this.soilHumidity = data.soil_humidity || '--';
    // 更新卡片列表数据
    this.cardList = [
      { icon: $r('app.media.o2temper'), title: '空气温度', value: this.airTemperature, unit: ' ', subTitle: '空气湿度', subValue: this.airHumidity },
      { icon: $r('app.media.co2'), title: 'co2浓度', value:this.co2, unit: ' ', subTitle: ' ', subValue: '' },
      { icon: $r('app.media.sun'), title: '光照强度', value:this.light, unit: '      ', subTitle: '      ', subValue: '      ' },
      { icon: $r('app.media.earthtemper'), title: '土壤温度', value:this.soilTemperature, unit: ' ', subTitle: '土壤湿度', subValue: this.soilHumidity }
    ];
    // 根据数据判断系统状态
    this.updateSystemStatus(data);

    console.log('UI更新完成:', {
      airTemperature: this.airTemperature,
      airHumidity: this.airHumidity,
      co2: this.co2,
      light: this.light,
      soilTemperature: this.soilTemperature,
      soilHumidity: this.soilHumidity
    });
  }

  // 根据传感器数据判断系统状态
  updateSystemStatus(data: SensorData) {
    // 解析数值用于判断
    const temp = parseFloat(data.air_temperature) || 0;
    const hum = parseFloat(data.air_humidity) || 0;
    const soilTemp = parseFloat(data.soil_temperature) || 0;
    const soilHum = parseFloat(data.soil_humidity) || 0;

    // 判断系统状态
    let isOptimal = true;
    let issues: string[] = [];

    if (temp < 15 || temp > 35) {
      isOptimal = false;
      issues.push('温度异常');
    }
    if (hum < 40 || hum > 80) {
      isOptimal = false;
      issues.push('湿度异常');
    }
    if (soilTemp < 10 || soilTemp > 40) {
      isOptimal = false;
      issues.push('土壤温度异常');
    }
    if (soilHum < 30 || soilHum > 70) {
      isOptimal = false;
      issues.push('土壤湿度异常');
    }

    if (isOptimal) {
      this.systemStatus = '最佳';
      this.statusMessage = '所有自动灌溉与气候系统均以最高效率运行';
      this.color='#13EC5B'
    } else {
      this.systemStatus = '需关注';
      this.statusMessage = `检测到${issues.join('、')}，建议检查系统设置`;
      this.color='#EBA64C'
    }
  }

  // 手动刷新数据
  manualRefresh() {
    this.isLoading = true;
    this.fetchSensorData();
  }
  build() {
    NavDestination() {
        Column() {
          Row() {
            Text('')
              .width('30vp')
              .height('30vp')

            Text('智慧农业中心')
              .fontSize('20vp')
              .fontWeight(FontWeight.Bold)
            Stack() {
              Circle()
                .width('32vp')
                .height('32vp')
                .fill('rgba(19, 236, 91, 0.2)')
              Image($r('app.media.galarm'))
                .width('30vp')
                .padding(5)
                .borderRadius(15)
            }
            .onClick(() => {
              console.log('跳转到阈值警报');
              NavigationManager.getInstance().push('Alarm', { from: Yibiaopan })
            })

          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)

          Scroll() {
            Column() {

              Column({ space: 10 }) {
                Row() {
                  Text()
                    .width('12vp')
                    .height('12vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(6)
                  Text('运行状态')
                    .fontColor('#13EC5B')
                    .fontSize('15vp')
                }
                .alignSelf(ItemAlign.Start)
                .margin({ top: 15, left: 20 })
                .width('110vp')
                .height('25vp')
                .borderRadius(20)
                .backgroundColor('#3313ec5b')
                .justifyContent(FlexAlign.SpaceEvenly)

                Row() {
                  Text() {
                    Span('系统状态:').fontWeight(FontWeight.Bold).fontSize('25vp')
                    Span(` ${this.systemStatus}`).fontWeight(FontWeight.Bold).fontSize('25vp').fontColor('#13EC5B')
                  }
                }
                .alignSelf(ItemAlign.Start)
                .padding({ left: 20, top: 10 })

                Text(this.statusMessage)
                  .fontColor('#64748B')
                  .margin('5vp')

                Row() {
                  Stack({ alignContent: Alignment.Center }) {
                    Circle()
                      .width('40vp')
                      .height('40vp')
                      .fill('#E2E8F0')
                    Image($r('app.media.blackwater'))
                      .align(Alignment.Start)
                      .objectFit(ImageFit.Contain)
                      .width('40vp')
                      .borderRadius(20)
                      .padding(10)
                      .height('40vp')
                      .border({
                        width: 2,
                        color: Color.White
                      })

                    Image($r('app.media.blacksun'))
                      .backgroundColor('#E2E8F0')
                      .objectFit(ImageFit.Contain)
                      .width('40vp')
                      .borderRadius(20)
                      .padding(10)
                      .offset({ x: 30, y: 0 })
                      .border({
                        width: 2,
                        color: Color.White
                      })
                      .borderStyle(BorderStyle.Solid)
                    Image($r('app.media.blackwind'))
                      .backgroundColor('#E2E8F0')
                      .objectFit(ImageFit.Contain)
                      .width('40vp')
                      .borderRadius(20)
                      .padding(10)
                      .offset({ x: 60, y: 0 })
                      .border({
                        width: 2,
                        color: Color.White
                      })
                      .height('40vp')

                  }
                  .width('100%')
                  .align(Alignment.Start).margin({ left: 20 })

                }

              }
              .width('345vp')
              .height('200vp')
              .margin({ top: 10 })
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


              Grid() {
                ForEach(this.cardList, (item: CardData,index:number) => {
                  GridItem() {
                    Column() {
                      Row({ space: 20 }) {
                        Column({ space: 10 }) {
                          Image(item.icon)
                            .width('20vp')
                          Text(item.title)
                            .fontSize('10vp')
                            .fontColor('#64748B')
                          Text(item.value)
                            .fontSize('20vp')
                            .fontWeight(FontWeight.Bold)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ top: 15 })

                        Column({ space: 10 }) {
                          Text(item.unit)
                            .width('20vp')
                            .height('20vp')
                          Text(item.subTitle)
                            .fontSize('10vp')
                            .fontColor('#64748B')
                          Text(item.subValue)
                            .fontSize('20vp')
                            .fontWeight(FontWeight.Bold)
                        }
                        .margin({ top: 15 })
                      }

                    }
                    .width('160vp')
                    .height('100vp')
                    .borderRadius(24)
                    .backgroundColor(Color.White)
                    .shadow({
                      radius: 10,
                      color: 'rgba(110, 230, 155, 0.3)',
                      offsetX: -15,
                      offsetY: 6
                    })
                    .border({
                      color: '#E8E8E8',
                      width: 0.5
                    })
                  }

                })
              }
              .margin({ top: 20, bottom: 20 })
              .rowsGap(10)
              .columnsGap(10)

              Column({ space: 6 }) {
                Column() {
                  Text('位置概览')
                    .width('100%')
                    .padding({ left: 20, top: 20 })
                  Image($r('app.media.location'))
                    .width('345vp')
                    .padding(15)
                }
                .width('345vp')
                .borderRadius(20)
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


                Column({ space: 6 }) {
                  Text('实时监控')
                    .width('100%')
                    .padding({ left: 20, top: 20 })
                    .textAlign(TextAlign.Start)
                  Text()
                    .width('300vp')
                    .height('120vp')
                    .backgroundColor('#80f1f5f9')
                    .padding({ top: 10 })
                    .borderRadius(16)
                    .border({
                      color: '#E2E8F0',
                      width: 1
                    })
                }
                .width('345vp')
                .height('180vp')
                .borderRadius(20)
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
                .margin({
                  top:20
                })
              }

              Column() {
                Text('AI功能')
                  .fontSize('20')
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .padding({ left: 20, top: 20 })
                Row({ space: 10 }) {
                  Image($r('app.media.AI'))
                    .padding(5)
                    .margin({ left: 20 })
                    .width('35vp')
                    .backgroundColor('#3313ec5b')
                    .borderRadius(8)
                    .shadow({
                      radius: 10,
                      color: 'rgba(0, 0, 0, 0.2)',
                      offsetX: 3,
                      offsetY: 3
                    })
                  Column({ space: 2 }) {
                    Text('AI识别').fontWeight(FontWeight.Bold)
                    Text('AI自动识别植物种类').fontColor('#64748B').fontSize('10vp')
                  }
                  .margin({ left: 5 })
                  .alignItems(HorizontalAlign.Start)

                  Blank()
                    .layoutWeight(1)
                  Row() {
                    Text('去体验')
                      .fontSize('12vp')
                      .fontColor('#13EC5B')
                      .fontWeight(FontWeight.Bold)
                    Image($r('app.media.arrow'))
                      .fillColor('#13EC5B')
                      .width('10vp')
                  }
                  .margin({ right: 20 })
                  .padding(7)
                  .backgroundColor('#3313ec5b')
                  .borderRadius(20)
                  .border({
                    color: '#13EC5B',
                    width: 1
                  })
                  .onClick(() => {
                    console.log('跳转到AI识别页面');
                    NavigationManager.getInstance().push('AIidentify',{form:Yibiaopan})
                  })

                }
                .width('345vp')
                .height('60vp')
                .borderRadius(20)
                .backgroundColor(Color.White)
                .margin({ bottom: 10,top:15 })
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

            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#80f1f5f9')
          .flexShrink(0) //防止被压缩
          .scrollBar(BarState.Off)


          Tabs({ barPosition: BarPosition.End,index:this.selectedIndex }) {
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
            if (index === 1) {
              NavigationManager.getInstance().push('Equipment', { from: Yibiaopan })
            }
            if (index === 2) {
              NavigationManager.getInstance().push('Count', { from: Yibiaopan })
            }
            if (index === 3) {
              NavigationManager.getInstance().push('Setting', { from: Yibiaopan,username:this.loginUsername })
            }
          })
          .animationDuration(0)
        }

    }.hideTitleBar(true)
  }
  @Builder
  tabBarBuilder(itemIndex:number,title:string,img:ResourceStr,){
    Column({space:2}){
      Image(img)
        .width('30vp')
        .padding(2)
        .fillColor(this.selectedIndex===itemIndex?'#13EC5B':'#94A3B8')
      Text(title)
        .fontSize('12vp')
        .fontColor(this.selectedIndex===itemIndex?'#13EC5B':'#94A3B8')
    }
    .width('100%')
    .height('50vp')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)


}
}


