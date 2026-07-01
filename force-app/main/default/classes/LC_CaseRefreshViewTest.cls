// Test for: LC_CaseRefreshView
@isTest
public class LC_CaseRefreshViewTest {

    @isTest
    static void refreshViewTest() {
        Payer_Factor__c parent = new Payer_Factor__c(InsuranceCode__c = '333');
        insert parent;
        Payer_Factor__c payerFactor = new Payer_Factor__c(Name_of_parent__c = parent.Id);
        insert payerFactor;
        Case cas = new Case(PayerFactor__c = payerFactor.Id);
        insert cas;

        Test.startTest();
        LC_CaseRefreshView controller = new LC_CaseRefreshView();
        Response res1 = controller.executeAction(new Map<String, Object>{'actionName' => 'refreshView', 'recordId' => cas.Id});
        Response res2 = controller.executeAction(new Map<String, Object>{'actionName' => 'refreshView', 'recordId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        LC_CaseRefreshView controller = new LC_CaseRefreshView();
        try {
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'wrong', 'recordId' => UserInfo.getUserId()});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION wrong', e.getMessage());
        }
        Test.stopTest();
    }
}