function announceGeneral(message) {
  const region = document.getElementById("ariaLiveRegion");
  if (region) {
    region.textContent = "";
    setTimeout(() => {
      region.textContent = message;
    }, 50);
  }
}

function highlightSortedColumns(stack) {
  const headers = document.querySelectorAll("#dashboardTable th");
  headers.forEach(th => {
    th.classList.remove("sorted");
    const icon = th.querySelector(".sort-icon");
    if (icon) {
      icon.textContent = "";
      icon.title = "";
      icon.setAttribute("aria-label", "");
    }
  });

  stack.forEach(s => {
    const th = document.querySelector(`#dashboardTable th[data-index="${s.index}"]`);
    if (th) {
      th.classList.add("sorted");
      const icon = th.querySelector(".sort-icon");
      if (icon) {
        icon.textContent = s.direction === "ascending" ? "↑" : "↓";
        icon.title = s.direction === "ascending"
          ? "Sorted ascending (A → Z, 0 → 9)"
          : "Sorted descending (Z → A, 9 → 0)";
        icon.setAttribute("aria-label", icon.title);
      }
    }
  });
}
function applyFilters() {
  const filters = getFilterState();
  const table = document.getElementById("dashboardTable");
  const rows = Array.from(table.rows).slice(1);

  rows.forEach(row => {
    let visible = true;
    Object.entries(filters).forEach(([key, value]) => {
      if (!value) return;
      const cell = row.querySelector(`td[data-key="${key}"]`);
      const cellText = cell?.innerText.trim().toLowerCase() || "";
      if (!cellText.includes(value.toLowerCase())) {
        visible = false;
      }
    });
    row.style.display = visible ? "" : "none";
  });

  announceGeneral("Filters applied.");
}


function toggleFilters() {
  const panel = document.getElementById("filterPanel");
  if (panel) {
    const isVisible = panel.style.display !== "none";
    panel.style.display = isVisible ? "none" : "";
    announceGeneral(isVisible ? "Filters hidden." : "Filters shown.");
  }
}

function resetFilters() {
  document.querySelectorAll("[data-filter]").forEach(el => {
    if (el.tagName === "SELECT") {
      el.selectedIndex = 0;
    } else if (el.tagName === "INPUT") {
      el.value = "";
    }
  });
  applyFilters();
  announceGeneral("Filters reset.");
}

function toggleFilters() {
  const panel = document.getElementById("filterPanel");
  if (!panel) return;

  const isOpen = panel.classList.contains("open");
  if (isOpen) {
    panel.classList.remove("open");
    localStorage.setItem("filtersVisible", "false");
    announceGeneral("Filters hidden.");
  } else {
    panel.classList.add("open");
    localStorage.setItem("filtersVisible", "true");
    announceGeneral("Filters shown.");
  }
}

function resetFilters() {
  document.querySelectorAll("[data-filter]").forEach(el => {
    if (el.tagName === "SELECT") {
      el.selectedIndex = 0;
    } else if (el.tagName === "INPUT") {
      el.value = "";
    }
  });
  applyFilters();
  announceGeneral("Filters reset.");
}

document.addEventListener("DOMContentLoaded", () => {
  const panel = document.getElementById("filterPanel");
  const saved = localStorage.getItem("filtersVisible");
  if (panel && saved === "true") {
    panel.classList.add("open");
  }
});
function saveNamedPreset() {
  const name = prompt("Enter a name for this preset:");
  if (!name) return;

  const filters = getFilterState();
  const presets = JSON.parse(localStorage.getItem("filterPresets") || "{}");
  presets[name] = filters;
  localStorage.setItem("filterPresets", JSON.stringify(presets));
  populatePresetDropdown();
  announceGeneral(`Preset "${name}" saved.`);
}

function loadSelectedPreset() {
  const selector = document.getElementById("presetSelector");
  const name = selector.value;
  if (!name) return;

  const presets = JSON.parse(localStorage.getItem("filterPresets") || "{}");
  const filters = presets[name];
  if (!filters) return;

  Object.entries(filters).forEach(([key, value]) => {
    const el = document.querySelector(`[data-filter="${key}"]`);
    if (el) {
      if (el.tagName === "SELECT") el.value = value;
      else if (el.tagName === "INPUT") el.value = value;
    }
  });

  applyFilters();
  announceGeneral(`Preset "${name}" loaded.`);
}

function deleteSelectedPreset() {
  const selector = document.getElementById("presetSelector");
  const name = selector.value;
  if (!name) return;

  const confirmed = confirm(`Delete preset "${name}"?`);
  if (!confirmed) return;

  const presets = JSON.parse(localStorage.getItem("filterPresets") || "{}");
  delete presets[name];
  localStorage.setItem("filterPresets", JSON.stringify(presets));
  populatePresetDropdown();
  announceGeneral(`Preset "${name}" deleted.`);
}

function populatePresetDropdown() {
  const selector = document.getElementById("presetSelector");
  const presets = JSON.parse(localStorage.getItem("filterPresets") || "{}");

  selector.innerHTML = '<option value="">— Select Preset —</option>';
  Object.keys(presets).forEach(name => {
    const option = document.createElement("option");
    option.value = name;
    option.textContent = name;
    selector.appendChild(option);
  });
}

document.addEventListener("DOMContentLoaded", () => {
  populatePresetDropdown();

  const panel = document.getElementById("filterPanel");
  const saved = localStorage.getItem("filtersVisible");
  if (panel && saved === "true") {
    panel.classList.add("open");
  }
});

async function syncPresetToBackend(name, filters) {
  await fetch("/api/presets", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, filters }),
  });
}

async function fetchPresetsFromBackend() {
  const res = await fetch("/api/presets");
  const presets = await res.json();
  localStorage.setItem("filterPresets", JSON.stringify(presets));
  populatePresetDropdown();
}
function savePresetToCookie(name, filters) {
  document.cookie = `filterPreset_${name}=${encodeURIComponent(JSON.stringify(filters))}; path=/; max-age=31536000`;
}
function loadPresetFromCookie(name) {
  const match = document.cookie.match(new RegExp(`filterPreset_${name}=([^;]+)`));
  return match ? JSON.parse(decodeURIComponent(match[1])) : null;
}
function loadSelectedPreset() {
  const selector = document.getElementById("presetSelector");
  const name = selector.value;
  if (!name) return;

  const presets = JSON.parse(localStorage.getItem("filterPresets") || "{}");
  let filters = presets[name];

  if (!filters) {
    filters = loadPresetFromCookie(name);
    if (!filters) {
      announceGeneral(`Preset "${name}" not found.`);
      return;
    }
  }

  Object.entries(filters).forEach(([key, value]) => {
    const el = document.querySelector(`[data-filter="${key}"]`);
    if (el) {
      if (el.tagName === "SELECT") el.value = value;
      else if (el.tagName === "INPUT") el.value = value;
    }
  });

  applyFilters();
  announceGeneral(`Preset "${name}" loaded.`);
}
async function syncPreset(name, filters) {
  try {
    await fetch("/api/presets", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, filters }),
    });
  } catch (err) {
    console.warn("Backend unavailable, saving to cookie.");
    savePresetToCookie(name, filters);
  }
}
