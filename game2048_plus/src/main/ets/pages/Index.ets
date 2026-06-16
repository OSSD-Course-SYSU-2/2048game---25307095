/**
 * 2048 Game Main Page
 * Responsive 2048 game supporting: Watch, Phone, Tablet, PC, Dual/Tri-foldable devices.
 * 
 * 关键修复：使用扁平化数值数组 @State flatBoard 作为 UI 数据源
 * 避免 ArkTS 对嵌套对象 (gameState.board[row][col]) 响应性限制
 */

import { Game2048Model, Tile, GameState } from '../model/Game2048Model';
import { BreakPointSystem, DeviceBreakpoint, DeviceCategory } from '../utils/BreakPointSystem';
import { preferences } from '@kit.ArkData';
import { TileCellComponent } from '../components/TileCellComponent';
import { TeachingOverlay } from '../components/TeachingOverlay';
import { BOARD_SIZE, SWIPE_THRESHOLD, TILE_COLORS, TILE_TEXT_COLORS } from '../constants/GameConstants';

const PREFERENCE_NAME: string = 'game2048_storage';
const BEST_SCORE_KEY: string = 'best_score';

@Entry
@Component
struct Index {
  // === 核心：扁平化棋盘数值数组，ArkTS 能可靠追踪 ===
  @State flatBoard: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  @State score: number = 0;
  @State bestScore: number = 0;
  @State moveCount: number = 0;
  
  @State currentBreakpoint: DeviceBreakpoint = DeviceBreakpoint.SM;
  @State deviceCategory: DeviceCategory = DeviceCategory.PHONE;
  @State showWinDialog: boolean = false;
  @State showGameOverDialog: boolean = false;
  // 模式选择：开始前显示选择界面
  @State showModeSelect: boolean = true;
  // 教学模式：进入教程覆盖层
  @State showTeaching: boolean = false;

  private gameModel: Game2048Model = new Game2048Model(BOARD_SIZE);
  private breakPointSystem: BreakPointSystem = BreakPointSystem.getInstance();

  private getBoardContainerSize(): number {
    switch (this.currentBreakpoint) {
      case DeviceBreakpoint.XS:
        return 160;
      case DeviceBreakpoint.SM:
        return 300;
      case DeviceBreakpoint.MD:
        return 420;
      case DeviceBreakpoint.LG:
        return 500;
      case DeviceBreakpoint.XL:
        return 560;
      default:
        return 300;
    }
  }

  private getTileSize(): number {
    const containerSize = this.getBoardContainerSize();
    const gap = this.getGap();
    return (containerSize - gap * (BOARD_SIZE + 1)) / BOARD_SIZE;
  }

  private getGap(): number {
    switch (this.currentBreakpoint) {
      case DeviceBreakpoint.XS:
        return 6;
      case DeviceBreakpoint.SM:
        return 8;
      default:
        return 10;
    }
  }

  private getTileFontSize(value: number): number {
    const tileSize = this.getTileSize();
    if (value < 100) {
      return tileSize * 0.4;
    } else if (value < 1000) {
      return tileSize * 0.35;
    } else {
      return tileSize * 0.25;
    }
  }

  private getScoreTitleFontSize(): number {
    switch (this.currentBreakpoint) {
      case DeviceBreakpoint.XS:
        return 10;
      case DeviceBreakpoint.SM:
        return 13;
      default:
        return 16;
    }
  }

  private getScoreValueFontSize(): number {
    switch (this.currentBreakpoint) {
      case DeviceBreakpoint.XS:
        return 16;
      case DeviceBreakpoint.SM:
        return 22;
      default:
        return 28;
    }
  }

  aboutToAppear(): void {
    this.breakPointSystem.register();
    this.currentBreakpoint = this.breakPointSystem.getCurrentBreakpoint();
    this.deviceCategory = this.breakPointSystem.getDeviceCategory();

    this.breakPointSystem.addListener((bp: DeviceBreakpoint, category: DeviceCategory) => {
      this.currentBreakpoint = bp;
      this.deviceCategory = category;
    });

    // 监听游戏状态变化，同步到扁平化数组
    this.gameModel.addListener((state: GameState) => {
      this.syncFromGameState(state);
      if (state.isWin) {
        this.showWinDialog = true;
      }
      if (state.isGameOver) {
        this.showGameOverDialog = true;
      }
    });

    this.loadBestScore();
    // 先不初始化棋盘，等用户选择模式后再初始化
  }

  aboutToDisappear(): void {
    this.breakPointSystem.unregister();
    this.saveBestScore();
  }

  /** 开始普通模式 */
  private startNormalMode(): void {
    this.gameModel.initBoard();
    this.showModeSelect = false;
  }

  /** 开始教学模式 */
  private startTeachingMode(): void {
    this.gameModel.initBoard();
    this.showModeSelect = false;
    this.showTeaching = true;
  }

  /** 关闭教学 */
  private closeTeaching(): void {
    this.showTeaching = false;
  }

  /** 从 GameState 同步数据到扁平化数组 */
  private syncFromGameState(state: GameState): void {
    const newBoard: number[] = [];
    for (let r = 0; r < BOARD_SIZE; r++) {
      for (let c = 0; c < BOARD_SIZE; c++) {
        const tile: Tile | null = state.board[r][c];
        newBoard.push(tile ? tile.value : 0);
      }
    }
    this.flatBoard = newBoard;
    this.score = state.score;
    this.bestScore = state.bestScore;
    this.moveCount = state.moveCount;
  }

  private async loadBestScore(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), PREFERENCE_NAME);
      const best = await dataPreferences.get(BEST_SCORE_KEY, 0) as number;
      this.gameModel.setBestScore(best);
    } catch (e) {
      console.error('Failed to load best score');
    }
  }

  private async saveBestScore(): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), PREFERENCE_NAME);
      await dataPreferences.put(BEST_SCORE_KEY, this.bestScore);
      await dataPreferences.flush();
    } catch (e) {
      console.error('Failed to save best score');
    }
  }

  private getTileBgColor(value: number): string {
    if (value === 0) {
      return 'rgba(238, 228, 218, 0.35)';
    }
    return TILE_COLORS[value] || '#3C3A32';
  }

  private getTileTextColor(value: number): string {
    return TILE_TEXT_COLORS[value] || '#FFFFFF';
  }

  /** 处理 PanGesture 滑动 — 仅在游戏主界面有效 */
  private handlePanSwipe(event: GestureEvent): void {
    // 守卫条件：模式选择界面、胜利弹窗、游戏结束弹窗、教学覆盖层显示时不响应滑动
    if (this.showModeSelect || this.showWinDialog || this.showGameOverDialog || this.showTeaching) {
      return;
    }
    if (!event) {
      return;
    }
    const offsetX: number = event.offsetX;
    const offsetY: number = event.offsetY;

    if (Math.abs(offsetX) < SWIPE_THRESHOLD && Math.abs(offsetY) < SWIPE_THRESHOLD) {
      return;
    }

    if (Math.abs(offsetX) > Math.abs(offsetY)) {
      if (offsetX > 0) {
        this.gameModel.moveRight();
      } else {
        this.gameModel.moveLeft();
      }
    } else {
      if (offsetY > 0) {
        this.gameModel.moveDown();
      } else {
        this.gameModel.moveUp();
      }
    }
  }

  private handleKeyEvent(event: KeyEvent): void {
    // 守卫条件：模式选择界面、胜利弹窗、游戏结束弹窗、教学覆盖层显示时不响应键盘
    if (this.showModeSelect || this.showWinDialog || this.showGameOverDialog || this.showTeaching) {
      return;
    }
    if (event.type === KeyType.Down) {
      const key = event.keyCode;
      if (key === 2054 || key === 2017) {
        this.gameModel.moveLeft();
      } else if (key === 2055 || key === 2018) {
        this.gameModel.moveRight();
      } else if (key === 2056 || key === 2019) {
        this.gameModel.moveUp();
      } else if (key === 2057 || key === 2020) {
        this.gameModel.moveDown();
      }
    }
  }

  private getDeviceName(): string {
    switch (this.deviceCategory) {
      case DeviceCategory.WATCH:
        return '手表';
      case DeviceCategory.PHONE:
        return '手机';
      case DeviceCategory.TABLET:
        return '平板';
      case DeviceCategory.PC:
        return '电脑';
      case DeviceCategory.FOLDABLE_DUAL:
        return '双折叠屏';
      case DeviceCategory.FOLDABLE_TRI:
        return '三折叠屏';
      default:
        return '';
    }
  }

  // =============================
  //  @Builder 片段
  // =============================

  @Builder ModeSelectScreen() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#FAF8EF')

      Column() {
        // Logo 区域
        Column() {
          Text('2048')
            .fontSize(64)
            .fontWeight(FontWeight.Bold)
            .fontColor('#776E65')

          Text('数字益智游戏')
            .fontSize(16)
            .fontColor('#BBADA0')
            .margin({ top: 4 })
        }
        .margin({ bottom: 48 })

        // 普通模式按钮
        Column() {
          Text('🎮 普通模式')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('直接开始游戏')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ top: 4 })
        }
        .width(260)
        .padding({ top: 24, bottom: 24 })
        .backgroundColor('#8F7A66')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.startNormalMode();
        })

        Row()
          .width(260)
          .height(1)
          .backgroundColor('#EDE0C8')
          .margin({ top: 20, bottom: 20 })

        // 教学模式按钮
        Column() {
          Text('📖 教学模式')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('学习规则与高手策略')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ top: 4 })
        }
        .width(260)
        .padding({ top: 24, bottom: 24 })
        .backgroundColor('#EDC22E')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.startTeachingMode();
        })

        // 底部提示
        Text('合并相同数字，挑战 2048！')
          .fontSize(12)
          .fontColor('#BBADA0')
          .margin({ top: 40 })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder ScoreBox(label: string, value: number) {
    Column() {
      Text(label)
        .fontSize(this.getScoreTitleFontSize())
        .fontColor('#EEE4DA')
        .fontWeight(FontWeight.Bold)
      Text(value.toString())
        .fontSize(this.getScoreValueFontSize())
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
    }
    .width('45%')
    .padding({
      top: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 8,
      bottom: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 8
    })
    .borderRadius(6)
    .backgroundColor('#BBADA0')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder WinOverlay() {
    Stack() {
      Column() {
        Text('🎉 恭喜!')
          .fontSize(36)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
        Text('你达到了 2048!')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .margin({ top: 10 })
        Row({ space: 12 }) {
          Button('继续游戏')
            .onClick(() => {
              this.gameModel.continueGame();
              this.showWinDialog = false;
            })
            .backgroundColor('#EDC22E')
            .fontColor('#FFFFFF')
          Button('新游戏')
            .onClick(() => {
              this.gameModel.newGame();
              this.showWinDialog = false;
            })
            .backgroundColor('#8F7A66')
            .fontColor('#FFFFFF')
        }
        .margin({ top: 20 })
      }
      .padding(30)
      .borderRadius(10)
      .backgroundColor('rgba(0, 0, 0, 0.7)')
    }
    .width('100%')
    .height('100%')
  }

  @Builder GameOverOverlay() {
    Stack() {
      Column() {
        Text('游戏结束')
          .fontSize(36)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
        Text(`最终得分: ${this.score}`)
          .fontSize(20)
          .fontColor('#FFFFFF')
          .margin({ top: 10 })
        Button('再来一局')
          .onClick(() => {
            this.saveBestScore();
            this.gameModel.newGame();
            this.showGameOverDialog = false;
          })
          .backgroundColor('#8F7A66')
          .fontColor('#FFFFFF')
          .margin({ top: 20 })
      }
      .padding(30)
      .borderRadius(10)
      .backgroundColor('rgba(0, 0, 0, 0.7)')
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      // =====================
      // 模式选择界面（首次进入）
      // =====================
      if (this.showModeSelect) {
        this.ModeSelectScreen()
      }

      // =====================
      // 游戏主界面（模式选择后显示）
      // =====================
      if (!this.showModeSelect) {
        Column() {
          // Header
          Row() {
            Text('2048')
              .fontSize(this.currentBreakpoint === DeviceBreakpoint.XS ? 24 : 36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#776E65')
            Blank()
            Text(this.getDeviceName())
              .fontSize(this.currentBreakpoint === DeviceBreakpoint.XS ? 10 : 13)
              .fontColor('#BBADA0')
              .fontWeight(FontWeight.Bold)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .backgroundColor('#EDE0C8')
            Blank()
            Text('📖 教程')
              .fontSize(this.currentBreakpoint === DeviceBreakpoint.XS ? 10 : 13)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .backgroundColor('#EDC22E')
              .onClick(() => {
                this.showTeaching = true;
              })
          }
          .width(this.getBoardContainerSize())
          .margin({ bottom: this.currentBreakpoint === DeviceBreakpoint.XS ? 6 : 12 })

          // Score
          Row({ space: this.currentBreakpoint === DeviceBreakpoint.XS ? 6 : 10 }) {
            this.ScoreBox('分数', this.score)
            this.ScoreBox('最高分', this.bestScore)
          }
          .width(this.getBoardContainerSize())
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: this.currentBreakpoint === DeviceBreakpoint.XS ? 6 : 12 })

          // Move count & New game
          Row() {
            Text(`步数: ${this.moveCount}`)
              .fontSize(this.currentBreakpoint === DeviceBreakpoint.XS ? 11 : 14)
              .fontColor('#776E65')
            Blank()
            Button('新游戏')
              .fontSize(this.currentBreakpoint === DeviceBreakpoint.XS ? 11 : 14)
              .fontColor('#FFFFFF')
              .backgroundColor('#8F7A66')
              .borderRadius(6)
              .padding({
                left: this.currentBreakpoint === DeviceBreakpoint.XS ? 10 : 16,
                right: this.currentBreakpoint === DeviceBreakpoint.XS ? 10 : 16,
                top: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 8,
                bottom: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 8
              })
              .onClick(() => {
                this.saveBestScore();
                this.gameModel.newGame();
              })
          }
          .width(this.getBoardContainerSize())
          .margin({ bottom: this.currentBreakpoint === DeviceBreakpoint.XS ? 6 : 12 })

          // === Game Board ===
          Column() {
            // Row 0
            Row() {
              TileCellComponent({ value: this.flatBoard[0], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[1], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[2], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[3], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
            }
            .justifyContent(FlexAlign.SpaceEvenly)
            .width('100%')

            // Row 1
            Row() {
              TileCellComponent({ value: this.flatBoard[4], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[5], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[6], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[7], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
            }
            .justifyContent(FlexAlign.SpaceEvenly)
            .width('100%')

            // Row 2
            Row() {
              TileCellComponent({ value: this.flatBoard[8], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[9], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[10], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[11], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
            }
            .justifyContent(FlexAlign.SpaceEvenly)
            .width('100%')

            // Row 3
            Row() {
              TileCellComponent({ value: this.flatBoard[12], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[13], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[14], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
              TileCellComponent({ value: this.flatBoard[15], tileSize: this.getTileSize(), borderRadius_: this.currentBreakpoint === DeviceBreakpoint.XS ? 4 : 6 })
            }
            .justifyContent(FlexAlign.SpaceEvenly)
            .width('100%')
          }
          .width(this.getBoardContainerSize())
          .height(this.getBoardContainerSize())
          .padding(this.getGap())
          .borderRadius(this.currentBreakpoint === DeviceBreakpoint.XS ? 6 : 10)
          .backgroundColor('#BBADA0')
          .justifyContent(FlexAlign.SpaceEvenly)

          // Instructions
          if (this.currentBreakpoint !== DeviceBreakpoint.XS) {
            Text(this.deviceCategory === DeviceCategory.PC ? '方向键或WASD移动' : '滑动屏幕移动方块')
              .fontSize(12)
              .fontColor('#BBADA0')
              .margin({ top: 16 })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FAF8EF')
        .onKeyEvent((event: KeyEvent) => {
          this.handleKeyEvent(event);
        })
        .gesture(
          PanGesture({ fingers: 1, distance: 5 })
            .onActionEnd((event: GestureEvent) => {
              this.handlePanSwipe(event);
            })
        )

        // Win overlay
        if (this.showWinDialog) {
          this.WinOverlay()
        }

        // Game over overlay
        if (this.showGameOverDialog) {
          this.GameOverOverlay()
        }
      }

      // =====================
      // 教学模式覆盖层（独立渲染，不阻塞游戏）
      // =====================
      if (this.showTeaching) {
        TeachingOverlay({
          closeCallback: () => {
            this.closeTeaching();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
