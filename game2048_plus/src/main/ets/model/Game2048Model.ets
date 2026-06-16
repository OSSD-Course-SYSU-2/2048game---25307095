/**
 * 2048 Game Core Logic Model
 * Handles board state, tile movement, merging, scoring, and game status.
 */

export class Tile {
  value: number;
  id: number;
  isNew: boolean;      // 是否新生成的方块
  isMerged: boolean;   // 是否本次移动合并而成
  row: number;
  col: number;
  previousRow: number; // 移动前位置
  previousCol: number;

  constructor(value: number, id: number, row: number, col: number) {
    this.value = value;
    this.id = id;
    this.isNew = false;
    this.isMerged = false;
    this.row = row;
    this.col = col;
    this.previousRow = row;
    this.previousCol = col;
  }
}

export class CellPosition {
  row: number;
  col: number;

  constructor(row: number, col: number) {
    this.row = row;
    this.col = col;
  }
}

export class GameState {
  board: (Tile | null)[][];
  score: number;
  maxTileValue: number;
  isGameOver: boolean;
  isWin: boolean;
  hasWon: boolean;
  boardSize: number;
  moveCount: number;

  constructor(board: (Tile | null)[][], score: number, maxTileValue: number,
    isGameOver: boolean, isWin: boolean, hasWon: boolean,
    boardSize: number, moveCount: number) {
    this.board = board;
    this.score = score;
    this.maxTileValue = maxTileValue;
    this.isGameOver = isGameOver;
    this.isWin = isWin;
    this.hasWon = hasWon;
    this.boardSize = boardSize;
    this.moveCount = moveCount;
  }
}

type ListenerCallback = (state: GameState) => void;

export class Game2048Model {
  private boardSize: number = 4;
  private board: (Tile | null)[][] = [];
  private score: number = 0;
  private maxTileValue: number = 0;
  private isGameOver: boolean = false;
  private isWin: boolean = false;
  private hasWon: boolean = false;
  private moveCount: number = 0;
  private tileIdCounter: number = 0;
  private listeners: Array<ListenerCallback> = [];

  constructor(boardSize: number = 4) {
    this.boardSize = boardSize;
    this.initBoard();
  }

  public addListener(callback: ListenerCallback): void {
    this.listeners.push(callback);
  }

  public removeListener(callback: ListenerCallback): void {
    const index = this.listeners.indexOf(callback);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    const state: GameState = this.buildGameState();
    for (const listener of this.listeners) {
      listener(state);
    }
  }

  private buildGameState(): GameState {
    // 直接引用棋盘数组（浅拷贝结构，不深拷贝每个 Tile）
    // 安全原因：listener 只读取 tile.value 数值并立即转换为 flatBoard，
    // 不会保留 Tile 引用，因此不需要深拷贝
    const board: (Tile | null)[][] = [];
    let boardMax: number = 0;
    for (let r = 0; r < this.boardSize; r++) {
      board[r] = [];
      for (let c = 0; c < this.boardSize; c++) {
        const tile: Tile | null = this.board[r][c];
        board[r][c] = tile;
        if (tile !== null && tile.value > boardMax) {
          boardMax = tile.value;
        }
      }
    }
    // 以棋盘实际最大值为准，确保不遗漏任何方块（包括初始随机生成的2/4）
    if (boardMax > this.maxTileValue) {
      this.maxTileValue = boardMax;
    }
    return new GameState(board, this.score, this.maxTileValue,
      this.isGameOver, this.isWin, this.hasWon,
      this.boardSize, this.moveCount);
  }

  public initBoard(): void {
    this.board = [];
    for (let r = 0; r < this.boardSize; r++) {
      this.board[r] = [];
      for (let c = 0; c < this.boardSize; c++) {
        this.board[r][c] = null;
      }
    }
    this.score = 0;
    this.maxTileValue = 0;
    this.isGameOver = false;
    this.isWin = false;
    this.hasWon = false;
    this.moveCount = 0;
    this.tileIdCounter = 0;
    this.addRandomTile();
    this.addRandomTile();
    this.notifyListeners();
  }

  public newGame(): void {
    this.initBoard();
  }

  private getEmptyCells(): CellPosition[] {
    const empty: CellPosition[] = [];
    for (let r = 0; r < this.boardSize; r++) {
      for (let c = 0; c < this.boardSize; c++) {
        if (this.board[r][c] === null) {
          empty.push(new CellPosition(r, c));
        }
      }
    }
    return empty;
  }

  private addRandomTile(): boolean {
    const emptyCells: CellPosition[] = this.getEmptyCells();
    if (emptyCells.length === 0) {
      return false;
    }
    const randomIndex: number = Math.floor(Math.random() * emptyCells.length);
    const cell: CellPosition = emptyCells[randomIndex];
    const value: number = Math.random() < 0.9 ? 2 : 4;
    const tile: Tile = new Tile(value, this.tileIdCounter++, cell.row, cell.col);
    tile.isNew = true;
    this.board[cell.row][cell.col] = tile;
    if (value > this.maxTileValue) {
      this.maxTileValue = value;
    }
    return true;
  }

  private resetFlags(): void {
    for (let r = 0; r < this.boardSize; r++) {
      for (let c = 0; c < this.boardSize; c++) {
        const tile: Tile | null = this.board[r][c];
        if (tile !== null) {
          tile.isNew = false;
          tile.isMerged = false;
          tile.previousRow = r;
          tile.previousCol = c;
        }
      }
    }
  }

  private checkGameOver(): boolean {
    if (this.getEmptyCells().length > 0) {
      return false;
    }
    for (let r = 0; r < this.boardSize; r++) {
      for (let c = 0; c < this.boardSize; c++) {
        const current: Tile | null = this.board[r][c];
        if (current === null) {
          continue;
        }
        if (c < this.boardSize - 1) {
          const right: Tile | null = this.board[r][c + 1];
          if (right !== null && right.value === current.value) {
            return false;
          }
        }
        if (r < this.boardSize - 1) {
          const down: Tile | null = this.board[r + 1][c];
          if (down !== null && down.value === current.value) {
            return false;
          }
        }
      }
    }
    return true;
  }

  private slideRow(row: (Tile | null)[]): (Tile | null)[] {
    const tiles: Tile[] = [];
    for (let k = 0; k < row.length; k++) {
      const tile: Tile | null = row[k];
      if (tile !== null) {
        tiles.push(tile);
      }
    }

    const result: (Tile | null)[] = [];
    let i: number = 0;
    while (i < tiles.length) {
      if (i < tiles.length - 1 && tiles[i].value === tiles[i + 1].value) {
        const mergedValue: number = tiles[i].value * 2;
        const mergedTile: Tile = new Tile(mergedValue, this.tileIdCounter++, 0, 0);
        mergedTile.isMerged = true;
        mergedTile.previousRow = tiles[i].previousRow;
        mergedTile.previousCol = tiles[i].previousCol;
        this.score += mergedValue;
        if (mergedValue > this.maxTileValue) {
          this.maxTileValue = mergedValue;
        }
        if (mergedValue >= 2048 && !this.hasWon) {
          this.hasWon = true;
          this.isWin = true;
        }
        result.push(mergedTile);
        i += 2;
      } else {
        result.push(tiles[i]);
        i++;
      }
    }
    while (result.length < this.boardSize) {
      result.push(null);
    }
    return result;
  }

  public moveLeft(): boolean {
    return this.move(0);
  }

  public moveRight(): boolean {
    return this.move(1);
  }

  public moveUp(): boolean {
    return this.move(2);
  }

  public moveDown(): boolean {
    return this.move(3);
  }

  private move(direction: number): boolean {
    if (this.isGameOver) {
      return false;
    }

    this.resetFlags();
    let moved: boolean = false;

    for (let i = 0; i < this.boardSize; i++) {
      const line: (Tile | null)[] = new Array(this.boardSize);

      for (let j = 0; j < this.boardSize; j++) {
        if (direction === 0) {
          line[j] = this.board[i][j];
        } else if (direction === 1) {
          line[j] = this.board[i][this.boardSize - 1 - j];
        } else if (direction === 2) {
          line[j] = this.board[j][i];
        } else {
          line[j] = this.board[this.boardSize - 1 - j][i];
        }
      }

      const newLine: (Tile | null)[] = this.slideRow(line);

      for (let j = 0; j < this.boardSize; j++) {
        const oldTile: Tile | null = line[j];
        const newTile: Tile | null = newLine[j];
        if (oldTile !== newTile) {
          moved = true;
        }
      }

      for (let j = 0; j < this.boardSize; j++) {
        const tile: Tile | null = newLine[j];
        if (tile !== null) {
          tile.row = direction === 2 ? j : (direction === 3 ? this.boardSize - 1 - j : i);
          tile.col = direction === 0 ? j : (direction === 1 ? this.boardSize - 1 - j : i);
        }
        if (direction === 0) {
          this.board[i][j] = tile;
        } else if (direction === 1) {
          this.board[i][this.boardSize - 1 - j] = tile;
        } else if (direction === 2) {
          this.board[j][i] = tile;
        } else {
          this.board[this.boardSize - 1 - j][i] = tile;
        }
      }
    }

    if (moved) {
      this.moveCount++;
      this.addRandomTile();
      if (this.checkGameOver()) {
        this.isGameOver = true;
      }
      this.notifyListeners();
    }

    return moved;
  }

  public setMaxTileValue(value: number): void {
    if (value > this.maxTileValue) {
      this.maxTileValue = value;
    }
  }

  public continueGame(): void {
    this.isWin = false;
  }

  public getBoardSize(): number {
    return this.boardSize;
  }

  public getMaxTileValue(): number {
    return this.maxTileValue;
  }
}
