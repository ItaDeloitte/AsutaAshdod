@isTest
private class LC_OmniChanelControllerTest {

    @TestSetup
    static void makeData() {
        Case cas = new Case(OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1].Id);
        insert cas;
        CaseHistory casHistory = new CaseHistory(CaseId = cas.Id, Field = 'Owner');
        insert casHistory;
    }

    @isTest 
    static void getInitDataTest() {
        Test.startTest();
        LC_OmniChanelController controller = new LC_OmniChanelController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'getInitData'});
        Test.stopTest();
    }

    @isTest
    static void checkStatusPossibilityTest() {
        Test.startTest();
        LC_OmniChanelController controller = new LC_OmniChanelController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'checkStatusPossibility', 'statusId' => '0R18E0000000Y6rSAE'});
        Test.stopTest();
    }

    @isTest
    static void assignOwnerFirstOwnerTest() {
        Case cas = [SELECT Id, First_user_to_own_the_case__c FROM Case LIMIT 1];
        cas.First_user_to_own_the_case__c = UserInfo.getUserId();
        update cas;
        Test.startTest();
        LC_OmniChanelController controller = new LC_OmniChanelController();
        Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'assignOwner', 'itemId' => cas.Id});
        Test.stopTest();
    }

    @isTest
    static void assignOwnerTest() {
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        LC_OmniChanelController controller = new LC_OmniChanelController();
        try {
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'assignOwner', 'itemId' => cas.Id});
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            LC_OmniChanelController controller = new LC_OmniChanelController();
            Response res = controller.executeAction(new Map<String, Object>{'actionName' => 'ex'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION ex', e.getMessage());
        }
        Test.stopTest();
    }
}