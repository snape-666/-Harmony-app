import { JSON } from "@kit.ArkTS";
import {NavigationManager} from '../common/NavigationManager'
import { http } from "@kit.NetworkKit";
import { preferences } from "@kit.ArkData";

interface RegisterResponse {
  success: boolean;
  message: string;
  key?: string;
}

interface GetCodeResponse {
  success: boolean;
  message: string;
  key?: string;
}

interface requestBody {
  username: string;
  password: string;
  email: string;
  key: string;
  code: string;
}

@Entry
@Component
export struct Register {
  @State params:Record<string,Object>={};
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
  @State verificationCode: string = '';
  @State verificationKey: string = '';  // 保存验证码key
  @State isLoading: boolean = false;

  // 错误信息
  @State usernameError: string = '';
  @State passwordError: string = '';
  @State confirmPasswordError: string = '';
  @State emailError: string = '';
  @State codeError: string = '';
  @State registerError: string = '';

  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State countdown: number = 0;

  private dataPreferences?: preferences.Preferences;
  private readonly API_BASE_URL: string = 'https://guet-farm.netlify.app/.netlify/functions';
  private countdownTimer?: number;


  aboutToAppear(): void {
    console.log('传入参数',JSON.stringify(this.params));
    this.initPreferences();
  }
  aboutToDisappear(): void {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
    }
    this.isLoading = false;
  }

  getContext(): Context {
    return this.getContext() as Context;
  }

  async initPreferences() {
    try {
      this.dataPreferences = await preferences.getPreferences(this.getContext(), 'agri_connect_prefs');
      console.log('本地存储初始化成功');
    } catch (error) {
      console.error('本地存储初始化失败:', error.message);
    }
  }

  // 表单验证
  validateForm(): boolean {
    let isValid: boolean = true;

    // 用户名验证
    if (!this.username || this.username.trim() === '') {
      this.usernameError = '请输入用户名';
      isValid = false;
    } else if (this.username.length < 2) {
      this.usernameError = '用户名至少2个字符';
      isValid = false;
    } else {
      this.usernameError = '';
    }

    // 密码验证
    if (!this.password) {
      this.passwordError = '请输入密码';
      isValid = false;
    } else if (this.password.length < 6) {
      this.passwordError = '密码至少6位数';
      isValid = false;
    } else {
      this.passwordError = '';
    }

    // 确认密码验证
    if (!this.confirmPassword) {
      this.confirmPasswordError = '请确认密码';
      isValid = false;
    } else if (this.confirmPassword !== this.password) {
      this.confirmPasswordError = '两次输入的密码不一致';
      isValid = false;
    } else {
      this.confirmPasswordError = '';
    }

    // 邮箱验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!this.email) {
      this.emailError = '请输入邮箱';
      isValid = false;
    } else if (!emailRegex.test(this.email)) {
      this.emailError = '请输入正确的邮箱格式';
      isValid = false;
    } else {
      this.emailError = '';
    }

    // 验证码验证
    if (!this.verificationCode) {
      this.codeError = '请输入验证码';
      isValid = false;
    } else if (this.verificationCode.length < 4) {
      this.codeError = '验证码至少4位';
      isValid = false;
    } else {
      this.codeError = '';
    }

    return isValid;
  }

  // 获取验证码 (GET请求)
  async getVerificationCode() {
    // 邮箱验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!this.email) {
      this.emailError = '请先输入邮箱';
      return;
    }
    if (!emailRegex.test(this.email)) {
      this.emailError = '请输入正确的邮箱格式';
      return;
    }

    if (this.countdown > 0) {
      console.log('请等待倒计时结束');
      return;
    }

    this.isLoading = true;

    try {
      const response = await this.getCodeRequest(this.email);
      console.log('获取验证码响应:', response);

      if (response.success) {
        // 保存验证码key
        this.verificationKey = response.key || '';
        this.showToast('验证码已发送到您的邮箱');
        this.startCountdown();
      } else {
        this.showToast(response.message || '发送失败，请重试');
      }
    } catch (error) {
      console.error('获取验证码失败:', error);
      this.showToast('发送失败，请检查网络');
    } finally {
      this.isLoading = false;
    }
  }

  // 获取验证码请求 (GET)
  async getCodeRequest(email: string): Promise<GetCodeResponse> {
    const httpRequest: http.HttpRequest = http.createHttp();
    try {
      const url = `${this.API_BASE_URL}/getCode?email=${encodeURIComponent(email)}`;
      console.log('请求URL:', url);

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout:500,
        readTimeout:500
      });

      console.log('响应状态码:', response.responseCode);
      console.log('响应数据:', response.result);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as GetCodeResponse;  // ✅ 添加 as GetCodeResponse
        return result;
      } else {
        return {
          success: false,
          message: `请求失败，状态码：${response.responseCode}`
        };
      }
    } catch (error) {
      console.error('获取验证码异常:', error.message);
      return {
        success: false,
        message: '网络请求失败'
      };
    } finally {
      httpRequest.destroy();
    }
  }

  // 注册请求
  async registerRequest(username: string, password: string, email: string, key: string, code: string): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();

    try {
      const requestBody: requestBody = {
        username: username.trim(),
        password: password,
        email: email.trim(),
        key: key,
        code: code
      };

      console.log('注册请求参数:', JSON.stringify(requestBody));

      const response = await httpRequest.request(`${this.API_BASE_URL}/register`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestBody),
        connectTimeout:500,
        readTimeout: 500
      });

      console.log('注册响应码:', response.responseCode);
      console.log('注册响应:', response.result);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as GetCodeResponse;  // ✅ 添加 as GetCodeResponse
        return result;
      } else {
        return {
          success: false,
          message: `注册失败，状态码：${response.responseCode}`
        };
      }
    } catch (error) {
      console.error('注册请求异常:', error.message);
      return {
        success: false,
        message: '网络请求失败'
      };
    } finally {
      httpRequest.destroy();
    }
  }

  // 开始倒计时
  startCountdown() {
    this.countdown = 60;
    this.countdownTimer = setInterval(() => {
      if (this.countdown > 0) {
        this.countdown--;
      } else {
        if (this.countdownTimer) {
          clearInterval(this.countdownTimer);
        }
      }
    }, 1000);
  }

  // 处理注册
  async handleRegister() {
    console.log('========== 开始注册 ==========');
    console.log('1. 用户名:', this.username);
    console.log('2. 邮箱:', this.email);
    console.log('3. 验证码:', this.verificationCode);
    console.log('4. 验证码key:', this.verificationKey);
    // 重置错误
    this.registerError = '';

    // 表单验证
    if (!this.validateForm()) {
      console.log('表单验证失败');
      return;
    }

    console.log('表单验证通过');

    // 检查是否已获取验证码
    if (!this.verificationKey) {
      this.showToast('请先获取验证码');
      return;
    }

    // 防止重复点击
    if (this.isLoading) {
      console.log('正在注册中...');
      return;
    }

    this.isLoading = true;

    try {
      const result = await this.registerRequest(
        this.username,
        this.password,
        this.email,
        this.verificationKey,
        this.verificationCode
      );
      console.log('注册接口返回:', result);
      if (result.success) {
        console.log('注册成功:', result.message);
        this.showToast('注册成功！请登录');

        // 注册成功后跳转到登录页
        setTimeout(() => {
          NavigationManager.getInstance().pop();
        }, 1000);
      } else {
        console.log('注册失败:', result.message);
        this.registerError = result.message;
        this.showToast(result.message);
      }
    } catch (error) {
      console.error('注册出错:', error);
      this.registerError = '注册失败，请重试';
      this.showToast('注册失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  showToast(message: string) {
    console.log('提示:', message);
  }


  build() {
 NavDestination() {
  Stack() {
    Image($r('app.media.loginBac'))
      .borderRadius('30')

    Column() {
      Column( ) {
        Column({ space: 3 }) {
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


        Column() {
          Scroll() {
            Column(){
            Column() {
              Column({ space: 3 }) {
                Text('欢迎注册智慧农场!')
                  .fontSize('25vp')
                  .fontWeight(FontWeight.Bold)
              }
              .margin({ top: 20, left: 20 })
              .alignItems(HorizontalAlign.Start)

              Column({ space: 5 }) {
                Text('用户名')
                TextInput({ placeholder: '请输入用户名' })
                  .height('50')
                  .borderRadius(16)
                  .backgroundColor(Color.White)
                  .border({
                    color: this.usernameError ? '#FF4444' : '#E5E7EB',
                    width: 1
                  })
                  .onChange((value: string) => {
                    this.username = value;
                    this.usernameError = '';
                    this.registerError = '';
                  })
                if (this.usernameError) {
                  Text(this.usernameError).fontSize('12vp').fontColor('#FF4444')
                }

                Text('密码')
                  .padding({ top: 10 })
                TextInput({ placeholder: '请输入至少6位数密码' })
                  .type(InputType.Password)
                  .height('50')
                  .borderRadius(16)
                  .backgroundColor(Color.White)
                  .border({
                    color: this.passwordError ? '#FF4444' : '#E5E7EB',
                    width: 1
                  })
                  .onChange((value: string) => {
                    this.password = value;
                    this.passwordError = '';
                    this.registerError = '';
                  })
                if (this.passwordError) {
                  Text(this.passwordError).fontSize('12vp').fontColor('#FF4444')
                }


                Text('确认密码')
                  .padding({ top: 10 })
                TextInput({ placeholder: '请输入至少6位数密码' })
                  .type(InputType.Password)
                  .height('50vp')
                  .borderRadius(16)
                  .backgroundColor(Color.White)
                  .border({
                    color: this.confirmPasswordError ? '#FF4444' : '#E5E7EB',
                    width: 1
                  })
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                    this.confirmPasswordError = '';
                    this.registerError = '';
                  })
                if (this.confirmPasswordError) {
                  Text(this.confirmPasswordError).fontSize('12vp').fontColor('#FF4444')
                }

                Text('邮箱')
                  .padding({ top: 10 })
                TextInput({ placeholder: '输入您的邮箱地址' })

                  .height('50vp')
                  .borderRadius(16)
                  .backgroundColor(Color.White)
                  .border({
                    color: this.emailError ? '#FF4444' : '#E5E7EB',
                    width: 1
                  })
                  .onChange((value: string) => {
                    this.email = value;
                    this.emailError = '';
                  })
                if (this.emailError) {
                  Text(this.emailError).fontSize('12vp').fontColor('#FF4444')
                }

                Text('验证码')
                  .padding({ top: 10 })
                Row({ space: 5 }) {
                  TextInput({ placeholder: '请输入验证码' })
                    .height('50vp')
                    .width('150vp')
                    .borderRadius(16)
                    .backgroundColor(Color.White)
                    .border({
                      color: this.codeError ? '#FF4444' : '#E5E7EB',
                      width: 1
                    })
                    .onChange((value: string) => {
                      this.verificationCode = value;
                      this.codeError = '';
                    })

                  Blank()
                  Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
                    .height('40vp')
                    .margin({ right: 10 })
                    .backgroundColor(this.countdown > 0 ? '#999' : '#13EC5B')
                    .enabled(this.countdown === 0 && !this.isLoading)
                    .onClick(() => {
                      this.getVerificationCode();
                    })
                }.width('100%')

                if (this.codeError) {
                  Text(this.codeError).fontSize('12vp').fontColor('#FF4444')
                }
                Flex() {
                }.flexGrow(1)
              }
              .margin({ left: 20, right: 20, top: 10 })
              .alignItems(HorizontalAlign.Start)

            }
            .alignItems(HorizontalAlign.Start)


            Button() {
              Row({ space: 15 }) {
                Text('注册')
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Black)
                  .fontSize('20vp')
                Image($r('app.media.arrow'))
                  .width(17)

              }
            }
            .margin({ top: 20, bottom: 20 })
            .backgroundColor('#13EC5B')
            .width('300vp')
            .height('50vp')
            .shadow({
              radius: 20,
              color: 'rgba(20,100,50,0.3)',
              offsetY: 15
            })
            .onClick(() => {
              this.handleRegister();
            })
          }
          }
          .scrollBar(BarState.Off)
          .scrollBarColor('#807e8396')
          .scrollBarWidth(4)
        }

        .width('340vp')
        .height('590vp')
        .margin({ top: 10 })
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




      }
      .height('100%')

    }
    .margin({bottom:30})
  }

}
.hideTitleBar(true)
}
}
