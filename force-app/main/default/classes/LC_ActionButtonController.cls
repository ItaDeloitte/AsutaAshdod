/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Custom Buttons component Apex Controller class to keep main logical entries
 * 
 * Test                 LC_ActionButtonTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             27-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_ActionButtonController implements ILCController {

    public class LC_ActionButtonException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'obtainButtons' {
                return this.obtainButtons(
                    (String) params.get('recordId')
                );
            }
            when else {
                throw new LC_ActionButtonException(LC_ActionButtonUtil.ERR_UNKNOWN_ACTION);
            }
        }
    }

    private Response obtainButtons(String recordId) {
        System.debug('LC_ActionButtonController.obtainButtons...');
        return new Response(LC_ActionButtonService.getInstance(recordId).obtainButtons());
    }
}