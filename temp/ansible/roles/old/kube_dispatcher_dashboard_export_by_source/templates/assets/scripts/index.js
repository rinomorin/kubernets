import React from "react";
import ReactDOM from "react-dom";
import Dashboard from "./Dashboard";

const props = window.__DASHBOARD_PROPS__;
ReactDOM.render(<Dashboard {...props} />, document.getElementById("reactDashboard"));
