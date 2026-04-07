import { NavigationManager } from '../common/NavigationManager';

@Entry
@Component
export struct Rule {
  @State params:Record<string,Object>={};

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
          Text('自动化规则').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 15, right: 15 })

        Scroll(){
          Column(){
            Row(){
              Text('自动行为').fontColor('#64748B')
              Text('3个运行中').fontColor('#13EC5B')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(20)








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
}