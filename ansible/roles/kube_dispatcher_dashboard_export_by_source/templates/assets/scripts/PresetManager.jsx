import React, { useState } from "react";
import { useFilterPresets } from "./useFilterPresets";

export default function PresetManager({ onApplyFilters }) {
  const {
    presets,
    activePreset,
    savePreset,
    loadPreset,
    deletePreset,
  } = useFilterPresets();

  const [presetName, setPresetName] = useState("");

  const handleSave = () => {
    if (!presetName) return;
    const filters = collectFilters();
    savePreset(presetName, filters);
    setPresetName("");
  };

  const handleLoad = (e) => {
    const name = e.target.value;
    const filters = loadPreset(name);
    if (filters && typeof onApplyFilters === "function") {
      onApplyFilters(filters);
    }
  };

  const handleDelete = () => {
    if (!presetName) return;
    deletePreset(presetName);
    setPresetName("");
  };

  return (
    <div className="preset-manager">
      <label>
        Presets:
        <select value={activePreset || ""} onChange={handleLoad}>
          <option value="">— Select Preset —</option>
          {Object.keys(presets).map((name) => (
            <option key={name} value={name}>
              {name}
            </option>
          ))}
        </select>
      </label>

      <input
        type="text"
        placeholder="Preset name"
        value={presetName}
        onChange={(e) => setPresetName(e.target.value)}
      />

      <button onClick={handleSave}>💾 Save Preset</button>
      <button onClick={handleDelete}>🗑️ Delete Preset</button>
    </div>
  );
}

// Utility to collect filters from DOM
function collectFilters() {
  const filters = {};
  document.querySelectorAll("[data-filter]").forEach((el) => {
    filters[el.dataset.filter] =
      el.tagName === "SELECT" ? el.value : el.value.trim();
  });
  return filters;
}
