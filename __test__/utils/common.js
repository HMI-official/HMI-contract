import fs from "fs";

export const readJson = (path) => {
  try {
    return JSON.parse(fs.readFileSync(path, "utf8"));
  } catch (error) {
    console.log("fail to read json file");
    console.log(error);

    return {};
  }
};

export const writeJson = (path, modifiedJson) => {
  try {
    const json = JSON.stringify(modifiedJson);
    fs.writeFile(path, json, "utf8", (e) => e);
    return true;
  } catch (error) {
    console.log("fail to write json file");
    console.log(error);
    return false;
  }
};

export const makeDir = (path) => {
  try {
    if (fs.existsSync(path)) return true;
    fs.mkdirSync(path);
    return true;
  } catch (error) {
    console.log("fail to make dir");
    console.log(error);
    return false;
  }
};
