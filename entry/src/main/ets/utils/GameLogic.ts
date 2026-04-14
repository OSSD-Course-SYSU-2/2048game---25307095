/**
 * 2048游戏逻辑类
 * 处理游戏的核心逻辑，包括棋盘操作、移动、合并、得分等
 */

export class GameLogic {
  // 棋盘大小
  public static readonly BOARD_SIZE = 4;
  // 目标分数（16384）
  public static readonly TARGET_SCORE = 16384;
  
  // 游戏状态枚举
  public static readonly GameState = {
    PLAYING: 'playing',
    WON: 'won',
    LOST: 'lost'
  } as const;
  
  // 移动方向枚举
  public static readonly Direction = {
    UP: 'up',
    DOWN: 'down',
    LEFT: 'left',
    RIGHT: 'right'
  } as const;
  
  // 棋盘数据
  private board: number[][];
  // 当前分数
  private score: number;
  // 最高分数
  private bestScore: number;
  // 游戏状态
  private gameState: string;
  // 移动历史（用于撤销功能）
  private history: { board: number[][], score: number }[];
  // 是否已经达到目标（16384）
  private hasReachedTarget: boolean;
  
  constructor() {
    this.board = this.createEmptyBoard();
    this.score = 0;
    this.bestScore = 0;
    this.gameState = GameLogic.GameState.PLAYING;
    this.history = [];
    this.hasReachedTarget = false;
    this.initializeGame();
  }
  
  /**
   * 创建空棋盘
   */
  private createEmptyBoard(): number[][] {
    const board: number[][] = [];
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      board[i] = [];
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        board[i][j] = 0;
      }
    }
    return board;
  }
  
  /**
   * 初始化游戏
   */
  public initializeGame(): void {
    this.board = this.createEmptyBoard();
    this.score = 0;
    this.gameState = GameLogic.GameState.PLAYING;
    this.hasReachedTarget = false;
    this.history = [];
    
    // 添加两个初始方块
    this.addRandomTile();
    this.addRandomTile();
    
    // 保存初始状态
    this.saveState();
  }
  
  /**
   * 获取当前棋盘
   */
  public getBoard(): number[][] {
    return this.board.map(row => [...row]);
  }
  
  /**
   * 获取当前分数
   */
  public getScore(): number {
    return this.score;
  }
  
  /**
   * 获取最高分数
   */
  public getBestScore(): number {
    return this.bestScore;
  }
  
  /**
   * 获取游戏状态
   */
  public getGameState(): string {
    return this.gameState;
  }
  
  /**
   * 是否达到目标（16384）
   */
  public hasWon(): boolean {
    return this.hasReachedTarget;
  }
  
  /**
   * 添加随机方块
   * 90%概率添加2，10%概率添加4
   */
  private addRandomTile(): boolean {
    const emptyCells: [number, number][] = [];
    
    // 查找所有空单元格
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        if (this.board[i][j] === 0) {
          emptyCells.push([i, j]);
        }
      }
    }
    
    if (emptyCells.length === 0) {
      return false;
    }
    
    // 随机选择一个空单元格
    const randomIndex = Math.floor(Math.random() * emptyCells.length);
    const [row, col] = emptyCells[randomIndex];
    
    // 90%概率为2，10%概率为4
    const value = Math.random() < 0.9 ? 2 : 4;
    this.board[row][col] = value;
    
    return true;
  }
  
  /**
   * 保存当前状态到历史记录
   */
  private saveState(): void {
    // 深拷贝棋盘
    const boardCopy = this.board.map(row => [...row]);
    this.history.push({
      board: boardCopy,
      score: this.score
    });
    
    // 限制历史记录长度
    if (this.history.length > 10) {
      this.history.shift();
    }
  }
  
  /**
   * 撤销上一步操作
   */
  public undo(): boolean {
    if (this.history.length <= 1) {
      return false; // 只有初始状态，无法撤销
    }
    
    // 移除当前状态
    this.history.pop();
    
    // 恢复到上一个状态
    const previousState = this.history[this.history.length - 1];
    this.board = previousState.board.map(row => [...row]);
    this.score = previousState.score;
    
    // 更新游戏状态
    this.updateGameState();
    
    return true;
  }
  
  /**
   * 移动棋盘
   */
  public move(direction: string): boolean {
    // 保存当前状态
    this.saveState();
    
    let moved = false;
    const oldBoard = this.board.map(row => [...row]);
    
    switch (direction) {
      case GameLogic.Direction.UP:
        moved = this.moveUp();
        break;
      case GameLogic.Direction.DOWN:
        moved = this.moveDown();
        break;
      case GameLogic.Direction.LEFT:
        moved = this.moveLeft();
        break;
      case GameLogic.Direction.RIGHT:
        moved = this.moveRight();
        break;
    }
    
    // 如果棋盘发生了变化，添加新方块
    if (moved) {
      this.addRandomTile();
      this.updateGameState();
      this.updateBestScore();
    } else {
      // 如果没有移动，移除保存的状态
      this.history.pop();
    }
    
    return moved;
  }
  
  /**
   * 向上移动
   */
  private moveUp(): boolean {
    let moved = false;
    
    for (let col = 0; col < GameLogic.BOARD_SIZE; col++) {
      const column = [];
      
      // 提取列数据
      for (let row = 0; row < GameLogic.BOARD_SIZE; row++) {
        column.push(this.board[row][col]);
      }
      
      // 处理列
      const result = this.processLine(column);
      
      // 更新棋盘
      for (let row = 0; row < GameLogic.BOARD_SIZE; row++) {
        if (this.board[row][col] !== result[row]) {
          moved = true;
        }
        this.board[row][col] = result[row];
      }
    }
    
    return moved;
  }
  
  /**
   * 向下移动
   */
  private moveDown(): boolean {
    let moved = false;
    
    for (let col = 0; col < GameLogic.BOARD_SIZE; col++) {
      const column = [];
      
      // 提取列数据（从下到上）
      for (let row = GameLogic.BOARD_SIZE - 1; row >= 0; row--) {
        column.push(this.board[row][col]);
      }
      
      // 处理列
      const result = this.processLine(column);
      
      // 更新棋盘（从下到上）
      for (let row = GameLogic.BOARD_SIZE - 1; row >= 0; row--) {
        const index = GameLogic.BOARD_SIZE - 1 - row;
        if (this.board[row][col] !== result[index]) {
          moved = true;
        }
        this.board[row][col] = result[index];
      }
    }
    
    return moved;
  }
  
  /**
   * 向左移动
   */
  private moveLeft(): boolean {
    let moved = false;
    
    for (let row = 0; row < GameLogic.BOARD_SIZE; row++) {
      const line = [...this.board[row]];
      const result = this.processLine(line);
      
      // 更新棋盘
      for (let col = 0; col < GameLogic.BOARD_SIZE; col++) {
        if (this.board[row][col] !== result[col]) {
          moved = true;
        }
        this.board[row][col] = result[col];
      }
    }
    
    return moved;
  }
  
  /**
   * 向右移动
   */
  private moveRight(): boolean {
    let moved = false;
    
    for (let row = 0; row < GameLogic.BOARD_SIZE; row++) {
      const line = [...this.board[row]].reverse();
      const result = this.processLine(line);
      
      // 更新棋盘（反转回来）
      for (let col = 0; col < GameLogic.BOARD_SIZE; col++) {
        const index = GameLogic.BOARD_SIZE - 1 - col;
        if (this.board[row][col] !== result[index]) {
          moved = true;
        }
        this.board[row][col] = result[index];
      }
    }
    
    return moved;
  }
  
  /**
   * 处理一行或一列的数据
   * 合并相同的数字并计算得分
   */
  private processLine(line: number[]): number[] {
    // 过滤掉0
    let filtered = line.filter(val => val !== 0);
    const result: number[] = [];
    
    // 合并相同的数字
    for (let i = 0; i < filtered.length; i++) {
      if (i < filtered.length - 1 && filtered[i] === filtered[i + 1]) {
        const mergedValue = filtered[i] * 2;
        result.push(mergedValue);
        
        // 更新分数
        this.score += mergedValue;
        
        // 检查是否达到目标
        if (mergedValue === GameLogic.TARGET_SCORE) {
          this.hasReachedTarget = true;
        }
        
        i++; // 跳过下一个元素，因为它已经被合并了
      } else {
        result.push(filtered[i]);
      }
    }
    
    // 填充0到原始长度
    while (result.length < GameLogic.BOARD_SIZE) {
      result.push(0);
    }
    
    return result;
  }
  
  /**
   * 检查游戏是否结束
   */
  private checkGameOver(): boolean {
    // 检查是否有空单元格
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        if (this.board[i][j] === 0) {
          return false;
        }
      }
    }
    
    // 检查是否有可以合并的相邻单元格
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        const current = this.board[i][j];
        
        // 检查右侧
        if (j < GameLogic.BOARD_SIZE - 1 && current === this.board[i][j + 1]) {
          return false;
        }
        
        // 检查下方
        if (i < GameLogic.BOARD_SIZE - 1 && current === this.board[i + 1][j]) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  /**
   * 更新游戏状态
   */
  private updateGameState(): void {
    if (this.hasReachedTarget) {
      this.gameState = GameLogic.GameState.WON;
    } else if (this.checkGameOver()) {
      this.gameState = GameLogic.GameState.LOST;
    } else {
      this.gameState = GameLogic.GameState.PLAYING;
    }
  }
  
  /**
   * 更新最高分数
   */
  private updateBestScore(): void {
    if (this.score > this.bestScore) {
      this.bestScore = this.score;
    }
  }
  
  /**
   * 设置最高分数（用于从存储中加载）
   */
  public setBestScore(score: number): void {
    this.bestScore = score;
  }
  
  /**
   * 获取可能的移动方向（用于AI提示）
   */
  public getPossibleMoves(): string[] {
    const moves: string[] = [];
    
    // 检查每个方向是否有效
    const directions = [
      GameLogic.Direction.UP,
      GameLogic.Direction.DOWN,
      GameLogic.Direction.LEFT,
      GameLogic.Direction.RIGHT
    ];
    
    for (const direction of directions) {
      // 创建棋盘副本
      const boardCopy = this.board.map(row => [...row]);
      const scoreCopy = this.score;
      
      // 尝试移动
      let moved = false;
      switch (direction) {
        case GameLogic.Direction.UP:
          moved = this.moveUp();
          break;
        case GameLogic.Direction.DOWN:
          moved = this.moveDown();
          break;
        case GameLogic.Direction.LEFT:
          moved = this.moveLeft();
          break;
        case GameLogic.Direction.RIGHT:
          moved = this.moveRight();
          break;
      }
      
      // 恢复棋盘
      this.board = boardCopy;
      this.score = scoreCopy;
      
      if (moved) {
        moves.push(direction);
      }
    }
    
    return moves;
  }
  
  /**
   * 获取下一个最佳移动（简单AI提示）
   */
  public getBestMove(): string | null {
    const possibleMoves = this.getPossibleMoves();
    if (possibleMoves.length === 0) {
      return null;
    }
    
    // 简单策略：随机选择一个可能的移动
    const randomIndex = Math.floor(Math.random() * possibleMoves.length);
    return possibleMoves[randomIndex];
  }
  
  /**
   * 重置游戏（保留最高分）
   */
  public resetGame(): void {
    this.initializeGame();
  }
  
  /**
   * 获取棋盘上所有非零数字
   */
  public getAllNumbers(): number[] {
    const numbers: number[] = [];
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        if (this.board[i][j] > 0) {
          numbers.push(this.board[i][j]);
        }
      }
    }
    return numbers;
  }
  
  /**
   * 获取棋盘上最大数字
   */
  public getMaxNumber(): number {
    let max = 0;
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        if (this.board[i][j] > max) {
          max = this.board[i][j];
        }
      }
    }
    return max;
  }
  
  /**
   * 从保存的状态恢复游戏
   */
  public restoreFromState(
    board: number[][],
    score: number,
    bestScore: number,
    hasWon: boolean
  ): void {
    // 验证棋盘大小
    if (board.length !== GameLogic.BOARD_SIZE || board[0].length !== GameLogic.BOARD_SIZE) {
      console.error('Invalid board size for restore');
      return;
    }
    
    // 恢复棋盘状态
    this.board = board.map(row => [...row]);
    this.score = score;
    this.bestScore = bestScore;
    this.hasReachedTarget = hasWon;
    
    // 更新游戏状态
    this.updateGameState();
    
    // 清空历史记录
    this.history = [];
    
    // 保存初始状态
    this.saveState();
  }
  
  /**
   * 获取当前游戏状态的快照（用于保存）
   */
  public getGameSnapshot(): {
    board: number[][];
    score: number;
    bestScore: number;
    hasWon: boolean;
    gameState: string;
  } {
    return {
      board: this.board.map(row => [...row]),
      score: this.score,
      bestScore: this.bestScore,
      hasWon: this.hasReachedTarget,
      gameState: this.gameState
    };
  }
  
  /**
   * 检查棋盘是否有效
   */
  public isValidBoard(board: number[][]): boolean {
    if (!board || board.length !== GameLogic.BOARD_SIZE) {
      return false;
    }
    
    for (let i = 0; i < GameLogic.BOARD_SIZE; i++) {
      if (!board[i] || board[i].length !== GameLogic.BOARD_SIZE) {
        return false;
      }
      
      for (let j = 0; j < GameLogic.BOARD_SIZE; j++) {
        const value = board[i][j];
        if (value < 0 || !Number.isInteger(value)) {
          return false;
        }
      }
    }
    
    return true;
  }
}