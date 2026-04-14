/**
 * 2048游戏主页面
 * 支持手机、电脑、平板、手表等多设备适配
 * 包含数据持久化功能
 */

import { GameLogic } from '../utils/GameLogic';
import { TileComponent } from '../components/TileComponent';
import { preferencesManager } from '../utils/PreferencesManager';
import mediaquery from '@ohos.mediaquery';

@Component
export struct Game2048 {
  // 游戏逻辑实例
  private gameLogic: GameLogic = new GameLogic();
  
  // 游戏状态
  @State board: number[][] = [];
  @State score: number = 0;
  @State bestScore: number = 0;
  @State gameState: string = GameLogic.GameState.PLAYING;
  @State hasWon: boolean = false;
  
  // 设备类型
  @State deviceType: string = 'phone';
  
  // 动画状态
  @State animateTile: boolean = false;
  @State animateTileIndex: number = -1;
  
  // 是否有保存的游戏
  @State hasSavedGame: boolean = false;
  
  // 媒体查询监听器
  private mediaQuery: mediaquery.MediaQueryListener | null = null;
  
  async aboutToAppear(): Promise<void> {
    // 初始化Preferences
    await preferencesManager.initialize();
    
    // 加载保存的最高分
    const savedBestScore = await preferencesManager.loadBestScore();
    if (savedBestScore > 0) {
      this.gameLogic.setBestScore(savedBestScore);
      this.bestScore = savedBestScore;
    }
    
    // 检查是否有保存的游戏
    this.hasSavedGame = await preferencesManager.hasSavedGame();
    if (this.hasSavedGame) {
      // 在实际应用中，这里可以显示一个弹窗询问用户是否继续上次游戏
      // 暂时先自动加载保存的游戏
      const loaded = await this.loadSavedGame();
      if (!loaded) {
        // 如果加载失败，初始化新游戏
        this.initializeGame();
        this.hasSavedGame = false;
      }
    } else {
      // 没有保存的游戏，初始化新游戏
      this.initializeGame();
    }
    
    // 设置媒体查询监听器，检测设备类型
    this.setupMediaQuery();
  }
  
  aboutToDisappear() {
    // 清理媒体查询监听器
    if (this.mediaQuery) {
      this.mediaQuery.off('change');
    }
  }
  
  // 初始化游戏
  private initializeGame(): void {
    this.gameLogic.initializeGame();
    this.updateGameState();
  }
  
  // 更新游戏状态
  private async updateGameState(): Promise<void> {
    this.board = this.gameLogic.getBoard();
    this.score = this.gameLogic.getScore();
    this.bestScore = this.gameLogic.getBestScore();
    this.gameState = this.gameLogic.getGameState();
    this.hasWon = this.gameLogic.hasWon();
    
    // 保存游戏状态
    await this.saveGameState();
    
    // 如果当前分数超过最高分，保存最高分
    if (this.score > this.bestScore) {
      await preferencesManager.saveBestScore(this.score);
    }
  }
  
  // 设置媒体查询
  private setupMediaQuery(): void {
    // 检测设备类型
    const listener = mediaquery.matchMediaSync('(max-width: 320px)');
    this.mediaQuery = listener;
    listener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.deviceType = 'watch';
      } else {
        // 进一步检测其他设备
        const tabletQuery = mediaquery.matchMediaSync('(min-width: 600px) and (max-width: 1024px)');
        const desktopQuery = mediaquery.matchMediaSync('(min-width: 1025px)');
        
        if (tabletQuery.matches) {
          this.deviceType = 'tablet';
        } else if (desktopQuery.matches) {
          this.deviceType = 'desktop';
        } else {
          this.deviceType = 'phone';
        }
      }
    });
  }
  
  // 保存游戏状态
  private async saveGameState(): Promise<void> {
    try {
      await preferencesManager.saveGameState(
        this.board,
        this.score,
        this.hasWon
      );
    } catch (error) {
      console.error('Failed to save game state:', error);
    }
  }
  
  // 加载保存的游戏
  private async loadSavedGame(): Promise<boolean> {
    try {
      const savedGame = await preferencesManager.loadGameState();
      if (savedGame) {
        // 验证棋盘数据
        if (this.gameLogic.isValidBoard(savedGame.board)) {
          // 从保存的状态恢复游戏
          this.gameLogic.restoreFromState(
            savedGame.board,
            savedGame.currentScore,
            this.bestScore,
            savedGame.hasWon
          );
          
          // 更新UI状态
          this.board = this.gameLogic.getBoard();
          this.score = this.gameLogic.getScore();
          this.gameState = this.gameLogic.getGameState();
          this.hasWon = this.gameLogic.hasWon();
          
          return true;
        } else {
          console.warn('Invalid board data in saved game');
          return false;
        }
      }
      return false;
    } catch (error) {
      console.error('Failed to load saved game:', error);
      return false;
    }
  }
  
  // 清除保存的游戏
  private async clearSavedGame(): Promise<void> {
    try {
      await preferencesManager.clearGameState();
    } catch (error) {
      console.error('Failed to clear saved game:', error);
    }
  }
  
  // 获取方块大小（根据设备类型）
  private getTileSize(): number {
    switch (this.deviceType) {
      case 'watch':
        return 40; // watch_tile_size
      case 'tablet':
        return 80; // tablet_tile_size
      case 'desktop':
        return 90; // desktop_tile_size
      default:
        return 65; // tile_size
    }
  }
  
  // 获取方块字体大小（根据设备类型）
  private getTileFontSize(value: number): number {
    const valueStr = value.toString();
    const length = valueStr.length;
    
    if (this.deviceType === 'watch') {
      return 16; // watch_tile_font_size
    } else if (this.deviceType === 'tablet') {
      if (length <= 3) {
        return 36; // tablet_tile_font_size
      } else if (length <= 4) {
        return 32; // tile_font_size_medium
      } else {
        return 24; // tile_font_size_small
      }
    } else if (this.deviceType === 'desktop') {
      if (length <= 3) {
        return 40; // desktop_tile_font_size
      } else if (length <= 4) {
        return 32; // tile_font_size_medium
      } else {
        return 24; // tile_font_size_small
      }
    } else {
      if (length <= 3) {
        return 40; // tile_font_size_large
      } else if (length <= 4) {
        return 32; // tile_font_size_medium
      } else {
        return 24; // tile_font_size_small
      }
    }
  }
  
  // 处理滑动事件
  private async handleSwipe(direction: string): Promise<void> {
    if (this.gameState === GameLogic.GameState.PLAYING) {
      const moved = this.gameLogic.move(direction);
      if (moved) {
        // 触发动画
        this.animateTile = true;
        setTimeout(() => {
          this.animateTile = false;
        }, 200);
        
        await this.updateGameState();
      }
    }
  }
  
  // 新游戏
  private async newGame(): Promise<void> {
    this.gameLogic.initializeGame();
    await this.updateGameState();
    
    // 清除保存的游戏状态
    await this.clearSavedGame();
  }
  
  // 撤销操作
  private undoMove(): void {
    const success = this.gameLogic.undo();
    if (success) {
      this.updateGameState();
    }
  }
  
  // 获取提示
  private getHint(): void {
    const bestMove = this.gameLogic.getBestMove();
    if (bestMove) {
      // 这里可以显示提示，例如高亮显示建议的移动方向
      console.log(`建议移动方向: ${bestMove}`);
      // 在实际应用中，可以显示一个提示动画或文本
    }
  }
  
  // 渲染游戏棋盘
  @Builder
  private renderGameBoard() {
    Column() {
      // 游戏棋盘网格
      ForEach(this.board, (row: number[], rowIndex: number) => {
        Row() {
          ForEach(row, (value: number, colIndex: number) => {
            TileComponent({
              value: value,
              tileSize: this.getTileSize(),
              tileMargin: 5,
              animate: this.animateTile && value > 0
            })
            .width(this.getTileSize() + 5 * 2)
            .height(this.getTileSize() + 5 * 2)
          })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#BBADA0')
    .borderRadius(6)
    .padding(10)
  }
  
  // 渲染分数卡片
  @Builder
  private renderScoreCard(label: string, score: number) {
    Column() {
      Text(label)
        .fontSize(12) // score_label_font_size
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
      
      Text(score.toString())
        .fontSize(16) // score_font_size
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 })
    }
    .width(80) // score_card_width
    .height(60) // score_card_height
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#8F7A66')
    .borderRadius(6)
    .padding(8)
  }
  
  // 渲染游戏控制按钮
  @Builder
  private renderGameControls() {
    Row() {
      // 如果有保存的游戏，显示继续游戏按钮，否则显示新游戏按钮
      if (this.hasSavedGame && this.score === 0) {
        // 继续游戏按钮（只在有保存的游戏且当前分数为0时显示）
        Button('继续游戏')
          .width('40%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#8F7A66')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(async () => {
            const loaded = await this.loadSavedGame();
            if (loaded) {
              this.hasSavedGame = false;
            }
          })
      } else {
        // 新游戏按钮
        Button('新游戏')
          .width('40%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#8F7A66')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(async () => {
            await this.newGame();
            this.hasSavedGame = false;
          })
      }
      
      // 撤销按钮
      Button('撤销')
        .width('25%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#8F7A66')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ left: 8 })
        .onClick(() => {
          this.undoMove();
        })
      
      // 提示按钮
      Button('提示')
        .width('25%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#8F7A66')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ left: 8 })
        .onClick(() => {
          this.getHint();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 24 })
  }
  
  // 渲染游戏结束/胜利弹窗
  @Builder
  private renderGameOverlay() {
    if (this.gameState !== GameLogic.GameState.PLAYING) {
      Stack({ alignContent: Alignment.Center }) {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#0000007F')
        
        // 弹窗内容
        Column() {
          if (this.gameState === GameLogic.GameState.WON) {
            // 胜利弹窗
            Text('恭喜！')
              .fontSize(32)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
            
            Text('你赢了！要继续挑战更高分吗？')
              .fontSize(16)
              .fontColor(Color.White)
              .margin({ bottom: 24 })
            
            Button('继续游戏')
              .width('60%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.White)
              .fontColor('#8F7A66')
              .borderRadius(8)
              .onClick(() => {
                // 继续游戏
                this.gameState = GameLogic.GameState.PLAYING;
              })
          } else {
            // 游戏结束弹窗
            Text('游戏结束')
              .fontSize(32)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
            
            Text('没有可移动的方块了，再试一次吧！')
              .fontSize(16)
              .fontColor(Color.White)
              .margin({ bottom: 24 })
            
            Button('再试一次')
              .width('60%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.White)
              .fontColor('#8F7A66')
              .borderRadius(8)
              .onClick(() => {
                this.newGame();
              })
          }
        }
        .width('80%')
        .padding(32)
        .backgroundColor('#8F7A66')
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(100)
    }
  }
  
  // 渲染游戏说明
  @Builder
  private renderInstructions() {
    Column() {
      Text('游戏说明')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#776E65')
        .margin({ bottom: 8 })
      
      Text('滑动屏幕移动方块，合并相同数字，目标是获得2048方块！')
        .fontSize(12)
        .fontColor('#776E65')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 12 })
      
      Row() {
        Text('滑动移动')
          .fontSize(12)
          .fontColor('#776E65')
          .margin({ right: 16 })
        
        Text('合并数字')
          .fontSize(12)
          .fontColor('#776E65')
          .margin({ right: 16 })
        
        Text('目标2048')
          .fontSize(12)
          .fontColor('#776E65')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F9F6F2')
    .borderRadius(12)
    .margin({ top: 24 })
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('2048')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#776E65')
        
        // 分数显示
        Row() {
          this.renderScoreCard('分数', this.score)
          this.renderScoreCard('最高分', this.bestScore)
        }
        .margin({ left: 'auto' })
      }
      .width('100%')
      .padding(16)
      .alignItems(VerticalAlign.Center)
      
      // 游戏棋盘区域
      Column() {
        // 棋盘容器
        Column() {
          this.renderGameBoard()
        }
        .width(this.deviceType === 'watch' ? '90%' : '100%')
        .aspectRatio(1)
        .margin({ top: 16 })
        .gesture(
          // 滑动手势
          PanGesture({ distance: 20 })
            .onActionStart((event: GestureEvent) => {
              // 记录起始位置
            })
            .onActionUpdate((event: GestureEvent) => {
              // 处理滑动更新
            })
            .onActionEnd(async (event: GestureEvent) => {
              // 计算滑动方向
              const offsetX = event.offsetX;
              const offsetY = event.offsetY;
              
              if (Math.abs(offsetX) > Math.abs(offsetY)) {
                // 水平滑动
                if (offsetX > 0) {
                  await this.handleSwipe(GameLogic.Direction.RIGHT);
                } else {
                  await this.handleSwipe(GameLogic.Direction.LEFT);
                }
              } else {
                // 垂直滑动
                if (offsetY > 0) {
                  await this.handleSwipe(GameLogic.Direction.DOWN);
                } else {
                  await this.handleSwipe(GameLogic.Direction.UP);
                }
              }
            })
        )
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding($r('app.float.content_padding'))
      
      // 游戏控制按钮
      this.renderGameControls()
      
      // 游戏说明（在手机上显示，在其他设备上可能隐藏或调整位置）
      if (this.deviceType === 'phone' || this.deviceType === 'tablet') {
        this.renderInstructions()
      }
      
      // 游戏结束/胜利弹窗
      this.renderGameOverlay()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.game_background'))
    .justifyContent(FlexAlign.Start)
  }
}