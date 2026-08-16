// Test for: LC_BaseController
@isTest
private class LC_BaseControllerTest {

    @isTest
    static void executeTest() {
        Test.startTest();
        Response res = LC_BaseController.execute('LC_AppointmentController', new Map<String, Object>());
        Test.stopTest();
    }

    @isTest
    static void exception1Test() {
        Test.startTest();
        Response res = LC_BaseController.execute('LC_NoClass', new Map<String, Object>());
        Test.stopTest();
    }

    @isTest
    static void exception2Test() {
        Test.startTest();
        Response res = LC_BaseController.execute('LC_SearchUtils', new Map<String, Object>());
        Test.stopTest();
    }
}