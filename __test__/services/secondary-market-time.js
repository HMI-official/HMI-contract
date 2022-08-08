import { MINTING_DATE, UNIX_TIME, BASE_PATH, EXT } from "../constants/index.js";
import { writeJson, getUnixTime, makeDir } from "../utils/index.js";
// import {} from "../utils/day.js";

const main = () => {
  // const MINTING_DATE = "8/25/2022 2:00:00 PM PST";
  const date = new Date();
  // const date = new Date(MINTING_DATE);
  // to unix time
  const mintingDateUnix = getUnixTime(date);
  const mintingDateUnixAddWeek = mintingDateUnix + 1 * UNIX_TIME.MINUTE;

  const obj = {
    release: mintingDateUnixAddWeek,
    diff: mintingDateUnixAddWeek - mintingDateUnix,
  };
  console.log(`minting date|| ${mintingDateUnix}`);
  console.log(`secondary market release date in unix || ${obj.release}`);
  console.log(
    `difference between release date and minting date || ${
      (obj.release - mintingDateUnix) / UNIX_TIME.DAY
    } days`
  );

  const folderPath = `${BASE_PATH}/__test__/data`;
  makeDir(folderPath);

  const path = `${folderPath}/secondary-market-time${EXT}`;
  writeJson(path, obj);
};

main();
