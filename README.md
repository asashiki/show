# show · Asashiki 项目展示站

> 浅仪式 Asashiki 各项目的**在线展示**集合 → **https://show.asashiki.com**
>
> 比截图更高级：页面会跟随项目演进，由 [Asashiki Design](https://github.com/asashiki/asashiki-design) 设计系统统一驱动。

这是一个**纯静态站点**，无构建步骤，托管在 Cloudflare Pages。任何能向本仓库推送代码的人（或 AI）都能维护它。

## 目录结构

```
show/
├── index.html              # 首页：所有项目卡片网格
├── projects/
│   └── sticker-mcp.html    # 单项目展示页（其余项目照此克隆）
├── console-app.html        # mcp-switch 控制台 SPA 外壳（真实前端 + 演示 mock 层）
├── console/
│   └── assets/             # 控制台构建产物（JS / CSS，从 mcp-switch 同步）
├── assets/
│   ├── site.css            # 站点样式（基于设计系统 tokens）
│   └── theme.js            # 明/暗 + 四季配色切换
├── _headers                # Cloudflare Pages 缓存 / 安全头
├── _redirects              # SPA 回退（/console/* → console-app.html）
└── README.md
```

### 两种展示形态

1. **静态示意页**（`projects/*.html`）—— 抄项目关键 UI 元素做静态仿真，轻量、自包含。多数项目用这种。
2. **实页展示**（`console-app.html` + `console/assets/`）—— 当项目本身就有一套完整前端时，直接搬它的**构建产物**进来，再注入一层「mock fetch」喂样例数据：跑的是真实代码，所以与线上**视觉与交互完全一致**，无需后端。即 mcp-switch 控制台的实页展示，访问 `/console/`（经 `_redirects` 回退到 `console-app.html`）。
   - 更新方式：`pnpm build` mcp-switch 的 console-web 后，把 `apps/mcp-gateway/console-web-dist/assets/*` 覆盖到 `console/assets/`，必要时同步 `console-app.html` 里引用的文件名 hash。
   - mock 层只在控制台启动前预置假 token + 拦截 `/api/console/*`，**不改动控制台一行源码**。
   - **外壳为何放在 `/console/` 之外**：Cloudflare Pages 会把 URL 里的 `.html` / `/index` 清理掉；若重写目标在 `/console/` 下（如 `/console/index.html`→清理为 `/console/`），会重新命中 `/console/*` 形成无限重定向，部署被拒。放在根的 `console-app.html`（清理为 `/console-app`）不匹配 `/console/*`，安全。

## 设计来源（重要）

页面**不写死颜色和强调尺寸**，统一引用设计系统的 CSS 变量，通过 jsDelivr CDN 接入：

```html
<link rel="stylesheet"
  href="https://cdn.jsdelivr.net/gh/asashiki/asashiki-design@main/tokens/tokens.css" />
```

因此 [`asashiki-design`](https://github.com/asashiki/asashiki-design) 改了配色，本站会自动跟随。
配色 / 间距 / 圆角规则见该仓库的 `DESIGN.md`：强调色面积 ≤15%、圆角只用 7/10/14px、用 1px 描边分层而非重阴影。

## 新增一个项目展示页

1. 复制 `projects/sticker-mcp.html` → `projects/<项目名>.html`，替换文案、特性、演示与安装片段。
2. 演示区只需**抄项目里的关键元素**做静态示意（仿气泡、仿组件），不必实现真实功能。
3. 在 `index.html` 的 `.grid` 里加一张卡片，链接到新页面。
4. 提交并推送，Cloudflare Pages 自动部署。

## 本地预览

```bash
python3 -m http.server 8080   # 然后访问 http://localhost:8080
```

## 部署（Cloudflare Pages）

- 连接本 GitHub 仓库，**构建命令留空**，**输出目录 = `/`（根目录）**。
- 自定义域名绑定 `show.asashiki.com`。
- 每次推送到默认分支即自动发布。

## 相关仓库

| 仓库 | 作用 |
| --- | --- |
| [`asashiki-design`](https://github.com/asashiki/asashiki-design) | 设计系统 · 提供 tokens |
| [`doc`](https://github.com/asashiki/doc) | 文档展示站 → doc.asashiki.com |
