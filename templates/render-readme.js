import fs from "fs";
import ejs from "ejs";

let services = JSON.parse(fs.readFileSync("./data/services.json", "utf-8"));

const sortServices = (a, b) => a.name.toLowerCase().localeCompare(b.name);

ejs.renderFile(
  "./templates/README.ejs",
  { services, sortServices },
  {},
  function (err, str) {
    if (err) {
      console.error(err);
      return;
    }
    fs.writeFileSync("README.md", str, "utf-8");
  }
);
