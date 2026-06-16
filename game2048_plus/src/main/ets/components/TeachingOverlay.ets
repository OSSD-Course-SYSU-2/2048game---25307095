/**
 * 2048 教学模式组件
 * 提供交互式多页教程，引导新玩家快速上手
 * 注意：此组件始终渲染内容，由父组件通过 if 条件控制显隐
 */

interface TutorialPage {
  title: string;
  subtitle: string;
  content: string[];
  tip: string;
}

const TUTORIAL_PAGES: TutorialPage[] = [
  {
    title: '🎮 欢迎来到 2048',
    subtitle: '一款让人上瘾的数字益智游戏',
    content: [
      '• 在 4×4 的网格上滑动方块，合并相同数字',
      '• 目标：拼出一个「2048」方块！',
      '• 合并数字获得分数，数字越大分数越高',
    ],
    tip: '看似简单，但需要策略才能达到 2048！'
  },
  {
    title: '🖱️ 基本操作',
    subtitle: '滑动控制所有方块',
    content: [
      '• 向上/下/左/右滑动 → 所有方块同时移动',
      '• 两个相同数字相撞 → 合并为一个（相加）',
      '• 每次移动后，会在随机空位生成一个新方块（2 或 4）',
      '• 键盘玩家：方向键 或 WASD 控制',
    ],
    tip: 'TIP: 滑动时注意所有方块都会移动，提前想好布局！'
  },
  {
    title: '🧮 计分规则',
    subtitle: '合并不停，分数不停',
    content: [
      '• 每合并一次，获得合并后数字的分数',
      '• 例如：合并两个 8 → 得到 16 分',
      '• 合并两个 1024 → 得到 2048 分',
      '• 「步数」显示你已操作的次数',
    ],
    tip: 'TIP: 合并大数字时分数暴涨，但别只顾分数忘了策略！'
  },
  {
    title: '🏆 核心策略：角落大法',
    subtitle: '新手必学的第一策略',
    content: [
      '• ① 把你的最大数字固定在「一个角落」',
      '• ② 沿着这个角落的两条边构建递减序列',
      '• ③ 只用「三个方向」操作，避免破坏角落布局',
    ],
    tip: '🌟 推荐：把最大数字放左下角，只用↓←→（不上滑）！'
  },
  {
    title: '🔗 进阶技巧：链式构建',
    subtitle: '像搭积木一样组织棋盘',
    content: [
      '• 在角落边构建「数字链」：2→4→8→16→32...',
      '• 保持链上的数字从角落向外「递减」排列',
      '• 合并大数字前，先把周围的小数字清理掉',
    ],
    tip: '🌟 好的布局 = 角落最大，沿边递减，中间不乱！'
  },
  {
    title: '🚫 常见错误',
    subtitle: '新手最容易犯的 4 个错误',
    content: [
      '❌ 四个方向乱滑 → 破坏布局',
      '❌ 中间留空格 → 大数字被夹在中间',
      '❌ 急于合并大数字 → 忽略了小数字的整理',
      '❌ 不看下一步 → 移动前先想想后果',
    ],
    tip: '💡 每次移动前问自己：这步会破坏我的角落布局吗？'
  },
  {
    title: '🎯 高手心法',
    subtitle: '成为 2048 达人的秘诀',
    content: [
      '• 保持耐心：好的局面需要慢慢经营',
      '• 预见未来：至少想好两步之后的布局',
      '• 灵活应变：当局面不利时及时调整策略',
      '• 熟能生巧：多练习，你会越来越强！',
    ],
    tip: '🔥 2048 的最高境界：行云流水，一气呵成！'
  }
];

@Component
export struct TeachingOverlay {
  private closeCallback: () => void = () => {};
  @State currentPage: number = 0;

  build() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.6)')

      // 教程卡片
      Column() {
        // 顶部进度条
        Row() {
          ForEach(TUTORIAL_PAGES, (_page: TutorialPage, index: number) => {
            Column()
              .width(30)
              .height(4)
              .borderRadius(2)
              .backgroundColor(index <= this.currentPage ? '#EDC22E' : 'rgba(255,255,255,0.3)')
              .margin({ left: 3, right: 3 })
          })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 页面编号
        Text(`第 ${this.currentPage + 1}/${TUTORIAL_PAGES.length} 页`)
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ bottom: 8 })

        // 标题
        Text(TUTORIAL_PAGES[this.currentPage].title)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .width('100%')

        // 副标题
        Text(TUTORIAL_PAGES[this.currentPage].subtitle)
          .fontSize(15)
          .fontColor('rgba(255,255,255,0.75)')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 6, bottom: 20 })

        // 分隔线
        Column()
          .width('60%')
          .height(1)
          .backgroundColor('rgba(255,255,255,0.2)')
          .margin({ bottom: 20 })

        // 内容列表
        Column() {
          ForEach(TUTORIAL_PAGES[this.currentPage].content, (line: string) => {
            Text(line)
              .fontSize(15)
              .fontColor('rgba(255,255,255,0.9)')
              .lineHeight(24)
              .width('100%')
              .margin({ bottom: 6 })
          })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })
        .layoutWeight(1)

        // 提示框
        Row() {
          Text(TUTORIAL_PAGES[this.currentPage].tip)
            .fontSize(14)
            .fontColor('#EDC22E')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('rgba(237, 194, 46, 0.12)')
        .borderRadius(8)
        .margin({ top: 16, bottom: 20 })

        // 导航按钮
        Row({ space: 12 }) {
          // 关闭按钮
          Button('✕ 关闭')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(20)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.currentPage = 0;
              if (this.closeCallback) {
                this.closeCallback();
              }
            })

          // 上一页
          if (this.currentPage > 0) {
            Button('← 上一页')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#8F7A66')
              .borderRadius(20)
              .height(44)
              .layoutWeight(1)
              .onClick(() => {
                this.currentPage--;
              })
          }

          // 下一页 / 完成
          Button(this.currentPage < TUTORIAL_PAGES.length - 1 ? '下一页 →' : '🎉 开始游戏!')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor(this.currentPage < TUTORIAL_PAGES.length - 1 ? '#EDC22E' : '#F65E3B')
            .borderRadius(20)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              if (this.currentPage < TUTORIAL_PAGES.length - 1) {
                this.currentPage++;
              } else {
                this.currentPage = 0;
                if (this.closeCallback) {
                  this.closeCallback();
                }
              }
            })
        }
        .width('100%')
      }
      .width('88%')
      .height('80%')
      .padding(24)
      .backgroundColor('rgba(60, 58, 50, 0.95)')
      .borderRadius(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Block)
  }
}
