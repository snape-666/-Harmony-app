import { NavigationManager } from "../common/NavigationManager";
import { preferences } from "@kit.ArkData";

@Entry
@Component
export struct About {
  @State params:Record<string,Object>={};
  @State username: string = '';
  @State currentRating: number = 0;
  private preferencesInstance: preferences.Preferences | null = null;
  private readonly STORAGE_NAME: string = 'user_ratings';
  aboutToAppear() {
    // 获取从 Setting 传入的 username
    if (this.params && this.params['username']) {
      this.username = this.params['username'] as string;
      console.log('About页面接收到的用户名:', this.username);
    }
    // 加载该用户的评分
    this.loadRatingFromLocal();
  }

  async loadRatingFromLocal() {
    try {
      if (!this.username || this.username === '') {
        console.log('用户名为空，跳过加载评分');
        return;
      }
      const context = this.getUIContext().getHostContext();
      if (!context) {
        console.error('获取Context失败');
        return;
      }
      let dataPreferences = await preferences.getPreferences(context, this.STORAGE_NAME);
      this.preferencesInstance = dataPreferences;
      let savedRating = await dataPreferences.get(this.username, 0) as number;
      this.currentRating = savedRating;
      console.log(`加载用户 ${this.username} 的评分: ${savedRating}`);
    } catch (error) {
      console.error(`加载评分失败: ${error}`);
    }
  }

  async saveRatingToLocal(rating: number) {
    if (!this.username || this.username === '') {
      console.log('用户名为空，跳过保存评分');
      return;
    }
    const context = this.getUIContext().getHostContext();
    if (!context) {
      console.error('获取Context失败');
      return;
    }
    if (!this.preferencesInstance) {
      try {
        this.preferencesInstance = await preferences.getPreferences(context, this.STORAGE_NAME);
      } catch (error) {
        console.error(`获取存储失败: ${error}`);
        return;
      }
    }
    try {
      await this.preferencesInstance.put(this.username, rating);
      await this.preferencesInstance.flush();
      console.info(`已保存用户 ${this.username} 的评分: ${rating}`);
    } catch (error) {
      console.error(`保存评分失败: ${error}`);
    }
  }

  handleRating(index: number) {
    let newRating = index + 1;
    this.currentRating = newRating;
    this.saveRatingToLocal(newRating);
  }

  build() {
    NavDestination(){
      Column(){
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
          Text('关于').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })
Column(){
  Column({ space: 12 }) {
    Image($r('app.media.gleaf'))
      .width('64vp')
      .borderRadius(15)
      .padding(10)
      .objectFit(ImageFit.Contain)
      .backgroundColor('rgba(19, 236, 91, 0.3)')
    Image($r('app.media.login1'))
      .width('26vp')
      .backgroundColor(Color.White)
      .borderRadius(10)
      .padding(2)
      .position({ x: '160vp', y: '50vp' })
    Text('AgriConnect')
      .fontSize('30vp')
      .fontWeight(FontWeight.Bold)
   Text('版本号1.2.0').fontWeight(FontWeight.Bold).fontColor('#64748B')
    Column({space:10}){
      Image($r('app.media.smile'))
        .width('77vp')
        .margin({top:15})
      Text('为APP打个分吧').fontWeight(FontWeight.Bold).fontSize('20vp')
      Row(){
        ForEach([0, 1, 2, 3, 4], (index: number) => {
          Image($r('app.media.star'))
            .width('25vp')
            .fillColor(this.currentRating > index ? '#00FF00' : '#CCCCCC')  // 绿色 vs 灰色
            .onClick(() => {
              this.handleRating(index);
            })
        }, (index: number) => index.toString())
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('75%')

    }
    .backgroundColor(Color.White)
    .width('80%')
    .height('200vp')
    .borderRadius(20)
    .margin({top:50})
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 6
    })
  }
  .margin({top:20,bottom:20})



}
.width('100%')
.layoutWeight(1)
.backgroundColor('#80f1f5f9')

        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }.hideTitleBar(true)
  }
}