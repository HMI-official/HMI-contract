// 1659957010
import { MINTING_DATE, BASE_PATH, EXT } from "../../constants/index.js";
import { makeDir, writeJson } from "../../utils/common.js";
import { changeTimeZone, diffDay, getUnixTime } from "../../utils/day.js";

const main = () => {
  const begin = getMintInfo(MINTING_DATE.og.begin);
  const end = getMintInfo(MINTING_DATE.og.end);
  const obj = { begin, end };
  const folderPath = `${BASE_PATH}/__test__/data`;
  makeDir(folderPath);
  writeJson(`${folderPath}/og-time${EXT}`, obj);
  console.log(`file saved: ${folderPath}/og-time${EXT}`);
};

const getMintInfo = (mintDate) => {
  // 일단 유닉스 타임은 맞아
  const date = new Date(mintDate);
  const unix = getUnixTime(date);
  const remain = diffDay(mintDate);
  // get la now time
  const now = getUnixTime(new Date());
  const gap = unix - now;

  // TODO: 이거는 프론트엔드로 옮기기

  return { unix, mintDate, remain, gap, now };
};

main();
