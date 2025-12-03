const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
const PORT = 3001;

let presets = {
  "default": { role: "web", source: "internal", host: "node01" }
};

app.use(cors());
app.use(bodyParser.json());

app.get("/api/presets", (req, res) => {
  res.json(presets);
});

app.post("/api/presets", (req, res) => {
  const { name, filters } = req.body;
  if (!name || !filters) return res.status(400).send("Missing name or filters");
  presets[name] = filters;
  res.status(200).send("Preset saved");
});

app.delete("/api/presets/:name", (req, res) => {
  const name = req.params.name;
  delete presets[name];
  res.status(200).send("Preset deleted");
});

app.listen(PORT, () => {
  console.log(`Dispatcher mock server running on http://localhost:${PORT}`);
});
