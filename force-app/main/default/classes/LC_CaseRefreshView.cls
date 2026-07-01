// Test: LC_CaseRefreshViewTest
public class LC_CaseRefreshView implements ILCController {

    public class LC_CaseRefreshViewException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'refreshView' {
                return this.refreshView((String) params.get('recordId'));
            }
            when else {
                throw new LC_CaseRefreshViewException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response refreshView(String recordId) {
        System.debug('LC_CaseRefreshView.refreshView...\nrecordId: ' + recordId);
        Case cas = [SELECT Id, IsRefreshed__c, PayerFactor__c, PayerFactor__r.Parent_Code__c FROM Case WHERE Id =: recordId];
        if (!cas.IsRefreshed__c && cas.PayerFactor__r.Parent_Code__c == '333') {
            cas.IsRefreshed__c = true;
            update cas;
            System.debug('success\ncas: ' + cas);
            return new Response(true);
        }
        System.debug('success\ncas: ' + cas);
        return new Response(false);
    }
}