import execute from '@salesforce/apex/LC_BaseController.execute';
import { loggerService } from './loggerService';
import { utils } from '../utils';

class ExecuteService {
  showLogs = true;

  enableLogs() {
    this.showLogs = true;
  }

  disableLogs() {
    this.showLogs = false;
  }

  execute(controllerName, params) {
    const requestParams = {
      controllerName,
      params
    };
    return this.runControllerMethod(execute, requestParams).then(res => {
      return this.checkResponse(res);
    });
  }

  runControllerMethod(method, requestParams) {
    const { controllerName } = requestParams;
    const logParams = utils.unproxyData({
      controllerName,
      requestParams
    });
    const now = Date.now();
    this.logBlue(`REQUEST`, logParams);

    return method(requestParams).then(res => {
      const tookTime = Date.now() - now;
      this.logGreen(`RESPONSE (${tookTime}ms)`, logParams, res);
      return res;
    });
  }

  checkResponse(res) {
    if (typeof res === 'object' && res.isSuccess) {
      return res.responseObj;
    }
    throw res;
  }

  logGreen(logName, ...args) {
    const styles = this.buildLogTitleStyles('green');
    this.colorLog(logName, styles, ...args);
  }
  logBlue(logName, ...args) {
    const styles = this.buildLogTitleStyles('blue');
    this.colorLog(logName, styles, ...args);
  }

  colorLog(logName, styles, ...args) {
    this.log(`%c ${logName} `, styles, ...args);
  }

  log(...args) {
    if (!this.showLogs) {
      return;
    }
    loggerService.log(...args);
  }

  buildLogTitleStyles(bgColor = 'blue', color = 'white') {
    return `background: ${bgColor}; color: ${color};font-weight:bold;border-radius:4px`;
  }
}

export const executeService = new ExecuteService();