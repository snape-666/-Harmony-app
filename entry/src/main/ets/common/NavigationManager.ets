// common/NavigationManager.ets

export class NavigationManager {
  private static instance: NavigationManager;
  private navPathStack: NavPathStack | null = null;
  /** 仪表盘在导航栈中处于被覆盖状态时置为 true，用于暂停传感器轮询与 Toast */
  private static dashboardSensorPaused: boolean = false;

  static isDashboardSensorPaused(): boolean {
    return NavigationManager.dashboardSensorPaused;
  }

  private static setDashboardSensorPaused(paused: boolean): void {
    NavigationManager.dashboardSensorPaused = paused;
  }

  static getInstance(): NavigationManager {
    if (!NavigationManager.instance) {
      NavigationManager.instance = new NavigationManager();
    }
    return NavigationManager.instance;
  }

  // 设置导航栈（在根页面初始化时调用）
  setNavPathStack(stack: NavPathStack) {
    this.navPathStack = stack;
  }

  // 跳转页面
  push(name: string, param?: ESObject) {
    if (this.navPathStack) {
      this.navPathStack.pushPath({ name, param });
      // 进入子页时仪表盘被遮挡，暂停传感器轮询；进入仪表盘本身则恢复
      if (name === 'Yibiaopan') {
        NavigationManager.setDashboardSensorPaused(false);
      } else {
        NavigationManager.setDashboardSensorPaused(true);
      }
      console.log(`跳转到: ${name}`, param);
    } else {
      console.error('NavigationManager: navPathStack 未初始化');
    }
  }

  // 返回上一页
  pop() {
    if (this.navPathStack) {
      this.navPathStack.pop();
      NavigationManager.setDashboardSensorPaused(false);
    }
  }

  // 返回到指定页面
  popToName(name: string) {
    if (this.navPathStack) {
      this.navPathStack.popToName(name);
      NavigationManager.setDashboardSensorPaused(name !== 'Yibiaopan');
    }
  }

  // 清空栈并跳转
  clearAndPush(name: string, param?: ESObject) {
    if (this.navPathStack) {
      this.navPathStack.clear();
      this.navPathStack.pushPath({ name, param });
      NavigationManager.setDashboardSensorPaused(name !== 'Yibiaopan');
    }
  }

  // 获取当前导航栈
  getNavPathStack(): NavPathStack | null {
    return this.navPathStack;
  }
}

