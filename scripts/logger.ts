import * as log from "jsr:@std/log";

log.setup({
  handlers: {
    console: new log.ConsoleHandler("DEBUG"),
  },

  loggers: {
    default: {
      level: "DEBUG",
      handlers: ["console"],
    },
  },
});

const Logger = log.getLogger();
export { Logger };
