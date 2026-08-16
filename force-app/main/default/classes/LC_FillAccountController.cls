// Test: LC_FillAccountTest
public with sharing class LC_FillAccountController implements ILCController {

    public class LC_FillAccountException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'isAccountFull' {
                return this.isAccountFull(
                    (String) params.get('opptId'));
            }
            when 'getAccount' {
                return this.getAccount(
                    (String) params.get('opptId'));
            }
            when 'setAccount' {
                return this.setAccount(
                    (String) params.get('opptId'),
                    (Map<String, Object>) JSON.deserializeUntyped((String) params.get('accountData')));
            }
            when else {
                throw new LC_FillAccountException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response isAccountFull(String opptId) {
        System.debug('LC_FillAccountController.getAccount...');
        Boolean isAccountFull = LC_FillAccountService.getInstance(opptId).isAccountFull();
        System.debug('isAccountFull: ' + isAccountFull);

        return new Response(isAccountFull);
    }

    private Response getAccount(String opptId) {
        System.debug('LC_FillAccountController.getAccount...');
        LC_FillAccountService.FormDetails formDetails = LC_FillAccountService.getInstance(opptId).getAccount();
        System.debug('formDetails: ' + formDetails);

        return new Response(formDetails);
    }

    private Response setAccount(String opptId, Map<String, Object> acctData) {
        System.debug('LC_FillAccountController.setAccount...');
        Id acctId = LC_FillAccountService.getInstance(opptId).setAccount(acctData);
        System.debug('acctId: ' + acctId);

        return new Response(acctId);
    }
}