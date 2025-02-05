This file is severely out of date. If you can help updating this translation, please reach out to us (contact in README.md - the English version).

# VoxeLibre
一個非官方的Luanti遊戲，遊玩方式和Minecraft類似。由davedevils從MineClone分拆。
由許多人開發。並非由Mojang Studios開發。<!-- "Mojang AB"'s Name changed at 2020/05, main README should change too -->

### 遊玩
你開始在一個完全由方塊隨機生成的世界裡。你可以探索這個世界，挖掘和建造世界上幾乎所有的方塊，以創造新的結構。你可以選擇在「生存模式」中進行遊戲，在這個模式中，你必須與怪物戰鬥，飢餓求生，並在遊戲的其他各個環節中慢慢進步，如採礦、養殖、建造機器等等。

或者你也可以在「創造模式」中玩，在這個模式中，你可以瞬間建造大部分東西。
#### Gameplay summary

* 沙盒式遊戲，沒有明確目標
* 生存：與怪物和飢餓搏鬥
* 挖礦來獲得礦物和寶物
* 附魔：獲得經驗值並以附魔強化你的工具
* 使用收集的方塊來創造偉大的建築
* 收集鮮花（和其他染料來源），令世界多姿多彩
* 找些種子並開始耕種
* 尋找或合成數百個物品之一
* 建立一個鐵路系統，並從礦車中得到樂趣
* 用紅石電路建造複雜的機器
* 在創造模式下，你幾乎可以免費建造任何東西，而且沒有限制。

## 如何開始
### 開始生存
* **挖樹幹**直到其破裂並收集木材
* 將木頭**放入2×2的格子中**（你的物品欄中的「合成格子」），然後製作4塊木材。
* 將4塊木材按2×2的形狀擺放在合成格子裡，製作成合成臺。
* **右鍵單擊製作臺**以獲得3×3製作網格，製作更複雜的東西
* 使用**合成指南**（書形圖標）了解所有可能的合成方式
* **製作一個木鎬**，這樣你就可以挖石頭了。
* 不同的工具可以打破不同種類的方塊。試試吧！
* 繼續玩你想玩的。盡情享受吧！

### 耕種
* 找到種子
* 合成鋤頭
* 用鋤頭右鍵點擊泥土或類似的方塊，創建農田
* 將種子放在農田上，看著它們長出來
* Collect plant when fully grown
* If near water, farmland becomes wet and speeds up growth

### Furnace
* Craft furnace
* Furnace allows you to obtain more items
* Upper slot must contain a smeltable item (example: iron ore)
* Lower slot must contain a fuel item (example: coal)
* See tooltips in crafting guide to learn about fuels and smeltable items

### Additional help
More help about the gameplay, blocks items and much more can be found from inside
the game. You can access the help from your inventory menu.

### Special items
The following items are interesting for Creative Mode and for adventure
map builders. They can not be obtained in-game or in the creative inventory.

* Barrier: `mcl_core:barrier`

Use the `/giveme` chat command to obtain them. See the in-game help for
an explanation.

#### Incomplete items
These items do not work yet, but you can get them with `/giveme` for testing:

* Minecart with Chest: `mcl_minecarts:chest_minecart`
* Minecart with Furnace: `mcl_minecarts:furnace_minecart`
* Minecart with Hopper: `mcl_minecarts:hopper_minecart`
* Minecart with Command Block: `mcl_minecarts:command_block_minecart`

## Installation
This game requires [Luanti](https://www.luanti.org) to run (version 5.0.0 or
later). So you need to install Luanti first. Only stable versions of Luanti
are officially supported.
There is no support for running VoxeLibre in development versions of Luanti.

To install VoxeLibre (if you haven't already), move this directory into the
“games” directory of your Luanti data directory. Consult the help of
Luanti to learn more.

## Project description
* **開發目標：我的世界, Java版, 版本 1.12**
* VoxeLibre還包括Luanti支持的Optifine功能。
* 後期Minecraft版本的功能可能會偷偷加入，但它們的優先級較低。
* 總的來說，Minecraft的目標是在Luanti目前允許的情況下進行克隆。
* 克隆Minecraft是最優先的。
* VoxeLibre將使用不同的圖形和聲音，但風格相似。
* 克隆界面沒有優先權。只會被粗略地模仿。
* 在Luanti中發現的局限性將在開發過程中被記錄和報告。

## 完成程度
該遊戲目前處於**alpha**階段。
它是可玩的，但尚未完成，預計會出現許多錯誤。
向後兼容性是**不能保證的**，更新你的世界可能會造成大大小小的bug（比如「缺少節點」的錯誤甚至崩潰）。

已經實現以下功能：

* 工具，武器
* 盔甲
* 合成和熔煉系統：2×2 合成格, 合成臺 (3×3 合成格), 熔爐, 合成教學
* 儲物箱，大型儲物箱，終界箱和界伏盒
* 熔爐, 漏斗
* 飢餓和飽食
* 大多數怪物和動物
* Minecraft 1.12中的所有礦物<!-- Minecraft 1.17 added copper, so here must mark the version is 1.12, then main README should also add this -->
* 主世界的大部分方塊
* 水和岩漿
* 天氣
* 28個生態域
* 地獄，熾熱的維度
* 紅石電路（部分）
* 礦車（部分）
* 狀態效果（部分）
* 經驗系統
* 附魔
* 釀造，藥水，藥水箭（部分）
* 船
* 火
* 建築方塊：樓梯、半磚、門、地板門、柵欄、柵欄門、牆。
* 時鐘
* 指南針
* 海綿
* 史萊姆方塊（不與紅石互動）
* 小植物和樹苗
* 染料
* 旗幟
* 裝飾方塊：玻璃、染色玻璃、玻璃片、鐵柵欄、陶土（和染色版本）、頭顱等
* 物品展示框
* 唱片機
* 床
* 物品欄
* 創造模式物品欄
* 生產
* 書和羽毛筆
* 一些服務器命令
* 還有更多！

以下是不完整的特性：

* 生成結構（特別是村莊）
* 一些怪物和動物
* 紅石系統
* 終界
* 特殊的礦車
* 一些不簡單的方塊和物品。

額外功能（在Minecraft 1.11中沒有）。

* 內置合成指南，向你展示製作和熔煉的配方
* 遊戲中的幫助系統包含了大量關於遊戲基礎知識、方塊、物品等方面的幫助。
* 臨時製作配方。它們的存在只是為了在你不在創造模式下時，提供一些其他無法獲得的物品。這些配方將隨著開發的進行和更多功能的出現而被移除。
* 完全可修改（得益於Luanti強大的Lua API）。
* 新的方塊和物品：
    * 查找工具，顯示觸及事物的幫助
    * 更多的半磚和樓梯
    * 地獄磚柵欄門
    * 紅地獄磚柵欄
    * 紅地獄磚柵欄門

與Minecraft的技性術差異：

* 高度限制為31000格(遠高於Minecraft)
* 水平世界大小約為62000×62000格（比Minecraft中的小得多，但仍然非常大）。
* 仍然非常不完整和有問題
* 塊、物品、敵人和其他功能缺失。
* 一些項目的名稱略有不同，以便於區分。
* 唱片機的音樂不同
* 不同的材質（像素完美）
* 不同的聲音（各種來源）
* 不同的引擎（Luanti）

...最後，VoxeLibre是自由軟件！

## 錯誤報告
請在此處報告所有錯誤和缺少的功能：

<https://git.minetest.land/VoxeLibre/VoxeLibre/issues>

## Chating with the community
我們有Discord交流羣：

<https://discord.gg/84GKcxczG3>


## Other readme files

* `LICENSE.txt`：GPLv3許可文本
* `CONTRIBUTING.md`: 為那些想參與貢獻的人提供資訊
* `MISSING_ENGINE_FEATURES.md`: VoxeLibre需要改进，Luanti中缺失的功能列表。
* `API.md`: 關於MineClone2的API

## 參與者
有這麼多人要列出（抱歉）。詳情請查看各mod目錄。本節只是粗略地介紹了本遊戲的核心作者。

### 程式碼
* [Wuzzy](https://forum.luanti.org/memberlist.php?mode=viewprofile&u=3082)：大多數mod的主要程序員（已退休）
* davedevils：VoxeLibre的原型——「MineClone」的創造者
* [ex-bart](https://github.com/ex-bart)：紅石比較器
* [Rootyjr](https://github.com/Rootyjr)：釣竿和錯誤修復
* [aligator](https://github.com/aligator)：改進門
* [ryvnf](https://github.com/ryvnf)：爆炸物理
* MysticTempest：錯誤修復
* [bzoss](https://github.com/bzoss)：狀態效果，釀造，藥水
* kay27 <kay27@bk.ru>：經驗系統，錯誤修復和優化（當前維護者）
* [EliasFleckenstein03](https://github.com/EliasFleckenstein03)：終界水晶，附魔，燃燒的怪物/玩家，箱子的動畫和錯誤修復（當前維護者）
* epCode：更好的玩家動畫，新徽標
* 2mac：修復動力鐵軌的錯誤
* 更多：待篇寫 (請查看各mod目錄)

#### Mod（概括）

* `controls`: Arcelmi
* `flowlib`: Qwertymine13
* `walkover`: lordfingle
* `drippingwater`: kddekadenz
* `mobs_mc`: maikerumine, 22i and others
* `awards`: rubenwardy
* `screwdriver`: RealBadAngel, Maciej Kastakin, Luanti contributors
* `xpanes`: Luanti contributors
* `mesecons` mods: Jeija and contributors
* `wieldview`: Stuart Jones
* `mcl_meshhand`: Based on `newhand` by jordan4ibanez
* `mcl_mobs`: Based on Mobs Redo [`mobs`] by TenPlus1 and contributors
* 大多其他的Mod: Wuzzy

每个mod的详细參與者可以在各个mod目录中找到。

### 圖形
* [XSSheep](http://www.minecraftforum.net/members/XSSheep)：主要作者；Minecraft 1.11的Pixel Perfection资源包的制作者
* [Wuzzy](https://forum.luanti.org/memberlist.php?mode=viewprofile&u=3082)：主菜單圖像和各種編輯和添加的材質包
* [kingoscargames](https://github.com/kingoscargames)：現有材質的各種編輯和添加
* [leorockway](https://github.com/leorockway)：怪物紋理的一些編輯
* [xMrVizzy](https://minecraft.curseforge.com/members/xMrVizzy)：釉陶（材質以後會被替換）
* yutyo <tanakinci2002@gmail.com>：VoxeLibre標志
* 其他：GUI圖片

### 翻譯
* Wuzzy：德語
* Rocher Laurent <rocherl@club-internet.fr>：法語
* wuniversales：西班牙語
* kay27 <kay27@bk.ru>：俄語
* [Emoji](https://toyshost2.ddns.net)：繁體中文<!-- Hi, after the translate finish, this name should add to the main README too! -->

### 模型
* [22i](https://github.com/22i)：所有模型的作者
* [tobyplowy](https://github.com/tobyplowy)：對上述模型進行UV映射修復

### 聲音和音樂
多種來源。 有關詳細信息，請參見相應的mod目錄。

### 特殊感謝

* Wuzzy，感謝他啟動和維護VoxeLibre多年。
* celeron55，創建Luanti。
* Luanti的社區提供了大量的mods選擇，其中一些最終被納入VoxeLibre。
* Jordach，為《Big Freaking Dig》的唱片機音樂合輯而來
* 花了太多時間為Minecraft Wiki寫作的工作狂。它是創建這個遊戲的寶貴資源。
* Notch和Jeb是Minecraft背后的主要力量
* XSSheep用於創建Pixel Perfection資源包。
* [22i](https://github.com/22i) 提供出色的模型和支持
* [maikerumine](http://github.com/maikerumine) 揭開生物和生物群落的序幕

## 給程序員的信息
你可以在「API.md」中找到有趣和有用的信息。

## 法律信息
這是一款粉絲開發的遊戲，並非由Mojang AB開發或認可。

複製是一種愛的行為。請複制和分享! <3
下面是詳細的法律條文，有需要的朋友可以參考。

### License of source code
```
VoxeLibre (by kay27, EliasFleckenstein, Wuzzy, davedevils and countless others)
is an imitation of Minecraft.

VoxeLibre is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License (in the LICENSE.txt file) for more
details.

In the mods you might find in the read-me or license
text files a different license. This counts as dual-licensing.
You can choose which license applies to you: Either the
license of VoxeLibre (GNU GPLv3) or the mod's license.

VoxeLibre is a direct continuation of the discontinued MineClone
project by davedevils.

Mod credits:
See `README.txt` or `README.md` in each mod directory for information about other authors.
For mods that do not have such a file, the license is the source code license
of VoxeLibre and the author is Wuzzy.
```

### License of media (textures and sounds)
```
No non-free licenses are used anywhere.

The textures, unless otherwise noted, are based on the Pixel Perfection resource pack for Minecraft 1.11,
authored by XSSheep. Most textures are verbatim copies, while some textures have been changed or redone
from scratch.
The glazed terracotta textures have been created by (MysticTempest)[https://github.com/MysticTempest].
Source: <https://www.planetminecraft.com/texture_pack/131pixel-perfection/>
License: [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)

The main menu images are release under: [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

All other files, unless mentioned otherwise, fall under:
Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
http://creativecommons.org/licenses/by-sa/3.0/

See README.txt in each mod directory for detailed information about other authors.
```
