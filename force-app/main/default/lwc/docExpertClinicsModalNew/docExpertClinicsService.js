import { docExpertService } from 'c/docExpertService';

class DocExpertClinicsService {
  /**
   *
   * @param {Object} params
   * @param {string} params.id
   * @param {string} params.recordId
   */
  chooseClinic({ recordId, id }) {
    const params = {
      actionName: 'chooseClinic',
      clinicId: id,
      caseId: recordId
    };
    return this.request(params);
  }

  /**
   *
   * @param {*} params
   */
  request(params) {
    return docExpertService.request(params);
  }
}

export const docExpertClinicsService = new DocExpertClinicsService();