const SECOND = 60;
const MINUTE = 1 * SECOND;
const HOUR = 60 * MINUTE;
const DAY = 24 * HOUR;
const WEEK = 7 * DAY;

// OG 9/4 2pm PST - 9/5 2AM PST
// WL 9/6 2pm PST - 9/7 2pm PST
// Public 9/8 2pm PST -

export const UNIX_TIME = { SECOND, MINUTE, HOUR, DAY, WEEK };
// export const MINTING_DATE = "8/25/2022 2:00:00 PM PST";
export const MINTING_DATE = {
  og: { begin: "9/4/2022 2:00:00 PM PST", end: "9/5/2022 2:00:00 PM PST" },
  wl: { begin: "9/6/2022 2:00:00 PM PST", end: "9/7/2022 2:00:00 PM PST" },
  public: {
    begin: "9/8/2022 2:00:00 PM PST",
    end: "10/25/2022 2:00:00 PM PST",
  },
  test: {
    begin: "8/15/2022 8:36:00 PM PST",
    end: "8/15/2022 8:40:00 PM PST",
  },
};
// 8/21 2pm PST - 8/22 2pm PST (OG)
// 8/22 2pm PST - 8/24 2pm PST (WL)
// 8/25 2pm PST - 9/25 2pm PST (Public)
