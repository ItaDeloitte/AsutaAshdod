/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment 'Send Questionnaire Link' button Apex Controller class to keep main logical entries
 * 
 * Test                 LC_SendQuestionnaireLinkTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             13-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_SendQuestionnaireLinkController implements ILCController {

    public class LC_SendQuestionnaireLinkException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'obtainSurveyTakers' {
                return this.obtainSurveyTakers(
                    (String) params.get('appointmentId')
                );
            }
            when 'submit' {
                return this.submit(
                    (String) params.get('appointmentId'),
                    (String) params.get('surveyTakerId')
                );
            }
            when else {
                throw new LC_SendQuestionnaireLinkException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response obtainSurveyTakers(String appointmentId) {
        System.debug('LC_SendQuestionnaireLinkController.obtainSurveyTakers...');
        return new Response(LC_SendQuestionnaireLinkService.getInstance(appointmentId).obtainSurveyTakers());
    }

    private Response submit(String appointmentId, String surveyTakerId) {
        System.debug('LC_SendQuestionnaireLinkController.submit...');
        LC_SendQuestionnaireLinkService.getInstance(appointmentId).submit(
            String.isBlank(surveyTakerId) ? null : surveyTakerId
        );
        return new Response(LC_SendQuestionnaireLinkUtil.MSG_SUCCESS);
    }
}