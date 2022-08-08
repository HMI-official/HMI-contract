// 1659957010
import { MINTING_DATE, BASE_PATH, EXT } from "../constants/index.js";
import { makeDir, writeJson } from "../utils/common.js";
import { diffDay, getUnixTime } from "../utils/day.js";

// const data = new Date(1659957010 * 1000);
// const MINTING_DATE = "8/25/2022 2:00:00 PM PST";

const date = new Date(MINTING_DATE);
// to unix time
const mintingDateUnix = getUnixTime(date);
const now = getUnixTime(new Date());
console.log(`${MINTING_DATE} : ${mintingDateUnix}`);

const { day, hour, min, sec } = diffDay(MINTING_DATE);
console.log(
  `${MINTING_DATE} : ${day} days, ${hour} hours, ${min} minutes, ${sec} seconds`
);

const remainingTime = diffDay(MINTING_DATE);

const obj = {
  now,
  mintBegin: { unix: mintingDateUnix, mintData: MINTING_DATE },
  remainingTime,
  timeGap: mintingDateUnix - now,
  copyToContract: mintingDateUnix,
};
const folderPath = `${BASE_PATH}/__test__/data`;
makeDir(folderPath);
writeJson(`${folderPath}/mint-begin-time${EXT}`, obj);
