import {NavigationManager} from '../common/NavigationManager'
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.MDMKit';

interface ChangePasswordResponse {
  success: boolean;
  message: string;
  key?: string;
}

interface GetCodeResponse {
  success: boolean;
  message: string;
  key?: string;
}

interface requestBody  {
  username: string;
  newPassword: string;
  email: string;
  key: string;
  code: string;
}

@Entry
@Component
export struct LostPassword {
  @State params:Record<string,Object>={};
  @State username: string = '';
  @State email: string = '';
  @State verificationCode: string = '';
  @State verificationKey: string = '';  // 保存验证码key
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;

  // 错误信息
  @State usernameError: string = '';
  @State emailError: string = '';
  @State codeError: string = '';
  @State passwordError: string = '';
  @State confirmPasswordError: string = '';
  @State resetError: string = '';

  @State showNewPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State countdown: number = 0;

  private dataPreferences?: preferences.Preferences;
  private readonly API_BASE_URL: string = 'https://guet-farm.netlify.app/.netlify/functions';
  private countdownTimer?: number;

  aboutToAppear(): void {
    console.log('修改密码页接收到的参数:', JSON.stringify(this.params));
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

  // 实时验证确认密码
  onConfirmPasswordChange(value: string) {
    this.confirmPassword = value;
    // 实时验证
    if (!value || value.trim() === '') {
      this.confirmPasswordError = '请确认密码';
    } else if (value !== this.newPassword) {
      this.confirmPasswordError = '两次输入的密码不一致';
    } else {
      this.confirmPasswordError = '';
    }
  }

  // 实时验证新密码
  onNewPasswordChange(value: string) {
    this.newPassword = value;
    // 验证新密码
    if (!value || value.trim() === '') {
      this.passwordError = '请输入新密码';
    } else if (value.length < 6) {
      this.passwordError = '密码至少6位数';
    } else {
      this.passwordError = '';
    }

    // 如果确认密码已经输入了，重新验证确认密码
    if (this.confirmPassword) {
      if (this.confirmPassword !== value) {
        this.confirmPasswordError = '两次输入的密码不一致';
      } else {
        this.confirmPasswordError = '';
      }
    }
  }

  // 实时验证邮箱
  onEmailChange(value: string) {
    this.email = value;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!value || value.trim() === '') {
      this.emailError = '请输入邮箱';
    } else if (!emailRegex.test(value)) {
      this.emailError = '请输入正确的邮箱格式';
    } else {
      this.emailError = '';
    }
  }

  // 实时验证用户名
  onUsernameChange(value: string) {
    this.username = value;
    if (!value || value.trim() === '') {
      this.usernameError = '请输入用户名';
    } else {
      this.usernameError = '';
    }
  }

  // 实时验证验证码
  onCodeChange(value: string) {
    this.verificationCode = value;
    if (!value || value.trim() === '') {
      this.codeError = '请输入验证码';
    } else if (value.length < 4) {
      this.codeError = '验证码至少4位';
    } else {
      this.codeError = '';
    }
  }
  // 表单验证
  validateForm(): boolean {
    let isValid: boolean = true;
    console.log('开始验证表单...');
    console.log('用户名:', this.username);
    console.log('邮箱:', this.email);
    console.log('新密码:', this.newPassword);
    console.log('确认密码:', this.confirmPassword);
    console.log('验证码:', this.verificationCode);

    if (!this.username) {
      this.usernameError = '请输入用户名';
      isValid = false;
    } else if (this.username.length < 3) {
      this.usernameError = '验证码至少3位';
      isValid = false;
    } else {
      this.usernameError = '';
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

    // 新密码验证
    if (!this.newPassword || this.newPassword.trim() === '') {
      this.passwordError = '请输入新密码';
      isValid = false;
    } else if (this.newPassword.length < 6) {
      this.passwordError = '密码至少6位数';
      isValid = false;
    } else {
      this.passwordError = '';
    }

    // 确认密码验证
    if (!this.confirmPassword|| this.confirmPassword.trim() === '') {
      this.confirmPasswordError = '请确认密码';
      isValid = false;
    } else if (this.confirmPassword !== this.newPassword) {
      this.confirmPasswordError = '两次输入的密码不一致';
      isValid = false;
    } else {
      this.confirmPasswordError = '';
    }
    console.log('表单验证结果:', isValid);
    return isValid;
  }

  // 获取验证码 (GET请求)
  async getVerificationCode() {
    // 邮箱验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!this.email|| this.email.trim() === '') {
      this.emailError = '请先输入邮箱';
      this.showToast('请先输入邮箱');
      return;
    }
    if (!emailRegex.test(this.email)) {
      this.emailError = '请输入正确的邮箱格式';
      this.showToast('请输入正确的邮箱格式');
      return;
    }

    if (this.countdown > 0) {
      this.showToast(`请等待 ${this.countdown} 秒后重试`);
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
        extraData: JSON.stringify({ email: email }),  // 参数放在 body 里
        connectTimeout: 30000,
        readTimeout: 30000
      });

      console.log('响应状态码:', response.responseCode);
      console.log('响应数据:', response.result);

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
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
        message: '网络请求失败' + error.message

      };
    } finally {
      httpRequest.destroy();
    }
  }

  // 修改密码请求
  async changePasswordRequest(username: string, newPassword: string, email: string, key: string, code: string): Promise<ChangePasswordResponse> {
    const httpRequest = http.createHttp();

    try {
      const requestBody: requestBody = {
        username: username.trim(),
        newPassword: newPassword,
        email: email.trim(),
        key: key,
        code: code
      };

      console.log('修改密码请求参数:', JSON.stringify(requestBody));

      const response = await httpRequest.request(`${this.API_BASE_URL}/changepd`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestBody),
        connectTimeout: 30000,
        readTimeout: 30000
      });

      console.log('修改密码响应码:', response.responseCode);
      console.log('修改密码响应:', response.result);

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      } else {
        return {
          success: false,
          message: `修改失败，状态码：${response.responseCode}`
        };
      }
    } catch (error) {
      console.error('修改密码异常:', error.message);
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

  // 处理修改密码
  async handleResetPassword() {
    console.log('========== 开始修改密码 ==========');

    this.resetError = '';

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

    if (this.isLoading) {
      console.log('正在处理中...');
      return;
    }

    this.isLoading = true;

    try {
      const result = await this.changePasswordRequest(
        this.username,
        this.newPassword,
        this.email,
        this.verificationKey,
        this.verificationCode
      );

      if (result.success) {
        console.log('密码修改成功:', result.message);
        this.showToast('密码修改成功！请登录');

        setTimeout(() => {
          NavigationManager.getInstance().pop();
        }, 1500);
      } else {
        console.log('密码修改失败:', result.message);
        this.resetError = result.message;
        this.showToast(result.message);
      }
    } catch (error) {
      console.error('修改密码出错:', error);
      this.resetError = '修改失败，请重试';
      this.showToast('修改失败，请重试');
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
          Column() {
            Column({ space: 6 }) {
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
              Text('密码找回')
                .fontSize('15')
                .fontColor('#64748B')
            }


            Column({ space: 5 }) {
              Scroll(){
              Column() {
                Column() {
                  Column({ space: 10 }) {
                    Text('忘记密码?')
                      .fontSize('25vp')
                      .fontWeight(FontWeight.Bold)
                  }
                  .margin({ top: 20, left: 20 })
                  .alignItems(HorizontalAlign.Start)


                  Column({ space: 5 }) {
                    Text('用户名')
                      .padding({ top: 7 })
                    TextInput({ placeholder: '输入您的用户名' })
                      .height('50vp')
                      .borderRadius(16)
                      .backgroundColor(Color.White)
                      .border({
                        color: this.usernameError ? '#FF4444' : '#E5E7EB',
                        width: 1
                      })
                      .onChange((value: string) => {
                        this.onUsernameChange(value);
                      })
                    if (this.usernameError) {
                      Text(this.usernameError).fontSize('12vp').fontColor('#FF4444')
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
                        this.onEmailChange(value);
                      })
                    if (this.emailError) {
                      Text(this.emailError).fontSize('12vp').fontColor('#FF4444')
                    }


                    Text('验证码')
                      .padding({ top: 10 })
                    Row({ space: 6 }) {
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
                        .borderRadius(25)
                        .margin({ right: 10})
                        .backgroundColor(this.countdown > 0 ? '#999' : '#13EC5B')
                        .enabled(this.countdown === 0 && !this.isLoading)
                        .onClick(() => {
                          this.getVerificationCode();
                        })
                    }.width('100%')

                    if (this.codeError) {
                      Text(this.codeError).fontSize('12vp').fontColor('#FF4444')
                    }

                    Text('新密码')
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

                        this.onNewPasswordChange(value);
                      })
                    if (this.passwordError) {
                      Text(this.passwordError).fontSize('12vp').fontColor('#FF4444')
                    }
                    Text('确认密码')
                      .padding({ top: 10 })
                    TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
                      .type(InputType.Password)
                      .height('50vp')
                      .borderRadius(16)
                      .backgroundColor(Color.White)
                      .border({
                        color: this.confirmPasswordError ? '#FF4444' : '#E5E7EB',
                        width: 1
                      })
                      .onChange((value: string) => {
                        this.onConfirmPasswordChange(value);
                      })
                    if (this.confirmPasswordError) {
                      Text(this.confirmPasswordError)
                        .fontSize('12vp')
                        .fontColor('#FF4444')
                        .margin({ top: -4, bottom: 4 })
                    }
                  }
                  .margin({ left: 20, right: 20, top: 10 })
                  .alignItems(HorizontalAlign.Start)

                  Flex() {
                  }.flexGrow(1)
                }
                .alignItems(HorizontalAlign.Start)


                Button() {
                  Row({ space: 15 }) {
                    Text('提交')
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.Black)
                      .fontSize('20vp')
                    Image($r('app.media.arrow'))
                      .width(17)

                  }
                }
                .margin({ top: 20, bottom: 25 })
                .backgroundColor('#13EC5B')
                .width('300vp')
                .height('50vp')
                .shadow({
                  radius: 20,
                  color: 'rgba(20,100,50,0.3)',
                  offsetY: 15
                })
                .onClick(() => {
                  this.handleResetPassword();
                })
              }
            }.scrollBar(BarState.Off)
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

        }
        .margin({bottom:30})
      }
    }
    .hideTitleBar(true)

  }
}