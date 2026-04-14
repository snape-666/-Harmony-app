// AlarmManager.ts
import { notificationManager } from '@kit.NotificationKit';
import { vibrator } from '@kit.SensorServiceKit';
import { preferences } from '@kit.ArkData';
import { http } from '@kit.NetworkKit';
interface Data {
  temp: boolean;
  humi: boolean;
  co2: boolean;
  light: boolean;
}

// 在文件顶部添加接口定义
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

interface ApiResponse {
  success: boolean;
  count: number;
  data: Record<string, SensorData>;
}
export class AlarmManager {
  private static instance: AlarmManager;
  private dataPreferences?: preferences.Preferences;
  private refreshTimer?: number;
  private apiUrl = 'https://guet-farm.netlify.app/.netlify/functions/getData';

  // 阈值配置
  private tempMin = 18;
  private tempMax = 32;
  private humiMin = 40;
  private humiMax = 80;
  private co2Min = 300;
  private co2Max = 1200;
  private lightMin = 0;
  private lightMax = 1000;
  private isChecked = 0;

  private lastAlarmState: Data = { temp: false, humi: false, co2: false, light: false };


  static getInstance(): AlarmManager {
    if (!AlarmManager.instance) {
      AlarmManager.instance = new AlarmManager();
    }
    return AlarmManager.instance;
  }

  async init(context: Context,username: string) {
    this.dataPreferences = await preferences.getPreferences(context, 'alarm_prefs');
    const prefsName = `alarm_prefs_${username}`;  // 每个账号独立的存储
    this.dataPreferences = await preferences.getPreferences(context, prefsName);
    await this.loadConfig();
    this.startMonitoring();
    console.log('AlarmManager 初始化成功, 用户:', username);
  }

  private async loadConfig() {
    const configStr = await this.dataPreferences?.get('threshold_config', '');
    console.log('读取到的配置:', configStr);
    if (configStr && configStr !== '') {
      const arr = JSON.parse(configStr as string) as Array<number>;
      if (Array.isArray(arr) && arr.length >= 9) {
        this.tempMin = arr[0];
        this.tempMax = arr[1];
        this.humiMin = arr[2];
        this.humiMax = arr[3];
        this.co2Min = arr[4];
        this.co2Max = arr[5];
        this.lightMin = arr[6];
        this.lightMax = arr[7];
        this.isChecked= arr[8];  // 0 或 1
        console.log('加载配置成功, 报警开关:', this.isChecked);
      }
    }
  }

  async updateConfig(config: number[]) {
    if (!this.dataPreferences) {
      console.error('dataPreferences 未初始化');
      return;
    }
    await this.dataPreferences?.put('threshold_config', JSON.stringify(config));
    await this.dataPreferences?.flush();
    this.tempMin = config[0];
    this.tempMax = config[1];
    this.humiMin = config[2];
    this.humiMax = config[3];
    this.co2Min = config[4];
    this.co2Max = config[5];
    this.lightMin = config[6];
    this.lightMax = config[7];
    this.isChecked = config[8];
  }

  private startMonitoring() {
    this.refreshTimer = setInterval(() => {
      this.fetchAndCheck();
    }, 10000);
    this.fetchAndCheck(); // 立即执行一次
    console.log('开始监控数据');
  }

  private async fetchAndCheck() {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(this.apiUrl, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as Record<string, Object>;
        if (data['success'] === true && data['data']) {
          const dataObj = data['data'] as Record<string, Record<string, string>>;
          const points = Object.values(dataObj);
          const latest = points[points.length - 1];
          if (latest) {
            const currentTemp = parseFloat(latest.air_temperature) || 0;
            const currentHumi = parseFloat(latest.air_humidity) || 0;
            const currentCo2 = parseFloat(latest.co2) || 0;
            const currentLight = parseFloat(latest.light) || 0;
            this.checkAndSend(currentTemp, currentHumi, currentCo2, currentLight);
          }
        }
      }
      httpRequest.destroy();
    } catch (error) {
      console.error('获取数据失败:', error);
    }
  }

  private checkAndSend(temp: number, humi: number, co2: number, light: number) {
    if (!this.isChecked) return;

    // 温度
    const tempAlarm = temp < this.tempMin || temp > this.tempMax;
    if (tempAlarm && !this.lastAlarmState.temp) {
      this.lastAlarmState.temp = true;
      this.sendNotification('温度异常', `当前温度: ${temp}℃`);
    } else if (!tempAlarm) {
      this.lastAlarmState.temp = false;
    }
    // 湿度
    const humiAlarm = humi < this.humiMin || humi > this.humiMax;
    if (humiAlarm && !this.lastAlarmState.humi) {
      this.lastAlarmState.humi = true;
      this.sendNotification('湿度异常', `当前湿度: ${humi}%`);
      console.log('发送湿度报警');
    } else if (!humiAlarm) {
      this.lastAlarmState.humi = false;
    }

    // CO2
    const co2Alarm = co2 < this.co2Min || co2 > this.co2Max;
    if (co2Alarm && !this.lastAlarmState.co2) {
      this.lastAlarmState.co2 = true;
      this.sendNotification('CO2异常', `当前CO2: ${co2}ppm`);
      console.log('发送CO2报警');
    } else if (!co2Alarm) {
      this.lastAlarmState.co2 = false;
    }

    // 光照
    const lightAlarm = light < this.lightMin || light > this.lightMax;
    if (lightAlarm && !this.lastAlarmState.light) {
      this.lastAlarmState.light = true;
      this.sendNotification('光照异常', `当前光照: ${light}lx`);
      console.log('发送光照报警');
    } else if (!lightAlarm) {
      this.lastAlarmState.light = false;
    }
  }

  private async sendNotification(title: string, content: string) {
    try {
      await notificationManager.publish({
        id: Date.now(),
        content: { contentType: 0, normal: { title, text: content } }
      });
      await vibrator.startVibration({ type: 'time', duration: 2000 }, { id: 0, usage: 'alarm' });
      console.log('通知发送成功:', title);
    } catch (error) {
      console.error('通知失败:', error);
    }
  }

  stopMonitoring() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
  }
}