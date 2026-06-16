/**
 * 2048 教学模式组件 — 单页滚动布局
 * 通过 @Link 直接控制父组件的 showTeaching 状态
 * 所有教程内容在同一页上，上下滑动即可浏览
 */

interface TutorialSection {
  title: string;
  subtitle: string;
  content: string[];
  tip: string;
}

const TUTORIAL_SECTIONS: TutorialSection[] = [
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
  @Link showTeaching: boolean;

  // @Builder: 每个教程小节
  @Builder TutorialCard(section: TutorialSection, index: number) {
    Column() {
      // 序号
      Text(`${index + 1}. ${section.title}`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')

      Text(section.subtitle)
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.7)')
        .width('100%')
        .margin({ top: 4, bottom: 14 })

      // 分隔线
      Column()
        .width('50%')
        .height(1)
        .backgroundColor('rgba(255,255,255,0.15)')
        .margin({ bottom: 14 })

      // 内容
      Column() {
        ForEach(section.content, (line: string) => {
          Text(line)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.9)')
            .lineHeight(22)
            .width('100%')
            .margin({ bottom: 4 })
        })
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 提示
      Row() {
        Text(section.tip)
          .fontSize(13)
          .fontColor('#EDC22E')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('rgba(237, 194, 46, 0.12)')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.05)')
    .borderRadius(10)
    .margin({ bottom: 14 })
  }

  build() {
    Stack() {
      // 半透明背景 — 点击空白区域关闭
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.6)')
        .onClick(() => {
          this.showTeaching = false;
        })

      // 教程卡片容器 — 使用 Flex 布局确保 Scroll 获得正确的高度约束
      Flex({ direction: FlexDirection.Column }) {
        // 顶部标题栏（固定高度，不参与滚动）
        Row() {
          Text('📖 2048 完全指南')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Blank()
          Button('✕ 关闭')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(16)
            .height(36)
            .padding({ left: 14, right: 14 })
            .onClick(() => {
              this.showTeaching = false;
            })
        }
        .width('100%')
        .flexShrink(0)
        .padding({ left: 4, right: 4, bottom: 14 })

        // 可滚动内容区 — flexGrow(1) 占据剩余空间，内容超出时自动可滚
        Scroll() {
          Column() {
            ForEach(TUTORIAL_SECTIONS, (section: TutorialSection, index: number) => {
              this.TutorialCard(section, index)
            })

            // 底部提示
            Text('🎉 掌握了这些技巧，去挑战 2048 吧！')
              .fontSize(14)
              .fontColor('#EDC22E')
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 8, bottom: 8 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .width('100%')
        .flexGrow(1)
        .flexShrink(1)
      }
      .width('88%')
      .height('82%')
      .padding(20)
      .backgroundColor('rgba(48, 46, 40, 0.96)')
      .borderRadius(16)
      .hitTestBehavior(HitTestMode.Block)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Block)
  }
}
