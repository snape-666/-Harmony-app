import sendableColorSpaceManager from '@ohos.graphics.sendableColorSpaceManager';
import { JSON } from '@kit.ArkTS';
import { NavigationManager } from '../common/NavigationManager'
import { preferences } from '@kit.ArkData';
import { notificationManager } from '@kit.NotificationKit';
import { http } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { vibrator } from '@kit.SensorServiceKit';
import { AlarmManager } from '../common/AlarmManager';

// 阈值配置类（使用class而不是interface）
export class ThresholdConfig {
  tempMin: number = 18;
  tempMax: number = 32;
  humiMin: number = 40;
  humiMax: number = 80;
  co2Min: number = 300;
  co2Max: number = 1200;
  lightMin: number = 5000;
  lightMax: number = 25000;
  isChecked: boolean = false;

  constructor() {
    // 默认值已在属性中初始化
  }
}
// 传感器数据类型
interface SensorData {
  air_humidity: string;
  soil_humidity: string;
  soil_temperature: string;
  air_temperature: string;
  light: string;
  co2: string;
  date: string;
  time: string;
}
// API响应类型
interface ApiResponse {
  success: boolean;
  count: number;
  data: Record<string, SensorData>;
}

// 报警记录类型（用于防重复）
interface AlarmRecord {
  temp: boolean;
  humi: boolean;
  co2: boolean;
  light: boolean;
}

interface config {
  tempMin: number;
  tempMax: number;
  humiMin: number;
  humiMax: number;
  co2Min: number;
  co2Max: number;
  lightMin: number;
  lightMax: number;
  isChecked: boolean;
}

interface AlarmColor {
  text: string;
  color: string;
}

@Entry
@Component
export struct Alarm {
  @State username: string = '';
  @State params: Record<string, Object> = {};
  @State isChecked: boolean = false;

  // 当前实时数据
  @State currentTemp: number = 0;
  @State currentHumi: number = 0;
  @State currentCo2: number = 0;
  @State currentLight: number = 0;

  // 报警状态（用于UI显示红色）
  @State tempAlarm: boolean = false;
  @State humiAlarm: boolean = false;
  @State co2Alarm: boolean = false;
  @State lightAlarm: boolean = false;

  // 防重复报警记录（已发送过的报警不再重复发送）
  private lastAlarmState: AlarmRecord = {
    temp: false,
    humi: false,
    co2: false,
    light: false
  };
  // 温度
  @State tempMin: number = 18;
  @State tempMax: number = 32;
  readonly tempLimitMin: number = 10;
  readonly tempLimitMax: number = 40;

  // 湿度
  @State humiMin: number = 40;
  @State humiMax: number = 80;
  readonly humiLimitMin: number = 0;
  readonly humiLimitMax: number = 100;

  // CO2
  @State co2Min: number = 300;
  @State co2Max: number = 1200;
  readonly co2LimitMin: number = 0;
  readonly co2LimitMax: number = 2000;

  // 光照
  @State lightMin: number = 5000;
  @State lightMax: number = 25000;
  readonly lightLimitMin: number = 0;
  readonly lightLimitMax: number = 30000;

  // 添加所有 TextInput 的控制器
  private tempMinController: TextInputController = new TextInputController();
  private tempMaxController: TextInputController = new TextInputController();
  private humiMinController: TextInputController = new TextInputController();
  private humiMaxController: TextInputController = new TextInputController();
  private co2MinController: TextInputController = new TextInputController();
  private co2MaxController: TextInputController = new TextInputController();
  private lightMinController: TextInputController = new TextInputController();
  private lightMaxController: TextInputController = new TextInputController();
  private dataPreferences?: preferences.Preferences;
  private readonly THRESHOLD_KEY: string = 'threshold_config';
  private readonly API_URL: string = 'https://guet-farm.netlify.app/.netlify/functions/getData';
  private refreshTimer?: number;
  aboutToAppear(): void {
    console.log('接收的参数', JSON.stringify(this.params));
    this.username = this.params['username'] as string || '';
    console.log('Alarm接收到的用户名:', this.username);

    this.initPreferences();
    this.loadThresholdConfig();
    this.fetchSensorData();
    this.startAutoRefresh();
    // 请求通知权限
    this.requestNotificationPermission();

    // 初始化 AlarmManager（传入用户名）
    if (this.username) {
      const context = this.getUIContext().getHostContext();
      if (context) {
        AlarmManager.getInstance().init(context,this.username);
      }
    }
  }

  aboutToDisappear(): void {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
  }

  // 获取上下文
  getContext(): Context | undefined {
    const uiContext = this.getUIContext();
    if (uiContext) {
      return uiContext.getHostContext();
    }
    return undefined;
  }

  // 显示Toast
  showToast(message: string) {
    try {
      const uiContext = this.getUIContext();
      if (uiContext) {
        uiContext.getPromptAction().openToast({
          message: message,
          duration: 2000,
          bottom: 100
        });
      } else {
        console.log('Toast提示:', message);
      }
    } catch (error) {
      console.error('Toast显示失败:', error);
      console.log('Toast提示:', message);
    }
  }

  // 请求通知权限
  async requestNotificationPermission() {
    try {
      // 获取UIAbilityContext
      const context = this.getContext() as common.UIAbilityContext;

      // 检查通知是否已开启
      const isEnabled = await notificationManager.isNotificationEnabled();

      if (!isEnabled) {
        // 请求开启通知（需要传入context参数）
        await notificationManager.requestEnableNotification(context);
        console.log('通知权限申请成功');
      } else {
        console.log('通知权限已开启');
      }
    } catch (error) {
      console.error('获取通知权限失败:', error);
    }
  }

  // 发送系统通知（带震动和声音）
  async sendNotification(title: string, content: string) {
    if (!this.isChecked) {
      console.log('推送通知开关已关闭，不发送通知');
      return;
    }


   try {

     // 模拟器上用弹窗，真机用通知
     const isSimulator = true; // 模拟器调试时设为 true，真机发布时改为 false

     if (isSimulator) {
       // 弹窗方式
       AlertDialog.show({
         title: title,
         message: content,
         confirm: {
           value: '知道了',
           action: () => {}
         }
       });
       console.log('弹窗显示成功:', title);
     } else {
       // 通知方式
       const notificationRequest: notificationManager.NotificationRequest = {
         id: Date.now(),
         content: {
           contentType: 0,
           normal: {
             title: title,
             text: content
           }
         },
         deliveryTime: Date.now(),
         showDeliveryTime: true
       };
       await notificationManager.publish(notificationRequest);
       console.log('通知发送成功:', title);
     }

      // 播放默认通知音（系统会自动播放，不需要额外代码）
      // 震动也是系统自动处理，slotType 设置为 CONTENT_INFORMATION 会触发震动

      // 单独触发震动（替代slotType）
      try {
        await vibrator.startVibration({
          type: 'time',
          duration: 2000
        }, {
          id: 0,
          usage: 'alarm'
        });
      } catch (vibError) {
        console.error('震动失败:', vibError);
      }
    } catch (error) {
      console.error('发送通知失败:', error);
    }
  }

  // 初始化本地存储
  async initPreferences() {
    try {
      const context = this.getContext();
      if (context) {
        this.dataPreferences = await preferences.getPreferences(context, 'alarm_prefs');
        console.log('本地存储初始化成功');
      }
    } catch (error) {
      console.error('本地存储初始化失败:', error);
    }
  }

  // 加载阈值配置
  async loadThresholdConfig() {
    try {
      if (!this.dataPreferences) return;
      const configStr = await this.dataPreferences.get(this.THRESHOLD_KEY, '');
      console.log('读取到的配置字符串:', configStr);
      if (configStr && configStr !== '') {
        const arr= JSON.parse(configStr as string);
        if (Array.isArray(arr) && arr.length >= 9) {
          this.tempMin = arr[0];
          this.tempMax = arr[1];
          this.humiMin = arr[2];
          this.humiMax = arr[3];
          this.co2Min = arr[4];
          this.co2Max = arr[5];
          this.lightMin = arr[6];
          this.lightMax = arr[7];
          this.isChecked = arr[8];
          console.log('加载阈值配置成功');
        }
      }
    } catch (error) {
      console.error('加载阈值配置失败:', error);
    }
  }

  // 保存阈值配置
  async saveThresholdConfig() {
    try {
      if (!this.dataPreferences) return;
      const config: config= {
        tempMin: this.tempMin,
        tempMax: this.tempMax,
        humiMin: this.humiMin,
        humiMax: this.humiMax,
        co2Min: this.co2Min,
        co2Max: this.co2Max,
        lightMin: this.lightMin,
        lightMax: this.lightMax,
        isChecked: this.isChecked
      };
      await this.dataPreferences.put(this.THRESHOLD_KEY, JSON.stringify(config));
      await this.dataPreferences.flush();
      console.log('保存阈值配置成功');
    } catch (error) {
      console.error('保存阈值配置失败:', error);
    }
  }

  // 获取传感器数据
  async fetchSensorData() {
    try {
      console.log('开始获取传感器数据...');
      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(this.API_URL, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        connectTimeout: 30000,
        readTimeout: 30000
      });

      if (response.responseCode === 200) {
        console.log('获取数据成功，状态码:', response.responseCode);
        const outerResult = JSON.parse(response.result as string) as ApiResponse;
        console.log('解析结果:', JSON.stringify(outerResult));
        if (outerResult.success && outerResult.data) {
          const dataPoints = Object.values(outerResult.data);
          const latestData = dataPoints[dataPoints.length - 1];
          if (latestData) {
            // 解析数值（去掉单位）
            const newTemp = parseFloat(latestData.air_temperature) || 0;
            const newHumi = parseFloat(latestData.air_humidity) || 0;
            const newCo2 = parseFloat(latestData.co2) || 0;
            const newLight = parseFloat(latestData.light) || 0;
            console.log(`实时数据 - 温度:${newTemp}℃, 湿度:${newHumi}%, CO2:${newCo2}ppm, 光照:${newLight}lx`);
            console.log(`阈值 - 温度:${this.tempMin}~${this.tempMax}℃`);
            // 更新当前值
            this.currentTemp = newTemp;
            this.currentHumi = newHumi;
            this.currentCo2 = newCo2;
            this.currentLight = newLight;

            // 检查报警（传入新旧值对比）
            this.checkAndSendAlarms();
          }
        }
      }
      httpRequest.destroy();
    } catch (error) {
      console.error('获取传感器数据失败:', error);
    }
  }

  // 开始自动刷新（每10秒）
  startAutoRefresh() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
    this.refreshTimer = setInterval(() => {
      console.log('定时刷新传感器数据...');
      this.fetchSensorData();
    }, 10000);
  }

  // 检查并发送报警通知（只在状态变化时发送一次）
  checkAndSendAlarms() {
    // 检查温度
    const isTempAlarm = this.currentTemp < this.tempMin || this.currentTemp > this.tempMax;
    console.log(`温度是否报警: ${isTempAlarm}, 当前报警状态: ${this.tempAlarm}`);
    if (isTempAlarm !== this.tempAlarm) {
      this.tempAlarm = isTempAlarm;
      if (isTempAlarm && this.isChecked && !this.lastAlarmState.temp) {
        // 发送温度报警通知
        let alarmType = this.currentTemp < this.tempMin ? '过低' : '过高';
        this.sendNotification(
          '温度异常报警',
          `当前温度: ${this.currentTemp}℃ (正常范围: ${this.tempMin}~${this.tempMax}℃)\n状态: 温度${alarmType}，请及时检查！`
        );
        this.lastAlarmState.temp = true;
      } else if (!isTempAlarm) {
        this.lastAlarmState.temp = false;
      }
    }

    // 检查湿度
    const isHumiAlarm = this.currentHumi < this.humiMin || this.currentHumi > this.humiMax;
    console.log(`湿度是否报警: ${isHumiAlarm}, 当前报警状态: ${this.humiAlarm}`);
    if (isHumiAlarm !== this.humiAlarm) {
      this.humiAlarm = isHumiAlarm;
      if (isHumiAlarm && this.isChecked && !this.lastAlarmState.humi) {
        let alarmType = this.currentHumi < this.humiMin ? '过低' : '过高';
        this.sendNotification(
          '湿度异常报警',
          `当前湿度: ${this.currentHumi}% (正常范围: ${this.humiMin}~${this.humiMax}%)\n状态: 湿度${alarmType}，请及时检查！`
        );
        this.lastAlarmState.humi = true;
      } else if (!isHumiAlarm) {
        this.lastAlarmState.humi = false;
      }
    }

    // 检查CO2
    const isCo2Alarm = this.currentCo2 < this.co2Min || this.currentCo2 > this.co2Max;
    console.log(`co2是否报警: ${isCo2Alarm}, 当前报警状态: ${this.co2Alarm}`);
    if (isCo2Alarm !== this.co2Alarm) {
      this.co2Alarm = isCo2Alarm;
      if (isCo2Alarm && this.isChecked && !this.lastAlarmState.co2) {
        let alarmType = this.currentCo2 < this.co2Min ? '过低' : '过高';
        this.sendNotification(
          'CO₂浓度异常报警',
          `当前CO₂: ${this.currentCo2}ppm (正常范围: ${this.co2Min}~${this.co2Max}ppm)\n状态: CO₂浓度${alarmType}，请及时检查！`
        );
        this.lastAlarmState.co2 = true;
      } else if (!isCo2Alarm) {
        this.lastAlarmState.co2 = false;
      }
    }

    // 检查光照
    const isLightAlarm = this.currentLight < this.lightMin || this.currentLight > this.lightMax;
    console.log(`光照是否报警: ${isLightAlarm}, 当前报警状态: ${this.lightAlarm}`);
    console.log(`光照检查 - 当前:${this.currentLight}, 阈值:${this.lightMin}~${this.lightMax}, 是否报警:${isLightAlarm}`);
    if (isLightAlarm !== this.lightAlarm) {
      this.lightAlarm = isLightAlarm;
      if (isLightAlarm && this.isChecked && !this.lastAlarmState.light) {
        let alarmType = this.currentLight < this.lightMin ? '过低' : '过高';
        this.sendNotification(
          '光照异常报警',
          `当前光照: ${this.currentLight}lx (正常范围: ${this.lightMin}~${this.lightMax}lx)\n状态: 光照${alarmType}，请及时检查！`
        );
        this.lastAlarmState.light = true;
      } else if (!isLightAlarm) {
        this.lastAlarmState.light = false;
      }
    }
  }

  // 清除所有 TextInput 焦点的统一方法
  clearAllFocus() {
    this.tempMinController.stopEditing();
    this.tempMaxController.stopEditing();
    this.humiMinController.stopEditing();
    this.humiMaxController.stopEditing();
    this.co2MinController.stopEditing();
    this.co2MaxController.stopEditing();
    this.lightMinController.stopEditing();
    this.lightMaxController.stopEditing();
  }

  resetAll() {
    // 温度
    this.tempMin = 18;
    this.tempMax = 32;
    // 湿度
    this.humiMin = 40;
    this.humiMax = 80;
    // CO2
    this.co2Min = 300;
    this.co2Max = 1200;
    // 光照
    this.lightMin = 5000;
    this.lightMax = 25000;
    // 开关
    this.isChecked = false;

    console.log("已重置所有参数");
    // 重置后清除焦点
    this.clearAllFocus();
  }

  async applyChanges() {
    // 验证输入有效性
    if (this.tempMin >= this.tempMax) {
      this.showToast('温度下限必须小于上限');
      return;
    }
    if (this.humiMin >= this.humiMax) {
      this.showToast('湿度下限必须小于上限');
      return;
    }
    if (this.co2Min >= this.co2Max) {
      this.showToast('CO2下限必须小于上限');
      return;
    }
    if (this.lightMin >= this.lightMax) {
      this.showToast('光照下限必须小于上限');
      return;
    }

    // 保存配置
    await this.saveThresholdConfig();
    console.log("温度：" + this.tempMin + "~" + this.tempMax);
    console.log("湿度：" + this.humiMin + "~" + this.humiMax);
    console.log("CO2：" + this.co2Min + "~" + this.co2Max);
    console.log("光照：" + this.lightMin + "~" + this.lightMax);
    console.log("开关：" + this.isChecked);
    // 显示成功提示
    this.showToast('阈值设置已保存');

    // 立即重新检查报警（重置报警状态）
    this.lastAlarmState = { temp: false, humi: false, co2: false, light: false };
    this.checkAndSendAlarms();
    const alarmManager = AlarmManager.getInstance();
    alarmManager.updateConfig([
      this.tempMin, this.tempMax,
      this.humiMin, this.humiMax,
      this.co2Min, this.co2Max,
      this.lightMin, this.lightMax,
      this.isChecked ? 1 : 0
    ]);
    this.showToast('阈值设置已保存');
    // 应用后清除焦点
    this.clearAllFocus();
  }
  // 获取当前实时值的显示文本和颜色
  getCurrentValueDisplay(value: number, unit: string, min: number, max: number): AlarmColor {
    const isAbnormal = value < min || value > max;
    return {
      text: `${value}${unit}`,
      color: isAbnormal ? '#EF4444' : '#13EC5B'
    };
  }
  build() {
    NavDestination() {
      Column() {
        Row() {
          Stack() {
            Circle()
              .width('30vp')
              .height('30vp')
              .fill('#E2E8F0')
            Image($r('app.media.back'))
              .width('12')
              .onClick(() => {
                console.log('返回')
                NavigationManager.getInstance().pop()
              })

          }
          .margin({ left: 16 })

          Text('阈值警报')
            .fontSize('20vp')
            .fontWeight(FontWeight.Bold)
          Text('')
            .width('30vp')
            .height('30vp')
            .margin({ right: 16 })

        }
        .height('50vp')
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.alarm'))
                .width('20vp')
                .margin(20)
              Column({ space: 10 }) {
                Text('推送通知')
                  .fontWeight(FontWeight.Bold)
                Text('数值超出范围时接收警报')
                  .fontSize('12')
                  .fontColor('#475569')
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Toggle({ type: ToggleType.Switch, isOn: this.isChecked })
                .onChange((isOn: boolean) => {
                  this.isChecked = isOn; // 监听开关变化
                  console.log("开关状态：" + isOn);
                })
                .selectedColor('#13EC5B')
                .margin({ right: 20 })

            }
            .height('70vp')
            .width('95%')
            .borderRadius(20)
            .backgroundColor('#0f13ec5b')
            .border({
              color: '#3313ec5b',
              width: 1
            })
            .margin({top:10})

            Row() {
              Text('传感器参数')
                .fontColor('#94A3B8')
                .fontSize('15vp')
                .margin({ left: 16, top: 15 })
            }
            .alignSelf(ItemAlign.Start)

            // 温度传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#FFEDD5')
                    .borderRadius(18)
                  Image($r('app.media.redtemper'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('温度(℃)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text(this.getCurrentValueDisplay(this.currentTemp, '℃', this.tempMin, this.tempMax).text)
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor(this.getCurrentValueDisplay(this.currentTemp, '℃', this.tempMin, this.tempMax).color)
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.tempMax, this.tempLimitMin, this.tempLimitMax) -
                      this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.tempMax, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 温度文字
                  Text(`${this.tempMin}${'℃'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.tempMin, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.tempMax}${'℃'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.tempMax, this.tempLimitMin, this.tempLimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.tempMin.toString(),
                    controller: this.tempMinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.tempLimitMin && num < this.tempMax) {
                        this.tempMin = num
                      }
                    })
                    .onBlur(() => {
                      console.log('温度下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.tempMax.toString(),
                    controller: this.tempMaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.tempLimitMax && num > this.tempMin) {
                        this.tempMax = num
                      }
                    })
                    .onBlur(() => {
                      console.log('温度上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .backgroundColor(Color.White)
            .borderRadius(20)
            .margin({ top: 15 })
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })

            // 湿度传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#DBEAFE')
                    .borderRadius(18)
                  Image($r('app.media.water'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('湿度(%)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text(this.getCurrentValueDisplay(this.currentHumi, '%', this.humiMin, this.humiMax).text)
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor(this.getCurrentValueDisplay(this.currentHumi, '%', this.humiMin, this.humiMax).color)
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.humiMax, this.humiLimitMin, this.humiLimitMax) -
                      this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.humiMax, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 湿度文字
                  Text(`${this.humiMin}${'%'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.humiMin, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.humiMax}${'%'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.humiMax, this.humiLimitMin, this.humiLimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.humiMin.toString(),
                    controller: this.humiMinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.humiLimitMin && num < this.humiMax) {
                        this.humiMin = num
                      }
                    })
                    .onBlur(() => {
                      console.log('湿度下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.humiMax.toString(),
                    controller: this.humiMaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.humiLimitMax && num > this.humiMin) {
                        this.humiMax = num
                      }
                    })
                    .onBlur(() => {
                      console.log('湿度上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .borderRadius(20)
            .margin({ top: 15 })
            .backgroundColor(Color.White)
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })

            // CO2传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#F3E8FF')
                    .borderRadius(18)
                  Image($r('app.media.nco2'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('co2(ppm)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()

                Text(this.getCurrentValueDisplay(this.currentCo2, 'ppm', this.co2Min, this.co2Max).text)
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor(this.getCurrentValueDisplay(this.currentCo2, 'ppm', this.co2Min, this.co2Max).color)
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.co2Max, this.co2LimitMin, this.co2LimitMax) -
                      this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.co2Max, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // CO2文字
                  Text(`${this.co2Min}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.co2Min, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.co2Max}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.co2Max, this.co2LimitMin, this.co2LimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.co2Min.toString(),
                    controller: this.co2MinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.co2LimitMin && num < this.co2Max) {
                        this.co2Min = num
                      }
                    })
                    .onBlur(() => {
                      console.log('CO2下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.co2Max.toString(),
                    controller: this.co2MaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.co2LimitMax && num > this.co2Min) {
                        this.co2Max = num
                      }
                    })
                    .onBlur(() => {
                      console.log('CO2上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .borderRadius(20)
            .backgroundColor(Color.White)
            .margin({ top: 15})
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })

            // 光照传感器
            Column() {
              Row({ space: 10 }) {
                Stack() {
                  Circle()
                    .width('36vp')
                    .height('36vp')
                    .fill('#FEF9C3')
                    .borderRadius(18)
                  Image($r('app.media.sun'))
                    .padding(7)
                    .width('36vp')
                }
                .margin({ top: 20, left: 20 })

                Text('光照(lux)')
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .margin({ top: 20, left: 10 })

                Blank()


                Text(this.getCurrentValueDisplay(this.currentLight, 'lx', this.lightMin, this.lightMax).text)
                  .fontWeight(FontWeight.Bold)
                  .fontSize('20vp')
                  .fontColor(this.getCurrentValueDisplay(this.currentLight, 'lx', this.lightMin, this.lightMax).color)
                  .margin({ right: 20, top: 20 })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')

              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Stack() {
                    // 底部轨道
                    Row()
                      .width('100%')
                      .height('8vp')
                      .backgroundColor('#E2E8F0')
                      .borderRadius(5)

                    // 选中的绿色区间
                    Row()
                      .height('8vp')
                      .borderRadius(5)
                      .width(`${this.mapToSlider(this.lightMax, this.lightLimitMin, this.lightLimitMax) -
                      this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%`)
                      .backgroundColor('#4d13ec5b')
                      .position({ left: `${this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%` })
                  }

                  // 左圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 右圆点
                  Row()
                    .width('7vp')
                    .height('20vp')
                    .backgroundColor('#13EC5B')
                    .borderRadius(10)
                    .position({ left: `${this.mapToSlider(this.lightMax, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -5, y: 10 })

                  // 光照文字
                  Text(`${this.lightMin / 1000}${'k'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.lightMin, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -15, y: 35 })

                  Text(`${this.lightMax / 1000}${'k'}`)
                    .fontSize(16)
                    .fontColor('#13EC5B')
                    .position({ left: `${this.mapToSlider(this.lightMax, this.lightLimitMin, this.lightLimitMax)}%` })
                    .translate({ x: -15, y: 35 })
                }
                .width('90%')
                .height('100%')
                .alignContent(Alignment.Center)
              }
              .alignContent(Alignment.Center)
              .width('100%')
              .height('50vp')

              // 输入框
              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text("下限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.lightMin.toString(),
                    controller: this.lightMinController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num >= this.lightLimitMin && num < this.lightMax) {
                        this.lightMin = num
                      }
                    })
                    .onBlur(() => {
                      console.log('光照下限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column({ space: 6 }) {
                  Text("上限")
                    .fontSize(14)
                    .fontColor('#888')
                  TextInput({
                    text: this.lightMax.toString(),
                    controller: this.lightMaxController
                  })
                    .width('100%')
                    .height('40vp')
                    .backgroundColor('#F8FAFC')
                    .border({ width: 1, color: '#EAEAEA' })
                    .borderRadius(25)
                    .textAlign(TextAlign.Start)
                    .type(InputType.Number)
                    .onChange(v => {
                      let num = Number(v)
                      if (!isNaN(num) && num <= this.lightLimitMax && num > this.lightMin) {
                        this.lightMax = num
                      }
                    })
                    .onBlur(() => {
                      console.log('光照上限输入框失去焦点');
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(15)
              .margin(16)
            }
            .width('95%')
            .borderRadius(20)
            .backgroundColor(Color.White)
            .margin({ top: 15,bottom:15 })
            .shadow({
              radius: 10,
              color: 'rgba(0, 0, 0, 0.2)',
              offsetX: 6,
              offsetY: 6
            })
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#99f1f5f9')
        .flexShrink(0)
        .scrollBar(BarState.Off)

        Row({ space: 20 }) {
          Button('重置')
            .width('120vp')
            .fontColor('#475569')
            .backgroundColor('#F1F5F9')
            .border({
              color: '#D1D5DB',
              width: 1
            })
            .onClick(() => {
              this.resetAll();
            })

          Button('应用更改')
            .width('180')
            .backgroundColor('#13EC5B')
            .shadow({
              radius: 5,
              color: 'rgba(20,100,50,0.3)',
              offsetY: 6
            })
            .onClick(() => {
              this.applyChanges();
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('60vp')
      }
    }
    .onClick(() => {
      // 点击空白区域时，清除所有 TextInput 的焦点
      this.clearAllFocus();
    })
    .hideTitleBar(true)
  }

  private mapToSlider(move: number, minLimit: number, maxLimit: number): number {
    return ((move - minLimit) / (maxLimit - minLimit)) * 100;
  }
}