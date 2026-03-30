const THEME_MODE_KEY = "themeMode";
const THEME_PRESET_KEY = "themePreset";

const THEME_PRESETS = {
  rose: {
    "--ui-pill-bg": "#eba3c2",
    "--ui-pill-bg-hover": "#f0b4cd",
    "--ui-pill-border": "#f4bfd5",
    "--ui-nav-active": "#7f2750",
  },
  ocean: {
    "--ui-pill-bg": "#87b7f0",
    "--ui-pill-bg-hover": "#9cc4f4",
    "--ui-pill-border": "#b7d2f7",
    "--ui-nav-active": "#2f5f97",
  },
  forest: {
    "--ui-pill-bg": "#8fcf99",
    "--ui-pill-bg-hover": "#a4d9ac",
    "--ui-pill-border": "#bce7c3",
    "--ui-nav-active": "#2f7044",
  },
  sunset: {
    "--ui-pill-bg": "#f0b07b",
    "--ui-pill-bg-hover": "#f4c093",
    "--ui-pill-border": "#f7d0b1",
    "--ui-nav-active": "#a7522a",
  },
  violet: {
    "--ui-pill-bg": "#c0a0ef",
    "--ui-pill-bg-hover": "#ccb2f2",
    "--ui-pill-border": "#ddcdf8",
    "--ui-nav-active": "#6840a8",
  },
};

function getResolvedThemeMode(mode) {
  if (mode === "auto") {
    return window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
  }
  return mode || "dark";
}

function applyThemeMode(mode) {
  const resolvedMode = getResolvedThemeMode(mode);
  document.documentElement.setAttribute("data-theme-mode", resolvedMode);
}

function applyThemePreset(presetName) {
  const root = document.documentElement;
  const preset = THEME_PRESETS[presetName] || THEME_PRESETS.rose;
  Object.entries(preset).forEach(([key, value]) => root.style.setProperty(key, value));

  document.querySelectorAll(".theme-preset-btn").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.themePreset === presetName);
  });
}

function setupThemeModeDropdown() {
  const modeBtn = document.getElementById("theme-mode-btn");
  const modeOptions = document.getElementById("theme-mode-options");
  if (!modeBtn || !modeOptions) return;

  const savedMode = localStorage.getItem(THEME_MODE_KEY) || "dark";
  modeBtn.innerText = savedMode === "auto" ? "Auto (System)" : savedMode[0].toUpperCase() + savedMode.slice(1);
  applyThemeMode(savedMode);

  modeBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    modeOptions.classList.toggle("show");
  });

  modeOptions.querySelectorAll("li[data-mode]").forEach(item => {
    item.addEventListener("click", () => {
      const mode = item.dataset.mode || "dark";
      localStorage.setItem(THEME_MODE_KEY, mode);
      modeBtn.innerText = mode === "auto" ? "Auto (System)" : mode[0].toUpperCase() + mode.slice(1);
      modeOptions.classList.remove("show");
      applyThemeMode(mode);
    });
  });

  document.addEventListener("click", (e) => {
    if (!modeOptions.contains(e.target) && e.target !== modeBtn) {
      modeOptions.classList.remove("show");
    }
  });
}

function setupThemePresets() {
  const savedPreset = localStorage.getItem(THEME_PRESET_KEY) || "rose";
  applyThemePreset(savedPreset);

  document.querySelectorAll(".theme-preset-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const preset = btn.dataset.themePreset;
      if (!preset) return;
      localStorage.setItem(THEME_PRESET_KEY, preset);
      applyThemePreset(preset);
    });
  });
}

window.addEventListener("DOMContentLoaded", () => {
  setupThemeModeDropdown();
  setupThemePresets();
});
