import { NavigationManager } from '../common/NavigationManager';
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
// 活动日志接口
interface ActivityLog {
  id: string;           // 唯一标识
  content: string;      // 日志内容
  time: string;         // 时间戳
  dotColor: string;     // 圆点颜色（#3B82F6=蓝色正常, #F59E0B=黄色异常）
  timestamp: number;    // 用于排序的时间戳
}
// 日志项接口
interface LogItem {
  content: string;
  time: string;
  dotColor: string;
}

// 云端传感器数据响应接口
interface CloudDataResponse {
  success: boolean;
  count: number;
  data: Record<string, string>;
}
// 硬件更新阈值响应接口
interface HardwareUpdateThresholdsResponse {
  status: string;
  Co2Threshold?: number;
  SoilTempThreshold?: number;
  SoilHumidityThreshold?: number;
  LightThreshold?: number;
  WaterVolume?: number;
  DeviceID?: string;
}

// 硬件更新目标值响应接口
interface HardwareUpdateTargetsResponse {
  status: string;
  Co2Target?: number;
  SoilTempTarget?: number;
  SoilHumidityTarget?: number;
  DeviceID?: string;
}

// 硬件更新光源响应接口
interface HardwareUpdateLightResponse {
  status: string;
  Brightness?: number;
  Red?: number;
  Green?: number;
  Blue?: number;
  LightDuration?: number;
  DeviceID?: string;
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

// 硬件阈值响应接口
interface HardwareThresholdsResponse {
  Co2Threshold: number;
  SoilTempThreshold: number;
  SoilHumidityThreshold: number;
  LightThreshold: number;
  WaterVolume: number;
  DeviceID: string;
}

// 硬件目标值响应接口
interface HardwareTargetsResponse {
  Co2Target: number;
  SoilTempTarget: number;
  SoilHumidityTarget: number;
  DeviceID: string;
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

// 阈值数据接口
interface ThresholdData {
  co2Threshold: number;           // CO2浓度阈值
  soilTempThreshold: number;      // 土壤温度阈值
  soilHumidityThreshold: number;  // 土壤湿度阈值
  lightThreshold: number;         // 光照阈值
  waterVolumeThreshold: number;   // 水箱水量阈值
}

// 目标值数据接口
interface TargetData {
  co2Target: number;              // CO2浓度目标值
  soilTempTarget: number;         // 土壤温度目标值
  soilHumidityTarget: number;     // 土壤湿度目标值
}

// 传感器数据接口
interface SensorData {
  soilHumidity: number;     // 土壤湿度 (%)
  light: number;            // 光照强度 (lx)
  co2: number;              // CO2浓度 (ppm)
  waterVolume: number;      // 水箱水量 (L)
}
// ==================== 硬件接口服务类 ====================

class HardwareService {
  private deviceIp: string = '172.16.12.51';
  private deviceId: string = 'device_001';

  updateDeviceInfo(deviceIp: string, deviceId: string): void {
    this.deviceIp = deviceIp;
    this.deviceId = deviceId;
  }

  /**
   * 获取阈值数据
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
   * 更新阈值数据
   */
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
        const data = JSON.parse(response.result as string)as HardwareUpdateThresholdsResponse;
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

  /**
   * 获取目标值数据
   */
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

  /**
   * 更新目标值数据
   */
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
        const data = JSON.parse(response.result as string)as HardwareUpdateTargetsResponse;
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

  /**
   * 获取设备状态
   */
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

  /**
   * 发送控制指令
   */
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

  /**
   * 更新光源设置（用于夜间照明自动开灯）
   */
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
        const data = JSON.parse(response.result as string)as HardwareUpdateLightResponse;
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
// ==================== 后端云平台服务类 ====================

class CloudService {
  private static readonly SENSOR_API_URL = 'https://guet-farm.netlify.app/.netlify/functions/getData';
  private static readonly CONFIG_API_URL = 'https://guet-farm.netlify.app/.netlify/functions/cfg';

  /**
   * 获取传感器数据（土壤湿度、光照强度、CO2浓度）
   */
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

      // 获取最新的一条数据
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
        waterVolume: 0  // 从cfg接口获取
      };

      console.log(`[云平台] 传感器数据: 土壤湿度=${sensorData.soilHumidity}%, 光照=${sensorData.light}lx, CO2=${sensorData.co2}ppm`);
      return sensorData;
    } catch (error) {
      console.error('[云平台] 获取传感器数据失败:', JSON.stringify(error));
      return null;
    }
  }

  /**
   * 获取设备配置（水箱水量）
   */
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
  @State isCheck1: boolean = true;
  @State isCheck2: boolean = true;
  @State isCheck3: boolean = true;
  @State allLogs: ActivityLog[] = [];     // 所有日志
  @State displayLogs: ActivityLog[] = []; // 当前显示的日志（前3条或全部）
  @State showAllLogs: boolean = false;    // 是否显示全部日志
@State logList:LogItem[]=[
  { content: "自动灌溉系统启动", time: "14:20 PM", dotColor: "#3B82F6" },
  { content: "自动灌溉终止", time: "14:35 PM", dotColor: "#3B82F6" },
  { content: "B区域检测到活动", time: "11:04 AM", dotColor: "#F59E0B" },
];
  // 运行中的规则计数
  @State runningCount: number = 3;
  // ========== 阈值数据 ==========
  @State thresholds: ThresholdData = {
    co2Threshold: 500,           // CO2浓度阈值（ppm）
    soilTempThreshold: 35,       // 土壤温度阈值
    soilHumidityThreshold: 30,   // 土壤湿度阈值（%）
    lightThreshold: 20,          // 光照阈值（lx）
    waterVolumeThreshold: 200    // 水箱水量阈值（L）
  };

  // ========== 目标值数据 ==========
  @State targets: TargetData = {
    co2Target: 400,              // CO2目标值（低于此值关闭换气）
    soilTempTarget: 25,          // 土壤温度目标值
    soilHumidityTarget: 60       // 土壤湿度目标值（高于此值停止灌溉）
  };

  // ========== 传感器数据 ==========
  @State sensorData: SensorData = {
    soilHumidity: 0,
    light: 0,
    co2: 0,
    waterVolume: 0
  };

  // ========== 设备状态 ==========
  @State waterState: boolean = false;   // 水泵状态
  @State lightState: boolean = false;   // 补光状态
  @State airState: boolean = false;     // 换气状态

  // ========== 服务实例 ==========
  private hardwareService: HardwareService = new HardwareService();
  private cloudService: CloudService = new CloudService();

  // 定时器
  private sensorTimer: number = -1;
  private autoControlTimer: number = -1;
  /**
   * 添加活动日志
   * @param content 日志内容
   * @param isNormal 是否为正常状态（true=蓝色，false=黄色异常）
   */
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

    // 添加到列表头部（最新在上）
    this.allLogs = [newLog, ...this.allLogs];

    // 限制日志数量最多100条
    if (this.allLogs.length > 100) {
      this.allLogs = this.allLogs.slice(0, 100);
    }

    // 更新显示的日志
    this.updateDisplayLogs();
  }

  /**
   * 更新显示的日志列表
   */
  private updateDisplayLogs(): void {
    if (this.showAllLogs) {
      this.displayLogs = [...this.allLogs];
    } else {
      this.displayLogs = this.allLogs.slice(0, 3);
    }
  }

  /**
   * 切换显示全部/前3条
   */
  private toggleShowAllLogs(): void {
    this.showAllLogs = !this.showAllLogs;
    this.updateDisplayLogs();
  }
  // ========== 生命周期 ==========

  aboutToAppear(): void {
    console.log('自动化规则页面初始化');

    // 获取设备信息
    if (this.params['deviceId']) {
      this.hardwareService.updateDeviceInfo(this.params['deviceId'] as string, this.params['deviceId'] as string);
    }
    if (this.params['ipAddress']) {
      this.hardwareService.updateDeviceInfo(this.params['ipAddress'] as string, this.params['deviceId'] as string);
    }

    // 初始化阈值和目标值
    this.initThresholdsAndTargets();

    // 初始化设备状态
    this.initDeviceState();

    // 加载传感器数据
    this.loadSensorData();
    // 初始化示例日志
    this.initSampleLogs();

    // 启动定时器：每10秒获取传感器数据
    this.sensorTimer = setInterval(() => {
      this.loadSensorData();
    }, 10000);

    // 启动自动控制定时器：每5秒检查一次
    this.autoControlTimer = setInterval(() => {
      this.autoControl();
    }, 5000);
  }
  /**
   * 初始化示例日志
   */
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

  // ========== 初始化方法 ==========

  /**
   * 初始化阈值和目标值
   */
  async initThresholdsAndTargets(): Promise<void> {
    try {
      // 获取阈值
      const thresholds = await this.hardwareService.fetchThresholds();
      if (thresholds) {
        this.thresholds = thresholds;
        console.log('阈值初始化成功:', this.thresholds);
      } else {
        console.log('使用默认阈值');
      }

      // 获取目标值
      const targets = await this.hardwareService.fetchTargets();
      if (targets) {
        this.targets = targets;
        console.log('目标值初始化成功:', this.targets);
      } else {
        console.log('使用默认目标值');
      }
    } catch (error) {
      console.error('初始化阈值/目标值失败:', error);
    }
  }

  /**
   * 初始化设备状态
   */
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

  /**
   * 加载传感器数据
   */
  async loadSensorData(): Promise<void> {
    try {
      // 获取传感器数据（土壤湿度、光照、CO2）
      const sensorData = await this.cloudService.fetchSensorData();
      if (sensorData) {
        this.sensorData.soilHumidity = sensorData.soilHumidity;
        this.sensorData.light = sensorData.light;
        this.sensorData.co2 = sensorData.co2;
        console.log(`传感器数据更新: 土壤湿度=${this.sensorData.soilHumidity}%, 光照=${this.sensorData.light}lx, CO2=${this.sensorData.co2}ppm`);
      }

      // 获取水箱水量
      const waterVolume = await this.cloudService.fetchDeviceConfig(this.params['deviceId'] as string || 'device_001');
      if (waterVolume !== null) {
        this.sensorData.waterVolume = waterVolume;
        console.log(`水箱水量: ${this.sensorData.waterVolume}L`);

        // 水箱水量低于阈值提醒
        if (this.sensorData.waterVolume < this.thresholds.waterVolumeThreshold) {
          this.showGlobalToast(`⚠️ 水箱水量不足！当前仅剩${this.sensorData.waterVolume}L，请及时补水`);
        }
      }
    } catch (error) {
      console.error('加载传感器数据失败:', error);
    }
  }

  // ========== 自动控制逻辑 ==========

  /**
   * 自动控制主逻辑
   */
  async autoControl(): Promise<void> {
    // 更新运行中规则计数
    this.updateRunningCount();

    // 1. 自动灌溉控制
    if (this.isCheck1) {
      await this.autoIrrigationControl();
    }

    // 2. 夜间照明控制
    if (this.isCheck2) {
      await this.autoLightControl();
    }

    // 3. 温室通风控制
    if (this.isCheck3) {
      await this.autoAirControl();
    }
  }

  /**
   * 自动灌溉控制
   * 当土壤湿度低于阈值 → 开启水泵
   * 当土壤湿度高于目标值 → 关闭水泵
   */
  async autoIrrigationControl(): Promise<void> {
    // 检查水箱水量是否足够
    if (this.sensorData.waterVolume < this.thresholds.waterVolumeThreshold) {
      if (this.waterState) {
        // 水量不足时自动关闭水泵
        const result = await this.hardwareService.sendCommand('water-off');
        if (result && result.status === 'success') {
          this.waterState = result.WaterState;
          // 添加异常终止日志（黄色）
          this.addActivityLog(`自动灌溉异常终止(水量不足:${this.sensorData.waterVolume}L)`, false);
          this.showGlobalToast("⚠️ 水箱水量不足，自动灌溉已停止");
        }
      }
      return;
    }

    // 土壤湿度低于阈值 → 开启水泵
    if (this.sensorData.soilHumidity < this.thresholds.soilHumidityThreshold && !this.waterState) {
      console.log(`[自动灌溉] 土壤湿度${this.sensorData.soilHumidity}% < 阈值${this.thresholds.soilHumidityThreshold}%，开启水泵`);
      const result = await this.hardwareService.sendCommand('water');
      if (result && result.status === 'success') {
        this.waterState = result.WaterState;
        // 添加正常开启日志（蓝色）
        this.addActivityLog(`自动灌溉系统启动(土壤湿度:${this.sensorData.soilHumidity}%)`, true);
        this.showGlobalToast("💧 土壤干燥，自动灌溉已开启");
      }
    }

    // 土壤湿度高于目标值 → 关闭水泵
    if (this.sensorData.soilHumidity > this.targets.soilHumidityTarget && this.waterState) {
      console.log(`[自动灌溉] 土壤湿度${this.sensorData.soilHumidity}% > 目标值${this.targets.soilHumidityTarget}%，关闭水泵`);
      const result = await this.hardwareService.sendCommand('water-off');
      if (result && result.status === 'success') {
        this.waterState = result.WaterState;
        // 添加正常开启日志（蓝色）
        this.addActivityLog(`自动灌溉系统启动(土壤湿度:${this.sensorData.soilHumidity}%)`, true);
        this.showGlobalToast("✅ 土壤湿度已达标，自动灌溉已停止");
      }
    }
  }

  /**
   * 夜间照明控制
   * 当光照强度低于阈值 → 开启LED灯（亮度50%，RGB均为255）
   * 当光照强度高于阈值 → 关闭LED灯
   */
  async autoLightControl(): Promise<void> {
    // 光照低于阈值 → 开启补光
    if (this.sensorData.light < this.thresholds.lightThreshold && !this.lightState) {
      console.log(`[夜间照明] 光照${this.sensorData.light}lx < 阈值${this.thresholds.lightThreshold}lx，开启LED灯`);

      // 设置亮度50%，RGB全白(255,255,255)
      const success = await this.hardwareService.updateLightSetting(50, 255, 255, 255);
      if (success) {
        const result = await this.hardwareService.sendCommand('light');
        if (result && result.status === 'success') {
          this.lightState = result.LightState;
          // 添加正常开启日志（蓝色）
          this.addActivityLog(`夜间照明已开启(光照:${this.sensorData.light}lx)`, true);
          this.showGlobalToast("💡 环境光不足，夜间照明已开启");
        }
      }
    }

    // 光照恢复正常 → 关闭补光
    if (this.sensorData.light >= this.thresholds.lightThreshold && this.lightState) {
      console.log(`[夜间照明] 光照${this.sensorData.light}lx >= 阈值${this.thresholds.lightThreshold}lx，关闭LED灯`);
      const result = await this.hardwareService.sendCommand('light-off');
      if (result && result.status === 'success') {
        this.lightState = result.LightState;
        // 添加正常关闭日志（蓝色）
        this.addActivityLog(`夜间照明已关闭(光照:${this.sensorData.light}lx)`, true);
        this.showGlobalToast("🌞 光照充足，夜间照明已关闭");
      }
    }
  }

  /**
   * 温室通风控制
   * 当CO2浓度高于阈值 → 开启换气
   * 当CO2浓度低于目标值 → 关闭换气
   */
  async autoAirControl(): Promise<void> {
    // CO2浓度高于阈值 → 开启换气
    if (this.sensorData.co2 > this.thresholds.co2Threshold && !this.airState) {
      console.log(`[温室通风] CO2${this.sensorData.co2}ppm > 阈值${this.thresholds.co2Threshold}ppm，开启换气`);
      const result = await this.hardwareService.sendCommand('air');
      if (result && result.status === 'success') {
        this.airState = result.AirState;
        // 添加正常开启日志（蓝色）
        this.addActivityLog(`温室通风已启动(CO2:${this.sensorData.co2}ppm)`, true);
        this.showGlobalToast("🌬️ CO2浓度过高，温室通风已开启");
      }
    }

    // CO2浓度低于目标值 → 关闭换气
    if (this.sensorData.co2 < this.targets.co2Target && this.airState) {
      console.log(`[温室通风] CO2${this.sensorData.co2}ppm < 目标值${this.targets.co2Target}ppm，关闭换气`);
      const result = await this.hardwareService.sendCommand('air-off');
      if (result && result.status === 'success') {
        this.airState = result.AirState;
        // 添加正常关闭日志（蓝色）
        this.addActivityLog(`温室通风已关闭(CO2:${this.sensorData.co2}ppm)`, true);
        this.showGlobalToast("✅ CO2浓度已达标，温室通风已关闭");
      }
    }
  }

  // ========== UI辅助方法 ==========

  /**
   * 更新运行中的规则计数
   */
  private updateRunningCount(): void {
    let count = 0;
    if (this.isCheck1) count++;
    if (this.isCheck2) count++;
    if (this.isCheck3) count++;
    this.runningCount = count;
  }

  /**
   * 添加日志项
   */
  private addLogItem(content: string, dotColor: string): void {
    const now = new Date();
    const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const newLog: LogItem = {
      content: content,
      time: timeStr,
      dotColor: dotColor
    };
    this.logList = [newLog, ...this.logList];

    // 限制日志数量最多50条
    if (this.logList.length > 50) {
      this.logList = this.logList.slice(0, 50);
    }
  }

  /**
   * 全局Toast提示
   */
  private showGlobalToast(message: string): void {
    promptAction.openToast({
      message: message,
      duration: 2500
    });
  }

  build() {
    NavDestination() {
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
                  .onChange((value) => {
                    this.isCheck1 = value;
                    this.updateRunningCount();
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

                Toggle({ type: ToggleType.Switch, isOn: this.isCheck2})
                  .width('48vp')
                  .height('30vp')
                  .selectedColor('#13EC5B')
                  .onChange((value) => {
                    this.isCheck2= value;
                    this.updateRunningCount();
                  })
              }
              .width('100%')
              .margin({ top: 15 })
              .padding({ left: 15, right: 15 })

              Column({ space: 3 }) {
                Text() {
                  Span('条件:').fontColor(this.isCheck2 ? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('环境光<20lx').fontSize('12vp')
                }

                Text() {
                  Span('行为:').fontColor(this.isCheck2? '#13EC5B' : '#0F172A').fontSize('12vp')
                  Span('开启LED灯(亮度50%,白光)').fontSize('12vp')
                }
              }
              .width('90%')
              .height('50vp')
              .backgroundColor(this.isCheck2? '#0d13ec5b' : '#F1F5F9')
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
                  .onChange((value) => {
                    this.isCheck3= value;
                    this.updateRunningCount();
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
            Column(){
              // 标题 + 查看全部
              Row() {
                Text("活动日志")
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor("#1E293B")

                Blank()

                // 查看全部（可点击跳转）
                Text(this.showAllLogs ? "收起" : "查看全部")
                  .fontSize(15)
                  .fontColor("#13EC5B")
                  .onClick(() => {
                    this.toggleShowAllLogs();
                  })
              }
              .width("95%")
              .margin({ top: 15, bottom: 10,right:10 })

              // 分割线
              Divider().width("95%").color("#94A3B8")

              // 日志列表
              Column({ space: 0 }) {
                ForEach(this.displayLogs, (item: ActivityLog) => {
                  Row({ space: 12 }) {
                    // 左侧彩色圆点
                    Circle()
                      .width(10)
                      .height(10)
                      .fill(item.dotColor)

                    // 内容
                    Text(item.content)
                      .fontSize(15)
                      .fontColor("#333")
                      .layoutWeight(1)

                    // 时间
                    Text(item.time)
                      .fontSize(13)
                      .fontColor("#9CA3AF")
                  }
                  .width("95%")
                  .padding({ top: 14, bottom: 14 })

                  // 分割线
                  Divider().width("95%").color("#94A3B8")
                })
              }
              .margin({ top: 5 })
              // 当没有日志时显示提示
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
    }.hideTitleBar(true)
  }
}