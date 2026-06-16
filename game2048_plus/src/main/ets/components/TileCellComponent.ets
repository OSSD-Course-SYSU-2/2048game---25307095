/**
 * TileCell Component - 2048游戏方块组件
 * 使用 @Component 替代 @Builder，确保 ArkTS 状态管理能正确触发 UI 刷新
 */

import { TILE_COLORS, TILE_TEXT_COLORS } from '../constants/GameConstants';

@Component
export struct TileCellComponent {
  @Prop value: number = 0;  // 使用 @Prop 确保响应式更新
  @Prop tileSize: number = 60;
  @Prop borderRadius_: number = 6;

  private getTileBgColor(val: number): string {
    if (val === 0) {
      return 'rgba(238, 228, 218, 0.35)';
    }
    return TILE_COLORS[val] || '#3C3A32';
  }

  private getTileTextColor(val: number): string {
    return TILE_TEXT_COLORS[val] || '#FFFFFF';
  }

  private getTileFontSize(val: number): number {
    if (val < 100) {
      return this.tileSize * 0.4;
    } else if (val < 1000) {
      return this.tileSize * 0.35;
    } else {
      return this.tileSize * 0.25;
    }
  }

  build() {
    Stack() {
      if (this.value > 0) {
        Text(this.value.toString())
          .fontSize(this.getTileFontSize(this.value))
          .fontColor(this.getTileTextColor(this.value))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .borderRadius(this.borderRadius_)
    .backgroundColor(this.getTileBgColor(this.value))
  }
}
