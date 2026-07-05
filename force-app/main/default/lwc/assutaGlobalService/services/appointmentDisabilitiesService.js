//@ts-check
import { executeService } from './executeService';
import { appointmentService } from './appointmentService';
import { utils } from '../utils';

/**
 * @typedef {AppointmentDisabilitiesService} Service
 */

class AppointmentDisabilitiesService {
  /**
   *
   * @param {string} term
   */
  searchAppointments(term, caseId) {
    const params = {
      actionName: 'appointmentSearch',
      operationType: 'update',
      caseId: caseId,
      keyWord: term
    };
    return appointmentService.searchAppointments(params).then((data) => {
      return this.buildLookupAppointmentOptions(data);
    });
  }

  /**
   *
   * @param {string} appointmentId
   * @returns {Promise}
   */
  getSequenceAppointments(appointmentId) {
    console.log(appointmentId);
    const params = {
      operationType: 'update',
      appointmentId: appointmentId
    };
    return appointmentService.getSequenceAppointments(params);
  }
  /**
   *
   * @param {string} caseId
   * @param {string[]} appointmentIds
   * @returns {Promise}
   */
  getDisabilities(caseId, appointmentIds) {
    const params = {
      actionName: 'getDisabilities',
      caseId: caseId,
      appointmentIds: JSON.stringify(appointmentIds)
    };
    return this.request(params);
  }

  /**
   *
   * @param {string} caseId
   * @param {string[]} appointmentIds
   * @param {any[]} disabilities
   * @returns {Promise}
   */
  setDisabilities(caseId, appointmentIds, disabilities) {
    const params = {
      actionName: 'setDisabilities',
      caseId: caseId,
      appointmentIds: JSON.stringify(appointmentIds),
      jsonedParams: JSON.stringify(disabilities)
    };
    return this.request(params);
  }
  /**
   *
   * @param {any[]} data
   * @returns {any[]}
   */
  buildLookupAppointmentOptions(data) {
    return data.map((item) => {
      return Object.assign({}, item, {
        icon: null,
        title: item.Name,
        id: item.Id
      });
    });
  }

  /**
   *
   * @param {*} params
   * @returns {Promise}
   */
  request(params) {
    return executeService.execute('LC_DisabilityController', params);
  }
}

export const appointmentDisabilitiesService = new AppointmentDisabilitiesService();