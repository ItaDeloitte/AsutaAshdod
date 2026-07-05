//@ts-check

class LoggerService {
  /**
   *
   * @param  {...any} args
   */
  log(...args) {
    console.log(...args);
  }
  /**
   *
   * @param  {...any} args
   */
  info(...args) {
    console.info(...args);
  }
  /**
   *
   * @param  {...any} args
   */
  warn(...args) {
    console.warn(...args);
  }
  /**
   *
   * @param  {...any} args
   */
  error(...args) {
    console.error(...args);
  }
}

export const loggerService = new LoggerService();