//@ts-check

import { executeService } from './executeService';

/**
 * @typedef {AppointmentService} Service
 */

class AppointmentService {
  checkAccessionRegistry = {};

  /**
   *
   * @param {*} params
   * @returns {Promise}
   */
  searchAppointments(params) {
    params = Object.assign({ actionName: 'appointmentSearch' }, params);
    return this.request(params);
  }

  /**
   *
   * @param {*} params
   * @returns {Promise}
   */
  getSequenceAppointments(params) {
    params = Object.assign(
      {
        actionName: 'getSequenceAppointments',
        operationType: '',
        appointmentId: ''
      },
      params
    );
    return this.request(params);
  }

  /**
   *
   * @param {string} recordId
   * @returns {Promise}
   */
  isAppointmentAvailable(recordId) {
    const params = {
      actionName: 'isAppointmentAvailable',
      recordId: recordId
    };
    return this.request(params);
  }

  /**
   *
   * @param {string[]} procedureCodes
   * @returns {Promise}
   */
  isSequenceExist(procedureCodes) {
    var params = {
      actionName: 'isSequenceExist',
      procedureCodes: JSON.stringify(procedureCodes)
    };
    return this.request(params);
  }

  /**
   *
   * @param {string[]} procedureCodes
   * @returns {Promise}
   */
  checkProcedure(procedureCodes) {
    var params = {
      actionName: 'procedureCheck',
      procedureCodes: JSON.stringify(procedureCodes)
    };
    return this.request(params);
  }

  /**
   *
   * @param {string} procedureCode
   * @param {string} keyWord
   * @returns {Promise<any[]>}
   */
  searchTechnician(procedureCode, keyWord) {
    const params = {
      actionName: 'technicianSearch',
      procedureCode,
      keyWord
    };
    return this.request(params).then(data => {
      return data.map(item => this.buildTechnicianOption(item));
    });
  }

  /**
   *
   * @param {*} data
   * @return {*}
   */
  buildTechnicianOption(data) {
    return Object.assign({}, data, {
      value: data.id
    });
  }

  /**
   *
   * @param {string} procedureCode
   * @param {*} technician
   * @param {string} keyWord
   * @returns {Promise<any[]>}
   */
  searchTechnicianProcedure(procedureCode, technician, keyWord) {
    const params = {
      actionName: 'technicianProcedureSearch',
      accountId: technician.accountId,
      siteCode: technician.siteCode,
      procedureCode: procedureCode,
      keyWord
    };
    return this.request(params).then(res => {
      return res.map(item => {
        const procedure = item.procedure;
        procedure.isLeading = item.isLeading;
        return procedure;
      });
    });
  }

  createAppointmentArray(cmpId, reqParams) {
    this.checkAccessionRegistry[cmpId] = {
      cmpId: cmpId,
      isDestroyed: false,
      ids: []
    };
    const params = Object.assign({}, reqParams, {
      actionName: 'createAppointmentArray'
    });
    return this.request(params).then(ids => {
      const regObject = this.checkAccessionRegistry[cmpId];

      if (regObject) {
        if (regObject.isDestroyed) {
          this.checkAccessionNumber(cmpId, ids).catch(() => {});
        } else {
          regObject.ids = ids;
        }
      }
      return ids;
    });
  }

  checkAccessionNumberAfterCmpDestroy(cmpId) {
    const regObject = this.checkAccessionRegistry[cmpId];

    if (!regObject) {
      return;
    }
    regObject.isDestroyed = true;
    if (regObject.ids.length > 0) {
      this.checkAccessionNumber(cmpId, regObject.ids).catch(() => {});
    }
  }

  checkAccessionNumber(cmpId, appointmentIds) {
    delete this.checkAccessionRegistry[cmpId];
    const params = {
      actionName: 'checkAccessionNumber',
      recordIds: JSON.stringify(appointmentIds)
    };
    return this.request(params);
  }

  /**
   *
   * @param {*} params
   * @returns {Promise}
   */
  request(params) {
    return executeService.execute('LC_AppointmentController', params);
  }
}

export const appointmentService = new AppointmentService();