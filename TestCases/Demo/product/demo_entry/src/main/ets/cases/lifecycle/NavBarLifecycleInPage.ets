import { HMNavigation, HMRouterMgr } from '@hadss/hmrouter'
import { NavBarContent } from './NavBarContent'


@Entry
@Component
export struct NavBarLifecycleInPage {
  navigationId = 'NavBarLifecycleInPage';
  private pageLifecycleId: string = HMRouterMgr.generatePageLifecycleId();

  onPageShow(): void {
    HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onShown();
  }

  onPageHide(): void {
    HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onHidden();
  }

  aboutToDisappear(): void {
    HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onDisAppear();
  }

  onBackPress(): boolean {
    return HMRouterMgr.getPageLifecycleById(this.pageLifecycleId)?.onBackPressed() as boolean;
  }

  build() {
    Column() {
      HMNavigation({navigationId: this.navigationId}) {
        NavBarContent({ navigationId: this.navigationId })
      }
    }
  }
}