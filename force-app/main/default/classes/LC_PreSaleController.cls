// Test: LC_PreSaleTest
public without sharing class LC_PreSaleController implements ILCController {

    public class LC_PreSaleException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'createCase' {
                return this.createCase(
                    (String) params.get('opptId'));
            }
            when else {
                throw new LC_PreSaleException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response createCase(String opptId) {
        System.debug('LC_PreSaleController.createCase...');
        Id casId = LC_PreSaleService.getInstance(opptId).createCase();
        System.debug('casId: ' + casId);

        return new Response(casId);
    }
}