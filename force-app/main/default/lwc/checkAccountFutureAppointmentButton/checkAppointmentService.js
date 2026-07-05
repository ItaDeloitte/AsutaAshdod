import { executeService } from 'c/executeService';

class CheckAppointmentService {
  /**
   *
   * @param {string} recordId
   */
  checkFutureAppointment(recordId) {
    const params = {
      actionName: 'hasFutureAppointments',
      recordId
    };

    return this.request(params);
  }

  /**
   *
   * @param {string} recordId
   * @param {string} action
   */
  createCase(recordId, action) {
    const params = {
      actionName: 'createCase',
      recordId,
      action
    };

    return this.request(params);
  }

  /** @param {*} params */
  request(params) {
    return executeService.execute('LC_ButtonsController', params);
  }
}

export const checkAppointmentService = new CheckAppointmentService();