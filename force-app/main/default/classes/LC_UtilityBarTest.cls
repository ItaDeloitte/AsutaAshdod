@IsTest
public with sharing class LC_UtilityBarTest {

    @IsTest 
    static void isUserCanRefreshDashboardTest() {
        Test.startTest();
        Response response = new LC_UtilityBarController().executeAction(
            new Map<String, Object>{
                'actionName' => 'isUserCanRefreshDashboard'}
        );
        Test.stopTest();
    }
    
    @IsTest 
    static void refreshDashboardSuccessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LC_UtilityBarService.SalesforceAPIMock());
        Response response = new LC_UtilityBarController().executeAction(
            new Map<String, Object>{
                'actionName' => 'refreshDashboard',
                'dashboardId' => 'test',
                'refreshTime' => 60
            }
        );
        Test.stopTest();
    }

    @IsTest 
    static void refreshDashboardErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LC_UtilityBarService.SalesforceAPIMock(false));
        Response response = new LC_UtilityBarController().executeAction(
            new Map<String, Object>{
                'actionName' => 'refreshDashboard',
                'dashboardId' => 'test',
                'refreshTime' => 60}
        );
        Test.stopTest();
    }

    @IsTest
    static void exceptionTest() {
        Test.startTest();
        try {
            new LC_UtilityBarController().executeAction(new Map<String, Object>{'actionName' => 'exception'});
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION: exception', e.getMessage());
        }
        Test.stopTest();
    }
}