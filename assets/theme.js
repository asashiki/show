// 主题（明/暗）+ 季节配色（樱羽/青苔/蜜柑/雾凇）切换，记忆到 localStorage。
(function () {
  var root = document.documentElement;
  var palettes = ["sakura", "moss", "mikan", "frost"];
  var palIcon = { sakura: "🌸", moss: "🍃", mikan: "🍊", frost: "❄️" };

  var theme = localStorage.getItem("ad-theme") ||
    (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  var palette = localStorage.getItem("ad-palette") || "sakura";

  function apply() {
    root.setAttribute("data-theme", theme);
    root.setAttribute("data-palette", palette);
    var t = document.getElementById("themeBtn");
    var p = document.getElementById("paletteBtn");
    if (t) t.textContent = theme === "dark" ? "🌙" : "☀️";
    if (p) p.textContent = palIcon[palette];
  }
  apply();

  document.addEventListener("click", function (e) {
    if (e.target.closest("#themeBtn")) {
      theme = theme === "dark" ? "light" : "dark";
      localStorage.setItem("ad-theme", theme); apply();
    }
    if (e.target.closest("#paletteBtn")) {
      palette = palettes[(palettes.indexOf(palette) + 1) % palettes.length];
      localStorage.setItem("ad-palette", palette); apply();
    }
  });
})();
