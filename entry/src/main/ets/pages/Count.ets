import { NavigationManager } from "../common/NavigationManager";
import { SearchAll } from './SearchAll'
import { Yibiaopan } from './Yibiaopan'
import { Task } from './Task'
import { http } from '@kit.NetworkKit';
import {
  SensorRecord,
  parseGetDataResponseBody,
  flattenSensorData,
  filterRecordsForDay,
  seriesFromRecords,
  weekSeriesTemp,
  weekSeriesHumidity,
  weekSeriesCo2,
  formatPercentChange,
  co2StatusText,
  formatTempDisplay,
  formatHumidityDisplay,
  formatCo2Display,
  lastNumeric,
  padSeries,
  last7WeekdayLabels,
  indexOfMaxLastN
} from '../common/SensorDataParser';
import { StatAreaLineChart, StatSparkLineChart, StatBarSparkChart } from '../common/StatsCharts';

@Entry
@Component
export struct Count {
  @State params: Record<string, Object> = {};
  @State selectedIndex: number = 2;
  @State currentIndex: number = 0;

  private readonly API_URL: string = 'https://guet-farm.netlify.app/.netlify/functions/getData';
  @State records: SensorRecord[] = [];
  @State isLoading: boolean = true;
  @State loadError: string = '';
  @State chartVersion: number = 0;

  @State dayTempDisplay: string = '--';
  @State dayTempTrend: string = '--';
  @State dayTempTrendUp: boolean = true;
  @State dayTempSeries: number[] = [];

  @State dayHumDisplay: string = '--';
  @State dayHumTrend: string = '--';
  @State dayHumTrendUp: boolean = true;
  @State dayHumSeries: number[] = [];

  @State dayCo2Display: string = '--';
  @State dayCo2Series: number[] = [];
  @State dayCo2Status: string = '--';
  @State dayCo2BarIndex: number = 0;

  @State weekTempDisplay: string = '--';
  @State weekTempTrend: string = '--';
  @State weekTempTrendUp: boolean = true;
  @State weekTempSeries: number[] = [];
  @State weekAxisLabels: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @State weekHumDisplay: string = '--';
  @State weekHumTrend: string = '--';
  @State weekHumTrendUp: boolean = true;
  @State weekHumSeries: number[] = [];

  @State weekCo2Display: string = '--';
  @State weekCo2Series: number[] = [];
  @State weekCo2Status: string = '--';
  @State weekCo2BarIndex: number = 0;

  aboutToAppear(): void {
    this.fetchSensorData();
  }

  private trendUpFromText(s: string): boolean {
    if (s.length === 0 || s === '--') {
      return true;
    }
    return s.charAt(0) !== '-';
  }

  private refreshDerivedStats(): void {
    if (this.records.length === 0) {
      this.dayTempDisplay = '--';
      this.dayHumDisplay = '--';
      this.dayCo2Display = '--';
      this.dayTempTrend = '--';
      this.dayHumTrend = '--';
      this.dayTempSeries = [];
      this.dayHumSeries = [];
      this.dayCo2Series = [];
      this.dayCo2Status = '--';
      this.weekTempDisplay = '--';
      this.weekHumDisplay = '--';
      this.weekCo2Display = '--';
      this.weekTempTrend = '--';
      this.weekHumTrend = '--';
      this.weekTempSeries = [];
      this.weekHumSeries = [];
      this.weekCo2Series = [];
      this.weekCo2Status = '--';
      return;
    }

    const dayRecs = filterRecordsForDay(this.records, true);
    const dsTemp = seriesFromRecords(dayRecs, 'airTemp');
    const dsHum = seriesFromRecords(dayRecs, 'airHumidity');
    const dsCo2 = seriesFromRecords(dayRecs, 'co2');
    this.dayTempSeries = padSeries(dsTemp, 2);
    this.dayHumSeries = padSeries(dsHum, 2);
    this.dayCo2Series = padSeries(dsCo2, 2);

    this.dayTempDisplay = formatTempDisplay(lastNumeric(dsTemp));
    this.dayHumDisplay = formatHumidityDisplay(lastNumeric(dsHum));
    this.dayCo2Display = formatCo2Display(lastNumeric(dsCo2));
    this.dayCo2Status = co2StatusText(lastNumeric(dsCo2));

    const dtrend = formatPercentChange(dsTemp);
    const htrend = formatPercentChange(dsHum);
    this.dayTempTrend = dtrend === '--' ? '--' : dtrend;
    this.dayHumTrend = htrend === '--' ? '--' : `${htrend}趋势`;
    this.dayTempTrendUp = this.trendUpFromText(dtrend);
    this.dayHumTrendUp = this.trendUpFromText(htrend);

    const co2ForBar = dsCo2.length > 0 ? dsCo2 : this.dayCo2Series;
    this.dayCo2BarIndex = indexOfMaxLastN(co2ForBar, 5);

    const wt = weekSeriesTemp(this.records);
    const wh = weekSeriesHumidity(this.records);
    const wc = weekSeriesCo2(this.records);
    this.weekTempSeries = padSeries(wt, 2);
    this.weekHumSeries = padSeries(wh, 2);
    this.weekCo2Series = padSeries(wc, 2);

    this.weekTempDisplay = formatTempDisplay(lastNumeric(wt));
    this.weekHumDisplay = formatHumidityDisplay(lastNumeric(wh));
    this.weekCo2Display = formatCo2Display(lastNumeric(wc));
    this.weekCo2Status = co2StatusText(lastNumeric(wc));

    const wtd = formatPercentChange(wt);
    const wht = formatPercentChange(wh);
    this.weekTempTrend = wtd === '--' ? '--' : wtd;
    this.weekHumTrend = wht === '--' ? '--' : `${wht}趋势`;
    this.weekTempTrendUp = this.trendUpFromText(wtd);
    this.weekHumTrendUp = this.trendUpFromText(wht);

    const wcBar = wc.length > 0 ? wc : this.weekCo2Series;
    this.weekCo2BarIndex = indexOfMaxLastN(wcBar, 5);

    const labels = last7WeekdayLabels(this.records);
    if (labels.length > 0) {
      this.weekAxisLabels = labels;
    }
  }

  async fetchSensorData(): Promise<void> {
    this.isLoading = true;
    this.loadError = '';
    try {
      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(this.API_URL, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 30000,
        readTimeout: 30000
      });

      if (response.responseCode === 200) {
        const env = parseGetDataResponseBody(response.result as string);
        if (env && env.success && env.data) {
          this.records = flattenSensorData(env.data);
          this.refreshDerivedStats();
        } else {
          this.loadError = '获取数据失败';
          this.records = [];
          this.refreshDerivedStats();
        }
      } else {
        this.loadError = `请求失败 ${response.responseCode}`;
        this.records = [];
        this.refreshDerivedStats();
      }
      httpRequest.destroy();
    } catch (e) {
      console.error('Count fetchSensorData error:', e);
      this.loadError = '网络错误';
      this.records = [];
      this.refreshDerivedStats();
    } finally {
      this.isLoading = false;
      this.chartVersion++;
    }
  }

  build() {
    NavDestination() {
      Row() {
        Text('').width('40vp').height('40vp')
        Text('农场设备统计').fontWeight(FontWeight.Bold).fontSize('25vp')
        Stack() {
          Circle()
            .width('40vp')
            .height('40vp')
            .fill('#3313ec5b')
          Image($r('app.media.date'))
            .width('40vp')
            .height('40vp')
            .padding(10)
            .onClick(() => {
              NavigationManager.getInstance().push('Task', { from: Count })
            })
        }

      }.width('100%').justifyContent(FlexAlign.SpaceAround)

      Column() {
        Row() {
          this.item('日', 0)
          this.item('周', 1)
        }
        .width('70%')
        .height('40vp')
        .backgroundColor('#bfe5e6eb')
        .borderRadius(15)
        .margin({ top: 10 })
        .justifyContent(FlexAlign.SpaceAround)
        .alignSelf(ItemAlign.Center)

        if (this.isLoading) {
          Row() {
            LoadingProgress().width(32).height(32).color('#13EC5B')
            Text('加载中...').fontSize(14).fontColor('#64748B').margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 16 })
        } else if (this.loadError.length > 0) {
          Column() {
            Text(this.loadError).fontSize(14).fontColor('#EF4444')
            Text('点击重试')
              .fontSize(14)
              .fontColor('#137FEC')
              .margin({ top: 8 })
              .onClick(() => {
                this.fetchSensorData();
              })
          }
          .width('100%')
          .padding({ top: 16 })
        }

        Scroll() {
          Column() {
            if (this.currentIndex === 0) {
              this.dayPage()
            } else {
              this.weekPage()
            }
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#80f1f5f9')
        .flexShrink(0)
        .scrollBar(BarState.Off)

      }.layoutWeight(1)

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
          NavigationManager.getInstance().push('Yibiaopan', { from: Count })
        }
        if (index === 1) {
          NavigationManager.getInstance().push('Equipment', { from: Count })
        }
        if (index === 3) {
          NavigationManager.getInstance().push('Setting', { from: Count })
        }
      })
      .animationDuration(0)
    }.hideTitleBar(true)
  }

  @Builder
  item(title: string, index: number) {
    Text(title)
      .fontSize(16)
      .fontColor(this.currentIndex === index ? '#13EC5B' : '#666')
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.currentIndex === index ? '#fff' : 'transparent')
      .borderRadius(12)
      .padding({ left: 50, right: 50, top: 7, bottom: 7 })
      .onClick(() => {
        this.currentIndex = index;
        this.refreshDerivedStats();
      })
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

  @Builder
  cardList(img: string, backColor: string, title: string, area: string, date: string, time: string) {
    Row() {
      Image($r(img)).width('40vp').height('40vp')
        .backgroundColor(backColor)
        .padding(6)
        .objectFit(ImageFit.Contain)
        .borderRadius(10)
        .margin({ left: 15, right: 15 })
      Column() {
        Text(title).fontWeight(FontWeight.Bold).fontSize('15vp')
        Text(area).fontSize('10vp').fontColor('#64748B')
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Column() {
        Text(date).fontWeight(FontWeight.Bold).fontSize('13vp')
        Text(time).fontSize('10vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
      }.margin({ right: 15 })

    }
    .width('95%')
    .height('60vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({ bottom: 10 })
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })

  }

  @Builder
  dayPage() {
    Column() {
      Row() {
        Column() {
          Row({ space: 5 }) {
            Image($r('app.media.redtemper'))
              .width('12vp')
            Text('温度趋势').fontColor('#64748B').fontSize('15vp').fontWeight(FontWeight.Bold)
          }

          Text(this.dayTempDisplay).fontWeight(FontWeight.Bold).fontSize('20vp')
        }
        .alignItems(HorizontalAlign.Start)

        Text(this.dayTempTrend)
          .fontSize('10vp')
          .fontColor(this.dayTempTrendUp ? '#16A34A' : '#EF4444')
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.dayTempTrendUp ? '#DCFCE7' : '#FEE2E2')
          .borderRadius(25)
          .padding(6)
          .visibility(this.dayTempTrend === '--' ? Visibility.Hidden : Visibility.Visible)

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: 20, right: 20 })

      Column() {
        ForEach([this.chartVersion], (v: number) => {
          StatAreaLineChart({
            values: this.dayTempSeries, chartHeight: 90, lineColor: '#22C55E'
          })
        }, (v: number) => `dt-${v}`)

        Row() {
          Text('00:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('06:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('12:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('18:00').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          Text('23:59').fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)

      }.width('100%')
      .height('100vp')

    }
    .padding(0)
    .margin({ top: 20 })
    .width('95%')
    .height('180vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })

    Row({ space: 10 }) {
      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.water')).width('10vp')
            Text('湿度趋势').fontSize('12vp').fontColor('#64748B')
          }

          Text(this.dayHumDisplay).fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        ForEach([this.chartVersion], (v: number) => {
          StatSparkLineChart({
            values: this.dayHumSeries, chartHeight: 50, lineColor: '#3B82F6'
          })
        }, (v: number) => `dh-${v}`)

        Text(this.dayHumTrend)
          .fontColor(this.dayHumTrendUp ? '#16A34A' : '#EF4444')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.co2')).width('10vp')
            Text('co2水平').fontSize('12vp').fontColor('#64748B')
          }

          Text(this.dayCo2Display).fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        ForEach([this.chartVersion], (v: number) => {
          StatBarSparkChart({
            values: this.dayCo2Series, chartHeight: 50, activeIndex: this.dayCo2BarIndex
          })
        }, (v: number) => `dc-${v}`)

        Text(this.dayCo2Status)
          .fontColor(this.dayCo2Status === '最佳' ? '#22C55E' : '#64748B')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

    }
    .width('96%')
    .height('120vp')
    .margin({ top: 10, bottom: 10 })

    Row() {
      Text('历史预警').fontSize('15vp').fontWeight(FontWeight.Bold)
      Text('查看全部').fontColor('#137FEC').fontSize('15vp').fontWeight(FontWeight.Bold)
        .onClick(() => {
          NavigationManager.getInstance().push('SearchAll', { from: Count })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(10)

    this.cardList('app.media.redAlarm', '#FEE2E2', '高温预警', '温室B区-4号扇区', '今天', '14:20')
    this.cardList('app.media.shandian', '#FFEDD5', '传感器连接信号低', '主田节点#08', '今天', '09:45')
    this.cardList('app.media.success', '#1a22c55e', 'co2校准成功', '系统自动任务', '昨天', '22:00')
  }

  @Builder
  weekPage() {
    Column() {
      Row() {
        Column() {
          Row({ space: 5 }) {
            Image($r('app.media.redtemper'))
              .width('12vp')
            Text('温度趋势').fontColor('#64748B').fontSize('15vp').fontWeight(FontWeight.Bold)
          }

          Text(this.weekTempDisplay).fontWeight(FontWeight.Bold).fontSize('20vp')
        }
        .alignItems(HorizontalAlign.Start)

        Text(this.weekTempTrend)
          .fontSize('10vp')
          .fontColor(this.weekTempTrendUp ? '#16A34A' : '#EF4444')
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.weekTempTrendUp ? '#DCFCE7' : '#FEE2E2')
          .borderRadius(25)
          .padding(6)
          .visibility(this.weekTempTrend === '--' ? Visibility.Hidden : Visibility.Visible)

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: 20, right: 20 })

      Column() {
        ForEach([this.chartVersion], (v: number) => {
          StatAreaLineChart({
            values: this.weekTempSeries, chartHeight: 90, lineColor: '#22C55E'
          })
        }, (v: number) => `wt-${v}`)

        Row() {
          ForEach(this.weekAxisLabels, (label: string, idx: number) => {
            Text(label).fontSize('8vp').fontWeight(FontWeight.Bold).fontColor('#94A3B8')
          }, (label: string, idx: number) => `wl-${idx}`)
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)

      }.width('100%')
      .height('100vp')

    }
    .padding(0)
    .margin({ top: 20 })
    .width('95%')
    .height('180vp')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 8
    })

    Row({ space: 10 }) {
      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.water')).width('10vp')
            Text('湿度趋势').fontSize('12vp').fontColor('#64748B')
          }

          Text(this.weekHumDisplay).fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        ForEach([this.chartVersion], (v: number) => {
          StatSparkLineChart({
            values: this.weekHumSeries, chartHeight: 50, lineColor: '#3B82F6'
          })
        }, (v: number) => `wh-${v}`)

        Text(this.weekHumTrend)
          .fontColor(this.weekHumTrendUp ? '#16A34A' : '#EF4444')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

      Column() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.co2')).width('10vp')
            Text('co2水平').fontSize('12vp').fontColor('#64748B')
          }

          Text(this.weekCo2Display).fontSize('16vp').fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 15, top: 10 })

        ForEach([this.chartVersion], (v: number) => {
          StatBarSparkChart({
            values: this.weekCo2Series, chartHeight: 50, activeIndex: this.weekCo2BarIndex
          })
        }, (v: number) => `wc-${v}`)

        Text(this.weekCo2Status)
          .fontColor(this.weekCo2Status === '最佳' ? '#22C55E' : '#64748B')
          .fontSize('8vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 15, top: 8 })

      }
      .height('120vp')
      .width('48%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 8
      })

    }
    .width('96%')
    .height('120vp')
    .margin({ top: 10, bottom: 10 })

    Row() {
      Text('历史预警').fontSize('15vp').fontWeight(FontWeight.Bold)
      Text('查看全部').fontColor('#137FEC').fontSize('15vp').fontWeight(FontWeight.Bold)
        .onClick(() => {
          NavigationManager.getInstance().push('SearchAll', { from: Count })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(10)

    this.cardList('app.media.redAlarm', '#FEE2E2', '高温预警', '温室B区-4号扇区', '今天', '14:20')
    this.cardList('app.media.shandian', '#FFEDD5', '传感器连接信号低', '主田节点#08', '今天', '09:45')
    this.cardList('app.media.success', '#1a22c55e', 'co2校准成功', '系统自动任务', '昨天', '22:00')
  }
}
