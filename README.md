# Abyss Expedition · 深渊远征

一款暗黑奇幻像素风回合制 Roguelite。带领远征队穿过盐蚀地窟，选择路线、招募同伴并击败无灯司祭。

## 开始游戏

克隆仓库后，请从 [Pixel Frog 的 Tiny Swords 下载页](https://pixelfrog-assets.itch.io/tiny-swords) 下载 `Tiny Swords (Free Pack).zip`，解压到工程的 `assets/` 下，确认 `assets/Tiny Swords (Free Pack)/Units/` 存在。游戏在战斗和选人界面会读取这套素材，该素材包由作者单独提供。

用 Godot 4.8 dev6 打开 `project.godot`，按 **F5** 运行。选人时可输入种子。种子 `151` 可复现已经跑通的路线。

- 地图用滚轮浏览。青色外环标记可以前往的节点，悬停可查看房间说明。
- 战斗时点选技能，再点击高亮的目标。数字键 **1–3** 可选技能，范围技能会直接施放。
- **Esc** 可取消当前目标选择或打开暂停菜单。背包可查看职业、装备和消耗品。
- 开始远征、完成房间或在地图使用背包后会写入检查点。「继续游戏」从检查点返回地图。

## 工程

- [素材清单](docs/asset_catalog.md)
- [功能规格](specs/001-abyss-expedition/spec.md)
- [实施计划](specs/001-abyss-expedition/plan.md)
- [验收和限制](docs/verification.md)
- [选人截图](docs/screenshots/roster.png) · [地图截图](docs/screenshots/map.png) · [Boss 战截图](docs/screenshots/combat.png)

运行回归测试时，从工程根目录执行以下命令。将 Godot 路径换成本机安装位置。

```powershell
& D:/Godot/Godot_v4.8-dev6_win64_console.exe --headless --path . --time-scale 12 --script res://tests/run_tests.gd
```

