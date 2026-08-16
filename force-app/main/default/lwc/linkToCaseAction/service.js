/**
 * Created by danilvinnik on 12.09.2022.
 */
import {executeService} from 'c/executeService';

class Service {
    obtainCases(caseId, patientId){
        let params = {
            actionName: 'obtainCases',
            caseId: caseId,
            patientId: patientId
        };
        return this.request(params);
    }

    submit(caseId, selectedCaseId){
        let params = {
            actionName: 'submit',
            caseId: caseId,
            selectedCaseId: selectedCaseId
        };
        return this.request(params);
    }
    /**
     *
     * @param {*} params
     */
    request(params) {
        return executeService.execute('LC_LinkToCaseController', params);
    }
}

export const service = new Service();