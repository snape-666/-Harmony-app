import { NavigationManager } from '../common/NavigationManager'
import { Yibiaopan } from './Yibiaopan'
import { Equipment } from './Equipment'
import { Count } from './Count'
import { Rule } from './Rule'
import { Internet } from './Internet'
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { CircleShape } from '@kit.ArkUI';
import { image } from '@kit.ImageKit'
import { preferences } from '@kit.ArkData'
import { fileIo } from '@kit.CoreFileKit'
import {About} from './About'
import {Notice} from './Notice'


interface SettingItem {
  icon: ResourceStr;
  title: string;
  status: string;
  iconBgColor: ResourceColor;
  page: string
}
interface SettingItem2 {
  icon: ResourceStr;
  title: string;
  status: string;
  iconBgColor: ResourceColor;
  page: string
}
interface UserInfo {
  userId: string;
  userName: string;
  avatarBase64: string;
  loginTime: number;
}

@Entry
@Component
export struct Setting {
  @State avatarPixelMap: PixelMap | null = null;
  @State params: Record<string, Object> = {};
  @State selectedIndex: number = 3;
  @State userName: string = "username111"
  @State userId: string = ""
  @State avatarUrl: PixelMap | ResourceStr = $r('app.media.user');
  @State avatarBase64: string = '';
  @State selectedImageUri: string = '';

  private dataPreferences?: preferences.Preferences;
  private readonly USER_INFO_KEY: string = 'current_user_info';
  private readonly LOGIN_STATUS_KEY: string = 'is_logged_in';
  @State settingList: SettingItem[] = [
    {
      icon: $r('app.media.settingicon'),
      title: '网关配置',
      status: '已连接',
      iconBgColor: '#1a22c55e',
      page: 'Internet'
    },
    {
      icon: $r('app.media.auto'),
      title: '自动化规则',
      status: '3个运行中',
      iconBgColor: '#1a22c55e',
      page: 'Rule'
    },
    {
      icon: $r('app.media.alarm'),
      title: '通知设置',
      status: '',
      iconBgColor: '#1a22c55e',
      page: 'Notice'
    }
  ];
  @State settingList2: SettingItem2[] = [
    {
      icon: $r('app.media.Internet'),
      title: '语言',
      status: '中文(CN)',
      iconBgColor: '#F1F5F9',
      page: 'Words'
    },
    {
      icon: $r('app.media.about'),
      title: '关于',
      status: 'v2.4.0',
      iconBgColor: '#F1F5F9',
      page: 'About'
    }
  ];

  aboutToAppear() {
    console.log('Setting页面接收到的参数:', JSON.stringify(this.params));
    this.initPreferences();
    this.loadUserData();
    this.loadAvatarFromFile();
  }

  getContext(): Context | undefined {
    const uiContext = this.getUIContext();
    if (uiContext) {
      return uiContext.getHostContext();
    }
    return undefined;
  }

  showToast(message: string) {
    try {
      const uiContext = this.getUIContext();
      if (uiContext) {
        uiContext.getPromptAction().openToast({
          message: message,
          duration: 2000,
          bottom: 100
        });
      } else {
        console.log('Toast提示:', message);
      }
    } catch (error) {
      console.error('Toast显示失败:', error);
      console.log('Toast提示:', message);
    }
  }

  async initPreferences() {
    try {
      const context = this.getContext();
      if (context) {
        this.dataPreferences = await preferences.getPreferences(context, 'agri_connect_prefs');
        console.log('本地存储初始化成功');
      } else {
        console.error('获取Context失败');
      }
    } catch (error) {
      console.error('本地存储初始化失败:', error);
    }
  }

  async loadUserData() {
    try {
      if (!this.dataPreferences) return;

      console.log('Setting收到的完整参数', JSON.stringify(this.params));

      const loginUserName = this.params['username'] as string;
      this.userName = this.params['username'] as string || 'USER';
      console.log('设置的用户名:', this.userName);
      console.log('从params获取的用户名:', loginUserName);
      if (loginUserName && loginUserName !== '') {
        // 有登录参数，直接使用
        this.userName = loginUserName;
        console.log('设置用户名成功:', this.userName);

        // 保存用户信息到本地
        await this.saveUserData();
        console.log('用户数据加载成功:', this.userName);
      } else {
        console.log(' 没有接收到用户名参数');
        console.log('最终用户名:', this.userName);
        // 没有登录参数，从本地读取
        const userInfoStr = await this.dataPreferences.get(this.USER_INFO_KEY, '');
        if (userInfoStr) {
          const userInfo: UserInfo = JSON.parse(userInfoStr as string);
          this.userName = userInfo.userName;
          this.userId = userInfo.userId;
          // 头像从文件加载，不需要Base64
          console.log('从本地加载用户数据成功');
        }
      }
    } catch (error) {
      console.error('加载用户数据失败:', error);
    }
  }
//生成用户ID
  generateUserId(): string {
    const now = new Date();
    const year = now.getFullYear().toString().slice(-2);
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    const random = Math.floor(Math.random() * 1000000).toString().padStart(6, '0');

    this.userId = `AGR${year}${month}${day}${random}`;
    console.log('生成用户ID:', this.userId);
    return this.userId;
  }

  async saveUserData() {
    try {
      if (!this.dataPreferences) return;

      const userInfo: UserInfo = {
        userId:this.userId,
        userName: this.userName,
        avatarBase64: this.avatarBase64,
        loginTime: Date.now()
      };
      console.log('准备保存的用户信息:', JSON.stringify(userInfo));
      await this.dataPreferences.put(this.USER_INFO_KEY, JSON.stringify(userInfo));
      await this.dataPreferences.put(this.LOGIN_STATUS_KEY, true);
      await this.dataPreferences.flush();

      console.log('用户数据保存成功,用户名 ', this.userName);
    } catch (error) {
      console.error('保存用户数据失败:', error);
    }
  }

  async clearUserData() {
    try {
      if (!this.dataPreferences) return;

      await this.dataPreferences.delete(this.USER_INFO_KEY);
      await this.dataPreferences.delete(this.LOGIN_STATUS_KEY);
      await this.dataPreferences.flush();

      console.log('本地用户数据已清除');
    } catch (error) {
      console.error('清除用户数据失败:', error);
    }
  }

  // 3. 选择头像
  async selectAvatar() {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select();

      if (result.photoUris && result.photoUris.length > 0) {
        const uri = result.photoUris[0];
        this.showToast('处理中...');
        console.log('选择的URI:', uri);
        // 步骤1：将图库图片复制到应用沙箱
        const context = this.getUIContext().getHostContext();
        if (!context) {
          this.showToast('获取上下文失败');
          return;
        }
        const sandboxPath = `${context.filesDir}/temp_avatar.jpg`;
        // 关键修复：先通过 fileIo 读取文件
        const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
        const stat = fileIo.statSync(uri);
        const buffer = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buffer);
        fileIo.closeSync(file);
        const destFile = fileIo.openSync(sandboxPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
        fileIo.writeSync(destFile.fd, buffer);
        fileIo.closeSync(destFile);

        console.log('已复制到沙箱:', sandboxPath);

        // 创建图片源
        const imageSource = image.createImageSource(sandboxPath);

        // 创建PixelMap并缩放到70x70
        const pixelMap = await imageSource.createPixelMap({
          desiredSize: { width: 70, height: 70 }
        });

        // 保存到本地文件
        await this.savePixelMapToFile(pixelMap);

        // 更新显示
        this.avatarPixelMap = pixelMap;
        this.avatarUrl = pixelMap;
        // 释放资源
        // 步骤5：清理临时文件
        fileIo.unlinkSync(sandboxPath);

        imageSource.release();

        this.showToast('头像更新成功');
      }
    } catch (error) {
      console.error('选择头像失败:', error);
      this.showToast('选择头像失败');
    }
  }



  // 4. 保存PixelMap到文件
  async savePixelMapToFile(pixelMap: PixelMap): Promise<void> {
    try {
      const context = getContext(this);
      const filesDir = context.filesDir;
      const filePath = `${filesDir}/avatar.jpg`;

      // 编码为JPEG
      const imagePacker = image.createImagePacker();
      const buffer = await imagePacker.packToData(pixelMap, {
        format: 'image/jpeg',
        quality: 85
      });

      // 写入文件
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, buffer);
      fileIo.closeSync(file);

      imagePacker.release();
      console.log('头像保存成功:', filePath);
    } catch (error) {
      console.error('保存头像失败:', error);
    }
  }

  // 5. 从文件加载头像
  async loadAvatarFromFile(): Promise<void> {
    try {
      const context = getContext(this);
      const filePath = `${context.filesDir}/avatar.jpg`;

      // 检查文件是否存在
      if (!fileIo.accessSync(filePath)) {
        console.log('头像文件不存在');
        return;
      }

      // 读取文件
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(filePath);
      const buffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);

      // 转换为PixelMap
      const imageSource = image.createImageSource(buffer);
      const pixelMap = await imageSource.createPixelMap();

      this.avatarPixelMap = pixelMap;
      imageSource.release();

      console.log('头像加载成功');
    } catch (error) {
      console.error('加载头像失败:', error);
    }
  }

  // 6. 获取头像显示源
  getAvatarSource(): PixelMap | ResourceStr {
    if (this.avatarPixelMap) {
      return this.avatarPixelMap;
    }
    return $r('app.media.user');
  }
  async handleLogout() {
    await this.clearUserData();
    this.showToast('已退出登录');
    NavigationManager.getInstance().popToName('Login');
  }
  build() {
    NavDestination() {
      Row() {
        Text('设 置').fontWeight(FontWeight.Bold).fontSize('20vp')
      }.padding({ bottom: 10 })

      Column({ space: 15 }) {
        Column() {
          Row() {
            Stack() {
              Circle()
                .width(70)
                .height(70)
                .stroke('#22C55E')
                .strokeWidth(3)
                .fill(Color.White)

              Image(this.getAvatarSource())
                .width(70)
                .height(70)
                .objectFit(ImageFit.Cover)
                .borderRadius(35)
                .clip(true)
                .onClick(() => {
                  this.selectAvatar();
                })

              Image($r("app.media.edit"))
                .width(30)
                .height(30)
                .padding({ left: 7, right: 5 })
                .borderRadius(15)
                .objectFit(ImageFit.Contain)
                .fillColor(Color.White)
                .backgroundColor('#00C853')
                .position({ x: 50, y: 50 })
                .border({
                  width: 3,
                  color: Color.White
                })
                .onClick(() => {
                  this.selectAvatar();
                })
            }
            .margin({ right: 16})

            Column({ space: 5 }) {
              Text(this.params['username']as string || '--')
                .fontSize('25vp')
                .fontWeight(FontWeight.Bold)

            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .padding({left:30})

            Image($r("app.media.sun"))
              .width(40)
              .height(40)
              .fillColor("#00C853")
              .margin({ bottom: 40 })
          }
          .padding(15)
          .width("100%")
          .alignItems(VerticalAlign.Center)
        }
        .margin({ top: 15 })
        .backgroundColor(Color.White)
        .width('90%')
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 6
        })

        Text('配置管理').fontColor('#94A3B8').fontWeight(FontWeight.Bold).width('100%')
          .padding({ left: 15 })

        Column() {
          ForEach(this.settingList, (item: SettingItem, index: number) => {
            Row({ space: 15 }) {
              Image(item.icon)
                .width(45)
                .height(45)
                .objectFit(ImageFit.Contain)
                .fillColor('#13EC5B')
                .backgroundColor(item.iconBgColor)
                .borderRadius(12)
                .padding(7)

              Text(item.title)
                .fontSize('20vp')
                .fontWeight(FontWeight.Medium)
                .fontColor('#1E293B')
                .layoutWeight(1)

              if (item.status.length > 0) {
                Text(item.status)
                  .fontSize(16)
                  .fontColor('#94A3B8')
                  .margin({ right: 0 })
              }

              Image($r('app.media.next'))
                .width(16)
                .height(16)
                .fillColor('#CBD5E1')
            }
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
            .width('95%')
            .height('65vp')
            .onClick(() => {
              console.log(`点击了第${index + 1}项：${item.title}`);
              NavigationManager.getInstance().push(item.page, { from: Setting,username:this.userName })
            })

            if (index < this.settingList.length - 1) {
              Divider()
                .width('95%')
                .color('#94A3B8')
                .height(1)
                .margin(0)
            }
          }, (item: SettingItem) => item.title)
        }
        .backgroundColor(Color.White)
        .width('92%')
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 6
        })

        Text('通用').fontColor('#94A3B8').fontWeight(FontWeight.Bold).width('100%').padding({ left: 15 })

        Column() {
          ForEach(this.settingList2, (item: SettingItem2, index: number) => {
            Row({ space: 15 }) {
              Image(item.icon)
                .width(45)
                .height(45)
                .objectFit(ImageFit.Contain)
                .fillColor('#475569')
                .backgroundColor(item.iconBgColor)
                .borderRadius(12)
                .padding(10)

              Text(item.title)
                .fontSize('20vp')
                .fontWeight(FontWeight.Medium)
                .fontColor('#1E293B')
                .layoutWeight(1)

              if (item.status.length > 0) {
                Text(item.status)
                  .fontSize(16)
                  .fontColor('#94A3B8')
              }

              Image($r('app.media.next'))
                .width(16)
                .height(16)
                .fillColor('#CBD5E1')
            }
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
            .width('95%')
            .height('65vp')
            .onClick(() => {
              console.log(`点击了第${index + 1}项：${item.title}`);
              NavigationManager.getInstance().push(item.page, { from: Setting })
            })

            if (index < this.settingList.length - 1) {
              Divider()
                .width('95%')
                .color('#94A3B8')
                .height(1)
                .margin(0)
            }
          }, (item: SettingItem) => item.title)
        }
        .backgroundColor(Color.White)
        .width('92%')
        .borderRadius(20)
        .shadow({
          radius: 15,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 6
        })

        Row({ space: 10 }) {
          Image($r('app.media.allBack'))
            .width('20vp')
          Text('退出登录').fontColor('#EF4444')
        }
        .width('80%')
        .justifyContent(FlexAlign.Center)
        .height('50vp')
        .borderRadius(20)
        .border({
          color: '#FEE2E2',
          width: 2
        })
        .onClick(() => {
          this.handleLogout();
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#80f1f5f9')

      Tabs({ barPosition: BarPosition.End, index: this.selectedIndex }) {
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
        if (index === 1) {
          NavigationManager.getInstance().push('Equipment', { from: Equipment })
        }
        if (index === 2) {
          NavigationManager.getInstance().push('Count', { from: Equipment })
        }
      })
      .animationDuration(0)
    }.hideTitleBar(true)
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
}