/**
 * Created by danilvinnik on 15.09.2022.
 */

import {executeService} from 'c/executeService';
class Service {
    obtainCases(appointmentId){
        let params = {
            actionName: 'obtainSurveyTakers',
            appointmentId: appointmentId
        };
        return this.request(params);
    }
    submit(appointmentId, surveyTakerId){
        let params = {
            actionName: 'submit',
            appointmentId: appointmentId,
            surveyTakerId: surveyTakerId
        };
        return this.request(params);
    }
    /**
     *
     * @param {*} params
     */
    request(params) {
        return executeService.execute('LC_SendQuestionnaireLinkController', params);
    }
}
export const service = new Service();