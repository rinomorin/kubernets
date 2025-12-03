// Utility to export dashboard data with dispatcher-grade metadata
export function exportTable(format = "csv", activePreset = null) {
  const table = document.getElementById("dashboardTable");
  if (!table) {
    console.warn("Table not found.");
    return;
  }

  const rows = Array.from(table.rows);
  const data = rows.map(row =>
    Array.from(row.cells).map(cell => cell.innerText.trim())
  );

  const metadata = {
    exported_at: new Date().toISOString(),
    dashboard_title: document.title || "Dispatcher Dashboard",
    sort_stack: getSortStack(),
    filters: getFilterState(),
    visibility: getSectionVisibility(),
    pagination: getPaginationState(),
    active_preset: activePreset,
  };

  if (format === "json") {
    const json = JSON.stringify({ metadata, data }, null, 2);
    downloadFile(json, "dashboard_export.json", "application/json");
  } else {
    const csv = data.map(row => row.join(",")).join("\n");
    const blob = `${csv}\n\nMetadata:\n${JSON.stringify(metadata, null, 2)}`;
    downloadFile(blob, "dashboard_export.csv", "text/csv");
  }

  announceGeneral(`Exported dashboard as ${format.toUpperCase()}`);
}

// Download helper
function downloadFile(content, filename, mime) {
  const blob = new Blob([content], { type: mime });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
}

// Sort stack tracker (assumes global or context-managed)
function getSortStack() {
  return window.sortStack ? [...window.sortStack] : [];
}

// Filter state tracker
function getFilterState() {
  const filters = {};
  document.querySelectorAll("[data-filter]").forEach(el => {
    filters[el.dataset.filter] =
      el.tagName === "SELECT" ? el.value : el.value.trim();
  });
  return filters;
}

// Section visibility tracker
function getSectionVisibility() {
  const visibility = {};
  document.querySelectorAll("[data-section]").forEach(el => {
    visibility[el.dataset.section] = el.style.display !== "none";
  });
  return visibility;
}

// Pagination tracker
function getPaginationState() {
  const page = document.querySelector("[data-page]");
  const size = document.querySelector("[data-page-size]");
  return {
    current_page: page?.value || 1,
    page_size: size?.value || 25,
  };
}

// ARIA announcer
function announceGeneral(message) {
  const region = document.getElementById("ariaLiveRegion");
  if (region) {
    region.textContent = "";
    setTimeout(() => {
      region.textContent = message;
    }, 50);
  }
}
