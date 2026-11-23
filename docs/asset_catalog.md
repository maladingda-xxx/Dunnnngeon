# 美术资源清单

## 当前单位和字体

单位的纹理路径、裁剪矩形、动作帧和出手帧记录在 [data/unit_art.json](../data/unit_art.json)。各个战斗动作可以使用独立图集，按角色的待机比例和落脚点对齐。

| 单位 | 当前图像与动作 |
|---|---|
| 战士 | 蓝色 Warrior 待机、奔跑、两种挥砍和举盾 |
| 骑士 | 黑色 Lancer 原版待机（12 帧）、奔跑、水平突刺和防御 |
| 法师 | 原创伊格像素图集，金边紫色宽檐帽、短斗篷和青晶法杖 |
| 牧师 | 蓝色 Monk 待机、施法和治疗光效 |
| 游侠 | Tiny Swords Archer 原版动作，森林深绿配色和原版箭矢 |
| 盗贼 | 红色 Pawn 持刀待机、持刀奔跑和匕首动作 |
| 玄铁守卫 | 黑色 Warrior 举盾、奔跑和挥砍 |
| 灯骸祭师 | 红色 Monk 待机、施法和治疗光效 |

灰骨哨兵、回声蝠、深穴蝰、潮魂、断誓巨像和无灯司祭使用 [潮骸重绘图集](../assets/Enemies/tide-monsters.png)。图集由内置 ImageGen 参照原怪轮廓和 Tiny Swords 的像素密度生成，战斗中通过冲刺起伏、蓄力和施法特效表现动作。

Tiny Swords 免费包的单位图集中没有受击和死亡帧。缺少这些帧的单位使用短暂后仰、受击闪光和倒地淡出。

黑色 Lancer 在选人和战斗中显示完整长枪。地图、行动顺序、背包和招募卡使用同一张待机图里的盔甲区域，让小图优先显示人物。

[伊格的透明图集](../assets/Chars/igor-storm-mage.png) 由内置 ImageGen 参照游戏选人界面生成。四列三行共十二帧，按照从左到右、从上到下的顺序读取。待机四帧循环播放。灵火、星盐爆和雷印共用四帧施法动作，范围技能每次施放播放一遍。第三行前两帧用于受击和恢复，后两帧用于力竭倒地。

<details>
<summary>伊格图集生成提示词</summary>

```text
Edit the first attached image, a 12-frame game sprite atlas of Igor the mage, to visually match the Tiny Swords party sprites in the second image. In the second image, use the shapes and colors of the blue shield warrior, the blue-robed cleric, and the red-scarf dagger rogue as the style references. Ignore the old tiny purple mage in the third card and ignore the interface. Produce only the revised atlas. Preserve the 4-column by 3-row grid, facing toward the RIGHT in three-quarter overhead view, all twelve distinct poses and their order, transparency, and in each cell the centered placement and consistent boots baseline. Keep the pointed wizard hat and crystal staff as identity cues.

Redesign proportions substantially throughout: SHORT SQUAT AND BROAD, round bean-shaped chibi body, oversized pale warm-cream face with one or two small simple dark pixels for eyes, tiny stumpy rounded boots almost hidden under a broad bell-shaped cloak. Hat+face ~58% of the full height, body ~33%, boots ~9%. The fully standing silhouette including compact upright staff is approximately as wide as it is tall, except the thrusts which may extend horizontally. Hat has a large rounded brim and a short chunky bent tip with a thick golden band, not thin jagged zigzags. Royal lavender-purple hat and rich violet cloak in large bright flat color clusters, with warm gold band and cream face, dark navy near-black 1-grid-pixel outline, one chunky cool lilac highlight on the hat and small pale cyan staff jewel. Use the Tiny Swords shading construction: bold clear top-left lit planes, two or three flat shades per material, a few broad highlight clusters, raised broad chibi face, exaggerated thick stocky proportion, the same pixel grain as the reference. Remove delicate buckles, thin etched lines, cloth microtexture, dense shading, long thin limbs, dark muddy burgundy, glow gradients and miniature human anatomy. The character should read at a 64 by 64 pixel sprite resolution even though the atlas is delivered larger. Every frame must read as the same character with the same width and character volume.

Canvas EXACT 1536 by 1024 landscape with a regular 4 by 3 grid, each sprite centered in its 384 by roughly 341 cell, at least 8% empty alpha on all cell sides. Each idle sprite should occupy around 70 percent of cell height and 65 percent of cell width, with feet at roughly 88 percent of each cell height. Row 1 four standing idle poses with tiny bobs, staff on the right. Row 2 four clear casting key poses: pull the staff back, thrust it diagonally right with 2-3 small aqua pixels, follow through, return to upright. Row 3 four different poses: recoil hand shielding face, quick knee-bent recovery, sagging onto the knees, fully fallen on the floor with the staff. Exactly twelve figures, only transparent space between them. No grid marks, letters, scenery, floor shadow or extra objects.
```

</details>

界面使用随工程打包的 Fusion Pixel 12px 比例版简体中文字体，版本为 2026.11.10。字体授权文本随 [字体资源](../assets/fonts) 一并保存。[上游发行页](https://github.com/TakWolf/fusion-pixel-font/releases/tag/2026.11.10)

<details>
<summary>潮骸图集生成提示词</summary>

```text
Style transfer for a single game spritesheet, a 3 columns by 2 rows square-ish landscape grid with six isolated transparent cutout combat sprites. Reference image: the TOP row is a style sample (16-bit chunky outlined fantasy characters). The BOTTOM row is the edit target, six very low-res existing monsters. Redraw each monster with fresh details in the top-row pixel-art style. Deliver ONLY the six monster sprites in a regular 3 by 2 sheet, no existing image border, no panels, absolutely no words/letters/captions, no background, no floors or shadows, true alpha between and outside sprites. Order strictly: TOP LEFT gray ivory skeleton soldier with rust-red tattered scarf, compact sword and one dark eye socket, in aggressive standing pose; TOP CENTER wide dusky purple and mulberry cave bat with eyes and two spread ragged wings, flying; TOP RIGHT jade and grey-green coiled viper with raised cobra-like head, angular fangs, subtle red tongue. BOTTOM LEFT an upward-tapered spectral wraith, storm-blue hood, two turquoise eyes, teal flames, trailing torn ghost robes, no legs; BOTTOM CENTER huge hunched basalt and slate-blue stone golem, squared shoulders, large blunt fists and short stout legs, teal runes on chest, two eyes; BOTTOM RIGHT imposing void priest consisting of a floating ivory mask with a black hollow and no visible face over a midnight indigo armored ritual cloak, symmetrical jagged amber-gold ritual prongs on each shoulder reaching outward; fully drawn robes ending in pointed hems. Three-quarter side-view, the creatures mostly face LEFT. Center each complete sprite inside its equal grid cell, leave 12% minimum empty gutter on every edge of each cell. Equal transparent negative space left and right. Use a consistent 16-bit RPG pixel grid, hard stepped edges, clean full silhouettes, readable at 50-85 source pixels tall, clusters of flat shadow/midtone/highlight colors, near-black outline, restrained desaturated dungeon teal, mauve, bone and copper. Similar hand-pixelled medium detail to the top row. No painterly edges, no glow haze, no pixel texture outside silhouettes, no excess microdetail, no off-grid high resolution linework.
```

</details>

## 初版素材索引

初版的六类资源包含 278 张独立 RGBA PNG。透明边界按 alpha 通道非零区域测量。下表记录初版用途。

裁剪矩形依次记录 x、y、宽、高，左上为原点。

## Chars · 19 张

128 × 128 RGBA（19 张）

| 资源 | 来源 | 裁剪矩形 | 用途 |
|---|---|---|---|
| 备选素材 | assets/Chars/Chars_0.png | 32, 24, 56, 80 | 图集索引 |
| 备选素材 | assets/Chars/Chars_1.png | 40, 16, 56, 88 | 图集索引 |
| 法师 | assets/Chars/Chars_2.png | 40, 16, 48, 88 | 职业与队伍 |
| 备选素材 | assets/Chars/Chars_3.png | 32, 16, 56, 88 | 图集索引 |
| 盗贼 | assets/Chars/Chars_4.png | 40, 24, 48, 88 | 职业与队伍 |
| 备选素材 | assets/Chars/Chars_5.png | 32, 24, 56, 88 | 图集索引 |
| 备选素材 | assets/Chars/Chars_6.png | 40, 24, 48, 88 | 图集索引 |
| 备选素材 | assets/Chars/Chars_7.png | 24, 24, 72, 88 | 图集索引 |
| 备选素材 | assets/Chars/Chars_8.png | 40, 24, 48, 88 | 图集索引 |
| 备选素材 | assets/Chars/Chars_9.png | 40, 16, 48, 96 | 图集索引 |
| 牧师 | assets/Chars/Chars_10.png | 32, 16, 64, 96 | 职业与队伍 |
| 备选素材 | assets/Chars/Chars_11.png | 40, 24, 48, 88 | 图集索引 |
| 备选素材 | assets/Chars/Chars_12.png | 24, 24, 72, 88 | 图集索引 |
| 战士 | assets/Chars/Chars_13.png | 40, 24, 48, 72 | 职业与队伍 |
| 骑士 | assets/Chars/Chars_14.png | 40, 24, 48, 72 | 职业与队伍 |
| 备选素材 | assets/Chars/Chars_15.png | 32, 32, 64, 64 | 图集索引 |
| 备选素材 | assets/Chars/Chars_16.png | 32, 24, 48, 72 | 图集索引 |
| 备选素材 | assets/Chars/Chars_17.png | 32, 24, 48, 72 | 图集索引 |
| 游侠 | assets/Chars/Chars_18.png | 40, 24, 48, 72 | 职业与队伍 |

## Monsters · 40 张

128 × 128 RGBA（40 张）

| 资源 | 来源 | 裁剪矩形 | 用途 |
|---|---|---|---|
| 备选素材 | assets/Monsters/Monsters_0.png | 40, 40, 48, 56 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_1.png | 24, 32, 72, 64 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_2.png | 56, 32, 32, 64 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_3.png | 40, 48, 48, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_4.png | 32, 32, 64, 64 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_5.png | 32, 40, 64, 56 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_6.png | 32, 64, 72, 32 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_7.png | 32, 48, 64, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_8.png | 32, 48, 64, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_9.png | 32, 32, 64, 64 | 图集索引 |
| 玄铁守卫 | assets/Monsters/Monsters_10.png | 24, 48, 72, 48 | 遭遇战 |
| 回声蝠 | assets/Monsters/Monsters_11.png | 0, 40, 128, 40 | 遭遇战 |
| 备选素材 | assets/Monsters/Monsters_12.png | 24, 40, 72, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_13.png | 32, 32, 64, 56 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_14.png | 40, 40, 56, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_15.png | 16, 24, 88, 80 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_16.png | 40, 16, 40, 88 | 图集索引 |
| 灰骨哨兵 | assets/Monsters/Monsters_17.png | 32, 16, 72, 88 | 遭遇战 |
| 备选素材 | assets/Monsters/Monsters_18.png | 16, 16, 80, 88 | 图集索引 |
| 深穴蝰 | assets/Monsters/Monsters_19.png | 32, 32, 72, 64 | 遭遇战 |
| 备选素材 | assets/Monsters/Monsters_20.png | 8, 16, 104, 88 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_21.png | 16, 16, 96, 96 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_22.png | 16, 8, 96, 112 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_23.png | 0, 16, 128, 96 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_24.png | 40, 56, 56, 32 | 图集索引 |
| 灯骸祭师 | assets/Monsters/Monsters_25.png | 48, 24, 32, 72 | 遭遇战 |
| 备选素材 | assets/Monsters/Monsters_26.png | 32, 32, 56, 64 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_27.png | 32, 16, 64, 72 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_28.png | 32, 48, 72, 40 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_29.png | 48, 56, 40, 32 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_30.png | 24, 48, 80, 40 | 图集索引 |
| 潮魂 | assets/Monsters/Monsters_31.png | 8, 8, 112, 112 | 遭遇战 |
| 备选素材 | assets/Monsters/Monsters_32.png | 48, 64, 40, 16 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_33.png | 32, 32, 64, 56 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_34.png | 32, 40, 56, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_35.png | 48, 40, 40, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_36.png | 32, 40, 72, 48 | 图集索引 |
| 备选素材 | assets/Monsters/Monsters_37.png | 16, 16, 96, 96 | 图集索引 |
| 镜面异兽 | assets/Monsters/Monsters_38.png | 32, 40, 64, 48 | 遭遇战 |
| 备选素材 | assets/Monsters/Monsters_39.png | 32, 48, 64, 48 | 图集索引 |

## Giants · 6 张

256 × 256 RGBA（6 张）

| 资源 | 来源 | 裁剪矩形 | 用途 |
|---|---|---|---|
| 无灯司祭 | assets/Giants/Giants_0.png | 24, 72, 208, 120 | 首领和大型敌人 |
| 苔脊古龙 | assets/Giants/Giants_1.png | 56, 48, 144, 128 | 首领和大型敌人 |
| 备选素材 | assets/Giants/Giants_2.png | 80, 48, 128, 128 | 图集索引 |
| 备选素材 | assets/Giants/Giants_3.png | 64, 56, 128, 128 | 图集索引 |
| 备选素材 | assets/Giants/Giants_4.png | 48, 64, 168, 120 | 图集索引 |
| 断誓巨像 | assets/Giants/Giants_5.png | 56, 72, 152, 120 | 首领和大型敌人 |

## Scenery · 48 张

128 × 128 RGBA（48 张）

| 资源 | 来源 | 裁剪矩形 | 用途 |
|---|---|---|---|
| 木箱 | assets/Scenery/Scenery_0.png | 16, 32, 88, 64 | 地牢陈设与房间 |
| 镀金宝箱 | assets/Scenery/Scenery_1.png | 16, 32, 88, 64 | 地牢陈设与房间 |
| 秘银宝箱 | assets/Scenery/Scenery_2.png | 0, 24, 120, 72 | 地牢陈设与房间 |
| 备选素材 | assets/Scenery/Scenery_3.png | 32, 8, 64, 112 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_4.png | 48, 32, 40, 72 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_5.png | 40, 48, 56, 48 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_6.png | 40, 40, 56, 56 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_7.png | 40, 48, 48, 48 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_8.png | 40, 48, 40, 48 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_9.png | 32, 32, 80, 72 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_10.png | 32, 8, 72, 104 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_11.png | 48, 40, 32, 56 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_12.png | 16, 24, 88, 80 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_13.png | 8, 32, 112, 56 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_14.png | 8, 40, 112, 48 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_15.png | 16, 32, 104, 56 | 图集索引 |
| 祭烛 | assets/Scenery/Scenery_16.png | 40, 56, 40, 32 | 地牢陈设与房间 |
| 备选素材 | assets/Scenery/Scenery_17.png | 32, 32, 64, 56 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_18.png | 8, 16, 104, 88 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_19.png | 24, 16, 88, 88 | 图集索引 |
| 蓝色菌簇 | assets/Scenery/Scenery_20.png | 32, 24, 64, 80 | 地牢陈设与房间 |
| 备选素材 | assets/Scenery/Scenery_21.png | 32, 8, 56, 96 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_22.png | 40, 40, 48, 64 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_23.png | 32, 24, 72, 88 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_24.png | 24, 40, 80, 48 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_25.png | 32, 32, 72, 64 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_26.png | 24, 40, 80, 56 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_27.png | 24, 32, 72, 64 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_28.png | 24, 32, 80, 64 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_29.png | 8, 32, 104, 96 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_30.png | 32, 48, 56, 40 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_31.png | 16, 32, 88, 64 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_32.png | 16, 40, 88, 56 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_33.png | 16, 32, 88, 64 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_34.png | 24, 32, 88, 64 | 图集索引 |
| 枯根 | assets/Scenery/Scenery_35.png | 32, 0, 64, 80 | 地牢陈设与房间 |
| 泉水石门 | assets/Scenery/Scenery_36.png | 8, 24, 104, 88 | 地牢陈设与房间 |
| 祭坛 | assets/Scenery/Scenery_37.png | 16, 8, 88, 112 | 地牢陈设与房间 |
| 备选素材 | assets/Scenery/Scenery_38.png | 40, 16, 40, 96 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_39.png | 56, 32, 24, 80 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_40.png | 64, 32, 64, 96 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_41.png | 0, 32, 72, 96 | 图集索引 |
| 短烛 | assets/Scenery/Scenery_42.png | 56, 24, 8, 80 | 地牢陈设与房间 |
| 备选素材 | assets/Scenery/Scenery_43.png | 0, 48, 128, 40 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_44.png | 0, 48, 128, 40 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_45.png | 0, 48, 128, 40 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_46.png | 64, 0, 64, 96 | 图集索引 |
| 备选素材 | assets/Scenery/Scenery_47.png | 0, 0, 72, 96 | 图集索引 |

## Items · 72 张

128 × 128 RGBA（72 张）

| 资源 | 来源 | 裁剪矩形 | 用途 |
|---|---|---|---|
| 备选素材 | assets/Items/Items_0.png | 40, 32, 48, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_1.png | 48, 40, 40, 56 | 图集索引 |
| 镇静露 | assets/Items/Items_2.png | 40, 48, 48, 48 | 装备与消耗品 |
| 余烬药剂 | assets/Items/Items_3.png | 40, 40, 40, 56 | 装备与消耗品 |
| 净潮盐 | assets/Items/Items_4.png | 40, 40, 48, 56 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_5.png | 40, 32, 48, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_6.png | 40, 40, 40, 56 | 图集索引 |
| 备选素材 | assets/Items/Items_7.png | 40, 48, 48, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_8.png | 40, 32, 48, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_9.png | 40, 32, 56, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_10.png | 40, 32, 56, 64 | 图集索引 |
| 潮磨短剑 | assets/Items/Items_11.png | 40, 8, 40, 104 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_12.png | 48, 40, 32, 72 | 图集索引 |
| 备选素材 | assets/Items/Items_13.png | 48, 8, 32, 112 | 图集索引 |
| 银灯节杖 | assets/Items/Items_14.png | 48, 32, 40, 72 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_15.png | 40, 16, 56, 88 | 图集索引 |
| 备选素材 | assets/Items/Items_16.png | 48, 40, 32, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_17.png | 56, 40, 24, 56 | 图集索引 |
| 盐痕短刃 | assets/Items/Items_18.png | 48, 48, 24, 48 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_19.png | 32, 24, 56, 80 | 图集索引 |
| 备选素材 | assets/Items/Items_20.png | 56, 8, 8, 104 | 图集索引 |
| 备选素材 | assets/Items/Items_21.png | 40, 32, 48, 72 | 图集索引 |
| 备选素材 | assets/Items/Items_22.png | 48, 16, 40, 88 | 图集索引 |
| 劈潮斧 | assets/Items/Items_23.png | 40, 24, 56, 80 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_24.png | 48, 40, 24, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_25.png | 40, 32, 56, 56 | 图集索引 |
| 备选素材 | assets/Items/Items_26.png | 48, 32, 24, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_27.png | 48, 24, 24, 72 | 图集索引 |
| 备选素材 | assets/Items/Items_28.png | 48, 32, 24, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_29.png | 56, 24, 32, 80 | 图集索引 |
| 备选素材 | assets/Items/Items_30.png | 48, 32, 32, 72 | 图集索引 |
| 备选素材 | assets/Items/Items_31.png | 56, 16, 24, 88 | 图集索引 |
| 备选素材 | assets/Items/Items_32.png | 48, 40, 24, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_33.png | 48, 48, 32, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_34.png | 48, 40, 24, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_35.png | 64, 48, 8, 40 | 图集索引 |
| 藻纹咒典 | assets/Items/Items_36.png | 40, 40, 40, 48 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_37.png | 48, 40, 40, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_38.png | 48, 40, 40, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_39.png | 48, 40, 40, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_40.png | 40, 40, 40, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_41.png | 48, 40, 40, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_42.png | 56, 48, 32, 32 | 图集索引 |
| 备选素材 | assets/Items/Items_43.png | 48, 40, 32, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_44.png | 48, 40, 32, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_45.png | 48, 40, 32, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_46.png | 48, 40, 32, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_47.png | 48, 40, 32, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_48.png | 40, 40, 40, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_49.png | 40, 32, 48, 48 | 图集索引 |
| 备选素材 | assets/Items/Items_50.png | 40, 40, 48, 48 | 图集索引 |
| 铆铁徽记 | assets/Items/Items_51.png | 48, 40, 40, 40 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_52.png | 40, 40, 48, 40 | 图集索引 |
| 萤石护符 | assets/Items/Items_53.png | 48, 40, 48, 40 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_54.png | 32, 32, 64, 64 | 图集索引 |
| 备选素材 | assets/Items/Items_55.png | 48, 40, 40, 56 | 图集索引 |
| 备选素材 | assets/Items/Items_56.png | 8, 24, 112, 80 | 图集索引 |
| 备选素材 | assets/Items/Items_57.png | 56, 56, 24, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_58.png | 56, 56, 24, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_59.png | 24, 40, 72, 56 | 图集索引 |
| 备选素材 | assets/Items/Items_60.png | 48, 24, 40, 80 | 图集索引 |
| 备选素材 | assets/Items/Items_61.png | 56, 24, 16, 72 | 图集索引 |
| 备选素材 | assets/Items/Items_62.png | 32, 48, 72, 32 | 图集索引 |
| 备选素材 | assets/Items/Items_63.png | 40, 32, 64, 56 | 图集索引 |
| 备选素材 | assets/Items/Items_64.png | 16, 16, 88, 96 | 图集索引 |
| 备选素材 | assets/Items/Items_65.png | 32, 48, 64, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_66.png | 56, 40, 72, 40 | 图集索引 |
| 备选素材 | assets/Items/Items_67.png | 0, 64, 72, 8 | 图集索引 |
| 黎明残刃 | assets/Items/Items_68.png | 64, 16, 16, 88 | 装备与消耗品 |
| 备选素材 | assets/Items/Items_69.png | 32, 40, 64, 56 | 图集索引 |
| 备选素材 | assets/Items/Items_70.png | 40, 64, 56, 16 | 图集索引 |
| 备选素材 | assets/Items/Items_71.png | 48, 32, 48, 72 | 图集索引 |

## Tiles · 93 张

128 × 128 RGBA（93 张）

| 资源 | 来源 | 裁剪矩形 | 用途 |
|---|---|---|---|
| 备选素材 | assets/Tiles/Tiles_0.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_1.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_2.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_3.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_4.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_5.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_7.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_8.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_9.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_10.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_11.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_12.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_13.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_14.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_15.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_16.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_17.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_19.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_20.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_21.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_22.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_23.png | 0, 0, 128, 128 | 图集索引 |
| 石砌墙 | assets/Tiles/Tiles_24.png | 0, 0, 128, 128 | 地牢像素环境 |
| 备选素材 | assets/Tiles/Tiles_25.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_26.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_27.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_28.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_29.png | 0, 0, 128, 128 | 图集索引 |
| 暗石底纹 | assets/Tiles/Tiles_31.png | 0, 0, 128, 128 | 地牢像素环境 |
| 备选素材 | assets/Tiles/Tiles_32.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_33.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_34.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_35.png | 0, 0, 128, 128 | 图集索引 |
| 大块砖 | assets/Tiles/Tiles_36.png | 0, 0, 128, 128 | 地牢像素环境 |
| 备选素材 | assets/Tiles/Tiles_37.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_38.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_39.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_40.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_41.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_43.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_44.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_45.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_46.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_47.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_48.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_49.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_50.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_51.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_52.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_53.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_55.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_56.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_57.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_58.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_59.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_60.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_61.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_62.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_63.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_64.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_65.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_67.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_68.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_69.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_70.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_71.png | 0, 0, 128, 128 | 图集索引 |
| 碎砖墙面 | assets/Tiles/Tiles_72.png | 0, 0, 128, 128 | 地牢像素环境 |
| 备选素材 | assets/Tiles/Tiles_73.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_74.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_75.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_76.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_77.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_79.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_80.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_81.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_82.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_83.png | 0, 0, 128, 128 | 图集索引 |
| 石板边缘 | assets/Tiles/Tiles_84.png | 0, 0, 128, 128 | 地牢像素环境 |
| 备选素材 | assets/Tiles/Tiles_85.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_86.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_87.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_88.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_89.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_91.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_92.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_93.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_94.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_95.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_103.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_104.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_105.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_106.png | 0, 0, 128, 128 | 图集索引 |
| 备选素材 | assets/Tiles/Tiles_107.png | 0, 0, 128, 128 | 图集索引 |
