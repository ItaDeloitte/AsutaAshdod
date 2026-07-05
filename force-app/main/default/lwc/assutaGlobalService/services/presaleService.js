import { executeService } from './executeService';

class PresaleService {
  createCase(recordId) {
    const params = {
      actionName: 'createCase',
      opptId: recordId
    };
    return this.request(params);
  }

  request(params) {
    return executeService.execute('LC_PreSaleController', params);
  }
}

export const presaleService = new PresaleService();