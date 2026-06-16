/**
 * Responsive Breakpoint System
 * Detects device type and screen size changes for multi-device adaptation.
 * Supports: Watch, Phone, Tablet, PC, Dual-fold, Tri-fold devices.
 */

import { mediaquery, display } from '@kit.ArkUI';

export enum DeviceBreakpoint {
  XS = 'xs',    // Watch: [0, 320vp)
  SM = 'sm',    // Phone / Folding phone outer: [320, 600vp)
  MD = 'md',    // Foldable unfolded / Tablet portrait: [600, 840vp)
  LG = 'lg',    // Tablet landscape / PC / Tri-fold expanded: [840, 1440vp)
  XL = 'xl'     // PC large / Monitor: [1440, +∞)
}

export enum DeviceCategory {
  WATCH = 'watch',
  PHONE = 'phone',
  TABLET = 'tablet',
  PC = 'pc',
  FOLDABLE_DUAL = 'foldable_dual',   // Dual foldable (Mate X5/X6)
  FOLDABLE_TRI = 'foldable_tri'       // Tri foldable (Mate XT)
}

export class BreakPointSystem {
  private static instance: BreakPointSystem;
  private currentBreakpoint: DeviceBreakpoint = DeviceBreakpoint.SM;
  private deviceCategory: DeviceCategory = DeviceCategory.PHONE;
  private isFoldable: boolean = false;
  private foldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
  private listeners: Array<(bp: DeviceBreakpoint, category: DeviceCategory) => void> = [];

  private smListener?: mediaquery.MediaQueryListener;
  private mdListener?: mediaquery.MediaQueryListener;
  private lgListener?: mediaquery.MediaQueryListener;
  private xlListener?: mediaquery.MediaQueryListener;

  private constructor() {
    // 检测是否为折叠屏设备
    try {
      this.isFoldable = display.isFoldable();
      if (this.isFoldable) {
        this.foldStatus = display.getFoldStatus();
        this.updateDeviceCategoryByFold();
      }
    } catch (e) {
      this.isFoldable = false;
    }
  }

  public static getInstance(): BreakPointSystem {
    if (!BreakPointSystem.instance) {
      BreakPointSystem.instance = new BreakPointSystem();
    }
    return BreakPointSystem.instance;
  }

  private updateDeviceCategoryByFold(): void {
    if (!this.isFoldable) {
      return;
    }
    // 根据折叠状态判断设备类型
    try {
      this.foldStatus = display.getFoldStatus();
      if (this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED && this.currentBreakpoint === DeviceBreakpoint.XS) {
        this.deviceCategory = DeviceCategory.WATCH;
      } else if (this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
        this.deviceCategory = DeviceCategory.PHONE;
      } else {
        this.deviceCategory = DeviceCategory.FOLDABLE_TRI;
      }
    } catch (e) {
      this.deviceCategory = this.detectDeviceCategoryFallback();
    }
  }

  private detectDeviceCategoryFallback(): DeviceCategory {
    switch (this.currentBreakpoint) {
      case DeviceBreakpoint.XS:
        return DeviceCategory.WATCH;
      case DeviceBreakpoint.SM:
        return DeviceCategory.PHONE;
      case DeviceBreakpoint.MD:
        return this.isFoldable ? DeviceCategory.FOLDABLE_DUAL : DeviceCategory.TABLET;
      case DeviceBreakpoint.LG:
        return this.isFoldable ? DeviceCategory.FOLDABLE_TRI : DeviceCategory.TABLET;
      case DeviceBreakpoint.XL:
        return DeviceCategory.PC;
      default:
        return DeviceCategory.PHONE;
    }
  }

  public addListener(callback: (bp: DeviceBreakpoint, category: DeviceCategory) => void): void {
    this.listeners.push(callback);
  }

  public removeListener(callback: (bp: DeviceBreakpoint, category: DeviceCategory) => void): void {
    const index = this.listeners.indexOf(callback);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    for (const listener of this.listeners) {
      listener(this.currentBreakpoint, this.deviceCategory);
    }
  }

  private updateBreakpoint(bp: DeviceBreakpoint): void {
    if (this.currentBreakpoint !== bp) {
      this.currentBreakpoint = bp;
      this.deviceCategory = this.detectDeviceCategoryFallback();
      this.notifyListeners();
    }
  }

  public register(): void {
    try {
      // 注册媒体查询监听
      this.smListener = mediaquery.matchMediaSync('(320vp<=width<600vp)');
      this.smListener.on('change', (result: mediaquery.MediaQueryResult) => {
        if (result.matches) {
          this.updateBreakpoint(DeviceBreakpoint.SM);
        }
      });

      this.mdListener = mediaquery.matchMediaSync('(600vp<=width<840vp)');
      this.mdListener.on('change', (result: mediaquery.MediaQueryResult) => {
        if (result.matches) {
          this.updateBreakpoint(DeviceBreakpoint.MD);
        }
      });

      this.lgListener = mediaquery.matchMediaSync('(840vp<=width<1440vp)');
      this.lgListener.on('change', (result: mediaquery.MediaQueryResult) => {
        if (result.matches) {
          this.updateBreakpoint(DeviceBreakpoint.LG);
        }
      });

      this.xlListener = mediaquery.matchMediaSync('(1440vp<=width)');
      this.xlListener.on('change', (result: mediaquery.MediaQueryResult) => {
        if (result.matches) {
          this.updateBreakpoint(DeviceBreakpoint.XL);
        }
      });

      // 监听折叠状态变化
      if (this.isFoldable) {
        display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
          this.foldStatus = foldStatus;
          this.updateDeviceCategoryByFold();
          this.notifyListeners();
        });
      }

      // 初始化时检测当前断点
      this.detectInitialBreakpoint();
    } catch (e) {
      console.error('BreakPointSystem register failed: ' + JSON.stringify(e));
    }
  }

  private detectInitialBreakpoint(): void {
    try {
      if (this.xlListener?.matches) {
        this.updateBreakpoint(DeviceBreakpoint.XL);
      } else if (this.lgListener?.matches) {
        this.updateBreakpoint(DeviceBreakpoint.LG);
      } else if (this.mdListener?.matches) {
        this.updateBreakpoint(DeviceBreakpoint.MD);
      } else {
        this.updateBreakpoint(DeviceBreakpoint.SM);
      }
    } catch (e) {
      this.updateBreakpoint(DeviceBreakpoint.SM);
    }
  }

  public unregister(): void {
    this.smListener?.off('change');
    this.mdListener?.off('change');
    this.lgListener?.off('change');
    this.xlListener?.off('change');
    if (this.isFoldable) {
      display.off('foldStatusChange');
    }
    this.listeners = [];
  }

  public getCurrentBreakpoint(): DeviceBreakpoint {
    return this.currentBreakpoint;
  }

  public getDeviceCategory(): DeviceCategory {
    return this.deviceCategory;
  }

  public getIsFoldable(): boolean {
    return this.isFoldable;
  }

  public getFoldStatus(): display.FoldStatus {
    return this.foldStatus;
  }
}
