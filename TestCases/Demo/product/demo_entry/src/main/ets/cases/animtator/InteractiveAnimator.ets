import { HMAnimator, HMAnimatorHandle,
  HMRouterMgr,
  IHMAnimator, OpacityOption, ScaleOption, TranslateOption } from '@hadss/hmrouter'

@HMAnimator({ animatorName: 'interactiveAnimator' })
export class InteractiveAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '100%'
      opacityOption.opacity = 0.4
    })
    enterHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0'
      opacityOption.opacity = 1
    })
    enterHandle.onFinish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0'
      opacityOption.opacity = 1
    })

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0'
      opacityOption.opacity = 1
    })
    exitHandle.finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '100%'
      opacityOption.opacity = 0.4
    })
    exitHandle.onFinish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption) => {
      translateOption.x = '0'
      opacityOption.opacity = 0.4
    })
  }

  interactive(handle: HMAnimatorHandle): void {
    handle.actionStart((event: GestureEvent) => {
      if (event.offsetX > 0) {
        HMRouterMgr.pop()
      }
    })
    handle.updateProgress((event, proxy, operation, startOffset) => {
      if (!proxy?.updateTransition || !startOffset) {
        return
      }
      let offset = 0
      if (event.fingerList[0]) {
        offset = event.fingerList[0].localX - startOffset;
      }
      if (offset < 0) {
        proxy?.updateTransition(0)
        return;
      }
      let rectWidth = event.target.area.width as number
      let rate = offset / rectWidth
      proxy?.updateTransition(rate)
    })
    handle.actionEnd((event, proxy, operation, startOffset) => {
      if (!startOffset) {
        return
      }
      let rectWidth = event.target.area.width as number
      let rate = 0
      if (event.fingerList[0]) {
        rate = (event.fingerList[0].localX - startOffset) / rectWidth
      }
      if (rate > 0.4) {
        proxy?.finishTransition()
      } else {
        proxy?.cancelTransition?.()
      }
    })
  }
}