import { executeService } from 'c/executeService';

/** @module DocExpertise */
/** DocExpertService */
class DocExpertService {
  /** @param {*} caseId */
  isAvailable(caseId) {
    const params = {
      actionName: 'isAvailable',
      caseId
    };
    return this.request(params);
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string} params.doctorId
   */
  getDoctorClinics({ recordId, doctorId }) {
    const params = {
      actionName: 'obtainClinics',
      caseId: recordId,
      doctorId
    };

    return this.request(params);
  }

  /** @param {*} params */
  request(params) {
    return executeService.execute('LC_DoctorScreenController', params);
  }
}

export const docExpertService = new DocExpertService();
export * from './constants';
export * from './docExpertUtils';
export * from './types';