// common/DeviceStateService.ts
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// 设备状态接口
export interface DeviceRuntimeState {
  isDeviceOn: boolean;
  isWaterOn: boolean;
  isLightOn: boolean;
  currentLED: number;
  r: number;
  g: number;
  b: number;
  currentColorValue: string;
}

// 全局设备状态服务（单例模式）
export class DeviceStateService {
  private static instance: DeviceStateService | null = null;

  // 当前设备状态
  private currentState: DeviceRuntimeState = {
    isDeviceOn: true,
    isWaterOn: false,
    isLightOn: true,
    currentLED: 75,
    r: 255,
    g: 255,
    b: 255,
    currentColorValue: 'rgb(255, 255, 255)'
  };

  // 状态变化监听器列表
  private listeners: Array<(state: DeviceRuntimeState) => void> = [];

  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  static getInstance(): DeviceStateService {
    if (!DeviceStateService.instance) {
      DeviceStateService.instance = new DeviceStateService();
    }
    return DeviceStateService.instance;
  }

  // 设置上下文（在EntryAbility中调用）
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
    this.loadFromStorage();
  }

  // 获取当前状态（返回新对象，避免引用）
  getState(): DeviceRuntimeState {
    return {
      isDeviceOn: this.currentState.isDeviceOn,
      isWaterOn: this.currentState.isWaterOn,
      isLightOn: this.currentState.isLightOn,
      currentLED: this.currentState.currentLED,
      r: this.currentState.r,
      g: this.currentState.g,
      b: this.currentState.b,
      currentColorValue: this.currentState.currentColorValue
    };
  }

  // 更新状态
  setState(newState: DeviceRuntimeState): void {
    // 手动复制每个属性（不使用扩展运算符）
    this.currentState.isDeviceOn = newState.isDeviceOn;
    this.currentState.isWaterOn = newState.isWaterOn;
    this.currentState.isLightOn = newState.isLightOn;
    this.currentState.currentLED = newState.currentLED;
    this.currentState.r = newState.r;
    this.currentState.g = newState.g;
    this.currentState.b = newState.b;
    this.currentState.currentColorValue = newState.currentColorValue;

    console.log('设备状态已更新:', JSON.stringify(this.currentState));

    // 通知所有监听器
    this.notifyListeners();

    // 保存到本地持久化存储
    this.saveToStorage();
  }

  // 部分更新状态
  updateState(partial: Partial<DeviceRuntimeState>): void {
    if (partial.isDeviceOn !== undefined) {
      this.currentState.isDeviceOn = partial.isDeviceOn;
    }
    if (partial.isWaterOn !== undefined) {
      this.currentState.isWaterOn = partial.isWaterOn;
    }
    if (partial.isLightOn !== undefined) {
      this.currentState.isLightOn = partial.isLightOn;
    }
    if (partial.currentLED !== undefined) {
      this.currentState.currentLED = partial.currentLED;
    }
    if (partial.r !== undefined) {
      this.currentState.r = partial.r;
    }
    if (partial.g !== undefined) {
      this.currentState.g = partial.g;
    }
    if (partial.b !== undefined) {
      this.currentState.b = partial.b;
    }
    if (partial.currentColorValue !== undefined) {
      this.currentState.currentColorValue = partial.currentColorValue;
    }

    console.log('设备状态已更新:', JSON.stringify(this.currentState));
    this.notifyListeners();
    this.saveToStorage();
  }

  // 添加监听器
  addListener(listener: (state: DeviceRuntimeState) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index === -1) {
      this.listeners.push(listener);
    }
  }

  // 移除监听器
  removeListener(listener: (state: DeviceRuntimeState) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  // 通知所有监听器
  private notifyListeners(): void {
    const state = this.getState();
    for (let i = 0; i < this.listeners.length; i++) {
      const listener = this.listeners[i];
      try {
        listener(state);
      } catch (error) {
        console.error('通知监听器失败:', error);
      }
    }
  }

  // 保存到本地持久化存储
  private async saveToStorage(): Promise<void> {
    if (!this.context) {
      console.warn('上下文未设置，无法保存状态');
      return;
    }

    try {
      const dataPreferences = await preferences.getPreferences(this.context, 'device_state');
      await dataPreferences.put('isDeviceOn', this.currentState.isDeviceOn);
      await dataPreferences.put('isWaterOn', this.currentState.isWaterOn);
      await dataPreferences.put('isLightOn', this.currentState.isLightOn);
      await dataPreferences.put('currentLED', this.currentState.currentLED);
      await dataPreferences.put('r', this.currentState.r);
      await dataPreferences.put('g', this.currentState.g);
      await dataPreferences.put('b', this.currentState.b);
      await dataPreferences.put('currentColorValue', this.currentState.currentColorValue);
      await dataPreferences.flush();
      console.log('设备状态已保存到本地');
    } catch (error) {
      console.error('保存设备状态失败:', error);
    }
  }

  // 从本地加载状态
  private async loadFromStorage(): Promise<void> {
    if (!this.context) {
      console.warn('上下文未设置，无法加载状态');
      return;
    }

    try {
      const dataPreferences = await preferences.getPreferences(this.context, 'device_state');
      const isDeviceOn = await dataPreferences.get('isDeviceOn', true) as boolean;
      const isWaterOn = await dataPreferences.get('isWaterOn', false) as boolean;
      const isLightOn = await dataPreferences.get('isLightOn', true) as boolean;
      const currentLED = await dataPreferences.get('currentLED', 75) as number;
      const r = await dataPreferences.get('r', 255) as number;
      const g = await dataPreferences.get('g', 255) as number;
      const b = await dataPreferences.get('b', 255) as number;
      const currentColorValue = await dataPreferences.get('currentColorValue', 'rgb(255, 255, 255)') as string;

      this.currentState.isDeviceOn = isDeviceOn;
      this.currentState.isWaterOn = isWaterOn;
      this.currentState.isLightOn = isLightOn;
      this.currentState.currentLED = currentLED;
      this.currentState.r = r;
      this.currentState.g = g;
      this.currentState.b = b;
      this.currentState.currentColorValue = currentColorValue;

      console.log('从本地加载设备状态:', JSON.stringify(this.currentState));
      this.notifyListeners();
    } catch (error) {
      console.error('加载设备状态失败:', error);
    }
  }
}