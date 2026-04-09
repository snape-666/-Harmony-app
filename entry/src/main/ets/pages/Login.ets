import { promptAction, window } from "@kit.ArkUI";
import {NavigationManager} from '../common/NavigationManager'
import {Yibiaopan}from './Yibiaopan'
import {LostPassword} from './LostPassword'
import { preferences } from "@kit.ArkData";
import { http } from "@kit.NetworkKit";

// 定义登录响应接口
interface LoginResponse {
  success: boolean;
  message: string;
}
// 定义用户信息接口
interface UserInfo {
  username: string;
  loginTime: number;
}


interface requestInfo {
  username: string;
  password: string;
}

@Entry
@Component
 export struct Login {
 // private pageStack?: NavPathStack;
  @State params: Record<string, Object> = {};
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State usernameError: string = '';
  @State passwordError: string = '';
  @State loginError: string = '';
  @State showPassword: boolean = false;
  private dataPreferences?: preferences.Preferences;
  private readonly USER_INFO_KEY = 'user_info';
  private readonly LOGIN_STATUS_KEY = 'is_logged_in';
  private readonly API_URL = 'https://guet-farm.netlify.app/.netlify/functions/login';

  aboutToAppear() {
    console.log('详情页接收到的参数:', JSON.stringify(this.params));
    this.initPreferences();
  }
  aboutToDisappear() {
    this.isLoading = false;
  }

  onPageShow() {
    console.log('登录页面显示');
  }

  onPageHide() {
    console.log('登录页面隐藏');
  }
  // 初始化本地存储
  async initPreferences() {
    try {
      const context: Context = AppStorage.get('abilityContext') as Context;
      if (context) {
        this.dataPreferences = await preferences.getPreferences(context, 'agri_connect_prefs');
        console.log('本地存储初始化成功');
      } else {
        console.error('无法获取上下文');
      }
    } catch (error) {
      console.error('本地存储初始化失败:', JSON.stringify(error));
    }
  }

  // 检查自动登录
  async checkAutoLogin() {
    try {
      if (!this.dataPreferences) {
        return;
      }

      const isLoggedIn = await this.dataPreferences?.get(this.LOGIN_STATUS_KEY, false);
      const userInfoStr = await this.dataPreferences?.get(this.USER_INFO_KEY, '');

      if (isLoggedIn && userInfoStr && userInfoStr !== '') {
        const userInfo: UserInfo = JSON.parse(userInfoStr as string);
        if (userInfo && userInfo.username && userInfo.username !== '') {
          const currentTime: number = Date.now();
          // 检查登录是否超过7天（7天有效期）
          if (currentTime - userInfo.loginTime < 7 * 24 * 60 * 60 * 1000) {
            console.log('检测到有效登录状态，自动跳转');
            this.showToast('欢迎回来，' + userInfo.username);
            NavigationManager.getInstance().push('Yibiaopan', { from: 'Login', username: userInfo.username });
          } else {
            // 登录过期，清除本地数据
            await this.clearUserData();
          }
        }else {
          await this.clearUserData();
        }
      }
    } catch (error) {
      console.error('自动登录检查失败:', JSON.stringify(error));
    }
  }

  // 表单验证
  validateForm(): boolean {
    let isValid = true;

    // 用户名验证
    if (!this.username.trim()) {
      this.usernameError = '请输入用户名';
      isValid = false;
    } else if (this.username.length < 3) {
      this.usernameError = '用户名至少3个字符';
      isValid = false;
    } else {
      this.usernameError = '';
    }

    // 密码验证
    if (!this.password.trim()) {
      this.passwordError = '请输入密码';
      isValid = false;
    } else if (this.password.length < 6) {
      this.passwordError = '密码至少6位数';
      isValid = false;
    } else {
      this.passwordError = '';
    }
    if (!isValid) {
      this.showToast('请填写完整的登录信息');
    }
    return isValid;
  }
  async checkApiAvailability(): Promise<boolean> {
    const httpRequest: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await httpRequest.request(this.API_URL, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000,
      });
      console.log('接口可用，状态码:', response.responseCode);
      return true;
    } catch (error) {
      console.error('接口不可用:', error.message);
      return false;
    } finally {
      httpRequest.destroy();
    }
  }
  // 登录方法
  async handleLogin() {
    // 重置错误信息
    this.loginError = '';
    const isApiAvailable = await this.checkApiAvailability();
    if (!isApiAvailable) {
      this.showToast('接口服务不可用，请检查网络或联系管理员');
      this.isLoading = false;
      return;
    }

    // 表单验证
    if (!this.validateForm()) {
      return;
    }
    if (this.isLoading) {
     this.showToast('正在登录中，请勿重复点击');
      return;
    }
    // 设置加载状态
    this.isLoading = true;

    try {
      // 调用登录接口
      const loginResult = await this.loginRequest(this.username, this.password);

      if (loginResult.success) {
        // 登录成功
        console.log('登录成功:', loginResult.message);

        // 保存用户信息到本地
        await this.saveUserData(this.username);

        // 显示成功提示
        this.showToast(loginResult.message || '登录成功！');

        // 跳转到首页
        NavigationManager.getInstance().push('Yibiaopan', {
          from: 'Login',
          username: this.username
        });
      } else {
        // 登录失败
        this.loginError = loginResult.message || '登录失败，请检查用户名和密码';
        this.showToast(this.loginError);

        // 清空密码框
        this.password = '';
      }
    } catch (error) {
      console.error('登录请求失败:', JSON.stringify(error));
      this.loginError = '网络连接失败，请检查网络设置';
      this.showToast(this.loginError);
    } finally {
      this.isLoading = false;
    }
  }

  // 登录请求
  async loginRequest(username: string, password: string): Promise<LoginResponse> {

    if (!username || !password) {
      return {
        success: false,
        message: '用户名和密码不能为空'
      };
    }
    const httpRequest: http.HttpRequest = http.createHttp();

    try {
      console.log('开始发送登录请求:', this.API_URL);
      console.log('请求参数:', JSON.stringify({ username, password }));
      const requestData: requestInfo= {
        username: username.trim(),
        password: password
      };
      console.log('发送的数据格式:', JSON.stringify(requestData));
      const response: http.HttpResponse  = await httpRequest.request(this.API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'HarmonyOS-App'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout:5000,
        readTimeout: 5000,
        usingProtocol: http.HttpProtocol.HTTP1_1,  // 指定协议
        usingCache: false  // 禁用缓存
      });

      console.log('响应状态码:', response.responseCode);
      console.log('响应头:', JSON.stringify(response.header));
      console.log('响应数据:', response.result);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as LoginResponse;
        // 确保返回格式正确
        return {
          success: result.success === true,
          message: result.message || (result.success ? '登录成功' : '登录失败')
        };
      }else if (response.responseCode === 404) {
        return {
          success: false,
          message: '该账户不存在,请先注册'
        };
      }else if (response.responseCode === 400) {
        return {
          success: false,
          message: '账号或密码错误'
        };
      }
      else {
        const errorResponse: LoginResponse = {
          success: false,
          message: `HTTP ${response.responseCode}`
        };
        return errorResponse;
      }
    } catch (error) {
      console.error('登录请求异常:', JSON.stringify(error));
      const errorResponse: LoginResponse = {
        success: false,
        message: '网络请求失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  // 保存用户数据到本地
  async saveUserData(username: string) {
    try {
      if (!this.dataPreferences) {
        return;
      }

      // 验证用户名不为空
      if (!username || username.trim() === '') {
        console.error('无法保存空的用户名');
        return;
      }
      const userInfo: UserInfo = {
        username: username,
        loginTime: Date.now()
      };

      await this.dataPreferences?.put(this.USER_INFO_KEY, JSON.stringify(userInfo));
      await this.dataPreferences?.put(this.LOGIN_STATUS_KEY, true);
      await this.dataPreferences?.flush();

      console.log('用户数据保存成功');
    } catch (error) {
      console.error('保存用户数据失败:', JSON.stringify(error));
    }
  }

  // 清除用户数据
  async clearUserData() {
    try {
      await this.dataPreferences?.delete(this.USER_INFO_KEY);
      await this.dataPreferences?.delete(this.LOGIN_STATUS_KEY);
      await this.dataPreferences?.flush();
      console.log('用户数据清除成功');
    } catch (error) {
      console.error('清除用户数据失败:', JSON.stringify(error));
    }
  }

  // 显示提示信息
  showToast(message: string) {
    console.log('提示:', message);

  }

  // 登出方法（供其他页面调用）
  async logout() {
    try {
      // 清除本地数据
      await this.clearUserData();

      // 显示登出成功提示
      this.showToast('已安全退出登录');

      // 清空输入框
      this.username = '';
      this.password = '';

      console.log('登出成功');
    } catch (error) {
      console.error('登出失败:', JSON.stringify(error));
    }
  }



  build() {
NavDestination(){
Stack() {
  Image($r('app.media.loginBac'))
    .borderRadius('30')

  Column() {
    Column({ space: 12 }) {
      Image($r('app.media.gleaf'))
        .width('64vp')
        .borderRadius(15)
        .padding(10)
        .backgroundColor('rgba(19, 236, 91, 0.3)')
      Image($r('app.media.login1'))
        .width('26vp')
        .backgroundColor(Color.White)
        .borderRadius(10)
        .padding(2)
        .position({ x: '100vp', y: '50vp' })
      Text('AgriConnect')
        .fontSize('30vp')
        .fontWeight(FontWeight.Bold)
      Text('智慧农业系统')
        .fontSize('15')
        .fontColor('#64748B')
    }

    Column({ space: 5 }) {
      Column() {
        Column({ space: 3 }) {
          Text('欢迎回来')
            .fontSize('25vp')
            .fontWeight(FontWeight.Bold)
          Text('请登录以管理您的农场')
            .fontColor('#64748B')
        }
        .margin({ top: 40, left: 20 })
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('用户名')
          TextInput({ placeholder: '请输入用户名' })
            .height('50')
            .borderRadius(16)
            .backgroundColor(Color.White)
            .border({
              color: this.usernameError?'#FF4444':'#E5E7EB',
              width: 1
            })
            .onChange((value: string) => {
              this.username = value;
              if (this.usernameError) {
                this.validateForm();
              }
              if (this.loginError) {
                this.loginError = '';
              }
            })

          if (this.usernameError) {
            Text(this.usernameError)
              .fontSize('12vp')
              .fontColor('#FF4444')
              .margin({ top: -4, bottom: 4 })
          }


          Text('密码')
            .padding({ top: 10 })
          TextInput({ placeholder: '请输入至少6位数密码' })
            .type(InputType.Password)
            .height('50')
            .borderRadius(16)
            .backgroundColor(Color.White)
            .border({
              color: this.passwordError?'#FF4444':'#E5E7EB',
              width: 1
            })
            .onChange((value: string) => {
              this.password = value;
              if (this.passwordError) {
                this.validateForm();
              }
              if (this.loginError) {
                this.loginError = '';
              }
            })
          if (this.passwordError) {
            Text(this.passwordError)
              .fontSize('12vp')
              .fontColor('#FF4444')
              .margin({ top: -4, bottom: 4 })
          }

        }
        .margin({ left: 20, right: 20, top: 20 })
        .alignItems(HorizontalAlign.Start)
      }.alignItems(HorizontalAlign.Start)
      if (this.loginError) {
        Text(this.loginError)
          .fontSize('14vp')
          .fontColor('#FF4444')
          .margin({ top: 10, left: 20, right: 20 })
          .textAlign(TextAlign.Center)
      }

      Row() {
        Text('忘记密码?')
          .fontColor('#13EC5B')
          .fontSize('16vp')
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            console.log('跳转到忘记密码页');
            NavigationManager.getInstance().push('LostPassword',{from:Login})
          })
      }
      .justifyContent(FlexAlign.End).width('100%').margin({ right: 22, top: 5 })

      Button() {
        Row({ space: 15 }) {
          Text('登录')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .fontSize('20vp')
          Image($r('app.media.arrow'))
            .width(17)

        }
      }
      .margin({ top: 15 })
      .backgroundColor('#13EC5B')
      .width('300vp')
      .height('60vp')
      .shadow({
        radius: 20,
        color: 'rgba(20,100,50,0.3)',
        offsetY: 15
      })
      .onClick(() => {
        this.handleLogin();
      })

    }
    .width('340vp')
    .height('450vp')
    .margin({ top: 25 })
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

    Row() {
      Text('第一次使用AgriConnect?')
        .fontSize('15vp')
        .fontColor('#64748B')
      Text('注册账户')
        .fontColor('#13EC5B')
        .onClick(() => {
          console.log('跳转到注册页');
          NavigationManager.getInstance().push('Register',{from:Login})
        })

    }
    .width('80%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .margin({ top: 45 })

  }
  .margin({ top: 20 })

}

  } .hideTitleBar(true)


   }
  }

