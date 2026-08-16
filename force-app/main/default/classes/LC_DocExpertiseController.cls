/** Deprecated as of 30-11-2023 */
public without sharing class LC_DocExpertiseController implements ILCController {

    public class LC_DocExpertiseControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when else {
                throw new LC_DocExpertiseControllerException('UNKNOWN ACTION');
            }
        }
    }
}