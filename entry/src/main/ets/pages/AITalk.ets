import { NavigationManager } from "../common/NavigationManager";

@Entry
@Component
export struct AITalk {
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
              NavigationManager.getInstance().pop();
            })
          Text('AI助手').fontSize('25vp').fontWeight(FontWeight.Bold)
          Text('')
            .width('40vp')
            .height('40vp')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 15, right: 15 })
        Scroll(){

        }
        .backgroundColor(Color.Blue)
        .width('100%')
        .layoutWeight(1)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

    }.hideTitleBar(true)
  }
}