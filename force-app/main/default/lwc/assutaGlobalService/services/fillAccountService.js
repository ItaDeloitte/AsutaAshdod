//@ts-check
import { executeService } from './executeService';

class FillAccountService {

  /**
   *
   * @param {string} opptId
   */
  isAccountFull(opptId) {
    const params = {
      actionName: 'isAccountFull',
      opptId: opptId
    }
    return this.request(params);
  }

  /**
   *
   * @param {string} opptId
   * @returns
   */
  getFormConfig(opptId) {
    const params = {
      actionName: 'getAccount',
      opptId: opptId,
    };
    return this.request(params);

  }
  /**
   *
   * @param {string} opptId
   * @param {*} data
   * @returns
   */
  setAccount(opptId, data) {
    const params = {
      actionName: 'setAccount',
      opptId: opptId,
      accountData: JSON.stringify(data)
    };
    return this.request(params);
  }


  /**
   *
   * @param {*} params
   */
  request(params) {
    return executeService.execute('LC_FillAccountController', params);
  }
}

export const fillAccountService = new FillAccountService();