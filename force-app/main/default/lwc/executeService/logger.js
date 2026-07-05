//@ts-check
import { loggerService } from 'c/loggerService';

/**@module ExecuteService */
/**
 *
 */
export class Logger {
  showLogs = false;

  /**
   *
   * @param {boolean} showLogs
   */
  constructor(showLogs) {
    this.showLogs = showLogs;
  }

  /**
   *
   * @param {*} reqParams
   * @returns
   */
  getExecuteLog(reqParams) {
    const diffTime = this.makeDiffTime();

    return {
      logRequest: () => {
        this.logBlue(`REQUEST`, reqParams);
      },
      logResponse: (err, res) => {
        const timeText = `(${diffTime.getDiff()}ms)`;
        if (err) {
          this.logRed(`RESPONSE ERR ${timeText}`, reqParams, res);
          return;
        }
        this.logGreen(`RESPONSE ${timeText}`, reqParams, res);
      }
    };
  }

  /**
   *
   * @param {*} reqParams
   * @returns
   */
  getFakeExecuteLog(reqParams) {
    const diffTime = this.makeDiffTime();

    return {
      logRequest: () => {
        this.logOrange(`FAKE REQUEST`, reqParams);
      },
      logResponse: (err, res) => {
        const timeText = `(${diffTime.getDiff()}ms)`;
        if (err) {
          this.logRed(`FAKE RESPONSE ERR ${timeText}`, reqParams, res);
          return;
        }
        this.logOrange(`FAKE RESPONSE ${timeText}`, reqParams, res);
      }
    };
  }

  makeDiffTime() {
    let startTime = Date.now();
    return {
      getDiff() {
        return Date.now() - startTime;
      }
    };
  }

  /**
   *
   * @param {string} logName
   * @param  {...any} args
   */
  logGreen(logName, ...args) {
    const styles = this.buildLogTitleStyles('green');
    this.colorLog(logName, styles, ...args);
  }
  /**
   *
   * @param {string} logName
   * @param  {...any} args
   */
  logBlue(logName, ...args) {
    const styles = this.buildLogTitleStyles('blue');
    this.colorLog(logName, styles, ...args);
  }
  /**
   *
   * @param {string} logName
   * @param  {...any} args
   */
  logOrange(logName, ...args) {
    const styles = this.buildLogTitleStyles('orange');
    this.colorLog(logName, styles, ...args);
  }
  /**
   *
   * @param {string} logName
   * @param  {...any} args
   */
  logRed(logName, ...args) {
    const styles = this.buildLogTitleStyles('red');
    this.colorLog(logName, styles, ...args);
  }
  /**
   *
   * @param {string} logName
   * @param {string} styles
   * @param  {...any} args
   */
  colorLog(logName, styles, ...args) {
    this.log(`%c ${logName} `, styles, ...args);
  }
  /**
   *
   * @param  {...any} args
   */
  log(...args) {
    loggerService.log(...args);
  }
  /**
   *
   * @param {string} bgColor
   * @param {string} color
   * @returns {string}
   */
  buildLogTitleStyles(bgColor = 'blue', color = 'white') {
    return `background: ${bgColor}; color: ${color};font-weight:bold;border-radius:4px`;
  }
}