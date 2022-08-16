const SECOND = 60;
const MINUTE = 1 * SECOND;
const HOUR = 60 * MINUTE;
const DAY = 24 * HOUR;
const WEEK = 7 * DAY;

export const UNIX_TIME = { SECOND, MINUTE, HOUR, DAY, WEEK };
// export const MINTING_DATE = "8/25/2022 2:00:00 PM PST";
export const MINTING_DATE = {
  og: { begin: "8/21/2022 2:00:00 PM PST", end: "8/22/2022 2:00:00 PM PST" },
  wl: { begin: "8/22/2022 2:00:00 PM PST", end: "8/24/2022 2:00:00 PM PST" },
  public: { begin: "8/25/2022 2:00:00 PM PST", end: "TBD" },
  test: {
    begin: "8/15/2022 8:36:00 PM PST",
    end: "8/15/2022 8:40:00 PM PST",
  },
};
// 8/21 2pm PST - 8/22 2pm PST (OG)
// 8/22 2pm PST - 8/24 2pm PST (WL)
// 8/25 2pm PST - 9/25 2pm PST (Public)
