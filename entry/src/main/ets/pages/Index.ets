import { Game2048 } from './Game2048';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Game2048()
    }
    .width('100%')
    .height('100%')
  }
}