import { NavigationManager } from '../common/NavigationManager';
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import { GlobalState, GlobalStateService } from '../service/GlobalStateService';

// 活动日志接口
interface ActivityLog {
  id: string;
  content: string;
  time: string;
  dotColor: string;
  timestamp: number;
}

interface LogItem {
  content: string;
  time: string;
  dotColor: string;
}

interface CloudDataResponse {
  success: boolean;
  count: number;
  data: Record<string, string>;
}

interface HardwareUpdateThresholdsResponse {
  status: string;
  Co2Threshold?: number;
  SoilTempThreshold?: number;
  SoilHumidityThreshold?: number;
  LightThreshold?: number;
  WaterVolume?: number;
  DeviceID?: string;
}

interface HardwareUpdateTargetsResponse {
  status: string;
  Co2Target?: number;
  SoilTempTarget?: number;
  SoilHumidityTarget?: number;
  DeviceID?: string;
}

interface HardwareUpdateLightResponse {
  status: string;
  Brightness?: number;
  Red?: number;
  Green?: number;
  Blue?: number;
  LightDuration?: number;
  DeviceID?: string;
}

interface CloudSensorRecord {
  air_humidity: string;
  soil_humidity: string;
  soil_temperature: string;
  air_temperature: string;
  light: string;
  co2: string;
  date: string;
  time: string;
}

interface HardwareThresholdsResponse {
  Co2Threshold: number;
  SoilTempThreshold: number;
  SoilHumidityThreshold: number;
  LightThreshold: number;
  WaterVolume: number;
  DeviceID: string;
}

interface HardwareTargetsResponse {
  Co2Target: number;
  SoilTempTarget: number;
  SoilHumidityTarget: number;
  DeviceID: string;
}

interface HardwareStateResponse {
  WaterState: boolean;
  LightState: boolean;
  AirState: boolean;
  AutoModeState?: boolean;
  status?: string;
}

interface HardwareCommandResponse {
  status: string;
  WaterState: boolean;
  LightState: boolean;
  AirState: boolean;
  AutoModeState?: boolean;
  DeviceID: string;
}

interface DeviceConfigResponse {
  electricity: string;
  waterVolume: string;
  deviceID: string;
}

interface ThresholdData {
  co2Threshold: number;
  soilTempThreshold: number;
  soilHumidityThreshold: number;
  lightThreshold: number;
  waterVolumeThreshold: number;
}

interface TargetData {
  co2Target: number;
  soilTempTarget: number;
  soilHumidityTarget: number;
}

interface SensorData {
  soilHumidity: number;
  light: number;
  co2: number;
  waterVolume: number;
}

interface LightTimeSetting {
  brightness: number;
  red: number;
  green: number;
  blue: number;
  lightDuration: number;
  startHour?: number;
  startMinute?: number;
  endHour?: number;
  endMinute?: number;
}

interface GeneratedTypeLiteralInterface_1 {
  brightness: number;
  red: number;
  green: number;
  blue: number;
  startHour: number;
  startMinute: number;
  endHour: number;
  endMinute: number;
}

interface GeneratedTypeLiteralInterface_2 {
  Brightness: number;
  Red: number;
  Green: number;
  Blue: number;
  LightStartHour?: number;
  LightStartMinute?: number;
  LightEndHour?: number;
  LightEndMinute?: number;
}

interface GeneratedTypeLiteralInterface_3 {
  status: string;
}

class HardwareService {
  private deviceIp: string = '172.16.12.51';
  private deviceId: string = 'device_001';

  updateDeviceInfo(deviceIp: string, deviceId: string): void {
    this.deviceIp = deviceIp;
    this.deviceId = deviceId;
  }

  async fetchThresholds(): Promise<ThresholdData | null> {
    try {
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/thresholds`;
      console.info('[硬件接口] 获取阈值数据:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareThresholdsResponse;
        httpRequest.destroy();
        return {
          co2Threshold: data.Co2Threshold,
          soilTempThreshold: data.SoilTempThreshold,
          soilHumidityThreshold: data.SoilHumidityThreshold,
          lightThreshold: data.LightThreshold,
          waterVolumeThreshold: data.WaterVolume
        };
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 获取阈值失败:', JSON.stringify(error));
      return null;
    }
  }

  async updateThresholds(thresholds: Partial<ThresholdData>): Promise<boolean> {
    try {
      const formData: string[] = [];
      if (thresholds.co2Threshold !== undefined) formData.push(`Co2=${thresholds.co2Threshold}`);
      if (thresholds.soilTempThreshold !== undefined) formData.push(`SoilTemp=${thresholds.soilTempThreshold}`);
      if (thresholds.soilHumidityThreshold !== undefined) formData.push(`SoilHumidity=${thresholds.soilHumidityThreshold}`);
      if (thresholds.lightThreshold !== undefined) formData.push(`Light=${thresholds.lightThreshold}`);
      if (thresholds.waterVolumeThreshold !== undefined) formData.push(`WaterVolume=${thresholds.waterVolumeThreshold}`);

      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/thresholds`;
      console.info('[硬件接口] 更新阈值:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/x-www-form-urlencoded' },
        extraData: formData.join('&'),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareUpdateThresholdsResponse;
        httpRequest.destroy();
        return data.status === 'success';
      }
      httpRequest.destroy();
      return false;
    } catch (error) {
      console.error('[硬件接口] 更新阈值失败:', JSON.stringify(error));
      return false;
    }
  }

  async fetchTargets(): Promise<TargetData | null> {
    try {
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/targets`;
      console.info('[硬件接口] 获取目标值:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareTargetsResponse;
        httpRequest.destroy();
        return {
          co2Target: data.Co2Target,
          soilTempTarget: data.SoilTempTarget,
          soilHumidityTarget: data.SoilHumidityTarget
        };
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 获取目标值失败:', JSON.stringify(error));
      return null;
    }
  }

  async updateTargets(targets: Partial<TargetData>): Promise<boolean> {
    try {
      const formData: string[] = [];
      if (targets.co2Target !== undefined) formData.push(`Co2=${targets.co2Target}`);
      if (targets.soilTempTarget !== undefined) formData.push(`SoilTemp=${targets.soilTempTarget}`);
      if (targets.soilHumidityTarget !== undefined) formData.push(`SoilHumidity=${targets.soilHumidityTarget}`);

      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/targets`;
      console.info('[硬件接口] 更新目标值:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/x-www-form-urlencoded' },
        extraData: formData.join('&'),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareUpdateTargetsResponse;
        httpRequest.destroy();
        return data.status === 'success';
      }
      httpRequest.destroy();
      return false;
    } catch (error) {
      console.error('[硬件接口] 更新目标值失败:', JSON.stringify(error));
      return false;
    }
  }

  async fetchFullLightSetting(): Promise<GeneratedTypeLiteralInterface_1 | null> {
    try {
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/light`;
      console.info('[硬件接口] 获取完整光源设置:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as GeneratedTypeLiteralInterface_2;
        httpRequest.destroy();
        return {
          brightness: data.Brightness,
          red: data.Red,
          green: data.Green,
          blue: data.Blue,
          startHour: data.LightStartHour ?? 20,
          startMinute: data.LightStartMinute ?? 0,
          endHour: data.LightEndHour ?? 6,
          endMinute: data.LightEndMinute ?? 0
        };
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 获取完整光源设置失败:', JSON.stringify(error));
      return null;
    }
  }

  async updateLightSettingWithTime(
    brightness: number,
    red: number,
    green: number,
    blue: number,
    startHour: number,
    startMinute: number,
    endHour: number,
    endMinute: number
  ): Promise<boolean> {
    try {
      const formData = `Brightness=${brightness}&Red=${red}&Green=${green}&Blue=${blue}&LightStartHour=${startHour}&LightStartMinute=${startMinute}&LightEndHour=${endHour}&LightEndMinute=${endMinute}`;
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/light`;
      console.info('[硬件接口] 更新光源设置:', url, formData);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/x-www-form-urlencoded' },
        extraData: formData,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as GeneratedTypeLiteralInterface_3;
        httpRequest.destroy();
        return data.status === 'success';
      }
      httpRequest.destroy();
      return false;
    } catch (error) {
      console.error('[硬件接口] 更新光源设置失败:', JSON.stringify(error));
      return false;
    }
  }

  async fetchDeviceState(): Promise<HardwareStateResponse | null> {
    try {
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/state`;
      console.info('[硬件接口] 获取设备状态:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareStateResponse;
        httpRequest.destroy();
        return data;
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 获取设备状态失败:', JSON.stringify(error));
      return null;
    }
  }

  async sendCommand(command: string): Promise<HardwareCommandResponse | null> {
    try {
      const formData = `cmd=${command}`;
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/cmd`;
      console.info('[硬件接口] 发送指令:', command);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/x-www-form-urlencoded' },
        extraData: formData,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareCommandResponse;
        httpRequest.destroy();
        return data;
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 发送指令失败:', JSON.stringify(error));
      return null;
    }
  }

  async updateLightSetting(brightness: number, red: number, green: number, blue: number): Promise<boolean> {
    try {
      const formData = `Brightness=${brightness}&Red=${red}&Green=${green}&Blue=${blue}&LightDuration=30`;
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/light`;
      console.info('[硬件接口] 更新光源设置:', url, formData);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/x-www-form-urlencoded' },
        extraData: formData,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as HardwareUpdateLightResponse;
        httpRequest.destroy();
        return data.status === 'success';
      }
      httpRequest.destroy();
      return false;
    } catch (error) {
      console.error('[硬件接口] 更新光源设置失败:', JSON.stringify(error));
      return false;
    }
  }
}

class CloudService {
  private static readonly SENSOR_API_URL = 'https://guet-farm.netlify.app/.netlify/functions/getData';
  private static readonly CONFIG_API_URL = 'https://guet-farm.netlify.app/.netlify/functions/cfg';

  async fetchSensorData(): Promise<SensorData | null> {
    try {
      console.info('[云平台] 获取传感器数据:', CloudService.SENSOR_API_URL);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(CloudService.SENSOR_API_URL, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode !== 200) {
        console.error('[云平台] HTTP请求失败:', response.responseCode);
        httpRequest.destroy();
        return null;
      }

      const outerData = JSON.parse(response.result as string) as CloudDataResponse;
      httpRequest.destroy();

      if (!outerData.success || outerData.count === 0) {
        console.error('[云平台] 数据获取失败或无数据');
        return null;
      }

      const keys = Object.keys(outerData.data).sort();
      const latestKey = keys[keys.length - 1];
      const rawData = JSON.parse(outerData.data[latestKey]) as CloudSensorRecord;

      const parseValue = (str: string): number => {
        const match = str.match(/\d+(\.\d+)?/);
        return match ? parseFloat(match[0]) : 0;
      };

      const sensorData: SensorData = {
        soilHumidity: parseValue(rawData.soil_humidity),
        light: parseValue(rawData.light),
        co2: parseValue(rawData.co2),
        waterVolume: 0
      };

      console.log(`[云平台] 传感器数据: 土壤湿度=${sensorData.soilHumidity}%, 光照=${sensorData.light}lx, CO2=${sensorData.co2}ppm`);
      return sensorData;
    } catch (error) {
      console.error('[云平台] 获取传感器数据失败:', JSON.stringify(error));
      return null;
    }
  }

  async fetchDeviceConfig(deviceId: string): Promise<number | null> {
    try {
      const url = `${CloudService.CONFIG_API_URL}?deviceID=${deviceId}`;
      console.info('[云平台] 获取设备配置:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as DeviceConfigResponse;
        httpRequest.destroy();
        const match = data.waterVolume.match(/\d+/);
        const waterVolume = match ? parseInt(match[0], 10) : 0;
        console.log(`[云平台] 水箱水量: ${waterVolume}L`);
        return waterVolume;
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[云平台] 获取设备配置失败:', JSON.stringify(error));
      return null;
    }
  }
}

@Entry
@Component
export struct Rule {
  @State params: Record<string, Object> = {};
  @State isCheck1: boolean = false;
  @State isCheck2: boolean = false;
  @State isCheck3: boolean = false;
  @State showLightTimeSettingDialog: boolean = false;
  @State allLogs: ActivityLog[] = [];
  @State displayLogs: ActivityLog[] = [];
  @State showAllLogs: boolean = false;
  @State logList: LogItem[] = [
    { content: "自动灌溉系统启动", time: "14:20 PM", dotColor: "#3B82F6" },
    { content: "自动灌溉终止", time: "14:35 PM", dotColor: "#3B82F6" },
    { content: "B区域检测到活动", time: "11:04 AM", dotColor: "#F59E0B" },
  ];
  @State showLightTimePicker: boolean = false;
  @State showTimePickerDialog: boolean = false;
  @State lightStartHour: number = 20;
  @State lightStartMinute: number = 0;
  @State lightEndHour: number = 6;
  @State lightEndMinute: number = 0;
  @State currentLightSetting: LightTimeSetting | null = null;
  @State runningCount: number = 3;
  @State thresholds: ThresholdData = {
    co2Threshold: 500,
    soilTempThreshold: 35,
    soilHumidityThreshold: 30,
    lightThreshold: 20,
    waterVolumeThreshold: 200
  };
  @State targets: TargetData = {
    co2Target: 400,
    soilTempTarget: 25,
    soilHumidityTarget: 60
  };
  @State sensorData: SensorData = {
    soilHumidity: 0,
    light: 0,
    co2: 0,
    waterVolume: 0
  };
  @State waterState: boolean = false;
  @State lightState: boolean = false;
  @State airState: boolean = false;

  private hardwareService: HardwareService = new HardwareService();
  private cloudService: CloudService = new CloudService();
  private globalStateService: GlobalStateService = GlobalStateService.getInstance();
  private isSyncingFromGlobal: boolean = false;

  private sensorTimer: number = -1;
  private autoControlTimer: number = -1;
  private hourList: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
  private minuteList: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59];
  @State tempStartHour: number = 20;
  @State tempStartMinute: number = 0;
  @State tempEndHour: number = 6;
  @State tempEndMinute: number = 0;
  private timePickerType: 'start' | 'end' = 'start';
  private startHourScroller: Scroller = new Scroller();
  private startMinuteScroller: Scroller = new Scroller();
  private endHourScroller: Scroller = new Scroller();
  private endMinuteScroller: Scroller = new Scroller();

  async fetchCurrentLightSetting(): Promise<void> {
    const setting = await this.hardwareService.fetchFullLightSetting();
    if (setting) {
      this.lightStartHour = setting.startHour;
      this.lightStartMinute = setting.startMinute;
      this.lightEndHour = setting.endHour;
      this.lightEndMinute = setting.endMinute;
      this.currentLightSetting = {
        brightness: setting.brightness,
        red: setting.red,
        green: setting.green,
        blue: setting.blue,
        lightDuration: 30,
        startHour: setting.startHour,
        startMinute: setting.startMinute,
        endHour: setting.endHour,
        endMinute: setting.endMinute
      };
    } else {
      this.currentLightSetting = {
        brightness: 75,
        red: 255,
        green: 255,
        blue: 255,
        lightDuration: 30
      };
    }
  }

  async saveLightTimeSetting(): Promise<void> {
    const lightSetting = await this.hardwareService.fetchFullLightSetting();
    const brightness = lightSetting?.brightness ?? 75;
    const red = lightSetting?.red ?? 255;
    const green = lightSetting?.green ?? 255;
    const blue = lightSetting?.blue ?? 255;

    const success = await this.hardwareService.updateLightSettingWithTime(
      brightness, red, green, blue,
      this.lightStartHour, this.lightStartMinute,
      this.lightEndHour, this.lightEndMinute
    );

    if (success) {
      await this.globalStateService.updateTimeSetting(
        this.lightStartHour,
        this.lightStartMinute,
        this.lightEndHour,
        this.lightEndMinute
      );
      this.showGlobalToast(`补光时间已设置: ${this.formatTime(this.lightStartHour, this.lightStartMinute)}-${this.formatTime(this.lightEndHour, this.lightEndMinute)}\n当前亮度:${brightness}% RGB:(${red},${green},${blue})`);
      this.addActivityLog(`夜间照明时间已更新: ${this.formatTime(this.lightStartHour, this.lightStartMinute)}-${this.formatTime(this.lightEndHour, this.lightEndMinute)}`, true);
    } else {
      this.showGlobalToast('设置失败，请重试');
    }
  }

  private formatTime(hour: number, minute: number): string {
    return `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
  }

  showStartTimePicker(): void {
    this.tempStartHour = this.lightStartHour;
    this.tempStartMinute = this.lightStartMinute;
    this.timePickerType = 'start';
    this.showLightTimePicker = true;
  }

  showEndTimePicker(): void {
    this.tempEndHour = this.lightEndHour;
    this.tempEndMinute = this.lightEndMinute;
    this.timePickerType = 'end';
    this.showLightTimePicker = true;
  }

  confirmTimePicker(): void {
    if (this.timePickerType === 'start') {
      this.lightStartHour = this.tempStartHour;
      this.lightStartMinute = this.tempStartMinute;
    } else {
      this.lightEndHour = this.tempEndHour;
      this.lightEndMinute = this.tempEndMinute;
    }
    this.showLightTimePicker = false;
  }

  private addActivityLog(content: string, isNormal: boolean): void {
    const now = new Date();
    const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const timestamp = now.getTime();

    const newLog: ActivityLog = {
      id: timestamp.toString(),
      content: content,
      time: timeStr,
      dotColor: isNormal ? '#3B82F6' : '#F59E0B',
      timestamp: timestamp
    };

    this.allLogs = [newLog, ...this.allLogs];

    if (this.allLogs.length > 100) {
      this.allLogs = this.allLogs.slice(0, 100);
    }

    this.updateDisplayLogs();
  }

  private updateDisplayLogs(): void {
    if (this.showAllLogs) {
      this.displayLogs = this.allLogs.slice();
    } else {
      this.displayLogs = this.allLogs.slice(0, 3);
    }
  }

  private toggleShowAllLogs(): void {
    this.showAllLogs = !this.showAllLogs;
    this.updateDisplayLogs();
  }

  aboutToAppear(): void {
    console.log('自动化规则页面初始化');

    if (this.params['deviceId']) {
      this.hardwareService.updateDeviceInfo(this.params['deviceId'] as string, this.params['deviceId'] as string);
    }
    if (this.params['ipAddress']) {
      this.hardwareService.updateDeviceInfo(this.params['ipAddress'] as string, this.params['deviceId'] as string);
    }

    this.loadStateFromGlobal();
    this.listenToGlobalChanges();
    this.initThresholdsAndTargets();
    this.loadSensorData();
    this.initSampleLogs();

    this.sensorTimer = setInterval(() => {
      this.loadSensorData();
    }, 10000);

    this.autoControlTimer = setInterval(() => {
      this.autoControl();
    }, 5000);
  }

  // ✅ 修复：不使用展开运算符
  private loadStateFromGlobal(): void {
    this.isSyncingFromGlobal = true;

    const globalState = this.globalStateService.getState();

    this.isCheck1 = globalState.ruleSwitches.autoIrrigation;
    this.isCheck2 = globalState.ruleSwitches.nightLighting;
    this.isCheck3 = globalState.ruleSwitches.ventilation;

    this.lightStartHour = globalState.timeSetting.lightStartHour;
    this.lightStartMinute = globalState.timeSetting.lightStartMinute;
    this.lightEndHour = globalState.timeSetting.lightEndHour;
    this.lightEndMinute = globalState.timeSetting.lightEndMinute;

    // ✅ 修复：手动赋值 target 对象属性
    this.targets.co2Target = globalState.targets.co2Target;
    this.targets.soilTempTarget = globalState.targets.soilTempTarget;
    this.targets.soilHumidityTarget = globalState.targets.soilHumidityTarget;

    // ✅ 修复：手动赋值 thresholds 对象属性
    this.thresholds.co2Threshold = globalState.thresholds.co2Threshold;
    this.thresholds.soilTempThreshold = globalState.thresholds.soilTempThreshold;
    this.thresholds.soilHumidityThreshold = globalState.thresholds.soilHumidityThreshold;
    this.thresholds.lightThreshold = globalState.thresholds.lightThreshold;
    this.thresholds.waterVolumeThreshold = globalState.thresholds.waterVolumeThreshold;

    // ✅ 修复：手动赋值 currentLightSetting
    if (this.currentLightSetting) {
      this.currentLightSetting.brightness = globalState.lightSetting.brightness;
      this.currentLightSetting.red = globalState.lightSetting.red;
      this.currentLightSetting.green = globalState.lightSetting.green;
      this.currentLightSetting.blue = globalState.lightSetting.blue;
      this.currentLightSetting.lightDuration = globalState.lightSetting.lightDuration;
    } else {
      this.currentLightSetting = {
        brightness: globalState.lightSetting.brightness,
        red: globalState.lightSetting.red,
        green: globalState.lightSetting.green,
        blue: globalState.lightSetting.blue,
        lightDuration: globalState.lightSetting.lightDuration
      };
    }

    // ✅ 修复：手动赋值 sensorData
    this.sensorData.soilHumidity = globalState.sensorData.soilHumidity;
    this.sensorData.light = globalState.sensorData.light;
    this.sensorData.co2 = 0;
    this.sensorData.waterVolume = globalState.sensorData.waterVolume;

    this.waterState = globalState.deviceState.waterState;
    this.lightState = globalState.deviceState.lightState;
    this.airState = globalState.deviceState.airState;

    this.updateRunningCount();

    this.isSyncingFromGlobal = false;

    console.log('[Rule] 从全局状态加载完成');
  }

  // ✅ 修复：不使用展开运算符
  private listenToGlobalChanges(): void {
    this.globalStateService.addListener((newState: GlobalState) => {
      if (this.isSyncingFromGlobal) return;

      console.log('[Rule] 收到全局状态变化');

      this.isSyncingFromGlobal = true;

      this.isCheck1 = newState.ruleSwitches.autoIrrigation;
      this.isCheck2 = newState.ruleSwitches.nightLighting;
      this.isCheck3 = newState.ruleSwitches.ventilation;

      //  核心修复：只有在没打开时间选择器时，才同步全局时间
      if (!this.showTimePickerDialog && !this.showLightTimeSettingDialog) {
        this.lightStartHour = newState.timeSetting.lightStartHour;
        this.lightStartMinute = newState.timeSetting.lightStartMinute;
        this.lightEndHour = newState.timeSetting.lightEndHour;
        this.lightEndMinute = newState.timeSetting.lightEndMinute;
      }

      // 修复：手动赋值
      this.targets.co2Target = newState.targets.co2Target;
      this.targets.soilTempTarget = newState.targets.soilTempTarget;
      this.targets.soilHumidityTarget = newState.targets.soilHumidityTarget;

      this.thresholds.co2Threshold = newState.thresholds.co2Threshold;
      this.thresholds.soilTempThreshold = newState.thresholds.soilTempThreshold;
      this.thresholds.soilHumidityThreshold = newState.thresholds.soilHumidityThreshold;
      this.thresholds.lightThreshold = newState.thresholds.lightThreshold;
      this.thresholds.waterVolumeThreshold = newState.thresholds.waterVolumeThreshold;

      this.sensorData.soilHumidity = newState.sensorData.soilHumidity;
      this.sensorData.light = newState.sensorData.light;
      this.sensorData.waterVolume = newState.sensorData.waterVolume;

      this.waterState = newState.deviceState.waterState;
      this.lightState = newState.deviceState.lightState;
      this.airState = newState.deviceState.airState;

      if (this.currentLightSetting) {
        this.currentLightSetting.brightness = newState.lightSetting.brightness;
        this.currentLightSetting.red = newState.lightSetting.red;
        this.currentLightSetting.green = newState.lightSetting.green;
        this.currentLightSetting.blue = newState.lightSetting.blue;
        this.currentLightSetting.lightDuration = newState.lightSetting.lightDuration;
      }

      this.updateRunningCount();

      this.isSyncingFromGlobal = false;
    });
  }

  private initSampleLogs(): void {
    const now = new Date();
    const sampleLogs: ActivityLog[] = [
      {
        id: '1',
        content: '自动灌溉系统启动',
        time: `${now.getHours().toString().padStart(2, '0')}:${(now.getMinutes() - 15).toString().padStart(2, '0')}`,
        dotColor: '#3B82F6',
        timestamp: now.getTime() - 15 * 60 * 1000
      },
      {
        id: '2',
        content: '自动灌溉终止',
        time: `${now.getHours().toString().padStart(2, '0')}:${(now.getMinutes() - 10).toString().padStart(2, '0')}`,
        dotColor: '#3B82F6',
        timestamp: now.getTime() - 10 * 60 * 1000
      },
      {
        id: '3',
        content: '温室通风已启动',
        time: `${now.getHours().toString().padStart(2, '0')}:${(now.getMinutes() - 5).toString().padStart(2, '0')}`,
        dotColor: '#3B82F6',
        timestamp: now.getTime() - 5 * 60 * 1000
      }
    ];

    this.allLogs = sampleLogs;
    this.updateDisplayLogs();
  }

  aboutToDisappear(): void {
    if (this.sensorTimer !== -1) clearInterval(this.sensorTimer);
    if (this.autoControlTimer !== -1) clearInterval(this.autoControlTimer);
  }

  async initThresholdsAndTargets(): Promise<void> {
    try {
      const thresholds = await this.hardwareService.fetchThresholds();
      if (thresholds) {
        this.thresholds.co2Threshold = thresholds.co2Threshold;
        this.thresholds.soilTempThreshold = thresholds.soilTempThreshold;
        this.thresholds.soilHumidityThreshold = thresholds.soilHumidityThreshold;
        this.thresholds.lightThreshold = thresholds.lightThreshold;
        this.thresholds.waterVolumeThreshold = thresholds.waterVolumeThreshold;
        await this.globalStateService.updateThresholds({
          "co2Threshold": thresholds.co2Threshold,
          "soilTempThreshold": thresholds.soilTempThreshold,
          "soilHumidityThreshold": thresholds.soilHumidityThreshold,
          "lightThreshold": thresholds.lightThreshold,
          "waterVolumeThreshold": thresholds.waterVolumeThreshold
        });
        console.log('阈值初始化成功:', this.thresholds);
      } else {
        console.log('使用默认阈值');
      }

      const targets = await this.hardwareService.fetchTargets();
      if (targets) {
        this.targets.co2Target = targets.co2Target;
        this.targets.soilTempTarget = targets.soilTempTarget;
        this.targets.soilHumidityTarget = targets.soilHumidityTarget;
        await this.globalStateService.updateTargets({
          "co2Target": targets.co2Target,
          "soilTempTarget": targets.soilTempTarget,
          "soilHumidityTarget": targets.soilHumidityTarget
        });
        console.log('目标值初始化成功:', this.targets);
      } else {
        console.log('使用默认目标值');
      }
    } catch (error) {
      console.error('初始化阈值/目标值失败:', error);
    }
  }

  async initDeviceState(): Promise<void> {
    try {
      const state = await this.hardwareService.fetchDeviceState();
      if (state) {
        this.waterState = state.WaterState || false;
        this.lightState = state.LightState || false;
        this.airState = state.AirState || false;
        console.log('设备状态初始化成功');
      }
    } catch (error) {
      console.error('获取设备状态失败:', error);
    }
  }

  async loadSensorData(): Promise<void> {
    try {
      const sensorData = await this.cloudService.fetchSensorData();
      if (sensorData) {
        this.sensorData.soilHumidity = sensorData.soilHumidity;
        this.sensorData.light = sensorData.light;
        this.sensorData.co2 = sensorData.co2;
        console.log(`传感器数据更新: 土壤湿度=${this.sensorData.soilHumidity}%, 光照=${this.sensorData.light}lx, CO2=${this.sensorData.co2}ppm`);
      }

      const waterVolume = await this.cloudService.fetchDeviceConfig(this.params['deviceId'] as string || 'device_001');
      if (waterVolume !== null) {
        this.sensorData.waterVolume = waterVolume;
        console.log(`水箱水量: ${this.sensorData.waterVolume}L`);

        if (this.sensorData.waterVolume < this.thresholds.waterVolumeThreshold) {
          this.showGlobalToast(`⚠️ 水箱水量不足！当前仅剩${this.sensorData.waterVolume}L，请及时补水`);
        }
      }
    } catch (error) {
      console.error('加载传感器数据失败:', error);
    }
  }

  async autoControl(): Promise<void> {
    this.updateRunningCount();

    if (this.isCheck1) {
      await this.autoIrrigationControl();
    }

    if (this.isCheck2) {
      await this.autoLightControl();
    }

    if (this.isCheck3) {
      await this.autoAirControl();
    }
  }

  async autoIrrigationControl(): Promise<void> {
    if (this.sensorData.waterVolume < this.thresholds.waterVolumeThreshold) {
      if (this.waterState) {
        const result = await this.hardwareService.sendCommand('water-off');
        if (result && result.status === 'success') {
          this.waterState = result.WaterState;
          this.addActivityLog(`自动灌溉异常终止(水量不足:${this.sensorData.waterVolume}L)`, false);
          this.showGlobalToast("⚠️ 水箱水量不足，自动灌溉已停止");
        }
      }
      return;
    }

    if (this.sensorData.soilHumidity < this.thresholds.soilHumidityThreshold && !this.waterState) {
      console.log(`[自动灌溉] 土壤湿度${this.sensorData.soilHumidity}% < 阈值${this.thresholds.soilHumidityThreshold}%，开启水泵`);
      const result = await this.hardwareService.sendCommand('water');
      if (result && result.status === 'success') {
        this.waterState = result.WaterState;
        this.addActivityLog(`自动灌溉系统启动(土壤湿度:${this.sensorData.soilHumidity}%)`, true);
        this.showGlobalToast("💧 土壤干燥，自动灌溉已开启");
      }
    }

    if (this.sensorData.soilHumidity > this.targets.soilHumidityTarget && this.waterState) {
      console.log(`[自动灌溉] 土壤湿度${this.sensorData.soilHumidity}% > 目标值${this.targets.soilHumidityTarget}%，关闭水泵`);
      const result = await this.hardwareService.sendCommand('water-off');
      if (result && result.status === 'success') {
        this.waterState = result.WaterState;
        this.addActivityLog(`自动灌溉系统停止(土壤湿度:${this.sensorData.soilHumidity}%)`, true);
        this.showGlobalToast("✅ 土壤湿度已达标，自动灌溉已停止");
      }
    }
  }

  async autoLightControl(): Promise<void> {
    if (this.sensorData.light < this.thresholds.lightThreshold && !this.lightState) {
      console.log(`[夜间照明] 光照${this.sensorData.light}lx < 阈值${this.thresholds.lightThreshold}lx，开启LED灯`);

      const success = await this.hardwareService.updateLightSetting(50, 255, 255, 255);
      if (success) {
        const result = await this.hardwareService.sendCommand('light');
        if (result && result.status === 'success') {
          this.lightState = result.LightState;
          this.addActivityLog(`夜间照明已开启(光照:${this.sensorData.light}lx)`, true);
          this.showGlobalToast("💡 环境光不足，夜间照明已开启");
        }
      }
    }

    if (this.sensorData.light >= this.thresholds.lightThreshold && this.lightState) {
      console.log(`[夜间照明] 光照${this.sensorData.light}lx >= 阈值${this.thresholds.lightThreshold}lx，关闭LED灯`);
      const result = await this.hardwareService.sendCommand('light-off');
      if (result && result.status === 'success') {
        this.lightState = result.LightState;
        this.addActivityLog(`夜间照明已关闭(光照:${this.sensorData.light}lx)`, true);
        this.showGlobalToast("🌞 光照充足，夜间照明已关闭");
      }
    }
  }

  async autoAirControl(): Promise<void> {
    if (this.sensorData.co2 > this.thresholds.co2Threshold && !this.airState) {
      console.log(`[温室通风] CO2${this.sensorData.co2}ppm > 阈值${this.thresholds.co2Threshold}ppm，开启换气`);
      const result = await this.hardwareService.sendCommand('air');
      if (result && result.status === 'success') {
        this.airState = result.AirState;
        this.addActivityLog(`温室通风已启动(CO2:${this.sensorData.co2}ppm)`, true);
        this.showGlobalToast("🌬️ CO2浓度过高，温室通风已开启");
      }
    }

    if (this.sensorData.co2 < this.targets.co2Target && this.airState) {
      console.log(`[温室通风] CO2${this.sensorData.co2}ppm < 目标值${this.targets.co2Target}ppm，关闭换气`);
      const result = await this.hardwareService.sendCommand('air-off');
      if (result && result.status === 'success') {
        this.airState = result.AirState;
        this.addActivityLog(`温室通风已关闭(CO2:${this.sensorData.co2}ppm)`, true);
        this.showGlobalToast("✅ CO2浓度已达标，温室通风已关闭");
      }
    }
  }

  private updateRunningCount(): void {
    let count = 0;
    if (this.isCheck1) count++;
    if (this.isCheck2) count++;
    if (this.isCheck3) count++;
    this.runningCount = count;
  }

  private addLogItem(content: string, dotColor: string): void {
    const now = new Date();
    const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const newLog: LogItem = {
      content: content,
      time: timeStr,
      dotColor: dotColor
    };
    this.logList = [newLog, ...this.logList];

    if (this.logList.length > 50) {
      this.logList = this.logList.slice(0, 50);
    }
  }

  private showGlobalToast(message: string): void {
    promptAction.openToast({
      message: message,
      duration: 2500
    });
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Row() {
            Image($r('app.media.back'))
              .backgroundColor('#E2E8F0')
              .width('40vp')
              .height('40vp')
              .borderRadius(20)
              .padding(12)
              .onClick(() => {
                NavigationManager.getInstance().pop()
              })
            Text('自动化规则').fontSize('25vp').fontWeight(FontWeight.Bold)
            Text('')
              .width('40vp')
              .height('40vp')
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

          Scroll() {
            Column() {
              Row() {
                Text('自动行为').fontColor('#64748B')
                Text(`${this.runningCount}个运行中`).fontColor('#13EC5B')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(20)

              // 自动灌溉卡片
              Column({ space: 15 }) {
                Row({ space: 10 }) {
                  Image($r('app.media.autowater'))
                    .width('40vp')
                    .height('40vp')
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#3313ec5b')
                    .padding(10)
                    .borderRadius(10)
                  Column() {
                    Text('自动灌溉').fontWeight(FontWeight.Bold)
                    Text('智能水资源管理').fontColor('#64748B').fontSize('12vp')
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Toggle({ type: ToggleType.Switch, isOn: this.isCheck1 })
                    .width('48vp')
                    .height('30vp')
                    .selectedColor('#13EC5B')
                    .onChange(async (value) => {
                      this.isCheck1 = value;
                      this.updateRunningCount();
                      await this.globalStateService.updateRuleSwitches({ "autoIrrigation": value });
                    })
                }
                .width('100%')
                .margin({ top: 15 })
                .padding({ left: 15, right: 15 })

                Column({ space: 3 }) {
                  Text() {
                    Span('条件:').fontColor(this.isCheck1 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                    Span('土壤湿度<30%').fontSize('12vp')
                  }

                  Text() {
                    Span('行为:').fontColor(this.isCheck1 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                    Span('开启水泵进行灌溉,土壤湿度>60%时停止').fontSize('12vp')
                  }
                }
                .width('90%')
                .height('50vp')
                .backgroundColor(this.isCheck1 ? '#0d13ec5b' : '#F1F5F9')
                .padding(10)
                .borderRadius(10)
                .border({
                  width: 1,
                  color: this.isCheck1 ? '#3313ec5b' : '#F1F5F9'
                })
                .alignItems(HorizontalAlign.Start)
              }
              .padding({ bottom: 15 })
              .width('90%')
              .backgroundColor(Color.White)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 8
              })
              .borderRadius(20)
              .margin({ top: 15 })

              // 夜间照明卡片
              Column({ space: 15 }) {
                Row({ space: 10 }) {
                  Image($r('app.media.moon'))
                    .width('40vp')
                    .height('40vp')
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#3313ec5b')
                    .padding(10)
                    .borderRadius(10)
                  Column() {
                    Text('夜间照明').fontWeight(FontWeight.Bold)
                    Text('安全与导航').fontColor('#64748B').fontSize('12vp')
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Toggle({ type: ToggleType.Switch, isOn: this.isCheck2 })
                    .width('48vp')
                    .height('30vp')
                    .selectedColor('#13EC5B')
                    .onChange(async (value) => {
                      this.isCheck2 = value;
                      this.updateRunningCount();
                      // ✅ 修复：使用正确的字段名 "nightLighting"
                      await this.globalStateService.updateRuleSwitches({ "nightLighting": value });
                      if (value) {
                        this.fetchCurrentLightSetting();
                        this.showLightTimeSettingDialog = true;
                      }
                    })
                }
                .width('100%')
                .margin({ top: 15 })
                .padding({ left: 15, right: 15 })

                Column({ space: 3 }) {
                  Text() {
                    Span('条件:').fontColor(this.isCheck2 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                    Span(`环境光<${this.thresholds.lightThreshold}lx`).fontSize('12vp')
                  }

                  Text() {
                    Span('行为:').fontColor(this.isCheck2 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                    Span(`开启补光,开始时间:${this.formatTime(this.lightStartHour, this.lightStartMinute)},结束时间:${this.formatTime(this.lightEndHour, this.lightEndMinute)}`)
                      .fontSize('12vp')
                  }
                }
                .width('90%')
                .height('50vp')
                .backgroundColor(this.isCheck2 ? '#0d13ec5b' : '#F1F5F9')
                .padding(10)
                .borderRadius(10)
                .border({
                  width: 1,
                  color: this.isCheck2 ? '#3313ec5b' : '#F1F5F9'
                })
                .alignItems(HorizontalAlign.Start)
              }
              .padding({ bottom: 15 })
              .width('90%')
              .backgroundColor(Color.White)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 8
              })
              .borderRadius(20)
              .margin({ top: 15 })

              // 温室通风卡片
              Column({ space: 15 }) {
                Row({ space: 10 }) {
                  Image($r('app.media.fans'))
                    .width('40vp')
                    .height('40vp')
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#3313ec5b')
                    .padding(10)
                    .borderRadius(10)
                  Column() {
                    Text('温室通风口').fontWeight(FontWeight.Bold)
                    Text('空气环境控制').fontColor('#64748B').fontSize('12vp')
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Toggle({ type: ToggleType.Switch, isOn: this.isCheck3 })
                    .width('48vp')
                    .height('30vp')
                    .selectedColor('#13EC5B')
                    .onChange(async (value) => {
                      this.isCheck3 = value;
                      this.updateRunningCount();
                      // ✅ 修复：使用正确的字段名 "ventilation"
                      await this.globalStateService.updateRuleSwitches({ "ventilation": value });
                    })
                }
                .width('100%')
                .margin({ top: 15 })
                .padding({ left: 15, right: 15 })

                Column({ space: 3 }) {
                  Text() {
                    Span('条件:').fontColor(this.isCheck3 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                    Span('co2浓度>500ppm').fontSize('12vp')
                  }

                  Text() {
                    Span('行为:').fontColor(this.isCheck3 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                    Span('打开换气扇换气').fontSize('12vp')
                  }
                }
                .width('90%')
                .height('50vp')
                .backgroundColor(this.isCheck3 ? '#0d13ec5b' : '#F1F5F9')
                .padding(10)
                .borderRadius(10)
                .border({
                  width: 1,
                  color: this.isCheck3 ? '#3313ec5b' : '#F1F5F9'
                })
                .alignItems(HorizontalAlign.Start)
              }
              .padding({ bottom: 15 })
              .width('90%')
              .backgroundColor(Color.White)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 8
              })
              .borderRadius(20)
              .margin({ top: 15 })

              Text('近期事件').fontColor('#64748B').width('100%').padding(15)
              Column() {
                Row() {
                  Text("活动日志")
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor("#1E293B")

                  Blank()

                  Text(this.showAllLogs ? "收起" : "查看全部")
                    .fontSize(15)
                    .fontColor("#13EC5B")
                    .onClick(() => {
                      this.toggleShowAllLogs();
                    })
                }
                .width("95%")
                .margin({ top: 15, bottom: 10, right: 10 })

                Divider().width("95%").color("#94A3B8")

                Column({ space: 0 }) {
                  ForEach(this.displayLogs, (item: ActivityLog) => {
                    Row({ space: 12 }) {
                      Circle()
                        .width(10)
                        .height(10)
                        .fill(item.dotColor)

                      Text(item.content)
                        .fontSize(15)
                        .fontColor("#333")
                        .layoutWeight(1)

                      Text(item.time)
                        .fontSize(13)
                        .fontColor("#9CA3AF")
                    }
                    .width("95%")
                    .padding({ top: 14, bottom: 14 })

                    Divider().width("95%").color("#94A3B8")
                  })
                }
                .margin({ top: 5 })

                if (this.displayLogs.length === 0) {
                  Text("暂无活动记录")
                    .fontSize(14)
                    .fontColor("#94A3B8")
                    .width("95%")
                    .height(60)
                    .textAlign(TextAlign.Center)
                }
              }
              .width('90%')
              .backgroundColor(Color.White)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 8
              })
              .borderRadius(20)
              .margin({ top: 15 })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#80f1f5f9')
          .flexShrink(0)
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }

        // 时间设置弹窗
        if (this.showLightTimeSettingDialog) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.5)')
              .onClick(() => {
                this.showLightTimeSettingDialog = false;
              })

            Column() {
              Text('夜间照明设置')
                .fontSize('20vp')
                .fontWeight(FontWeight.Bold)
                .fontColor('#13EC5B')
                .margin({ top: 20 })

              Column() {
                Text('开始时间')
                  .fontSize('14vp')
                  .fontColor('#64748B')
                  .margin({ bottom: 5 })

                Row() {
                  Text(this.formatTime(this.lightStartHour, this.lightStartMinute))
                    .fontSize('24vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#13EC5B')
                    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                    .backgroundColor('#1a13ec5b')
                    .borderRadius(20)
                    .onClick(() => {
                      this.timePickerType = 'start';
                      this.tempStartHour = this.lightStartHour;
                      this.tempStartMinute = this.lightStartMinute;
                      this.showTimePickerDialog = true;
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .padding({ top: 15, bottom: 10 })

              Column() {
                Text('结束时间')
                  .fontSize('14vp')
                  .fontColor('#64748B')
                  .margin({ bottom: 5 })

                Row() {
                  Text(this.formatTime(this.lightEndHour, this.lightEndMinute))
                    .fontSize('24vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#13EC5B')
                    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                    .backgroundColor('#1a13ec5b')
                    .borderRadius(20)
                    .onClick(() => {
                      this.timePickerType = 'end';
                      this.tempEndHour = this.lightEndHour;
                      this.tempEndMinute = this.lightEndMinute;
                      this.showTimePickerDialog = true;
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .padding({ bottom: 10 })

              if (this.currentLightSetting) {
                Column() {
                  Text(`当前补光亮度: ${this.currentLightSetting.brightness}%`)
                    .fontSize('12vp')
                    .fontColor('#94A3B8')
                  Text(`当前补光颜色: RGB(${this.currentLightSetting.red},${this.currentLightSetting.green},${this.currentLightSetting.blue})`)
                    .fontSize('12vp')
                    .fontColor('#94A3B8')
                }
                .width('100%')
                .padding({ top: 5, bottom: 10 })
                .alignItems(HorizontalAlign.Center)
              }

              Divider().width('90%').color('#E2E8F0')

              Row({ space: 16 }) {
                Button("取消")
                  .width("40%")
                  .height('44vp')
                  .backgroundColor("#DFE3E2")
                  .fontColor("#2C2F2F")
                  .borderRadius(22)
                  .onClick(() => {
                    this.showLightTimeSettingDialog = false;
                  })

                Button("确认")
                  .width("40%")
                  .height(44)
                  .backgroundColor("#13EC5B")
                  .fontColor(Color.White)
                  .borderRadius(22)
                  .onClick(() => {
                    this.saveLightTimeSetting();
                    this.showLightTimeSettingDialog = false;
                  })
              }
              .padding({ left: 24, right: 24, bottom: 24 })
              .margin({ top: 10 })
            }
            .width("80%")
            .backgroundColor("#F8FFF8")
            .borderRadius(24)
          }
          .width('100%')
          .height('100%')
          .position({ x: 0, y: 0 })
          .zIndex(888)
        }


        // 时间滚动选择器弹窗
        if (this.showTimePickerDialog) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.5)')
              .onClick(() => {
                this.showTimePickerDialog = false;
              })

            Column() {
              Text(this.timePickerType === 'start' ? '选择开始时间' : '选择结束时间')
                .fontSize('18vp')
                .fontWeight(FontWeight.Bold)
                .fontColor('#13EC5B')
                .margin({ top: 20, bottom: 10 })

              Stack({ alignContent: Alignment.Center }) {
                Row()
                  .width('90%')
                  .height(60)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)

                Row({ space: 6 }) {
                  // 小时列表
                  List({ scroller: this.timePickerType === 'start' ? this.startHourScroller : this.endHourScroller }) {
                    ForEach(this.hourList, (hour: number) => {
                      ListItem() {
                        Text(hour.toString().padStart(2, '0'))
                          .fontSize((this.timePickerType === 'start' && this.tempStartHour === hour) ||
                            (this.timePickerType === 'end' && this.tempEndHour === hour) ? 48 : 32)
                          .fontColor((this.timePickerType === 'start' && this.tempStartHour === hour) ||
                            (this.timePickerType === 'end' && this.tempEndHour === hour) ? '#13EC5B' : '#999')
                          .fontWeight(FontWeight.Bold)
                          .textAlign(TextAlign.Center)
                      }
                      .width('100%')
                      .height(60)
                    })
                  }
                  .width('45%')
                  .height(180)
                  .alignListItem(ListItemAlign.Center)
                  .scrollSnapAlign(ScrollSnapAlign.CENTER)
                  .scrollBar(BarState.Off)
                  .onScrollIndex((start, end, center) => {
                    if (this.timePickerType === 'start') {
                      this.tempStartHour = this.hourList[center];
                    } else {
                      this.tempEndHour = this.hourList[center];
                    }
                  })

                  Text(':')
                    .fontSize(48)
                    .fontColor('#999')
                    .fontWeight(FontWeight.Bold)

                  // 分钟列表
                  List({ scroller: this.timePickerType === 'start' ? this.startMinuteScroller : this.endMinuteScroller }) {
                    ForEach(this.minuteList, (minute: number) => {
                      ListItem() {
                        Text(minute.toString().padStart(2, '0'))
                        // 核心修复：完全独立判断开始/结束时间
                          .fontSize((this.timePickerType === 'start' && this.tempStartMinute === minute) ||
                            (this.timePickerType === 'end' && this.tempEndMinute === minute) ? 48 : 32)
                          .fontColor((this.timePickerType === 'start' && this.tempStartMinute === minute) ||
                            (this.timePickerType === 'end' && this.tempEndMinute === minute) ? '#13EC5B' : '#999')
                          .fontWeight(FontWeight.Bold)
                          .textAlign(TextAlign.Center)
                      }
                      .width('100%')
                      .height(60)
                    })
                  }
                  .width('45%')
                  .height(180)
                  .alignListItem(ListItemAlign.Center)
                  .scrollSnapAlign(ScrollSnapAlign.CENTER)
                  .scrollBar(BarState.Off)
                  .onScrollIndex((start, end, center) => {
                    if (this.timePickerType === 'start') {
                      this.tempStartMinute = this.minuteList[center];
                    } else {
                      this.tempEndMinute = this.minuteList[center];
                    }
                  })
                }
              }
              .margin({ bottom: 15 })

              Row({ space: 16 }) {
                Button("取消")
                  .width('45%')
                  .height(50)
                  .backgroundColor('#DFE3E2')
                  .fontColor('#2C2F2F')
                  .borderRadius(25)
                  .onClick(() => {
                    this.showTimePickerDialog = false;
                  })

                Button("确定")
                  .width('45%')
                  .height(50)
                  .backgroundColor('#13EC5B')
                  .fontColor(Color.White)
                  .borderRadius(25)
                  .onClick(() => {
                    if (this.timePickerType === 'start') {
                      this.lightStartHour = this.tempStartHour;
                      this.lightStartMinute = this.tempStartMinute;
                    } else {
                      this.lightEndHour = this.tempEndHour;
                      this.lightEndMinute = this.tempEndMinute;
                    }
                    this.showTimePickerDialog = false;
                  })
              }
              .padding({ left: 24, right: 24, bottom: 24 })
            }
            .width('80%')
            .backgroundColor('#F8FFF8')
            .borderRadius(24)
          }
          .width('100%')
          .height('100%')
          .position({ x: 0, y: 0 })
          .zIndex(999)
        }
      }
      .backgroundColor(Color.Transparent)
      .width('100%')
      .height('100%')
    }.hideTitleBar(true)
  }
}