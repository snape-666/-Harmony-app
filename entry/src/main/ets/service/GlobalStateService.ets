// common/GlobalStateService.ts
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// ==================== 接口定义 ====================
// GlobalStateService.ts
export interface LightSettingState {
  brightness: number;
  red: number;
  green: number;
  blue: number;
  isLightOn: boolean;
  lightDuration: number;
}

export interface DeviceState {
  waterState: boolean;
  lightState: boolean;
  airState: boolean;
  autoModeState: boolean;
}

export interface SensorDataState {
  soilHumidity: number;
  light: number;
  electricity: number;
  waterVolume: number;
}

export interface ThresholdsState {
  co2Threshold: number;
  soilTempThreshold: number;
  soilHumidityThreshold: number;
  lightThreshold: number;
  waterVolumeThreshold: number;
}

export interface DeviceInfoState {
  deviceId: string;
  deviceIp: string;
}

export interface TimeSettingState {
  lightStartHour: number;
  lightStartMinute: number;
  lightEndHour: number;
  lightEndMinute: number;
}

export interface TargetState {
  co2Target: number;
  soilTempTarget: number;
  soilHumidityTarget: number;
}

export interface RuleSwitchState {
  autoIrrigation: boolean;
  nightLighting: boolean;
  ventilation: boolean;
}

export interface GlobalState {
  deviceInfo: DeviceInfoState;
  isDeviceOn: boolean;
  isWaterOn: boolean;
  targetWaterVolume: number;
  lightSetting: LightSettingState;
  deviceState: DeviceState;
  sensorData: SensorDataState;
  thresholds: ThresholdsState;
  timeSetting: TimeSettingState;
  targets: TargetState;
  ruleSwitches: RuleSwitchState;
  notifyConfig: NotifyState;
}
// 新建一个独立的通知状态接口
export interface NotifyState {
  notifySystem: boolean;
  notifyBanner: boolean;
  notifyMode: 'sound' | 'vibrate' | 'silent';
}
type StateChangeListener = (state: GlobalState) => void;

// ==================== 全局状态服务类 ====================

export class GlobalStateService {
  private static instance: GlobalStateService | null = null;
  private preferences: preferences.Preferences | null = null;
  private currentState: GlobalState;
  private listeners: StateChangeListener[] = [];
  private readonly STORAGE_NAME: string = 'global_device_state';
  private isInitialized: boolean = false;
  private context: common.UIAbilityContext | null = null;

  // 默认状态
  private readonly DEFAULT_STATE: GlobalState = {
    deviceInfo: {
      deviceId: 'device_001',
      deviceIp: '172.16.12.51',
    },
    isDeviceOn: true,
    isWaterOn: false,
    targetWaterVolume: 500,
    lightSetting: {
      brightness: 75,
      red: 255,
      green: 255,
      blue: 255,
      isLightOn: false,
      lightDuration: 30
    },
    deviceState: {
      waterState: false,
      lightState: false,
      airState: false,
      autoModeState: true
    },
    sensorData: {
      soilHumidity: 0,
      light: 0,
      electricity: 0,
      waterVolume: 0
    },
    thresholds: {
      co2Threshold: 500,
      soilTempThreshold: 35,
      soilHumidityThreshold: 30,
      lightThreshold: 20,
      waterVolumeThreshold: 200
    },
    timeSetting: {
      lightStartHour: 20,
      lightStartMinute: 0,
      lightEndHour: 6,
      lightEndMinute: 0
    },
    targets: {
      co2Target: 400,
      soilTempTarget: 25,
      soilHumidityTarget: 60
    },
    ruleSwitches: {
      autoIrrigation: false,
      nightLighting: false,
      ventilation: false
    },
    notifyConfig: {
      notifySystem: true,
      notifyBanner: true,
      notifyMode: 'sound'
    }
  };

  private constructor() {
    this.currentState = this.cloneState(this.DEFAULT_STATE);
  }

  static getInstance(): GlobalStateService {
    if (!GlobalStateService.instance) {
      GlobalStateService.instance = new GlobalStateService();
    }
    return GlobalStateService.instance;
  }

  // 深拷贝状态
  private cloneState(state: GlobalState): GlobalState {
    return JSON.parse(JSON.stringify(state));
  }

  // ==================== 初始化 ====================

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized) return;

    this.context = context;

    try {
      // 使用正确的 API：需要传入 Context 和文件名
      this.preferences = await preferences.getPreferences(context, this.STORAGE_NAME);
      await this.loadFromStorage();
      this.isInitialized = true;
      console.log('[GlobalStateService] 初始化完成');
    } catch (error) {
      console.error('[GlobalStateService] 初始化失败:', JSON.stringify(error));
    }
  }

  private async loadFromStorage(): Promise<void> {
    if (!this.preferences) return;

    try {
      const savedState = await this.preferences.get('globalState', '') as string;
      if (savedState && savedState.length > 0) {
        const parsed: Record<string, Object> = JSON.parse(savedState);
        this.mergeState(parsed);
        console.log('[GlobalStateService] 从存储加载状态成功');
      }
    } catch (error) {
      console.error('[GlobalStateService] 加载存储失败:', JSON.stringify(error));
    }
  }

  private mergeState(parsed: Record<string, Object>): void {
    // 合并 deviceInfo
    const deviceInfo = parsed['deviceInfo'] as Record<string, string>;
    if (deviceInfo) {
      if (deviceInfo['deviceId']) this.currentState.deviceInfo.deviceId = deviceInfo['deviceId'];
      if (deviceInfo['deviceIp']) this.currentState.deviceInfo.deviceIp = deviceInfo['deviceIp'];
    }

    // 合并基础字段
    if (parsed['isDeviceOn'] !== undefined) this.currentState.isDeviceOn = parsed['isDeviceOn'] as boolean;
    if (parsed['isWaterOn'] !== undefined) this.currentState.isWaterOn = parsed['isWaterOn'] as boolean;
    if (parsed['targetWaterVolume'] !== undefined) this.currentState.targetWaterVolume = parsed['targetWaterVolume'] as number;

    // 合并 lightSetting
    const lightSetting = parsed['lightSetting'] as Record<string, number | boolean>;
    if (lightSetting) {
      if (lightSetting['brightness'] !== undefined) this.currentState.lightSetting.brightness = lightSetting['brightness'] as number;
      if (lightSetting['red'] !== undefined) this.currentState.lightSetting.red = lightSetting['red'] as number;
      if (lightSetting['green'] !== undefined) this.currentState.lightSetting.green = lightSetting['green'] as number;
      if (lightSetting['blue'] !== undefined) this.currentState.lightSetting.blue = lightSetting['blue'] as number;
      if (lightSetting['isLightOn'] !== undefined) this.currentState.lightSetting.isLightOn = lightSetting['isLightOn'] as boolean;
      if (lightSetting['lightDuration'] !== undefined) this.currentState.lightSetting.lightDuration = lightSetting['lightDuration'] as number;
    }

    // 合并 deviceState
    const deviceState = parsed['deviceState'] as Record<string, boolean>;
    if (deviceState) {
      if (deviceState['waterState'] !== undefined) this.currentState.deviceState.waterState = deviceState['waterState'];
      if (deviceState['lightState'] !== undefined) this.currentState.deviceState.lightState = deviceState['lightState'];
      if (deviceState['airState'] !== undefined) this.currentState.deviceState.airState = deviceState['airState'];
      if (deviceState['autoModeState'] !== undefined) this.currentState.deviceState.autoModeState = deviceState['autoModeState'];
    }

    // 合并 sensorData
    const sensorData = parsed['sensorData'] as Record<string, number>;
    if (sensorData) {
      if (sensorData['soilHumidity'] !== undefined) this.currentState.sensorData.soilHumidity = sensorData['soilHumidity'];
      if (sensorData['light'] !== undefined) this.currentState.sensorData.light = sensorData['light'];
      if (sensorData['electricity'] !== undefined) this.currentState.sensorData.electricity = sensorData['electricity'];
      if (sensorData['waterVolume'] !== undefined) this.currentState.sensorData.waterVolume = sensorData['waterVolume'];
    }

    // 合并 thresholds
    const thresholds = parsed['thresholds'] as Record<string, number>;
    if (thresholds) {
      if (thresholds['co2Threshold'] !== undefined) this.currentState.thresholds.co2Threshold = thresholds['co2Threshold'];
      if (thresholds['soilTempThreshold'] !== undefined) this.currentState.thresholds.soilTempThreshold = thresholds['soilTempThreshold'];
      if (thresholds['soilHumidityThreshold'] !== undefined) this.currentState.thresholds.soilHumidityThreshold = thresholds['soilHumidityThreshold'];
      if (thresholds['lightThreshold'] !== undefined) this.currentState.thresholds.lightThreshold = thresholds['lightThreshold'];
      if (thresholds['waterVolumeThreshold'] !== undefined) this.currentState.thresholds.waterVolumeThreshold = thresholds['waterVolumeThreshold'];
    }

    // 合并 timeSetting
    const timeSetting = parsed['timeSetting'] as Record<string, number>;
    if (timeSetting) {
      if (timeSetting['lightStartHour'] !== undefined) this.currentState.timeSetting.lightStartHour = timeSetting['lightStartHour'];
      if (timeSetting['lightStartMinute'] !== undefined) this.currentState.timeSetting.lightStartMinute = timeSetting['lightStartMinute'];
      if (timeSetting['lightEndHour'] !== undefined) this.currentState.timeSetting.lightEndHour = timeSetting['lightEndHour'];
      if (timeSetting['lightEndMinute'] !== undefined) this.currentState.timeSetting.lightEndMinute = timeSetting['lightEndMinute'];
    }

    // 合并 targets
    const targets = parsed['targets'] as Record<string, number>;
    if (targets) {
      if (targets['co2Target'] !== undefined) this.currentState.targets.co2Target = targets['co2Target'];
      if (targets['soilTempTarget'] !== undefined) this.currentState.targets.soilTempTarget = targets['soilTempTarget'];
      if (targets['soilHumidityTarget'] !== undefined) this.currentState.targets.soilHumidityTarget = targets['soilHumidityTarget'];
    }

    // 合并 ruleSwitches
    const ruleSwitches = parsed['ruleSwitches'] as Record<string, boolean>;
    if (ruleSwitches) {
      if (ruleSwitches['autoIrrigation'] !== undefined) this.currentState.ruleSwitches.autoIrrigation = ruleSwitches['autoIrrigation'];
      if (ruleSwitches['nightLighting'] !== undefined) this.currentState.ruleSwitches.nightLighting = ruleSwitches['nightLighting'];
      if (ruleSwitches['ventilation'] !== undefined) this.currentState.ruleSwitches.ventilation = ruleSwitches['ventilation'];
    }
  }

  private async saveToStorage(): Promise<void> {
    if (!this.preferences) return;

    try {
      const stateStr: string = JSON.stringify(this.currentState);
      await this.preferences.put('globalState', stateStr);
      await this.preferences.flush();
      console.log('[GlobalStateService] 状态已持久化保存');
    } catch (error) {
      console.error('[GlobalStateService] 保存存储失败:', JSON.stringify(error));
    }
  }

  // ==================== 获取状态 ====================

  getState(): GlobalState {
    return this.cloneState(this.currentState);
  }

  getDeviceInfo(): DeviceInfoState {
    return this.cloneState(this.currentState).deviceInfo;
  }

  getLightSetting(): LightSettingState {
    return this.cloneState(this.currentState).lightSetting;
  }

  getTimeSetting(): TimeSettingState {
    return this.cloneState(this.currentState).timeSetting;
  }

  getRuleSwitches(): RuleSwitchState {
    return this.cloneState(this.currentState).ruleSwitches;
  }

  getSensorData(): SensorDataState {
    return this.cloneState(this.currentState).sensorData;
  }

  getThresholds(): ThresholdsState {
    return this.cloneState(this.currentState).thresholds;
  }

  getTargets(): TargetState {
    return this.cloneState(this.currentState).targets;
  }

  // ==================== 更新状态 ====================

  async updateState(partialState: Record<string, Object>): Promise<void> {
    this.mergeState(partialState);
    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateDeviceInfo(deviceId: string, deviceIp: string): Promise<void> {
    this.currentState.deviceInfo.deviceId = deviceId;
    this.currentState.deviceInfo.deviceIp = deviceIp;
    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateDeviceOnOff(isOn: boolean): Promise<void> {
    console.log('[GlobalStateService] updateDeviceOnOff 被调用, isOn:', isOn);
    this.currentState.isDeviceOn = isOn;
    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateWaterState(isWaterOn: boolean, targetWaterVolume?: number): Promise<void> {
    this.currentState.isWaterOn = isWaterOn;
    if (targetWaterVolume !== undefined) {
      this.currentState.targetWaterVolume = targetWaterVolume;
    }
    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateLightSetting(
    brightness?: number,
    red?: number,
    green?: number,
    blue?: number,
    isLightOn?: boolean
  ): Promise<void> {
    if (brightness !== undefined) this.currentState.lightSetting.brightness = brightness;
    if (red !== undefined) this.currentState.lightSetting.red = red;
    if (green !== undefined) this.currentState.lightSetting.green = green;
    if (blue !== undefined) this.currentState.lightSetting.blue = blue;
    if (isLightOn !== undefined) this.currentState.lightSetting.isLightOn = isLightOn;

    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateDeviceState(deviceState: Record<string, boolean>): Promise<void> {
    if (deviceState['waterState'] !== undefined) this.currentState.deviceState.waterState = deviceState['waterState'];
    if (deviceState['lightState'] !== undefined) this.currentState.deviceState.lightState = deviceState['lightState'];
    if (deviceState['airState'] !== undefined) this.currentState.deviceState.airState = deviceState['airState'];
    if (deviceState['autoModeState'] !== undefined) this.currentState.deviceState.autoModeState = deviceState['autoModeState'];

    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateSensorData(sensorData: Record<string, number>): Promise<void> {
    if (sensorData['soilHumidity'] !== undefined) this.currentState.sensorData.soilHumidity = sensorData['soilHumidity'];
    if (sensorData['light'] !== undefined) this.currentState.sensorData.light = sensorData['light'];
    if (sensorData['electricity'] !== undefined) this.currentState.sensorData.electricity = sensorData['electricity'];
    if (sensorData['waterVolume'] !== undefined) this.currentState.sensorData.waterVolume = sensorData['waterVolume'];

    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateThresholds(thresholds: Record<string, number>): Promise<void> {
    if (thresholds['co2Threshold'] !== undefined) this.currentState.thresholds.co2Threshold = thresholds['co2Threshold'];
    if (thresholds['soilTempThreshold'] !== undefined) this.currentState.thresholds.soilTempThreshold = thresholds['soilTempThreshold'];
    if (thresholds['soilHumidityThreshold'] !== undefined) this.currentState.thresholds.soilHumidityThreshold = thresholds['soilHumidityThreshold'];
    if (thresholds['lightThreshold'] !== undefined) this.currentState.thresholds.lightThreshold = thresholds['lightThreshold'];
    if (thresholds['waterVolumeThreshold'] !== undefined) this.currentState.thresholds.waterVolumeThreshold = thresholds['waterVolumeThreshold'];

    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateTimeSetting(
    startHour: number,
    startMinute: number,
    endHour: number,
    endMinute: number
  ): Promise<void> {
    this.currentState.timeSetting.lightStartHour = startHour;
    this.currentState.timeSetting.lightStartMinute = startMinute;
    this.currentState.timeSetting.lightEndHour = endHour;
    this.currentState.timeSetting.lightEndMinute = endMinute;

    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateTargets(targets: Record<string, number>): Promise<void> {
    if (targets['co2Target'] !== undefined) this.currentState.targets.co2Target = targets['co2Target'];
    if (targets['soilTempTarget'] !== undefined) this.currentState.targets.soilTempTarget = targets['soilTempTarget'];
    if (targets['soilHumidityTarget'] !== undefined) this.currentState.targets.soilHumidityTarget = targets['soilHumidityTarget'];

    await this.saveToStorage();
    this.notifyListeners();
  }

  async updateRuleSwitches(ruleSwitches: Record<string, boolean>): Promise<void> {
    if (ruleSwitches['autoIrrigation'] !== undefined) this.currentState.ruleSwitches.autoIrrigation = ruleSwitches['autoIrrigation'];
    if (ruleSwitches['nightLighting'] !== undefined) this.currentState.ruleSwitches.nightLighting = ruleSwitches['nightLighting'];
    if (ruleSwitches['ventilation'] !== undefined) this.currentState.ruleSwitches.ventilation = ruleSwitches['ventilation'];

    await this.saveToStorage();
    this.notifyListeners();
  }

  // ==================== 监听器 ====================

  addListener(listener: StateChangeListener): void {
    this.listeners.push(listener);
  }

  removeListener(listener: StateChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    const state = this.getState();
    for (let i = 0; i < this.listeners.length; i++) {
      try {
        this.listeners[i](state);
      } catch (error) {
        console.error('[GlobalStateService] 监听器执行失败:', JSON.stringify(error));
      }
    }
  }
}