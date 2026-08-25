# STARFALL // 星坠拾荒者

一个零素材、可直接编译的 Dora SSR 街机掌机游戏：驾驶拾荒艇收集黄色星核、躲避红色故障体，并用冲刺创造高分连击。

## 先运行原生电脑版本

```bash
DORA_PROJECT="$PWD/games/Starfall" ./dora-lab dev
```

电脑原生键位：

- `WASD` / 方向键：移动
- 鼠标：瞄准
- 鼠标左键 / `Space`：冲刺
- `P` / `Esc`：暂停
- `R`：重新开始

## 再运行掌机适配版本

```bash
DORA_PROJECT="$PWD/games/Starfall" \
DORA_ENTRY=handheld.lua \
./dora-lab dev
```

macOS / Windows 上会显示 Dora 虚拟手柄；Linux 掌机上不会显示遮挡画面的虚拟手柄。

R36S 键位：

| 游戏意图 | 掌机输入 |
|---|---|
| 移动 | 左摇杆或方向键 |
| 瞄准 | 右摇杆 |
| 冲刺 / 确认重开 | A |
| 暂停 / 继续 | Start 或 Select |
| 随时重新开始 | X |

## AI 开发入口

- 桌面入口：`init.ts`
- 掌机入口：`handheld.ts`
- 游戏循环与绘制：`Script/Game.ts`
- 语义输入状态：`Script/Input/Actions.ts`
- 原生电脑输入：`Script/Input/Desktop.ts`
- R36S 输入：`Script/Input/Handheld.ts`
- 目标尺寸与说明：`Script/TargetProfile.ts`

两个入口共享同一套游戏逻辑，输入适配和屏幕配置互相隔离。修改后必须先验证桌面版本，再验证 `640x480` 掌机版本。
