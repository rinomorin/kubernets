function getFilterState() {
  const filters = {};
  document.querySelectorAll("[data-filter]").forEach(el => {
    filters[el.dataset.filter] = el.value || el.checked || null;
  });
  return filters;
}

function getSectionVisibility() {
  const visibility = {};
  document.querySelectorAll("[data-section]").forEach(el => {
    visibility[el.dataset.section] = el.style.display !== "none";
  });
  return visibility;
}

function getPaginationState() {
  const page = document.querySelector("[data-page]");
  const size = document.querySelector("[data-page-size]");
  return {
    current_page: page?.value || 1,
    page_size: size?.value || 25,
  };
}
