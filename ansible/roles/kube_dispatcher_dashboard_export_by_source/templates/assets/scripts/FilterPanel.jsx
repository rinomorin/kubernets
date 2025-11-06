import React, { useState, useEffect } from "react";
import { useFilterPresets } from "./useFilterPresets";

export default function FilterPanel({ onApply }) {
  const [visible, setVisible] = useState(true);
  const { activePreset, loadPreset } = useFilterPresets();

  useEffect(() => {
    const saved = localStorage.getItem("filtersVisible");
    if (saved === "false") setVisible(false);
  }, []);

  const togglePanel = () => {
    const newState = !visible;
    setVisible(newState);
    localStorage.setItem("filtersVisible", newState ? "true" : "false");
  };

  const resetFilters = () => {
    document.querySelectorAll("[data-filter]").forEach(el => {
      if (el.tagName === "SELECT") el.selectedIndex = 0;
      else if (el.tagName === "INPUT") el.value = "";
    });
    onApply?.(collectFilters());
  };

  const applyFilters = () => {
    onApply?.(collectFilters());
  };

  return (
    <section className="filter-panel">
      <div className="filter-controls">
        <button onClick={togglePanel}>🎛️ Toggle Filters</button>
        <button onClick={resetFilters}>♻️ Reset Filters</button>
        <button onClick={applyFilters}>🔍 Apply Filters</button>
      </div>

      {visible && (
        <div className="filters">
          <label>
            Role:
            <select data-filter="role">
              <option value="">All</option>
              <option value="web">Web</option>
              <option value="db">Database</option>
              <option value="cache">Cache</option>
            </select>
          </label>

          <label>
            Source:
            <select data-filter="source">
              <option value="">All</option>
              <option value="internal">Internal</option>
              <option value="external">External</option>
            </select>
          </label>

          <label>
            Host contains:
            <input type="text" data-filter="host" placeholder="e.g. node01" />
          </label>
        </div>
      )}
    </section>
  );
}

function collectFilters() {
  const filters = {};
  document.querySelectorAll("[data-filter]").forEach(el => {
    filters[el.dataset.filter] =
      el.tagName === "SELECT" ? el.value : el.value.trim();
  });
  return filters;
}
