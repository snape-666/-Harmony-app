// common/NavigationManager.ets

export class NavigationManager {
  private static instance: NavigationManager;
  private navPathStack: NavPathStack | null = null;


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
      console.log(`跳转到: ${name}`, param);
    } else {
      console.error('NavigationManager: navPathStack 未初始化');
    }
  }

  // 返回上一页
  pop() {
    if (this.navPathStack) {
      this.navPathStack.pop();
    }
  }

  // 返回到指定页面
  popToName(name: string) {
    if (this.navPathStack) {
      this.navPathStack.popToName(name);
    }
  }

  // 清空栈并跳转
  clearAndPush(name: string, param?: ESObject) {
    if (this.navPathStack) {
      this.navPathStack.clear();
      this.navPathStack.pushPath({ name, param });
    }
  }

  // 获取当前导航栈
  getNavPathStack(): NavPathStack | null {
    return this.navPathStack;
  }
}

