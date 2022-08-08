// 1659957010
import { diffDay } from "./utils/day.js";

// const data = new Date(1659957010 * 1000);
const MINTING_DATE = "8/25/2022 2:00:00 PM PST";

const date = new Date(MINTING_DATE);
// to unix time
const unixTime = (date.getTime() / 1000).toFixed(0);
console.log(`minting begin time(unix time): ${unixTime}`);

const { day, hour, min, sec } = diffDay(MINTING_DATE);
// console.log(day, "|", hour, "|", min, "|", sec);
