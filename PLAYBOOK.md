# show 执行手册（PLAYBOOK）

> 给后来维护本仓库的人 / AI。照此做，避免重复踩坑。
> 本站 = 纯静态，Cloudflare Pages 托管，**构建命令留空，输出目录 `/`**。

---

## 一、两种展示形态，先选对

| 形态 | 用在哪 | 怎么做 |
| --- | --- | --- |
| **静态示意页** `projects/<项目>.html` | 多数项目 | 单个自包含 HTML，抄项目关键 UI 元素做静态仿真，不实现真实功能 |
| **实页展示** `console/`（或同类目录） | 项目本身有一整套完整前端时 | 直接搬它的**构建产物**，注入一层 mock 喂样例数据，跑真实代码 |

新增「静态示意页」：复制 `projects/sticker-mcp.html` 改文案 → 在 `index.html` 网格加一张卡片 → 推送。

---

## 二、实页展示的正确做法（mcp-switch 控制台即范例）

控制台是 React SPA，`BrowserRouter basename="/console"`。要让它在 `show.asashiki.com/console/` 上**和线上一模一样**地显示，又不连后端：

### 1. 文件布局（纯静态，**不要 `_redirects`**）

```
console/
├── index.html      # SPA 外壳 = 真实 dist 的 index.html + 一段内联 mock <script>
└── assets/         # 真实构建产物（JS / CSS），从源项目 dist 原样拷过来
```

- `/console/` → 由 `console/index.html` 走目录索引提供；
- `/console/assets/*.js,css` → 真实文件，按正确 MIME 直接送达；
- `basename=/console` 与真实 URL `/console/` 天然匹配，SPA 正常挂载。

### 2. 内联 mock 层（放在 bundle 的 `<script type="module">` **之前**）

职责，三件事，**绝不改源项目一行代码**：

1. **路径守卫**：若 `location.pathname` 不在 `/console` 下，`history.replaceState` 改成 `/console/`（防 basename 不匹配渲染空白）。
2. **预置假会话**：`localStorage` 写入源项目用的 token / user key，绕过登录页直达主界面。
3. **拦截 fetch**：monkeypatch `window.fetch`，对该项目所有后端路径（如 `/api/console/*`）返回**贴近真实的样例数据**；写操作返回温和成功。`window.fetch.bind` 记得判空保护。

> 数据形状必须**严格对齐源项目的 API 类型**，缺字段会让 React 运行时崩溃 → 空白。

### 3. 更新构建产物

源项目 `pnpm build` 后，把 `dist/assets/*` 覆盖到 `console/assets/`，并同步 `console/index.html` 里引用的**文件名 hash**（如 `index-XXXX.js`）。

---

## 三、❌ 绝对不要做的事（每一条都真摔过）

1. **不要用 `_redirects` 给 `/console/*` 做 SPA 回退。**
   Cloudflare Pages 会**清理 URL**（剥 `.html` 和 `/index`）。后果：
   - catch-all `/console/*  /console-app.html  200` 会把 `/console/` 下**所有路径，包括 JS/CSS 资源**一起匹配；目标 `.html` 被剥 → 200 重写降级成 **307 跳转**。于是 `/console/assets/x.js` 被 307 跳到 HTML 页 → 浏览器拿 HTML 当 JS 解析失败 → **React 不挂载 → 空白页**。
   - 目标若写 `/console/index.html` → 被剥成 `/console/` → 重新命中 `/console/*` → **无限重定向，部署直接被拒**。
   - 结论：实页展示用纯静态文件就够。代价仅仅是「深链接子路由（如 `/console/skills`）直接刷新会 404」——落地页内点 tab 走前端路由完全正常，对展示无影响，可接受。

2. **不要加原页面没有的横幅 / 水印 / 装饰**（如「演示模式…」）。要的是**原封不动复刻**，不是再创作。

3. **不要把 SPA 外壳放到 `/console/` 命名空间之外**（如根目录 `console-app.html`）。直接被打开时路径不在 `/console` 下 → basename 不匹配 → 空白。

---

## 四、🔍 排查通道（出问题按这个查，别靠猜）

1. **一定 curl 线上**，不要只信本地：
   ```bash
   curl -sS -D - -o /dev/null "https://show.asashiki.com/console/assets/<bundle>.js"
   ```
   关键看：状态码是不是 `200`、`content-type` 是不是 `text/javascript`。
   **返回 307 或 text/html = 资源被重定向/当成 HTML 了**（多半是 `_redirects` 中招）。
   > 本地 `python -m http.server` 和 jsdom **测不出** Cloudflare 的 `_redirects` / URL 清理行为，这类 bug 只在线上暴露。

2. **页面有横幅/外壳但内容空白** = HTML 跑了、bundle 没挂载 → 查 JS 资源是否正确送达、或 basename 是否匹配。

3. **用 jsdom 实跑真实 bundle** 抓挂载错误（补 `matchMedia` / `crypto.randomUUID` / `Response` 等 polyfill；`pretendToBeVisual:false` 防动画死循环）：能直接看出 React 是否挂载、basename 是否匹配、初始化是否报错、`#root` 最终 innerHTML。

4. **改完 push 后轮询线上**资源 `content-type` 确认新版生效，再让用户**强刷**（Ctrl+F5，旧的 307 会被浏览器缓存）。

---

## 五、部署（Cloudflare Pages）

- 连接本仓库，**构建命令留空**，**输出目录 `/`**，自定义域名 `show.asashiki.com`。
- 推送默认分支即自动发布。`doc.asashiki.com` 同理（仓库 `asashiki/doc`）。
