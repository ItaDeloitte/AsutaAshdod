/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Case 'Link To Case' quick action Apex Controller class to keep main logical entries
 * 
 * Test                 LC_LinkToCaseTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_LinkToCaseController implements ILCController {

    public class LC_LinkToCaseException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'obtainCases' {
                return this.obtainCases(
                    (String) params.get('caseId')
                );
            }
            when 'submit' {
                return this.submit(
                    (String) params.get('caseId'),
                    (String) params.get('selectedCaseId')
                );
            }
            when else {
                throw new LC_LinkToCaseException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response obtainCases(String caseId) {
        System.debug('LC_DoctorScreenController.obtainCases...');
        return new Response(LC_LinkToCaseService.getInstance(caseId).obtainCases());
    }

    private Response submit(String caseId, String selectedCaseId) {
        System.debug('LC_DoctorScreenController.submit...');
        LC_LinkToCaseService.getInstance(caseId).submit(
            String.isBlank(selectedCaseId) ? null : selectedCaseId
        );
        return new Response(LC_LinkToCaseUtil.MSG_SUCCESS);
    }
}