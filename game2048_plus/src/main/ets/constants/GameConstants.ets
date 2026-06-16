/**
 * 2048 Game shared constants
 * Color mappings and configuration shared across components.
 */

// Tile background colors mapped to value
export const TILE_COLORS: Record<number, string> = {
  2: '#EEE4DA',
  4: '#EDE0C8',
  8: '#F2B179',
  16: '#F59563',
  32: '#F67C5F',
  64: '#F65E3B',
  128: '#EDCF72',
  256: '#EDCC61',
  512: '#EDC850',
  1024: '#EDC53F',
  2048: '#EDC22E',
  4096: '#3C3A32',
  8192: '#3C3A32'
};

export const TILE_TEXT_COLORS: Record<number, string> = {
  2: '#776E65',
  4: '#776E65',
  8: '#FFFFFF',
  16: '#FFFFFF',
  32: '#FFFFFF',
  64: '#FFFFFF',
  128: '#FFFFFF',
  256: '#FFFFFF',
  512: '#FFFFFF',
  1024: '#FFFFFF',
  2048: '#FFFFFF',
  4096: '#FFFFFF',
  8192: '#FFFFFF'
};

export const BOARD_SIZE: number = 4;

export const SWIPE_THRESHOLD: number = 10;
