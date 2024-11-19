import { HMNavigation, HMRouter } from '@hadss/hmrouter'
import { PageConstants } from '../../constants/PageConstants'
import { NavBarContent } from './NavBarContent'

@HMRouter({ pageUrl: PageConstants.NAVBAR_LIFECYCLE_IN_NST })
@Component
export struct NavBarLifecycleInDst {
  navigationId = 'NavBarLifecycleInDst'

  build() {
    HMNavigation({navigationId: this.navigationId }) {
      NavBarContent({ navigationId: this.navigationId })
    }
  }
}