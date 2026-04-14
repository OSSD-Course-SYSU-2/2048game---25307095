/**
 * Preferences数据持久化管理器
 * 用于保存和加载游戏数据（最高分、游戏状态等）
 */

import preferences from '@ohos.data.preferences';

export class PreferencesManager {
  private static instance: PreferencesManager | null = null;
  private preferences: preferences.Preferences | null = null;
  
  // 存储键名
  private static readonly KEY_BEST_SCORE = 'best_score';
  private static readonly KEY_GAME_STATE = 'game_state';
  private static readonly KEY_BOARD_DATA = 'board_data';
  private static readonly KEY_CURRENT_SCORE = 'current_score';
  private static readonly KEY_HAS_WON = 'has_won';
  
  // 单例模式
  public static getInstance(): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager();
    }
    return PreferencesManager.instance;
  }
  
  private constructor() {
    // 私有构造函数
  }
  
  /**
   * 初始化Preferences
   */
  public async initialize(): Promise<void> {
    try {
      // 创建Preferences实例
      this.preferences = await preferences.getPreferences(this.getContext(), 'game2048_data');
      console.log('Preferences initialized successfully');
    } catch (error) {
      console.error('Failed to initialize preferences:', error);
    }
  }
  
  /**
   * 获取上下文
   */
  private getContext(): Context {
    // 在HarmonyOS中，可以通过getContext获取上下文
    // 这里使用全局上下文
    return getContext() as Context;
  }
  
  /**
   * 保存最高分
   */
  public async saveBestScore(score: number): Promise<boolean> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      await this.preferences!.put(PreferencesManager.KEY_BEST_SCORE, score);
      await this.preferences!.flush();
      return true;
    } catch (error) {
      console.error('Failed to save best score:', error);
      return false;
    }
  }
  
  /**
   * 加载最高分
   */
  public async loadBestScore(): Promise<number> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      const score = await this.preferences!.get(PreferencesManager.KEY_BEST_SCORE, 0);
      return score as number;
    } catch (error) {
      console.error('Failed to load best score:', error);
      return 0;
    }
  }
  
  /**
   * 保存游戏状态
   */
  public async saveGameState(
    board: number[][],
    currentScore: number,
    hasWon: boolean
  ): Promise<boolean> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      // 将棋盘数据转换为字符串
      const boardString = JSON.stringify(board);
      
      await this.preferences!.put(PreferencesManager.KEY_BOARD_DATA, boardString);
      await this.preferences!.put(PreferencesManager.KEY_CURRENT_SCORE, currentScore);
      await this.preferences!.put(PreferencesManager.KEY_HAS_WON, hasWon);
      await this.preferences!.flush();
      
      return true;
    } catch (error) {
      console.error('Failed to save game state:', error);
      return false;
    }
  }
  
  /**
   * 加载游戏状态
   */
  public async loadGameState(): Promise<{
    board: number[][];
    currentScore: number;
    hasWon: boolean;
  } | null> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      const boardString = await this.preferences!.get(PreferencesManager.KEY_BOARD_DATA, '');
      const currentScore = await this.preferences!.get(PreferencesManager.KEY_CURRENT_SCORE, 0);
      const hasWon = await this.preferences!.get(PreferencesManager.KEY_HAS_WON, false);
      
      if (!boardString) {
        return null;
      }
      
      const board = JSON.parse(boardString as string);
      
      return {
        board,
        currentScore: currentScore as number,
        hasWon: hasWon as boolean
      };
    } catch (error) {
      console.error('Failed to load game state:', error);
      return null;
    }
  }
  
  /**
   * 清除保存的游戏状态
   */
  public async clearGameState(): Promise<boolean> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      await this.preferences!.delete(PreferencesManager.KEY_BOARD_DATA);
      await this.preferences!.delete(PreferencesManager.KEY_CURRENT_SCORE);
      await this.preferences!.delete(PreferencesManager.KEY_HAS_WON);
      await this.preferences!.flush();
      
      return true;
    } catch (error) {
      console.error('Failed to clear game state:', error);
      return false;
    }
  }
  
  /**
   * 清除所有数据
   */
  public async clearAllData(): Promise<boolean> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      await this.preferences!.clear();
      await this.preferences!.flush();
      
      return true;
    } catch (error) {
      console.error('Failed to clear all data:', error);
      return false;
    }
  }
  
  /**
   * 检查是否有保存的游戏
   */
  public async hasSavedGame(): Promise<boolean> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      const boardString = await this.preferences!.get(PreferencesManager.KEY_BOARD_DATA, '');
      return !!boardString;
    } catch (error) {
      console.error('Failed to check saved game:', error);
      return false;
    }
  }
  
  /**
   * 保存设置
   */
  public async saveSetting(key: string, value: any): Promise<boolean> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      await this.preferences!.put(key, value);
      await this.preferences!.flush();
      return true;
    } catch (error) {
      console.error(`Failed to save setting ${key}:`, error);
      return false;
    }
  }
  
  /**
   * 加载设置
   */
  public async loadSetting(key: string, defaultValue: any): Promise<any> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      const value = await this.preferences!.get(key, defaultValue);
      return value;
    } catch (error) {
      console.error(`Failed to load setting ${key}:`, error);
      return defaultValue;
    }
  }
}

// 导出单例实例
export const preferencesManager = PreferencesManager.getInstance();