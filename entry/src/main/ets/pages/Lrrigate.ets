import { Font } from "@ohos.arkui.UIContext";
import {NavigationManager} from '../common/NavigationManager'
import {AllHistory} from './AllHistory'
import { promptAction } from "@kit.ArkUI";
import { preferences } from '@kit.ArkData';
import { http } from '@kit.NetworkKit';
import { GlobalStateService } from '../service/GlobalStateService';
// 传感器数据接口
interface SensorDataResponse {
  success: boolean;
  count: number;
  data: Record<string, Record<string, SoilData>>;
}

interface SoilData {
  soil_humidity: string;
  time?: string;
}

interface GeneratedObjectLiteralInterface_1 {
  left: number;
  right: number;
  top: number;
  bottom: number;
}

@Entry
@Component
export struct Lrrigate {
  @State params:Record<string,Object>={};
  // ==================== 灌溉相关状态 ====================
  @State isWaterOn: boolean = false;           // 水泵开关状态
  @State targetWaterVolume: number = 500;       // 目标灌溉量 (L)，从设备页面同步
  @State currentIrrigated: number = 0;          // 当前已灌溉量 (L)
  @State progress: number = 0;                  // 进度百分比
  @State remainingMinutes: number = 0;          // 预计剩余分钟数

  // ==================== 今日/昨日灌溉量 ====================
  @State todayTotal: number = 0;                // 今日累计灌溉量 (L)
  @State yesterdayTotal: number = 0;             // 昨日累计灌溉量 (L)
  @State comparePercent: number = 0;             // 对比百分比
  @State isTrendUp: boolean = true;              // 上升/下降

  // ==================== 土壤湿度数据 ====================
  @State soilHumidityValues: number[] = [];      // 最近24小时土壤湿度数据
  @State isLoading: boolean = true;

  // ==================== 定时器 ====================
  private irrigationTimer: number = -1;          // 灌溉计时器
  private startTime: number = 0;                 // 灌溉开始时间戳
  private startWaterVolume: number = 0;          // 开始时的已灌溉量

  // ==================== 服务实例 ====================
  private globalStateService: GlobalStateService = GlobalStateService.getInstance();
  private preferencesInstance?: preferences.Preferences;
  private readonly STORAGE_NAME: string = 'irrigation_stats';

  // API 地址
  private readonly GET_DATA_URL: string = 'https://guet-farm.netlify.app/.netlify/functions/getData';

  // 土壤湿度颜色（透明度由低到高）
  private readonly HUMIDITY_COLORS: string[] = [
    'rgba(34,197,94,0.15)',  // 最低
    'rgba(34,197,94,0.30)',
    'rgba(34,197,94,0.45)',
    'rgba(34,197,94,0.60)',
    'rgba(34,197,94,0.75)',
    'rgba(34,197,94,0.90)',  // 最高
  ];
  private soilHumidityContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(
    new RenderingContextSettings(true)
  );
  async aboutToAppear(): Promise<void> {
    console.log('灌溉助手页面初始化');

    // 初始化本地存储
    await this.initPreferences();

    // 加载今日/昨日灌溉量
    await this.loadDailyStats();

    // 从全局状态获取目标灌溉量
    this.loadTargetFromGlobal();

    // 监听全局状态变化
    this.listenToGlobalChanges();

    // 加载土壤湿度数据
    await this.fetchSoilHumidityData();

    // 每10秒刷新土壤湿度
    setInterval(() => {
      this.fetchSoilHumidityData();
    }, 10000);
  }

  aboutToDisappear(): void {
    if (this.irrigationTimer !== -1) {
      clearInterval(this.irrigationTimer);
    }
  }

  /**
   * 初始化本地存储
   */
  async initPreferences(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext();
      if (context) {
        this.preferencesInstance = await preferences.getPreferences(context, this.STORAGE_NAME);
      }
    } catch (error) {
      console.error('初始化存储失败:', error);
    }
  }

  /**
   * 加载今日/昨日灌溉量
   */
  async loadDailyStats(): Promise<void> {
    try {
      const today = this.getTodayKey();
      const yesterday = this.getYesterdayKey();

      if (this.preferencesInstance) {
        this.todayTotal = await this.preferencesInstance.get(today, 0) as number;
        this.yesterdayTotal = await this.preferencesInstance.get(yesterday, 0) as number;
        // 如果没有真实数据，使用模拟数据
        if (this.todayTotal === 0 && this.yesterdayTotal === 0) {
          this.todayTotal = this.getMockTodayTotal();
          this.yesterdayTotal = this.getMockYesterdayTotal();
        }
        // 计算对比百分比
        if (this.yesterdayTotal > 0) {
          this.comparePercent = ((this.todayTotal - this.yesterdayTotal) / this.yesterdayTotal) * 100;
          this.isTrendUp = this.comparePercent >= 0;
        } else if (this.todayTotal > 0) {
          this.comparePercent = 100;
          this.isTrendUp = true;
        } else {
          this.comparePercent = 0;
          this.isTrendUp = true;
        }
      }
    else
    {
      // 无存储时使用模拟数据
      this.todayTotal = this.getMockTodayTotal();
      this.yesterdayTotal = this.getMockYesterdayTotal();
      this.comparePercent = ((this.todayTotal - this.yesterdayTotal) / this.yesterdayTotal) * 100;
      this.isTrendUp = this.comparePercent >= 0;
    }
  }
    catch (error) {
      console.error('加载日统计失败:', error);
      this.todayTotal = this.getMockTodayTotal();
      this.yesterdayTotal = this.getMockYesterdayTotal();
      this.comparePercent = ((this.todayTotal - this.yesterdayTotal) / this.yesterdayTotal) * 100;
      this.isTrendUp = this.comparePercent >= 0;
    }
  }

  /**
   * 保存今日灌溉量
   */
  async saveTodayTotal(additional: number): Promise<void> {
    try {
      this.todayTotal += additional;
      if (this.preferencesInstance) {
        const today = this.getTodayKey();
        await this.preferencesInstance.put(today, this.todayTotal);
        await this.preferencesInstance.flush();
      }
      // 重新计算对比
      if (this.yesterdayTotal > 0) {
        this.comparePercent = ((this.todayTotal - this.yesterdayTotal) / this.yesterdayTotal) * 100;
        this.isTrendUp = this.comparePercent >= 0;
      } else if (this.todayTotal > 0) {
        this.comparePercent = 100;
        this.isTrendUp = true;
      }
    } catch (error) {
      console.error('保存今日灌溉量失败:', error);
    }
  }

  /**
   * 获取今日日期键
   */
  private getTodayKey(): string {
    const now = new Date();
    return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
  }

  /**
   * 获取昨日日期键
   */
  private getYesterdayKey(): string {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return `${yesterday.getFullYear()}-${yesterday.getMonth() + 1}-${yesterday.getDate()}`;
  }

  /**
   * 从全局状态加载目标灌溉量
   */
  private loadTargetFromGlobal(): void {
    const globalState = this.globalStateService.getState();
    this.targetWaterVolume = globalState.targetWaterVolume;
    console.log('目标灌溉量:', this.targetWaterVolume);
  }

  /**
   * 监听全局状态变化
   */
  private listenToGlobalChanges(): void {
    this.globalStateService.addListener((newState) => {
      this.targetWaterVolume = newState.targetWaterVolume;
      // 如果灌溉未进行中，更新进度显示
      if (!this.isWaterOn && this.currentIrrigated < this.targetWaterVolume) {
        this.progress = (this.currentIrrigated / this.targetWaterVolume) * 100;
      }
    });
  }

  /**
   * 获取土壤湿度数据
   */
  async fetchSoilHumidityData(): Promise<void> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(this.GET_DATA_URL, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const outerData = JSON.parse(response.result as string) as SensorDataResponse;

        if (outerData.success && outerData.data) {
          const allData: SoilData[] = [];

          // 遍历所有日期和时间点
          Object.values(outerData.data).forEach(dateData => {
            Object.values(dateData).forEach(sensorItem => {
              if (sensorItem && sensorItem.soil_humidity) {
                allData.push(sensorItem);
              }
            });
          });

          // 按时间排序，取最近24条（约24小时）
          allData.sort((a, b) => {
            const timeA = a.time || '';
            const timeB = b.time || '';
            return timeA.localeCompare(timeB);
          });

          // 取最近24条数据
          const recentData = allData.slice(-24);

          // 解析土壤湿度值
          this.soilHumidityValues = recentData.map(item => {
            const match = item.soil_humidity.match(/\d+(\.\d+)?/);
            return match ? parseFloat(match[0]) : 0;
          });

          this.isLoading = false;
        }
      }
      httpRequest.destroy();
    } catch (error) {
      console.error('获取土壤湿度失败:', error);
      this.isLoading = false;
    }
    // 无数据或请求失败时，使用模拟数据
    this.soilHumidityValues = this.generateMockSoilHumidityData();
    this.isLoading = false;
    console.log('使用模拟土壤湿度数据:', this.soilHumidityValues);
  }

  /**
   * 开启/关闭水泵
   */
  async toggleWater(isOn: boolean): Promise<void> {
    if (isOn) {
      // 检查目标灌溉量是否有效
      if (this.targetWaterVolume <= 0) {
        promptAction.openToast({ message: '请先设置有效的目标灌溉量', duration: 2000 });
        this.isWaterOn = false;
        return;
      }

      // 开始灌溉
      this.startIrrigation();
    } else {
      // 停止灌溉
      this.stopIrrigation();
    }
  }

  /**
   * 开始灌溉
   */
  private startIrrigation(): void {
    this.isWaterOn = true;
    this.startTime = Date.now();
    this.currentIrrigated = 0;
    this.progress = 0;

    // 模拟灌溉速率：假设 0.5L/分钟（可根据实际情况调整）
    // 这里使用定时器模拟，实际应从硬件获取实时已灌溉量
    this.irrigationTimer = setInterval(() => {
      if (!this.isWaterOn) return;

      // 模拟每秒增加灌溉量（0.5L/分钟 = 0.00833L/秒）
      const increment = 0.00833 * 1; // 每秒增加
      this.currentIrrigated += increment;

      // 计算进度
      this.progress = (this.currentIrrigated / this.targetWaterVolume) * 100;
      if (this.progress > 100) this.progress = 100;

      // 计算剩余时间
      const elapsedMinutes = (Date.now() - this.startTime) / 1000 / 60;
      const rate = this.currentIrrigated / elapsedMinutes;
      if (rate > 0 && this.currentIrrigated < this.targetWaterVolume) {
        const remaining = (this.targetWaterVolume - this.currentIrrigated) / rate;
        this.remainingMinutes = Math.ceil(remaining);
      }

      // 达到目标灌溉量，自动停止
      if (this.currentIrrigated >= this.targetWaterVolume) {
        this.stopIrrigation(true);
      }
    }, 1000);
  }

  /**
   * 停止灌溉
   * @param completed 是否完成灌溉
   */
  private async stopIrrigation(completed: boolean = false): Promise<void> {
    if (this.irrigationTimer !== -1) {
      clearInterval(this.irrigationTimer);
      this.irrigationTimer = -1;
    }

    if (completed && this.currentIrrigated > 0) {
      // 保存今日灌溉量
      await this.saveTodayTotal(this.currentIrrigated);
      promptAction.openToast({ message: '灌溉完成！', duration: 2000 });
    }

    this.isWaterOn = false;
  }

  /**
   * 格式化剩余时间
   */
  private formatRemainingTime(): string {
    if (this.remainingMinutes <= 0) return '计算中...';
    if (this.remainingMinutes < 60) {
      return `预计还剩${this.remainingMinutes}分钟完成`;
    }
    const hours = Math.floor(this.remainingMinutes / 60);
    const minutes = this.remainingMinutes % 60;
    return `预计还剩${hours}小时${minutes}分钟完成`;
  }

  /**
   * 绘制土壤湿度柱状图（Canvas）
   */
  private drawSoilHumidityChart(context: CanvasRenderingContext2D, width: number, height: number): void {
    let  values = this.soilHumidityValues;
    if (values.length === 0) {
      values = this.generateMockSoilHumidityData();
    }

    // 计算最大值（至少为1）
    let maxValue = Math.max(...values);
    if (maxValue < 1) maxValue = 100;

    const padding: GeneratedObjectLiteralInterface_1 = { left: 8, right: 8, top: 10, bottom: 20 };
    const chartWidth = width - padding.left - padding.right;
    const chartHeight = height - padding.top - padding.bottom;
    const barCount = values.length;
    const barWidth = (chartWidth - (barCount - 1) * 2) / barCount; // 柱宽，间隙2px

    context.clearRect(0, 0, width, height);
    // 颜色透明度数组
    const colors: string[] = [
      'rgba(34,197,94,0.15)',
      'rgba(34,197,94,0.30)',
      'rgba(34,197,94,0.45)',
      'rgba(34,197,94,0.60)',
      'rgba(34,197,94,0.75)',
      'rgba(34,197,94,0.90)',
    ];
    // 绘制每个柱状
    for (let i = 0; i < barCount; i++) {
      const value = values[i];
      const barHeight = (value / maxValue) * chartHeight;
      const x = padding.left + i * (barWidth + 2);
      const y = padding.top + chartHeight - barHeight;

      // 根据高度决定颜色透明度
      const ratio = value / maxValue;
      const colorIndex = Math.min(Math.floor(ratio * this.HUMIDITY_COLORS.length), this.HUMIDITY_COLORS.length - 1);
      context.fillStyle = this.HUMIDITY_COLORS[colorIndex];
      context.fillRect(x, y, barWidth, barHeight);
    }

    // 绘制时间刻度（简略）
    context.fillStyle = '#94A3B8';
    context.font = '12vp sans-serif';
    const timeLabels = ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:00'];
    const step = barCount / timeLabels.length;
    for (let i = 0; i < timeLabels.length; i++) {
      const x = padding.left + i * step * (barWidth + 2);
      context.fillText(timeLabels[i], x, height-1);
    }
  }
  /**
   * 生成模拟土壤湿度数据（24小时，数值在 30-85 之间波动）
   */
  private generateMockSoilHumidityData(): number[] {
    const mockData: number[] = [];
    // 模拟一天中土壤湿度的变化：凌晨较高，中午较低，傍晚回升
    for (let i = 0; i < 24; i++) {
      let value: number;
      if (i >= 2 && i <= 8) {
        // 凌晨到清晨：湿度较高
        value = 70 + Math.random() * 15;
      } else if (i >= 11 && i <= 15) {
        // 中午：湿度较低
        value = 35 + Math.random() * 20;
      } else {
        // 其他时间：中等湿度
        value = 50 + Math.random() * 25;
      }
      mockData.push(Math.round(value));
    }
    return mockData;
  }

  /**
   * 生成模拟今日灌溉量（最近7天）
   */
  private getMockTodayTotal(): number {
    return 2.5; // 2.5L
  }

  /**
   * 生成模拟昨日灌溉量
   */
  private getMockYesterdayTotal(): number {
    return 2.2; // 2.2L
  }
  build() {
   NavDestination(){
     Column() {
       Row() {
         Image($r('app.media.back'))
           .backgroundColor('#E2E8F0')
           .width('40vp')
           .height('40vp')
           .borderRadius(20)
           .padding(9)
           .onClick(()=>{
             NavigationManager.getInstance().pop()
           })
         Text('灌溉助手').fontSize('25vp').fontWeight(FontWeight.Bold)
         Text('')
           .width('40vp')
           .height('40vp')
       }.width('100%').justifyContent(FlexAlign.SpaceAround)

       Scroll() {
         Column() {
           Column() {
           Row() {
             Text('智能水阀')
               .fontSize('20vp')
               .fontWeight(FontWeight.Bold)
               .fontColor('#13EC5B')
             Blank()
             Toggle({
               type: ToggleType.Switch,
               isOn: this.isWaterOn
             })
               .selectedColor('#13EC5B')
               .switchPointColor(Color.White)
               .onChange((newState: boolean) => {
                 this.isWaterOn = newState;
                 console.log('开关状态：', newState);
               })
               .width('50vp')
               .height('30vp')
           }.width('100%').padding({ left: 20, right: 20, top: 10 })

           Row({ space: 10 }) {
             Text(`${this.todayTotal.toFixed(1)}L`).fontWeight(FontWeight.Bold).fontSize('33vp')
             Row() {
               Image(this.isTrendUp ? $r('app.media.up') : $r('app.media.down')).width('15vp')
               Text(`${Math.abs(this.comparePercent).toFixed(1)}%对比昨天`)  .fontColor(this.isTrendUp ? '#22C55E' : '#EF4444')
             }
           }.width('100%').justifyContent(FlexAlign.Start).padding({ left: 20, top: 10 })

           Text('基于当前土壤湿度及天气预测，建议开启灌溉').fontSize('13vp').fontColor('#64748B')
             .width('100%').padding(15)
         }
         .margin({top:10})
         .width('95%')
         .backgroundColor(Color.White)
         .borderRadius(20)
         .shadow({
           radius: 100,
           color: '#3313ec5b',
           offsetX: 0,
           offsetY: 0
         })

         Row() {
           Text('实时灌溉').fontSize('20vp').fontWeight(FontWeight.Bold)
           Text('灌溉区').fontColor('#22C55E').fontWeight(FontWeight.Bold).fontSize('15vp')
         }
         .width('100%')
           .justifyContent(FlexAlign.SpaceBetween)
           .padding({left:20,right:20,top:20})

         Column(){
             Row(){
               Text('进展').fontColor('#64748B').fontWeight(FontWeight.Bold)
               Text(`${this.currentIrrigated.toFixed(1)}L/${this.targetWaterVolume}L`).fontWeight(FontWeight.Bold)
             }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(15)

           // 进度条容器
           Stack() {
             // 灰色底
             Row().width('100%').height(10).backgroundColor('#E5E7EB').borderRadius(5)

             // 绿色进度
             Row()
               .width(`${this.progress}%`)
               .height(10)
               .backgroundColor('#22C55E')
               .borderRadius(5)
           }
           .alignContent(Alignment.TopStart)
           .width('90%')

           Text(this.formatRemainingTime()).fontColor('#22C55E').fontSize('12vp')
             .width('100%')
             .padding({left:20,top:15})
         }
         .width('95%')
         .height('100vp')
         .backgroundColor(Color.White)
         .borderRadius(20)
         .shadow({
           radius: 100,
           color: '#3313ec5b',
           offsetX: 0,
           offsetY: 0
         })
           .margin({top:20})

           Row(){
             Text('土壤湿度水平').fontSize('20vp').fontWeight(FontWeight.Bold)
             Text('过去24H').fontColor('#22C55E').fontWeight(FontWeight.Bold).fontSize('13vp')
               .backgroundColor('#3322c55e')
               .borderRadius(15).padding(5)
           }
           .width('100%').justifyContent(FlexAlign.SpaceBetween)
           .padding({top:15,left:15,right:15})

           Column(){
             if (this.isLoading) {
               Row() {
                 LoadingProgress().width(32).height(32).color('#13EC5B')
                 Text('加载中...').fontSize(14).fontColor('#64748B').margin({ left: 8 })
               }
               .width('100%')
               .height('100vp')
               .justifyContent(FlexAlign.Center)
             } else {
               Canvas(this.soilHumidityContext)
                 .width('95%')
                 .height('95%')
                 .onReady(() => {
                   this.drawSoilHumidityChart(this.soilHumidityContext, 300, 100);
                 })
                 .onAreaChange((oldVal: Area, newVal: Area) => {
                   const width: number = newVal.width as number;
                   const height: number = newVal.height as number;
                   if (width > 1 && height > 1) {
                     this.drawSoilHumidityChart(this.soilHumidityContext, width, height);
                   }
                 })
             }

           }
           .width('95%')
           .height('140vp')
           .backgroundColor(Color.White)
           .borderRadius(20)
           .shadow({
             radius: 100,
             color: '#3313ec5b',
             offsetX: 0,
             offsetY: 0
           })
           .margin({top:20,bottom:20})

           Row(){
             Text('最近历史').fontWeight(FontWeight.Bold).fontSize('20vp')
             Text('查看全部').fontWeight(FontWeight.Bold).fontColor('#22C55E')
               .fontSize('18vp')
               .onClick(()=>{
                 NavigationManager.getInstance().push('AllHistory',{from:Lrrigate})
               })

           }
           .width('100%')
           .justifyContent(FlexAlign.SpaceBetween)
           .padding({left:15,right:15})

           this.cardList('app.media.gwater','自动灌溉','昨天,08:30AM-2.2L','成功')
           this.cardList('app.media.put','手动增压','两天前,04:15PM-0.5L','成功' )





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
  @Builder
  cardList(img:string,title:string,time:string,state:string){
    Row(){
      Image($r(img))
        .width('46vp')
        .height('46vp')
        .borderRadius(23)
        .objectFit(ImageFit.Contain)
        .padding(12)
        .backgroundColor('#1a22c55e')
        .margin({right:15})
      Column(){
        Text(title).fontWeight(FontWeight.Bold).fontSize('20vp')
        Text(time).fontColor('#64748B').fontSize('13vp')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text(state).fontColor('#22C55E').fontWeight(FontWeight.Bold).fontSize('13vp')
        .backgroundColor('#1a22c55e').padding(7).borderRadius(12)
    }
    .width('95%')
    .height('70vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 100,
      color: '#3313ec5b',
      offsetX: 0,
      offsetY: 0
    })
    .padding({left:15,right:15})
    .margin({top:20})

  }


}