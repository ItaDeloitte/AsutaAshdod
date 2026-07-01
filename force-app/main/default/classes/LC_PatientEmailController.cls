// Test: LC_PatientEmailControllerTest
public with sharing class LC_PatientEmailController implements ILCController {

    public class LC_PatientEmailControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'setPatientEmail' {
                return this.setPatientEmail((String) params.get('patientId'),
                                              (String) params.get('idType'),
                                              (String) params.get('email'));
            }
            when else {
                throw new LC_PatientEmailControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response setPatientEmail(String patientId, String idType, String email) {
        System.debug('LC_PatientEmailController.setPatientEmail...\npatientId: ' + patientId + '\nidType: ' + idType + '\nemail: ' +  email);
        Account account = LC_BackendUtils.getPatientEmail(patientId, idType);
        System.debug('account ' + account);
        Account patient = new Account(Id = account.Id);
        patient.PersonEmail = email;
        update patient;
        return new Response('success');
    }
}