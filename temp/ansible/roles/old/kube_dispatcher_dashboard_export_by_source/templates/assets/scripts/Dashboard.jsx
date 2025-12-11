import FilterPanel from "./FilterPanel";
import PresetManager from "./PresetManager";
import TableView from "./TableView";
import FooterMetadata from "./FooterMetadata";

export default function Dashboard(props) {
  const handleApplyFilters = (filters) => {
    // apply filters to table rows
  };

  return (
    <div className="dashboard">
      <FilterPanel onApply={handleApplyFilters} />
      <PresetManager />
      <TableView {...props} />
      <FooterMetadata {...props} />
    </div>
  );
}
