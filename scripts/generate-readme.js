import fs from "fs";
import path from "path";
import { execSync } from "child_process";
import ejs from "ejs";

const servicesDir = "./services";
const services = fs
  .readdirSync(servicesDir)
  .filter((d) => {
    const ymlPath = path.join(servicesDir, d, "service.yml");
    return fs.existsSync(ymlPath);
  })
  .map((d) => {
    const ymlPath = path.join(servicesDir, d, "service.yml");
    const json = execSync(`yq -o=json '.' '${ymlPath}'`, {
      encoding: "utf-8",
    });
    return JSON.parse(json);
  });

const sortServices = (a, b) => a.name.toLowerCase().localeCompare(b.name);

ejs.renderFile(
  "./docs/readme/README.ejs",
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
