/**
 * 2048游戏方块组件
 * 显示单个数字方块，根据数字大小显示不同颜色
 */

import { GameLogic } from '../utils/GameLogic';

@Component
export struct TileComponent {
  // 方块的值
  @Prop value: number = 0;
  // 方块大小
  @Prop tileSize: number = 65;
  // 方块边距
  @Prop tileMargin: number = 5;
  // 是否显示动画
  @Prop animate: boolean = false;
  
  // 计算方块颜色
  private getTileColor(): string {
    if (this.value === 0) {
      return '#CDC1B4'; // 空方块使用浅色
    }
    
    // 根据数字大小返回对应的颜色
    switch (this.value) {
      case 2:
        return '#EEE4DA';
      case 4:
        return '#EDE0C8';
      case 8:
        return '#F2B179';
      case 16:
        return '#F59563';
      case 32:
        return '#F67C5F';
      case 64:
        return '#F65E3B';
      case 128:
        return '#EDCF72';
      case 256:
        return '#EDCC61';
      case 512:
        return '#EDC850';
      case 1024:
        return '#EDC53F';
      case 2048:
        return '#EDC22E';
      case 4096:
        return '#EDBE1D';
      default:
        return '#EEE4DA';
    }
  }
  
  // 计算文本颜色
  private getTextColor(): string {
    // 数字大于等于8时使用浅色文本，否则使用深色文本
    return this.value >= 8 ? '#FFFFFF' : '#776E65';
  }
  
  // 计算字体大小
  private getFontSize(): number {
    const valueStr = this.value.toString();
    const length = valueStr.length;
    
    // 根据数字长度调整字体大小
    if (length <= 3) {
      return 40; // tile_font_size_large
    } else if (length <= 4) {
      return 32; // tile_font_size_medium
    } else {
      return 24; // tile_font_size_small
    }
  }
  
  // 获取显示文本
  private getDisplayText(): string {
    return this.value === 0 ? '' : this.value.toString();
  }
  
  build() {
    Column() {
      // 方块容器
      Stack() {
        // 方块背景
        Column() {
          // 数字文本
          if (this.value > 0) {
            Text(this.getDisplayText())
              .fontSize(this.getFontSize())
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getTextColor())
              .textAlign(TextAlign.Center)
          }
        }
        .width(this.tileSize)
        .height(this.tileSize)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.getTileColor())
        .borderRadius(6)
      }
      .width(this.tileSize + this.tileMargin * 2)
      .height(this.tileSize + this.tileMargin * 2)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.value === 0 ? 0.35 : 1) // 空方块半透明
    .scale({ x: this.animate && this.value > 0 ? 1.1 : 1, y: this.animate && this.value > 0 ? 1.1 : 1 })
  }
}