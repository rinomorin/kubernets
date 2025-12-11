import { useFilterPresets } from "./useFilterPresets";
import { exportTable } from "./exportUtils"; // assuming you modularized export logic

export default function HeaderControls() {
  const { activePreset } = useFilterPresets();

  return (
    <div className="controls">
      <button onClick={() => exportTable("csv", activePreset)}>📤 Export CSV</button>
      <button onClick={() => exportTable("json", activePreset)}>📤 Export JSON</button>
    </div>
  );
}
