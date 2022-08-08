export const diffDay = (mintingDate) => {
  //make this date: SAT, Aug 27th - 2pm PST
  // 2022년 8월 27일 오후 2시 PST
  const date = new Date(mintingDate);
  // const date = new Date(2022, 7, 27, 14, 0, 0);
  // now pst date
  const now = new Date();

  const diff = Number(date) - Number(now);
  if (diff < 0) return { day: 0, hour: 0, min: 0, sec: 0 };

  const diffDay = Math.floor(diff / (1000 * 60 * 60 * 24));
  const diffHour = Math.floor((diff / (1000 * 60 * 60)) % 24);
  const diffMin = Math.floor((diff / (1000 * 60)) % 60);
  const diffSec = Math.floor((diff / 1000) % 60);
  // console.log(diffDay, "|", diffHour, "|", diffMin, "|", diffSec);

  return { day: diffDay, hour: diffHour, min: diffMin, sec: diffSec };
};

export const getUnixTime = (date) => {
  const unixTime = (date.getTime() / 1000).toFixed(0);
  return Number(unixTime);
};
