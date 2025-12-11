function exportTable(format = "csv", activePreset = null) {
  const table = document.getElementById("dashboardTable");
  const rows = Array.from(table.rows);
  const data = rows.map((row) =>
    Array.from(row.cells).map((cell) => cell.innerText.trim())
  );

  const metadata = {
    exported_at: new Date().toISOString(),
    dashboard_title: document.title,
    sort_stack: [...sortStack],
    filters: getFilterState(),
    visibility: getSectionVisibility(),
    pagination: getPaginationState(),
    active_preset: activePreset,
  };

  if (format === "json") {
    const json = JSON.stringify({ metadata, data }, null, 2);
    downloadFile(json, "dashboard_export.json", "application/json");
  } else {
    const csv = data.map((row) => row.join(",")).join("\n");
    const blob = `${csv}\n\nMetadata:\n${JSON.stringify(metadata, null, 2)}`;
    downloadFile(blob, "dashboard_export.csv", "text/csv");
  }

  announceGeneral(`Exported dashboard as ${format.toUpperCase()}`);
}

function downloadFile(content, filename, mime) {
  const blob = new Blob([content], { type: mime });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
}

function exportTable(format = "csv") {
  const table = document.getElementById("dashboardTable");
  const rows = Array.from(table.rows);
  const data = rows.map(row =>
    Array.from(row.cells).map(cell => cell.innerText.trim())
  );

  const presetSelector = document.getElementById("presetSelector");
  const activePreset = presetSelector?.value || null;

  const metadata = {
    exported_at: new Date().toISOString(),
    dashboard_title: document.title,
    sort_stack: [...sortStack],
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
