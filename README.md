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
├── assets/
│   ├── site.css            # 站点样式（基于设计系统 tokens）
│   └── theme.js            # 明/暗 + 四季配色切换
├── _headers                # Cloudflare Pages 缓存 / 安全头
└── README.md
```

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
