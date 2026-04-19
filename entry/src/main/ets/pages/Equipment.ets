import { NavigationManager } from '../common/NavigationManager'
import { Yibiaopan } from './Yibiaopan'
import { Add } from './Add'
import {Lrrigate} from './Lrrigate'
import { promptAction } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { GlobalState, GlobalStateService, LightSettingState } from '../service/GlobalStateService';
import { preferences } from '@kit.ArkData';

// ==================== 接口定义 ====================
// 硬件阈值响应接口
interface HardwareThresholdsResponse {
  Co2Threshold: number;
  SoilTempThreshold: number;
  SoilHumidityThreshold: number;
  LightThreshold: number;
  WaterVolume: number;
  DeviceID: string;
}
// 阈值数据接口
interface ThresholdData {
  co2Threshold: number;
  soilTempThreshold: number;
  soilHumidityThreshold: number;
  lightThreshold: number;
  waterVolumeThreshold: number;
}
// 硬件光源设置响应接口
interface HardwareLightResponse {
  Brightness: number;
  Red: number;
  Green: number;
  Blue: number;
  LightDuration?: number;
  DeviceID?: string;
  status?: string;
}

// 硬件光源更新响应接口
interface HardwareLightUpdateResponse {
  status: string;
  Brightness: number;
  Red: number;
  Green: number;
  Blue: number;
  LightDuration: number;
  DeviceID: string;
}
// 目标灌溉量上传响应接口
interface TargetVolumeResponse {
  status: string;
  WaterVolumeTarget?: number;
  DeviceID?: string;
  message?: string;
}
// 硬件设备状态响应接口
interface HardwareStateResponse {
  WaterState: boolean;
  LightState: boolean;
  AirState: boolean;
  AutoModeState?: boolean;
  status?: string;
}

// 硬件指令响应接口
interface HardwareCommandResponse {
  status: string;
  WaterState: boolean;
  LightState: boolean;
  AirState: boolean;
  AutoModeState?: boolean;
  DeviceID: string;
}

// 设备配置响应接口（后端）
interface DeviceConfigResponse {
  electricity: string;
  waterVolume: string;
  deviceID: string;
}
// 设备信息接口
interface DeviceInfo {
  deviceId: string;
  ipAddress: string;
}



// 光源设置接口
interface LightSetting {
  brightness: number;        // 亮度 0-100（百分比）
  red: number;              // 红色分量 0-255
  green: number;            // 绿色分量 0-255
  blue: number;             // 蓝色分量 0-255
  lightDuration: number;    // 单次补光时长（分钟）
}

// 设备状态接口
interface DeviceState {
  waterState: boolean;      // 浇水状态
  lightState: boolean;      // 补光状态
  airState: boolean;        // 换气状态
  autoModeState: boolean;   // 自动模式状态
}

// 传感器数据接口（从后端获取）
interface SensorData {
  soilHumidity: number;     // 土壤湿度 (%)
  light: number;            // 光照强度 (lx)
  electricity: number;      // 电量百分比
  waterVolume: number;      // 水箱水量 (L)
}

// 后端配置信息接口
interface DeviceConfig {
  electricity: string;      // 电量百分比
  waterVolume: string;      // 水容量
  deviceID: string;         // 设备ID
}
// 云端传感器记录接口
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

// 云端数据响应接口
interface CloudDataResponse {
  success: boolean;
  count: number;
  data: Record<string, string>;  // 键为时间戳，值为JSON字符串
}
// ==================== 硬件接口服务类 ====================

interface GeneratedTypeLiteralInterface_2 {
  brightness: number;
  red: number;
  green: number;
  blue: number;
  startHour: number;
  startMinute: number;
  endHour: number;
  endMinute: number;
}

interface GeneratedTypeLiteralInterface_3 {
  Brightness: number;
  Red: number;
  Green: number;
  Blue: number;
  LightStartHour?: number;
  LightStartMinute?: number;
  LightEndHour?: number;
  LightEndMinute?: number;
}

class HardwareService {
  private deviceIp: string;
  private deviceId: string;

  constructor(deviceIp: string, deviceId: string) {
    this.deviceIp = deviceIp;
    this.deviceId = deviceId;
  }

  /**
   * 更新设备信息
   */
  updateDeviceInfo(deviceIp: string, deviceId: string): void {
    this.deviceIp = deviceIp;
    this.deviceId = deviceId;
  }
  /**
   * 【新增】获取阈值数据
   */
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


  /**
   * 获取光源设置
   */
  async fetchLightSetting(): Promise<LightSetting | null> {
    try {
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/light`;
      console.info('[硬件接口] 获取光源设置:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string)as HardwareLightResponse;
        httpRequest.destroy();
        return {
          brightness: data.Brightness,
          red: data.Red,
          green: data.Green,
          blue: data.Blue,
          lightDuration: data.LightDuration || 30
        };
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 获取光源设置失败:', JSON.stringify(error));
      return null;
    }
  }

  /**
   * 更新光源设置（亮度百分比自动转换）
   */
  async updateLightSetting(setting: LightSetting,startHour?:number,startMinute?:number,endHour?:number,endMinute?:number): Promise<boolean> {
    try {
      // brightness已经是百分比值（0-100），直接传递
      let formData = `Brightness=${setting.brightness}&Red=${setting.red}&Green=${setting.green}&Blue=${setting.blue}&LightDuration=${setting.lightDuration}`;

      // 如果传入了开始/结束时间，则添加到请求中
      if (startHour !== undefined && startMinute !== undefined) {
        formData += `&LightStartHour=${startHour}&LightStartMinute=${startMinute}`;
      }
      if (endHour !== undefined && endMinute !== undefined) {
        formData += `&LightEndHour=${endHour}&LightEndMinute=${endMinute}`;
      }
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
        const data = JSON.parse(response.result as string)as HardwareLightUpdateResponse;
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
  // ：获取完整光源设置（包含开始/结束时间）
  async fetchFullLightSetting(): Promise<GeneratedTypeLiteralInterface_2 | null> {
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
        const data = JSON.parse(response.result as string) as GeneratedTypeLiteralInterface_3;
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
  /**
   * 获取设备状态
   */
  async fetchDeviceState(): Promise<DeviceState | null> {
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
        const data = JSON.parse(response.result as string)as HardwareStateResponse;
        httpRequest.destroy();
        return {
          waterState: data.WaterState || false,
          lightState: data.LightState || false,
          airState: data.AirState || false,
          autoModeState: data.AutoModeState || false
        };
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 获取设备状态失败:', JSON.stringify(error));
      return null;
    }
  }

  /**
   * 发送控制指令
   */
  async sendCommand(command: string): Promise<DeviceState | null> {
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
        const data = JSON.parse(response.result as string)as HardwareCommandResponse;
        httpRequest.destroy();
        if (data.status === 'success') {
          return {
            waterState: data.WaterState,
            lightState: data.LightState,
            airState: data.AirState,
            autoModeState: data.AutoModeState || false
          };
        }
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[硬件接口] 发送指令失败:', JSON.stringify(error));
      return null;
    }
  }
}

// ==================== 后端云平台服务类 ====================

interface GeneratedTypeLiteralInterface_1 {
  soilHumidity: number;
  light: number;
}

class CloudService {
  private static readonly CONFIG_API_URL = 'https://guet-farm.netlify.app/.netlify/functions/cfg';
  // 获取设备配置信息（电量、水容量）
  async fetchDeviceConfig(deviceId: string): Promise<DeviceConfig | null> {
    try {
      const url = `${CloudService.CONFIG_API_URL}?deviceID=${deviceId}`;
      console.info('[云平台] 获取设备配置:', url);

      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as DeviceConfigResponse;
        httpRequest.destroy();
        return {
          electricity: data.electricity || '0%',
          waterVolume: data.waterVolume || '0L',
          deviceID: data.deviceID || deviceId
        };
      }
      httpRequest.destroy();
      return null;
    } catch (error) {
      console.error('[云平台] 获取设备配置失败:', JSON.stringify(error));
      return null;
    }
  }
 //获取土壤湿度和光照数据
  async fetchSoilAndLightData(): Promise<GeneratedTypeLiteralInterface_1 | null> {
    try {
      const url = 'https://guet-farm.netlify.app/.netlify/functions/getData';
      console.info('[云平台] 获取土壤湿度和光照数据:', url);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });
      console.info('[云平台] 响应状态码:', response.responseCode);
      console.info('[云平台] 响应原始数据:', response.result);
      if (response.responseCode !== 200) {
        console.error('[云平台] HTTP请求失败:', response.responseCode);
        httpRequest.destroy();
        return null;
      }
      // 检查响应内容是否为空
      if (!response.result || response.result === '') {
        console.error('[云平台] 响应内容为空');
        httpRequest.destroy();
        return null;
      }


      // 解析第一层JSON
     let outerData: CloudDataResponse;
      try {
        outerData = JSON.parse(response.result as string) as CloudDataResponse;
        console.info('[云平台] 第一层解析成功:', JSON.stringify(outerData));
      } catch (parseError) {
        console.error('[云平台] 第一层JSON解析失败:', parseError);
        console.error('[云平台] 原始响应:', response.result);
        httpRequest.destroy();
        return null;
      }

      // 检查outerData是否存在
      if (!outerData ||outerData.count === 0) {
        console.error('[云平台] outerData为null或undefined');
        httpRequest.destroy();
        return null;
      }

      // 检查success字段
      if (!outerData.success) {
        console.error('[云平台] API返回失败状态');
        httpRequest.destroy();
        return null;
      }
      if (!outerData.success || outerData.count === 0) {
        console.error('[云平台] 数据获取失败或无数据');
        return null;
      }

      // 获取最新的一条数据
      const keys = Object.keys(outerData.data).sort();
      console.info('[云平台] 数据键列表:', keys);
      if (keys.length === 0) {
        console.error('[云平台] 数据键列表为空');
        httpRequest.destroy();
        return null;
      }
      const latestKey = keys[keys.length - 1];
      const rawData = JSON.parse(outerData.data[latestKey]) as CloudSensorRecord;
      console.info('[云平台] 最新数据键:', latestKey);
      console.info('[云平台] 原始数据字符串:', rawData);

      // 解析数值（去掉单位）
      const parseValue = (str: string): number => {
        const match = str.match(/\d+(\.\d+)?/);
        return match ? parseFloat(match[0]) : 0;
      };

      const soilHumidity = parseValue(rawData.soil_humidity);
      const light = parseValue(rawData.light);

      console.log(`[云平台] 获取到数据: 土壤湿度=${soilHumidity}%, 光照=${light}lx, 时间=${rawData.date} ${rawData.time}`);

      return {
        soilHumidity: soilHumidity,
        light: light
      };
    } catch (error) {
      console.error('[云平台] 获取传感器数据失败:', JSON.stringify(error));
      return null;
    }
  }
  //解析电量百分比
  parseElectricity(electricityStr: string): number {
    const match = electricityStr.match(/\d+/);
    return match ? parseInt(match[0], 10) : 0;
  }
  /**
   * 解析水量数值
   */
  parseWaterVolume(volumeStr: string): number {
    const match = volumeStr.match(/\d+/);
    return match ? parseInt(match[0], 10) : 0;
  }
}


interface GeneratedObjectLiteralInterface_1 {
  isRunning: boolean;
  waterState: boolean;
  lightState: boolean;
}

@Entry
@Component
export struct Equipment {
  @State params: Record<string, Object> = {};
  @State selectedIndex: number = 1;

  // ==================== 设备信息 ====================
  @State deviceId: string = 'device_001';      // 设备ID
  @State deviceIp: string = '172.16.12.51';   // 设备IP地址
  @State isDeviceOn: boolean = true;           // 设备总开关状态（ON/OFF）
  // 加这一行！绝杀自动回变
  @State isManualToggle: boolean = false;
  // ==================== 服务实例 ====================
  private hardwareService: HardwareService = new HardwareService(this.deviceIp, this.deviceId);
  private cloudService: CloudService = new CloudService();
  // ==================== 阈值数据（全局唯一，初始化后不再修改）====================
  @State thresholds: ThresholdData = {
    co2Threshold: 800,
    soilTempThreshold: 35,
    soilHumidityThreshold: 60,    // 土壤湿度阈值，低于此值自动浇水
    lightThreshold: 500,          // 光照阈值，低于此值自动补光
    waterVolumeThreshold: 20      // 水箱水量阈值，低于此值通知补水
  };

  // ==================== 传感器数据（从后端实时获取）====================
  @State sensorData: SensorData = {
    soilHumidity: 0,      // 土壤湿度
    light: 0,             // 光照强度
    electricity: 0,       // 电量百分比
    waterVolume: 0        // 水箱水量(L)
  };

  // ==================== 设备状态 ====================
  @State deviceState: DeviceState = {
    waterState: false,      // 浇水状态
    lightState: false,      // 补光状态
    airState: false,        // 换气状态
    autoModeState: true     // 自动模式状态
  };

  @State isWaterOn: boolean = false;
  @State isLightOn: boolean = false;
  @State currentLED: number = 75;
  @State currentPour: number = 500;
  @State isInputEnable: boolean = true;
  @State currentColorValue: string = 'rgb(255, 255, 255)';
  // RGB 色值状态 (0-255)
  @State r: number = 255;
  @State g: number = 255;
  @State b: number = 255;

  // 输入框临时值（用于手动输入）
  @State rInput: string = '255';
  @State gInput: string = '255';
  @State bInput: string = '255';
  // UI显示数据
  @State electricityDisplay: string = '95%';    // 电量显示
  @State signalDisplay: string = '强(85%)';     // 信号显示
  @State waterVolumeDisplay: string = '120L';   // 水量显示
  @State totalElectricityUsed: number = 0;  // 累计用电量 (kWh)
  @State totalWaterUsed: number = 0;        // 累计用水量 (L)
  private totalUsagePreferences?: preferences.Preferences;
  private readonly TOTAL_USAGE_KEY: string = 'total_usage';
  private lastElectricity: number = 0;      // 上次记录的电量值
  private lastWaterVolume: number = 0;      // 上次记录的水量值
  // 定时器
  private sensorTimer: number = -1;      // 传感器数据定时器
  private autoControlTimer: number = -1; // 自动控制定时器
  private waterMonitorInterval: number = -1;    // 水量监控定时器

  // 防抖定时器
  private saveTimeout: number = -1;
  // 在 Equipment 组件内添加
  private globalStateService: GlobalStateService = GlobalStateService.getInstance();
  private isSyncingFromGlobal: boolean = false;
  // 计算实时颜色（总亮度 * RGB 色值）
  get currentColor():ResourceColor{
    return `rgb(${this.r}, ${this.g}, ${this.b})`;
  }
  // 灌溉开始时记录的水量
  private irrigationStartWaterVolume: number = 0;


  // 添加 TextInput 的控制器
  private textInputController: TextInputController = new TextInputController();

  async aboutToAppear(): Promise<void> {
    console.log('========== aboutToAppear 开始 ==========');
    // 初始化累加数据存储
    await this.initTotalUsageStorage();

    // 先打印当前全局状态
    const currentGlobal = this.globalStateService.getState();
    console.log('当前全局状态 isDeviceOn:', currentGlobal.isDeviceOn);
    console.log('测试硬件连接...');
    console.log('接收的数据',JSON.stringify(this.params));
    // 获取设备信息
    if (this.params['deviceId']) {
      this.deviceId = this.params['deviceId'] as string;
    }
    if (this.params['ipAddress']) {
      this.deviceIp = this.params['ipAddress'] as string;
    }
    console.log(`设备IP: ${this.deviceIp}, 设备ID: ${this.deviceId}`);
    // ：从全局状态加载
    await this.loadStateFromGlobal();
    // ：监听全局状态变化
    this.listenToGlobalChanges();

    // 初始化硬件服务
    this.hardwareService.updateDeviceInfo(this.deviceIp, this.deviceId);
    // 更新全局设备信息
    await this.globalStateService.updateDeviceInfo(this.deviceId, this.deviceIp);


    // 初始化阈值（从硬件获取，设置后不再修改）
   await this.initThresholds();

    // 加载传感器数据
   await this.loadSensorData();
    const result = await this.hardwareService.fetchLightSetting();
    if (result) {
      console.log('硬件连接正常:', result);
    } else {
      console.error('硬件连接失败');
    }
    // 启动定时器：每10秒获取一次传感器数据
    this.sensorTimer = setInterval(() => {
      if (this.isManualToggle) return;
      this.loadSensorData();
    }, 10000);
  }
  aboutToDisappear(): void {
    // 清理定时器
    if (this.sensorTimer !== -1) clearInterval(this.sensorTimer);
    if (this.autoControlTimer !== -1) clearInterval(this.autoControlTimer);
    if (this.saveTimeout !== -1) clearTimeout(this.saveTimeout);
  }
  /**
   * 初始化累加数据存储
   */
  async initTotalUsageStorage(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) {
        console.error('获取Context失败');
        return;
      }
      this.totalUsagePreferences = await preferences.getPreferences(context, 'total_usage_prefs');

      // 读取已累加的用电量和用水量
      const savedElectricity = await this.totalUsagePreferences.get('total_electricity', 0) as number;
      const savedWater = await this.totalUsagePreferences.get('total_water', 0) as number;

      this.totalElectricityUsed = savedElectricity;
      this.totalWaterUsed = savedWater;

      console.log(`累计用电量: ${this.totalElectricityUsed} kWh, 累计用水量: ${this.totalWaterUsed} L`);
    } catch (error) {
      console.error('初始化累加存储失败:', error);
    }
  }

  /**
   * 保存累加数据到本地
   */
  async saveTotalUsage(): Promise<void> {
    if (!this.totalUsagePreferences) return;
    try {
      await this.totalUsagePreferences.put('total_electricity', this.totalElectricityUsed);
      await this.totalUsagePreferences.put('total_water', this.totalWaterUsed);
      await this.totalUsagePreferences.flush();
      console.log(`保存累加数据: 用电=${this.totalElectricityUsed} kWh, 用水=${this.totalWaterUsed} L`);
    } catch (error) {
      console.error('保存累加数据失败:', error);
    }
  }

  /**
   * 更新累加用电量和用水量
   * @param currentElectricity 当前电量百分比
   * @param currentWaterVolume 当前水量(L)
   */
  async updateTotalUsage(currentElectricity: number, currentWaterVolume: number): Promise<void> {
    // 首次记录，只保存当前值，不累加
    if (this.lastElectricity === 0 && this.lastWaterVolume === 0) {
      this.lastElectricity = currentElectricity;
      this.lastWaterVolume = currentWaterVolume;
      console.log(`首次记录: 电量=${this.lastElectricity}%, 水量=${this.lastWaterVolume}L`);
      return;
    }

    // 计算减少的电量（电量百分比差值，累加时按1% = 0.1 kWh估算，可根据实际情况调整）
    const electricityDecrease = this.lastElectricity - currentElectricity;
    if (electricityDecrease > 0) {
      // 假设每1%电量对应0.1 kWh用电量（可根据实际硬件参数调整）
      const electricityUsedKwh = electricityDecrease * 0.1;
      this.totalElectricityUsed += electricityUsedKwh;
      console.log(`用电量增加: ${electricityUsedKwh.toFixed(2)} kWh, 累计: ${this.totalElectricityUsed.toFixed(2)} kWh`);
    }

    // 计算减少的水量
    const waterDecrease = this.lastWaterVolume - currentWaterVolume;
    if (waterDecrease > 0) {
      this.totalWaterUsed += waterDecrease;
      console.log(`用水量增加: ${waterDecrease} L, 累计: ${this.totalWaterUsed} L`);
    }

    // 更新上次记录值
    this.lastElectricity = currentElectricity;
    this.lastWaterVolume = currentWaterVolume;

    // 保存到本地
    await this.saveTotalUsage();
  }
  /**
   * 初始化阈值（从硬件获取，全局唯一，不再修改）
   */
  async initThresholds(): Promise<void> {
    try {
      const thresholds = await this.hardwareService.fetchThresholds();
      if (thresholds) {
        // 手动赋值
        this.thresholds.co2Threshold = thresholds.co2Threshold;
        this.thresholds.soilTempThreshold = thresholds.soilTempThreshold;
        this.thresholds.soilHumidityThreshold = thresholds.soilHumidityThreshold;
        this.thresholds.lightThreshold = thresholds.lightThreshold;
        this.thresholds.waterVolumeThreshold = thresholds.waterVolumeThreshold;

        // 同步到全局
        await this.globalStateService.updateThresholds({
          "co2Threshold": thresholds.co2Threshold,
          "soilTempThreshold": thresholds.soilTempThreshold,
          "soilHumidityThreshold": thresholds.soilHumidityThreshold,
          "lightThreshold": thresholds.lightThreshold,
          "waterVolumeThreshold": thresholds.waterVolumeThreshold
        });
        console.log('从硬件获取阈值成功:', this.thresholds);
      } else {
        console.log('使用默认阈值:', this.thresholds);
      }
    } catch (error) {
      console.error('获取阈值失败，使用默认值:', error);
    }
  }


  /**
   * 加载传感器数据（从后端获取）
   */
  async loadSensorData(): Promise<void> {
    try {
      // 获取设备配置（电量、水量）
      const config = await this.cloudService.fetchDeviceConfig(this.deviceId);
      if (config) {
        const newElectricity = this.cloudService.parseElectricity(config.electricity);
        const newWaterVolume = this.cloudService.parseWaterVolume(config.waterVolume);

        // 更新累加数据（在更新UI之前）
        await this.updateTotalUsage(newElectricity, newWaterVolume);

        // 更新电量显示
        this.sensorData.electricity = this.cloudService.parseElectricity(config.electricity);
        this.electricityDisplay = config.electricity;
        // 更新水量显示
        this.sensorData.waterVolume = newWaterVolume;
        this.waterVolumeDisplay = config.waterVolume;

        console.log(`传感器数据: 电量=${config.electricity}, 水量=${config.waterVolume}`);

        console.log(`当前水容量=${newWaterVolume}L, 目标灌溉量=${this.currentPour}L`);
        // 同步传感器数据到全局
        await this.globalStateService.updateSensorData({
          "electricity": this.sensorData.electricity,
          "waterVolume": this.sensorData.waterVolume
        });
      }


      // 获取土壤湿度和光照数据
      const soilAndLight = await this.cloudService.fetchSoilAndLightData();
      if (soilAndLight) {
        this.sensorData.soilHumidity = soilAndLight.soilHumidity;
        this.sensorData.light = soilAndLight.light;
        console.log(`土壤湿度=${soilAndLight.soilHumidity}%, 光照=${soilAndLight.light}lx`);
        //同步传感器数据到全局
        await this.globalStateService.updateSensorData({
          "soilHumidity": this.sensorData.soilHumidity,
          "light": this.sensorData.light
        });
      }
    } catch (error) {
      console.error('加载传感器数据失败:', error);
    }
  }
  // 从全局状态加载（不使用展开运算符）
  private async loadStateFromGlobal(): Promise<void> {
    this.isSyncingFromGlobal = true;

    const globalState = this.globalStateService.getState();

    this.isDeviceOn = globalState.isDeviceOn;
    this.isWaterOn = globalState.isWaterOn;
    this.currentPour = globalState.targetWaterVolume;

    this.isLightOn = globalState.lightSetting.isLightOn;
    this.currentLED = globalState.lightSetting.brightness;
    this.r = globalState.lightSetting.red;
    this.g = globalState.lightSetting.green;
    this.b = globalState.lightSetting.blue;

    // 手动赋值 deviceState，不使用展开运算符
    this.deviceState.waterState = globalState.deviceState.waterState;
    this.deviceState.lightState = globalState.deviceState.lightState;
    this.deviceState.airState = globalState.deviceState.airState;
    this.deviceState.autoModeState = globalState.deviceState.autoModeState;

    // 手动赋值 sensorData，不使用展开运算符
    this.sensorData.soilHumidity = globalState.sensorData.soilHumidity;
    this.sensorData.light = globalState.sensorData.light;
    this.sensorData.electricity = globalState.sensorData.electricity;
    this.sensorData.waterVolume = globalState.sensorData.waterVolume;

    this.electricityDisplay = `${globalState.sensorData.electricity}%`;
    this.waterVolumeDisplay = `${globalState.sensorData.waterVolume}L`;

    this.rInput = this.r.toString();
    this.gInput = this.g.toString();
    this.bInput = this.b.toString();

    this.updateColor();

    this.isSyncingFromGlobal = false;

    console.log('[Equipment] 从全局状态加载完成');
  }

  // 监听全局状态变化（不使用展开运算符）
  private listenToGlobalChanges(): void {
    this.globalStateService.addListener((newState: GlobalState) => {
      // 原有开关同步
      this.isDeviceOn = newState.isDeviceOn;

      console.log('[Equipment] 收到全局状态变化');

      this.isSyncingFromGlobal = true;
      this.isDeviceOn = newState.isDeviceOn;

      this.isWaterOn = newState.isWaterOn;
      this.currentPour = newState.targetWaterVolume;
      this.isLightOn = newState.lightSetting.isLightOn;
      this.currentLED = newState.lightSetting.brightness;
      if (newState.lightSetting) {
      this.r = newState.lightSetting.red;
      this.g = newState.lightSetting.green;
      this.b = newState.lightSetting.blue;
      this.rInput = this.r.toString();
      this.gInput = this.g.toString();
      this.bInput = this.b.toString();
      this.updateColor();
    }
      // 手动赋值 deviceState
      this.deviceState.waterState = newState.deviceState.waterState;
      this.deviceState.lightState = newState.deviceState.lightState;
      this.deviceState.airState = newState.deviceState.airState;
      this.deviceState.autoModeState = newState.deviceState.autoModeState;

      // 手动赋值 sensorData
      this.sensorData.soilHumidity = newState.sensorData.soilHumidity;
      this.sensorData.light = newState.sensorData.light;
      this.sensorData.electricity = newState.sensorData.electricity;
      this.sensorData.waterVolume = newState.sensorData.waterVolume;



      this.isSyncingFromGlobal = false;
    });
  }

  async toggleDeviceOnOff(): Promise<void> {

    // 手动点击了开关 → 锁定状态！定时器绝对不能改！
    this.isManualToggle = true;
    // 直接取反，强制修改本地+全局，不接受任何覆盖
    const newState = !this.isDeviceOn;
    this.isDeviceOn = newState;

    // 同步全局（仪表盘立刻更新）
    await this.globalStateService.updateState({ "isDeviceOn": newState});
    // 3. 执行硬件指令
    if (!newState) {
      // 关闭：直接关所有，彻底停止
      await this.hardwareService.sendCommand('water-off');
      await this.hardwareService.sendCommand('light-off');
      await this.hardwareService.sendCommand('Auto-off');
      this.isWaterOn = false;
      this.isLightOn = false;
      this.showToast('设备已关闭');
    } else {
      // 开启
      await this.hardwareService.sendCommand('Auto');
      this.showToast('设备已开启');
    }
    // 3秒后解锁（防止误操作，不影响正常使用）
    setTimeout(() => {
      this.isManualToggle = false;
    }, 3000);
  }

  // ==================== 水泵控制逻辑 ====================
  /**
   * 上传目标灌溉量到硬件
   */
  async uploadTargetWaterVolume(volume: number): Promise<boolean> {
    try {
      const url = `http://${this.deviceIp}/.netlify/functions/device/${this.deviceId}/targets`;
      const formData = `WaterVolume=${volume}`;
      console.info('[硬件接口] 上传目标灌溉量:', url, formData);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/x-www-form-urlencoded' },
        extraData: formData,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as TargetVolumeResponse;
        httpRequest.destroy();
        if (data.status === 'success') {
          console.log(`目标灌溉量上传成功: ${volume}L`);
          return true;
        } else {
          console.error('目标灌溉量上传失败:', data.message);
          return false;
        }
      }
      httpRequest.destroy();
      return false;
    } catch (error) {
      console.error('[硬件接口] 上传目标灌溉量失败:', JSON.stringify(error));
      return false;
    }
  }
  /**
   * 手动控制浇水开关
   * 开启前检查：目标灌溉量不能超过当前水容量
   */
  async toggleWater(isOn: boolean): Promise<void> {
    if (!this.isDeviceOn) {
      this.showToast('请先开启设备');
      this.isWaterOn = false;
      return;
    }

    // 开启水泵前的检查
    if (isOn) {
      if (this.currentPour <= 0) {
        this.showToast('请先设置有效的目标灌溉量（大于0L）');
        this.isWaterOn = false;
        return;
      }

      if (this.currentPour > this.sensorData.waterVolume) {
        this.showToast(`水量不足！当前水容量仅剩${this.sensorData.waterVolume}L，目标灌溉量${this.currentPour}L无法完成`);
        this.isWaterOn = false;
        return;
      }
      // 上传目标灌溉量到硬件
      const uploadSuccess = await this.uploadTargetWaterVolume(this.currentPour);
      if (!uploadSuccess) {
        this.showToast('目标灌溉量上传失败，请检查网络');
        this.isWaterOn = false;
        return;
      }
      // 记录开始灌溉时的水量
      this.irrigationStartWaterVolume = this.sensorData.waterVolume;
      console.log(`[灌溉开始] 当前水容量=${this.sensorData.waterVolume}L，目标灌溉量=${this.currentPour}L`);

      // 启动水量监控
      this.startWaterMonitoring();
    }

    const cmd = isOn ? 'water' : 'water-off';
    const result = await this.hardwareService.sendCommand(cmd);
    if (result) {
      this.deviceState.waterState = result.waterState;
      this.isWaterOn = result.waterState;
      this.showToast(isOn ? '浇水已开启' : '浇水已关闭');
    }
    // 同步到全局状态
    await this.globalStateService.updateWaterState(this.isWaterOn);
    await this.globalStateService.updateDeviceState({ "waterState": this.isWaterOn });
  }

  /**
   * 启动水量监控（每秒检查一次）
   * 当已用水量达到目标灌溉量时，自动关闭水泵
   */
  private startWaterMonitoring(): void {
    if (this.waterMonitorInterval !== -1) {
      clearInterval(this.waterMonitorInterval);
    }

    this.waterMonitorInterval = setInterval(async () => {
      const config = await this.cloudService.fetchDeviceConfig(this.deviceId);
      if (config && this.isWaterOn) {
        const currentWater = this.cloudService.parseWaterVolume(config.waterVolume);
        this.sensorData.waterVolume = currentWater;
        this.waterVolumeDisplay = config.waterVolume;

        const usedWater = this.irrigationStartWaterVolume - currentWater;
        console.log(`[水量监控] 起始=${this.irrigationStartWaterVolume}L, 当前=${currentWater}L, 已用=${usedWater}L, 目标=${this.currentPour}L`);

        if (usedWater >= this.currentPour) {
          console.log(`✅ 已达到目标灌溉量${this.currentPour}L，自动关闭水泵`);
          await this.forceStopWater();
          if (this.waterMonitorInterval !== -1) {
            clearInterval(this.waterMonitorInterval);
            this.waterMonitorInterval = -1;
          }
        }
      }
    }, 1000);
  }

  /**
   * 强制关闭水泵
   */
  private async forceStopWater(): Promise<void> {
    if (this.isWaterOn || this.deviceState.waterState) {
      const result = await this.hardwareService.sendCommand('water-off');
      if (result) {
        this.deviceState.waterState = result.waterState;
        this.isWaterOn = result.waterState;
        this.showToast('灌溉完成，水泵已自动关闭');
      }
    }
  }

  /**
   * 目标灌溉量变化时的验证
   */
  onTargetIrrigationChange(value: number): void {
    this.currentPour = value;
    if (this.currentPour > this.sensorData.waterVolume && this.sensorData.waterVolume > 0) {
      this.showNotification(`⚠️ 目标灌溉量${this.currentPour}L超过当前水容量${this.sensorData.waterVolume}L`);
    }
  }


  /**
   * 手动控制补光开关
   */
  async toggleLight(isOn: boolean): Promise<void> {
    if (!this.isDeviceOn) {
      this.showToast('请先开启设备');
      this.isLightOn = false;
      return;
    }
    //  关键修复：如果是开启补光灯，先保存当前的亮度/RGB设置到硬件
    if (isOn) {
      console.log('[补光] 开启前保存亮度/RGB设置');
      await this.saveLightSetting();
    }
    const cmd = isOn ? 'light' : 'light-off';
    const result = await this.hardwareService.sendCommand(cmd);
    if (result) {
      this.deviceState.lightState = result.lightState;
      this.isLightOn = result.lightState;
      this.updateColor();
      this.showToast(isOn ? '补光已开启' : '补光已关闭');
    }
    // 同步到全局状态
    await this.globalStateService.updateLightSetting(
      this.currentLED,
      this.r,
      this.g,
      this.b,
      this.isLightOn
    );
    await this.globalStateService.updateDeviceState({ "lightState": this.isLightOn });
  }





  /**
   * 保存补光设置到硬件
   */
  async saveLightSetting(): Promise<void> {
    console.log('========== saveLightSetting 被调用 ==========');
    console.log(`当前值: 亮度=${this.currentLED}%, RGB=(${this.r},${this.g},${this.b})`);
    // 同步到全局状态
    await this.globalStateService.updateLightSetting(
      this.currentLED,
      this.r,
      this.g,
      this.b,
      this.isLightOn);
    if (!this.isDeviceOn) {
      console.log('设备未开启，不保存补光设置');
      return;
    }

    const setting: LightSetting = {
      brightness: this.currentLED,
      red: this.r,
      green: this.g,
      blue: this.b,
      lightDuration: 30
    };

    const success = await this.hardwareService.updateLightSetting(setting);
    if (success) {
      console.log(`补光设置已保存: 亮度=${this.currentLED}%, RGB=(${this.r},${this.g},${this.b})`);
    } else {
      console.error('保存补光设置失败');
    }
  }


  // ==================== UI更新方法 ====================



  /**
   * 显示全局通知
   */
  showNotification(message: string): void {
    console.warn('全局通知:', message);
    promptAction.openToast({
      message: message,
      duration: 3000
    });
  }

  /**
   * 显示提示信息
   */
  private showToast(message: string): void {
    promptAction.openToast({
      message: message,
      duration: 2000
    });
  }
  // 添加一个方法来更新颜色
  updateColor() {
    this.currentColorValue = `rgb(${this.r}, ${this.g}, ${this.b})`;
    console.log(`颜色更新: ${this.currentColorValue}, 亮度=${this.currentLED}%`);
  }
  // 输入框校验 & 同步
  private syncRGBValue(input: string, setter: (val: number) => void, currentVal: number,inputSetter?: (val: string) => void): void {
    const num = parseInt(input, 10);
    if (!isNaN(num) && num >= 0 && num <= 255) {
      setter(num);
      if (inputSetter) {
        inputSetter(num.toString());  // 有效时更新输入框显示
      }
      this.updateColor();
      if (this.saveTimeout !== -1) clearTimeout(this.saveTimeout);
      this.saveTimeout = setTimeout(() => {
        this.saveLightSetting();
      }, 500);
    } else {
      // 非法值回滚
      setter(currentVal);
      if (inputSetter) {
        inputSetter(currentVal.toString());  // 无效时恢复输入框显示
      }
      // 提示用户输入无效
      promptAction.openToast({
        message: '请输入0-255之间的数字',
        duration: 2000
      });
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Row() {
            Row({ space: 10 }) {
              Image($r('app.media.ON'))
                .width('20vp')
                .fillColor(this.isDeviceOn ? '#13EC5B' : '#FF4444')
              Text(this.isDeviceOn ? 'ON' : 'OFF')
                .fontSize('20vp')
                .fontColor(this.isDeviceOn ? '#13EC5B' : '#FF4444')
                .fontWeight(FontWeight.Bold)

            }
            .backgroundColor(this.isDeviceOn ? '#1a13ec5b' : '#1aff4444')
            .padding(6)
            .borderRadius(25)
            .border({
              color: this.isDeviceOn ? '#3313ec5b' : '#33ff4444',
              width: 2
            })
            .margin({ left: 10 })
            .onClick(() => {
              this.toggleDeviceOnOff();
            })

            Text('设备管理')
              .fontWeight(FontWeight.Bold)
              .fontSize('25vp')
              .position({ x: '50%' })
              .translate({ x: '-50%' })
              .margin({ top: 6 })

            Image($r('app.media.add'))
              .width('36vp')
              .padding(7)
              .backgroundColor('#3313ec5b')
              .borderRadius(18)
              .margin({ right: 20 })
              .onClick(() => {
                console.log('跳转到添加设备页面');
                NavigationManager.getInstance().push('Add', { from: Equipment })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Scroll() {
            Column() {
              Row({ space: 20 }) {
                this.rowCard('app.media.electric', '用电量',  this.totalElectricityUsed.toFixed(1), 'kWh')
                this.rowCard('app.media.water', '用水量',  this.totalWaterUsed.toString(), 'L')
              }.margin({top:10})

              Text('控制中心')
                .fontWeight(FontWeight.Bold)
                .fontSize('20vp')
                .width('100%')
                .padding({ left: 20, top: 20, bottom: 20 })
              Row() {
                Image($r('app.media.water'))
                  .fillColor('#13EC5B')
                  .width('45vp')
                  .height('45vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(12)
                  .margin({ left: 16 })
                Column() {
                  Text('智能水阀').fontWeight(FontWeight.Bold).fontSize('18vp')
                  Text(this.isWaterOn ? '状态:运行中' : '状态:已停止')
                    .fontColor(this.isWaterOn ? '#13EC5B' : '#334155').fontSize('13vp')
                }
                .margin({ left: 20 })

                Blank()
                Image($r('app.media.next'))
                  .width('32vp')
                  .height('32vp')
                  .borderRadius(16)
                  .padding(8)
                  .backgroundColor('#3313ec5b')
                  .objectFit(ImageFit.Contain)
                  .margin({ right: 16 })
                  .onClick(()=>{
                    NavigationManager.getInstance().push('Lrrigate',{from:Equipment})
                  })

              }
              .width('95%')
              .height('75vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Row() {
                Image($r('app.media.fans'))
                  .fillColor('#13EC5B')
                  .width('45vp')
                  .height('45vp')
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#3313ec5b')
                  .padding(10)
                  .borderRadius(12)
                  .margin({ left: 16 })
                Column() {
                  Text('高效水泵').fontWeight(FontWeight.Bold).fontSize('18vp')
                  Row({ space: 20 }) {
                    Text('功率:450w').fontColor('#94A3B8').fontSize('13vp')
                    Text('流量:12L/M').fontColor('#94A3B8').fontSize('13vp')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 20 })

                Blank()
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.isWaterOn
                })
                  .margin({ right: 15 })
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((isOn: boolean) => {
                    this.isWaterOn = isOn;
                    this.toggleWater(isOn);
                    console.log('开关：', isOn);
                  })

              }
              .width('95%')
              .height('75vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Column() {
                Row() {
                  Image($r('app.media.sun'))
                    .fillColor('#13EC5B')
                    .width('45vp')
                    .height('45vp')
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#3313ec5b')
                    .padding(10)
                    .borderRadius(12)
                    .margin({ left: 16 })
                  Column() {
                    Text('LED补光灯').fontWeight(FontWeight.Bold).fontSize('18vp')
                    Text(`亮度:${this.currentLED}%`).fontSize('13vp').fontColor('#94A3B8')

                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 20 })

                  Blank()
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.isLightOn,
                  })
                    .margin({ right: 15 })
                    .width('48vp')
                    .height('30vp')
                    .selectedColor('#13EC5B')
                    .onChange(async (isOn: boolean) => {
                      await this.toggleLight(isOn);
                      console.log('开关：', isOn);
                    })
                }
                .width('100%')
                .margin({ top: 15 })

                Slider({
                  value: this.currentLED,
                  min: 0,
                  max: 100,
                  step: 1
                })
                  .width('90%')
                  .height(8)
                  .backgroundColor('#E2E8F0')
                  .trackColor('#E2E8F0')
                  .selectedColor('#E2E8F0')
                  .blockColor('#13EC5B')
                  .blockBorderColor(Color.White)
                  .blockBorderWidth(3)
                  .borderRadius(16)
                  .margin({ top: 10, bottom: 10 })
                  .onChange((value: number) => {
                    this.currentLED = value;
                    if (value > 0 && !this.isLightOn) {
                      this.isLightOn = true;
                    }
                    this.updateColor();
                    if (this.saveTimeout !== -1) clearTimeout(this.saveTimeout);
                    this.saveTimeout = setTimeout(() => {
                      this.saveLightSetting();
                    }, 500);
                  })




                Row() {
                  Text('0%').fontColor('#94A3B8').fontSize('12vp').fontWeight(FontWeight.Bold)
                  Blank()
                  Text('100%').fontColor('#94A3B8').fontSize('12vp').fontWeight(FontWeight.Bold)
                }
                .width('90%')

                Rect()
                  .width('90%')
                  .height('100vp')
                  .radius(20)
                  .fill(this.currentColorValue)
                  .margin({top:20})

                Row({space:20}) {
                  // R 通道
                  this.buildRGBChannel('R', '#ef4444', this.r, this.rInput, (val) => {
                    console.log('Setting R:', val);
                    this.r = val;
                    this.rInput = val.toString(); // 输入框实时跟随滑块
                    this.updateColor();
                    // 防抖保存
                    if (this.saveTimeout !== -1) clearTimeout(this.saveTimeout);
                    this.saveTimeout = setTimeout(() => {
                      this.saveLightSetting();
                    }, 500);
                  }, (val) => {
                    console.log('R input raw:', val);
                    this.rInput = val;
                    const num = parseInt(val, 10);
                    if (!isNaN(num) && num >= 0 && num <= 255) {
                      this.r = num;
                      this.rInput = num.toString(); // 强制同步输入框显示（核心修复）
                      this.updateColor();
                    }
                    // 删掉干扰的 syncRGBValue
                  })

                  // G 通道
                  this.buildRGBChannel('G', '#22c55e', this.g, this.gInput, (val) => {
                    console.log('Setting G:', val);
                    this.g = val;
                    this.gInput = val.toString(); // 输入框实时跟随滑块
                    this.updateColor();
                    if (this.saveTimeout !== -1) clearTimeout(this.saveTimeout);
                    this.saveTimeout = setTimeout(() => {
                      this.saveLightSetting();
                    }, 500);
                  }, (val) => {
                    console.log('G input raw:', val);
                    this.gInput = val;
                    const num = parseInt(val, 10);
                    if (!isNaN(num) && num >= 0 && num <= 255) {
                      this.g = num;
                      this.gInput = num.toString(); // 强制同步输入框显示（核心修复）
                      this.updateColor();
                    }
                    // 删掉干扰的 syncRGBValue
                  })

                  // B 通道
                  this.buildRGBChannel('B', '#3b82f6', this.b, this.bInput, (val) => {
                    console.log('Setting B:', val);
                    this.b = val;
                    this.bInput = val.toString(); // 输入框实时跟随滑块
                    this.updateColor()
                    if (this.saveTimeout !== -1) clearTimeout(this.saveTimeout);
                    this.saveTimeout = setTimeout(() => {
                      this.saveLightSetting();
                    }, 500);
                  }, (val) => {
                    console.log('B input raw:', val);
                    this.bInput = val;
                    const num = parseInt(val, 10);
                    if (!isNaN(num) && num >= 0 && num <= 255) {
                      this.b = num;
                      this.bInput = num.toString(); // 强制同步输入框显示（核心修复）
                      this.updateColor();
                    }
                    // 删掉干扰的 syncRGBValue
                  })
                }
                .width('95%')
                .margin(20)

              }
              .width('95%')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Column() {
                Row() {
                  Image($r('app.media.tongji'))
                    .width('22vp')
                    .fillColor('#13EC5B')
                    .margin({ left: 5, right: 10 })
                  Text('目标灌溉量')
                    .fontWeight(FontWeight.Bold).fontSize('18vp')
                  Blank()

                  TextInput({
                    text: this.currentPour.toString(),
                    controller: this.textInputController  // 绑定控制器
                  })
                    .type(InputType.Number)
                    .fontSize('15vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#13EC5B')
                    .width('60vp')
                    .padding({ left: 12, right: 12 })
                    .backgroundColor('#3313ec5b')
                    .borderRadius(20)
                    .onChange((val) => {
                      let num = Number(val);
                      if (!isNaN(num) && num >= 0 && num <= 1000) {
                        this.currentPour = num;
                      }
                      this.isInputEnable = false;
                      setTimeout(() => {
                        this.isInputEnable = true;
                      }, 10);
                    })
                    // 添加失去焦点事件
                    .onBlur(() => {
                      console.log('TextInput失去焦点，当前值:', this.currentPour);
                    })

                }.width('90%')
                .margin({ top: 15 })

                Slider({
                  value: this.currentPour,
                  min: 0,
                  max: 1000,
                  step: 1
                })
                  .width('90%')
                  .height(8)
                  .backgroundColor('#E2E8F0')
                  .trackColor('#E2E8F0')
                  .selectedColor('#E2E8F0')
                  .blockColor('#13EC5B')
                  .blockBorderColor(Color.White)
                  .blockBorderWidth(3)
                  .borderRadius(16)
                  .onChange(async (value: number) => {
                    this.currentPour = value;
                    await this.globalStateService.updateWaterState(this.isWaterOn, this.currentPour);
                  })
                  .margin({ top: 15 })

                Row() {
                  Text('0L')
                    .fontSize('12vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#94A3B8')
                  Blank()
                  Text('1000L')
                    .fontSize('12vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#94A3B8')
                }
                .width('90%')
                .margin({ top: 10 })

              }
              .width('95%')
              .height('110vp')
              .borderRadius(20)
              .shadow({
                radius: 15,
                color: 'rgba(0, 0, 0, 0.1)',
                offsetX: 0,
                offsetY: 6
              })
              .margin({ bottom: 16 })

              Row({space:10}) {
                this.endCard('app.media.xinhao','信号','强(85%)')
                this.endCard('app.media.battery', '电量', this.electricityDisplay)

              }



            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#80f1f5f9')
          .flexShrink(0)
          .scrollBar(BarState.Off)

          Tabs({ barPosition: BarPosition.End ,index:this.selectedIndex}) {
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
            if (index === 2) {
              NavigationManager.getInstance().push('Count', { from: Equipment })
            }
            if (index === 3) {
              NavigationManager.getInstance().push('Setting', { from: Equipment })
            }
          })
          .animationDuration(0)

        }
      }
      .onClick(() => {
        // 点击空白区域时，清除 TextInput 的焦点
        this.textInputController.stopEditing();
        this.isInputEnable = false;
        setTimeout(() => {
          this.isInputEnable = true;
        }, 20);
      })
    }.hideTitleBar(true)
  }
  @Builder
  endCard(img:string,title:string,text:string){
    Row({space:15}) {
      Image($r(img))
        .width('20vp')
        .margin({left:20})
      Column(){
        Text(title).fontWeight(FontWeight.Bold).fontColor('#64748B')
        Text(text).fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Start)

    }
    .width('165vp')
    .height('80vp')
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 16 })
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

  @Builder
  rowCard(img: string, title: string, num: string, unit: string) {
    Column() {
      Row({ space: 7 }) {
        Image($r(img))
          .width('20vp')
        Text(title)
          .fontSize('16vp')
          .fontColor('#64748B')
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding({ left: 20, top: 20 })

      Row({ space: 6 }) {
        Text(num)
          .fontWeight(FontWeight.Bold)
          .fontSize('20vp')
        Text(unit)
          .fontColor('#94A3B8')
          .fontSize('15vp')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 20, top: 15 })
    }
    .width('160vp')
    .height('100vp')
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 6
    })
  }
  @Builder
  buildRGBChannel(
    label: string,
    color: ResourceColor,
    value: number,
    inputValue: string,
    onSliderChange: (val: number) => void,
    onInputChange: (val: string) => void
  ) {
    Column({ space: 8}) {
      // 标签
      Text(label)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ bottom: 4 })

      // 滑块
      Slider({
        value: value,
        min: 0,
        max: 255,
        step: 1
      })
        .width('100%')
        .height(10)
        .blockColor('#22c55e')
        .selectedColor(Color.Transparent)
        .trackColor('#e5e7eb')
        .onChange((val: number) => {
          onSliderChange(val);  // 触发更新
          console.log(`${label} slider: ${val}`);
        })

      // 0 / 255 标注
      Row() {
        Text('0')
          .fontSize(18)
          .fontColor('#9ca3af')
        Text('255')
          .fontSize(18)
          .fontColor('#9ca3af')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 输入框
      TextInput({ text: inputValue, placeholder: '0-255' })
        .width('100%')
        .height(45)
        .borderRadius(12)
        .border({ width: 1, color: '#d1d5db' })
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .type(InputType.Number)
        .onChange((val: string) => {
          console.log(`${label} input change: ${val}`);
          onInputChange(val);  // 触发输入变化
          const num = parseInt(val, 10);
          if (!isNaN(num) && num >= 0 && num <= 255) {
            onSliderChange(num);  // 同时更新RGB值
          }
        })
        .onSubmit(() => {
          const num = parseInt(inputValue, 10);
          if (!isNaN(num) && num >= 0 && num <= 255) {
            onSliderChange(num);
          } else {
            // 如果无效，恢复为当前RGB值
            onSliderChange(value);
          }
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width('30%')
  }
}