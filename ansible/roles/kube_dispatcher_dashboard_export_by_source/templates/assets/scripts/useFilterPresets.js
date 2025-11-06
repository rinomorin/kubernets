import { useState, useEffect } from "react";

const COOKIE_PREFIX = "filterPreset_";

export function useFilterPresets() {
  const [presets, setPresets] = useState({});
  const [activePreset, setActivePreset] = useState(null);

  // Load presets from localStorage, cookies, or backend
  useEffect(() => {
    const local = localStorage.getItem("filterPresets");
    if (local) {
      setPresets(JSON.parse(local));
    } else {
      fetchPresetsFromBackend().catch(() => {
        const fallback = loadPresetsFromCookies();
        setPresets(fallback);
      });
    }
  }, []);

  // Save preset
  const savePreset = async (name, filters) => {
    const updated = { ...presets, [name]: filters };
    setPresets(updated);
    localStorage.setItem("filterPresets", JSON.stringify(updated));
    setCookie(name, filters);

    try {
      await fetch("/api/presets", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, filters }),
      });
    } catch {
      console.warn("Backend unavailable, saved to cookie.");
    }
  };

  // Load preset
  const loadPreset = (name) => {
    const filters = presets[name] || getCookie(name);
    if (!filters) return null;
    setActivePreset(name);
    return filters;
  };

  // Delete preset
  const deletePreset = async (name) => {
    const updated = { ...presets };
    delete updated[name];
    setPresets(updated);
    localStorage.setItem("filterPresets", JSON.stringify(updated));
    deleteCookie(name);

    try {
      await fetch(`/api/presets/${name}`, { method: "DELETE" });
    } catch {
      console.warn("Backend unavailable, deleted from cookie only.");
    }
  };

  return {
    presets,
    activePreset,
    savePreset,
    loadPreset,
    deletePreset,
  };
}

// Helpers
function setCookie(name, filters) {
  document.cookie = `${COOKIE_PREFIX}${name}=${encodeURIComponent(JSON.stringify(filters))}; path=/; max-age=31536000`;
}

function getCookie(name) {
  const match = document.cookie.match(new RegExp(`${COOKIE_PREFIX}${name}=([^;]+)`));
  return match ? JSON.parse(decodeURIComponent(match[1])) : null;
}

function deleteCookie(name) {
  document.cookie = `${COOKIE_PREFIX}${name}=; path=/; max-age=0`;
}

function loadPresetsFromCookies() {
  const cookies = document.cookie.split("; ");
  const result = {};
  cookies.forEach(c => {
    if (c.startsWith(COOKIE_PREFIX)) {
      const [key, val] = c.split("=");
      const name = key.replace(COOKIE_PREFIX, "");
      try {
        result[name] = JSON.parse(decodeURIComponent(val));
      } catch {}
    }
  });
  return result;
}

async function fetchPresetsFromBackend() {
  const res = await fetch("/api/presets");
  const data = await res.json();
  localStorage.setItem("filterPresets", JSON.stringify(data));
  return data;
}
