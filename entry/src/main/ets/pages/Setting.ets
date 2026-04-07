import {NavigationManager} from '../common/NavigationManager'
import {Yibiaopan}  from './Yibiaopan'
import {Equipment}  from './Equipment'
import {Count} from './Count'
@Entry
@Component
export struct Setting {
  @State params:Record<string,Object>={};
  build() {
    NavDestination(){
      Column(){

      }

    }.hideTitleBar(true)
  }
}