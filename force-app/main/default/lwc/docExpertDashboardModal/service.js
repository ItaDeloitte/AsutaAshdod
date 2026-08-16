import { docExpertService } from 'c/docExpertService';
import * as dashboardUtils from './utils';

class DashboardService {
  /**
   *
   * @param {string} recordId
   * @returns
   */
  getInitData(recordId) {
    const params = {
      actionName: 'init',
      caseId: recordId
    };

    return this.request(params).then((res) =>
      dashboardUtils.buildInitData(res)
    );
  }

  /**
   *
   * @param {DocExpertDashboardModalTypes.SearchDoctorsRequestParams} params
   */
  searchDoctors({
    recordId,
    searchType,
    onlyRecommended,
    procedureId,
    expertiseId,
    subExpertiseId,
    arrangements,
    settlements,
    doctorName
  }) {
    const params = {
      actionName: 'searchDoctors',
      caseId: recordId,
      onlyRecommended,
      procedureId,
      expertiseId,
      subExpertiseId,
      searchType,
      arrangements: JSON.stringify(arrangements),
      settlements: settlements ? JSON.stringify(settlements) : undefined,
      doctorName
    };

    return this.request(params);
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string} params.searchTerm
   */
  searchExpertise({ recordId, searchTerm }) {
    const params = {
      actionName: 'searchExpertises',
      caseId: recordId,
      keyword: searchTerm
    };

    return this.request(params).then((res) =>
      res.map((item) => dashboardUtils.buildExpertiseOption(item))
    );
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string} params.searchTerm
   * @param {string} params.expertiseId
   */
  searchSubExpertise({ recordId, searchTerm, expertiseId }) {
    const params = {
      actionName: 'searchSubExpertises',
      caseId: recordId,
      expertiseId: expertiseId,
      keyword: searchTerm
    };

    return this.request(params).then((res) =>
      res.map((item) => dashboardUtils.buildSubExpertiseOption(item))
    );
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string} params.searchTerm
   * @param {string} params.subExpertiseId
   */
  searchMedicalProcedure({ recordId, searchTerm, subExpertiseId }) {
    const params = {
      actionName: 'searchProcedures',
      caseId: recordId,
      keyword: searchTerm,
      subExpertiseId: subExpertiseId
    };

    return this.request(params).then((res) =>
      res.map((item) => dashboardUtils.buildMedProcedureOption(item))
    );
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string[]} params.doctorIds
   */
  recommendDoctors({ recordId, doctorIds }) {
    const params = {
      actionName: 'recommendDoctors',
      caseId: recordId,
      doctorIds: JSON.stringify(doctorIds)
    };

    return this.request(params);
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string[]} params.doctorIds
   */
  sendDoctorAdvisor({ recordId, doctorIds }) {
    const params = {
      actionName: 'sendDoctorAdvisor',
      caseId: recordId,
      doctorIds: JSON.stringify(doctorIds)
    };

    return this.request(params);
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string[]} params.doctorIds
   * @param {string} params.selectedDoctorId
   * @param {string} params.arrangementId
   */
  schedule({ recordId, doctorIds, selectedDoctorId, arrangementId }) {
    const params = {
      actionName: 'schedule',
      caseId: recordId,
      doctorIds: JSON.stringify(doctorIds),
      selectedDoctorId,
      arrangementId
    };

    return this.request(params);
  }

  /**
   * @param {Object} params
   * @param {string} params.recordId
   * @param {string} params.expertiseId
   * @param {string} params.subExpertiseId
   * @param {string} params.subExpertiseId
   * @param {string[]} params.doctorIds
   */
  getClosestAvailableSlotInfo({
    recordId,
    expertiseId,
    subExpertiseId,
    doctorIds
  }) {
    const params = {
      actionName: 'obtainClosestAvailableSlotInfo',
      caseId: recordId,
      expertiseId,
      subExpertiseId,
      doctorIds: JSON.stringify(doctorIds)
    };

    return this.request(params);
  }

  /** @param {*} params */
  request(params) {
    return docExpertService.request(params);
  }
}

export const dashboardService = new DashboardService();