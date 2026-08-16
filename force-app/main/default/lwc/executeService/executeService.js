//@ts-check
import execute from '@salesforce/apex/LC_BaseController.execute';
import { appConfig } from 'c/appConfig';
import { utils } from 'c/utils';
import { Logger } from './logger';

/**@module ExecuteService */

// const execute = (params) => {
//   return Promise.resolve(params);
// };

/**
 * @callback ControllerMethod
 * @param {...any} params
 * @returns {Promise}
 */

/**
 * ExecuteService
 */
class ExecuteService {
  logger = new Logger(appConfig.isDevelopment);
  showLogs = appConfig.isDevelopment;

  enableLogs() {
    this.logger.showLogs = true;
  }

  disableLogs() {
    this.logger.showLogs = false;
  }
  /**
   *
   * @param {string} controllerName
   * @param {*} params
   * @returns {Promise}
   */
  execute(controllerName, params) {
    const requestParams = utils.unproxyData({
      controllerName,
      params
    });
    return this.runControllerMethod(execute, requestParams).then((res) => {
      return this.checkResponse(res);
    });
  }
  /**
   *
   * @param {string} controllerName
   * @param {*} params
   * @returns {Promise}
   */
  fakeExecute(controllerName, params) {
    const requestParams = utils.unproxyData({
      controllerName,
      params
    });

    const logParams = {
      controllerName,
      requestParams
    };

    const fakeExecuteLog = this.logger.getFakeExecuteLog(logParams);
    fakeExecuteLog.logRequest();

    return utils.timeout(1000).then(() => {
      fakeExecuteLog.logResponse(null, {});
    });
  }
  /**
   *
   * @param {ControllerMethod} method
   * @param {*} requestParams
   * @returns {Promise}
   */
  runControllerMethod(method, requestParams) {
    const { controllerName } = requestParams;
    const logParams = utils.unproxyData({
      controllerName,
      requestParams
    });
    const executeLog = this.logger.getExecuteLog(logParams);
    executeLog.logRequest();

    return method(requestParams)
      .then((res) => {
        executeLog.logResponse(null, res);
        return res;
      })
      .catch((res) => {
        executeLog.logResponse(true, res);
        throw res;
      });
  }
  /**
   *
   * @param {*} res
   */
  checkResponse(res) {
    if (res.isSuccess) {
      return res.responseObj;
    }
    throw res;
  }
}

export const executeService = new ExecuteService();