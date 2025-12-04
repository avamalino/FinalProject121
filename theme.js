(function () {
  const root = document.documentElement;

  function systemPrefersDark() {
    return (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    );
  }

  function applySystemPreference() {
    // Set data-theme to 'light' or 'dark' based on system preference
    root.setAttribute("data-theme", systemPrefersDark() ? "dark" : "light");
  }

  // Start in AUTO logically, but apply the current system mode immediately
  root.setAttribute("data-theme", "auto");
  applySystemPreference();

  // Listen for system theme changes (e.g. macOS auto switching at sunset)
  if (window.matchMedia) {
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    mq.addEventListener("change", () => {
      // Only follow system if we're in AUTO
      if (root.getAttribute("data-theme") === "auto") {
        applySystemPreference();
      }
    });
  }

  // Manual overrides, if we ever want them from JS
  window.CatGameTheme = {
    setAuto() {
      root.setAttribute("data-theme", "auto");
      applySystemPreference();
    },
    setLight() {
      root.setAttribute("data-theme", "light");
    },
    setDark() {
      root.setAttribute("data-theme", "dark");
    },
  };
})();
