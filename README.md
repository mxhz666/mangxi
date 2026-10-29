# 芒西绘帧工作室 — AIGC 影像工作室作品集

浅色极简、大字号排版、动效型的 AIGC 影像工作室作品集网站，用于展示高质感商业 TVC 宣传片（服饰 / 品牌 / 国风 / 美式 / 电商短视频）。

- 品牌名：芒西绘帧工作室（英文名 MANGXI Studio，网址用 `mangxi`）
- Slogan：帧帧，皆是卖点
- 配色：琥珀金 `#F2B84B` / 西瓜赤 `#D94A4A` / 炭黑 `#141414` / 米白 `#F5F1E8`

## 目录结构

```
portfolio/
├── index.html         # 页面结构（文案、联系方式在这里改）
├── css/styles.css     # 样式与配色
├── js/
│   ├── script.js      # 交互动效
│   └── works.js       # 作品列表（自动生成，不要手改）
├── assets/            # 你的作品视频放这里
├── works.json         # 作品「源数据」（改标题/分类在这里）
├── scripts/build.ps1  # 自动生成 js/works.js 的脚本
├── 预览.bat            # 双击本地查看网页
├── 发布.bat            # 更新作品并发布（双击它）
├── 首次连接.bat        # 第一次连接 GitHub（只做一次）
└── README.md
```

## 怎么用（三步）

> 想先看看网页长什么样：双击 `预览.bat` 即可在浏览器打开。

### 第 1 步：把作品视频放进来
把视频拖进 `assets` 文件夹。文件名用英文或数字，例如 `01.mp4`。

### 第 2 步：一键发布
双击 `发布.bat`：
1. 自动扫描 `assets` 里的视频，加进作品列表；
2. 自动推送（git）到 GitHub。

### 第 3 步：等 1-2 分钟刷新网址
打开你的网址（`https://你的用户名.github.io/mangxi/`）就能看到新作品。

## 改标题 / 分类 / 说明

用记事本打开 `works.json`，每一条作品是：

```json
{ "title": "作品标题", "cat": "brand", "src": "assets/01.mp4", "meta": "品牌 TVC / 30s / 2025" }
```

- `title`：作品名
- `cat`：分类（apparel / brand / chinese / american / ecommerce）
- `src`：视频路径（`assets/01.mp4` 或在线网址）
- `meta`：卡片下方说明（类型 / 时长 / 年份）

改完保存，再双击 `发布.bat`。

## 替换主推片（首页大视频）

`index.html` 里搜 `hero-showreel.svg`，把那一行换成你的视频，例如：

```html
<video autoplay muted loop playsinline><source src="assets/showreel.mp4" type="video/mp4" /></video>
```

## 改联系方式

`index.html` 里搜：
- `zzq7896557`（微信）
- `@芒果配西瓜`（抖音）
- `hello@yourname.example`（邮箱，改成你的真实邮箱）

## 删除某个作品

1. 删掉 `assets` 文件夹里对应的视频文件；
2. 用记事本打开 `works.json`，删掉对应的那一行（整条 `{ ... }`）；
3. 重新双击 `发布.bat`。

## 首次部署到 GitHub Pages（拿网址）

1. 注册 GitHub：https://github.com （免费）
2. 新建仓库：New repository → 名字填 `mangxi`，选 **Public** → Create
3. 双击 `首次连接.bat`，按提示输入 GitHub 用户名和仓库名；弹出浏览器时点「授权」
4. 打开仓库 → Settings → Pages → Source 选 `main` 分支、根目录 `/` → Save
5. 等 1-2 分钟，页面会显示你的网址：`https://你的用户名.github.io/mangxi/`

## 提示

- 视频建议 mp4（H.264），单条控制在 **100MB 以内**（GitHub 免费限制，超了传不上去）。
  - 用**剪映**导出时：分辨率选 1080P、码率选「推荐」或更低、格式 MP4；
  - 或用**格式工厂 / HandBrake** 转一下，码率 4–8 Mbps，几十秒的片一般能压到几十 MB。
- GitHub Pages 国内多数时候能访问，偶尔会慢；想要更快更稳，可升级国内云存储（另配）。
- 当前作品用的是本地占位图，换成你的真实视频即可。
