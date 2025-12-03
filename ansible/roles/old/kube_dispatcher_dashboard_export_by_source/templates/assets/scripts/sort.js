let sortStack = [];
let lastSortStack = [];

function sortTable(n, forcedDirection = null) {
  const table = document.getElementById("dashboardTable");
  const rows = Array.from(table.rows).slice(1);
  const columnName = table.rows[0].cells[n]?.innerText.trim() || `Column ${n + 1}`;
  const existing = sortStack.find(s => s.index === n);
  const direction = forcedDirection || (!existing || existing.direction !== "ascending" ? "ascending" : "descending");

  sortStack = sortStack.filter(s => s.index !== n);
  sortStack.push({ index: n, name: columnName, direction });

  rows.sort((a, b) => {
    for (let i = sortStack.length - 1; i >= 0; i--) {
      const { index, direction } = sortStack[i];
      const valA = a.cells[index]?.innerText.trim().toLowerCase() || "";
      const valB = b.cells[index]?.innerText.trim().toLowerCase() || "";
      if (valA !== valB) {
        return direction === "ascending" ? valA.localeCompare(valB) : valB.localeCompare(valA);
      }
    }
    return 0;
  });

  rows.forEach(row => table.tBodies[0].appendChild(row));
  highlightSortedColumns(sortStack);
  announceGeneral(`Sorted by ${columnName} in ${direction} order`);
}

function addSecondarySort(n) {
  const table = document.getElementById("dashboardTable");
  const columnName = table.rows[0].cells[n]?.innerText.trim() || `Column ${n + 1}`;
  const existing = sortStack.find(s => s.index === n);
  const direction = existing ? (existing.direction === "ascending" ? "descending" : "ascending") : "ascending";

  sortStack = sortStack.filter(s => s.index !== n);
  sortStack.unshift({ index: n, name: columnName, direction });

  const rows = Array.from(table.rows).slice(1);
  rows.sort((a, b) => {
    for (let i = sortStack.length - 1; i >= 0; i--) {
      const { index, direction } = sortStack[i];
      const valA = a.cells[index]?.innerText.trim().toLowerCase() || "";
      const valB = b.cells[index]?.innerText.trim().toLowerCase() || "";
      if (valA !== valB) {
        return direction === "ascending" ? valA.localeCompare(valB) : valB.localeCompare(valA);
      }
    }
    return 0;
  });

  rows.forEach(row => table.tBodies[0].appendChild(row));
  highlightSortedColumns(sortStack);
  announceGeneral(`Secondary sort added: ${columnName} (${direction})`);
}

document.addEventListener("keydown", function (e) {
  const key = e.key;
  if (e.altKey && !e.metaKey) {
    const index = parseInt(key, 10) - 1;
    if (!isNaN(index)) {
      if (e.ctrlKey) {
        addSecondarySort(index);
      } else {
        const direction = e.shiftKey ? "descending" : "ascending";
        sortTable(index, direction);
      }
      e.preventDefault();
    }
  }
});
