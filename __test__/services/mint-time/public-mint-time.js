// 1659957010
import { MINTING_DATE, BASE_PATH, EXT } from "../../constants/index.js";
import { makeDir, writeJson } from "../../utils/common.js";
import { changeTimeZone, diffDay, getUnixTime } from "../../utils/day.js";

const main = () => {
  const begin = getMintInfo(MINTING_DATE.public.begin);
  const end = getMintInfo(MINTING_DATE.public.end);
  const obj = { begin, end };
  const folderPath = `${BASE_PATH}/__test__/data`;
  makeDir(folderPath);
  // writeJson(`${folderPath}/wl-time${EXT}`, obj);
  writeJson(`${folderPath}/public-time${EXT}`, obj);
  console.log(`file saved: ${folderPath}/public-time${EXT}`);
};

const getMintInfo = (mintDate) => {
  // 일단 유닉스 타임은 맞아
  const date = new Date(mintDate);
  const unix = getUnixTime(date);
  const remain = diffDay(mintDate);
  // get la now time
  const now = getUnixTime(new Date());
  const gap = unix - now;
  // const LAtime = getUnixTime(new Date());
  // const LaGap = new Date((LAtime - time7H) * 1000);
  // console.log(now);

  // TODO: 이거는 프론트엔드로 옮기기
  // const __test = changeTimeZone(mintDate, "America/Los_Angeles");
  // console.log(`la time: ${__test}`);
  // 아~ now가 한국시간이 아니라 unix시간이라서 16시간 빼면 안돼
  // la 시간이랑 pst랑 1시간 차이라
  // pst가 1시간 더 느려

  return { unix, mintDate, remain, gap, now };
};

main();
