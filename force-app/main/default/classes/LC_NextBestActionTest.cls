// Test for: LC_NextBestAction
@isTest
public class LC_NextBestActionTest {

    @isTest
    static void getFieldsTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'getFields');
        params.put('recordId', UserInfo.getUserId());
        params.put('apiNames', 'Id');

        Test.startTest();
        LC_NextBestAction controller = new LC_NextBestAction();
        Response res = controller.executeAction(params);
        Test.stopTest();
    }

    @isTest
    static void getFieldsExceptionTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'getFields');
        params.put('recordId', UserInfo.getUserId());
        params.put('apiNames', '');

        Test.startTest();
        LC_NextBestAction controller = new LC_NextBestAction();
        try {
            Response res = controller.executeAction(params);
        } catch (Exception e) {
            System.assertEquals('There are no api names is empty.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void executeActionExceptionTest() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('actionName', 'test');

        Test.startTest();
        LC_NextBestAction controller = new LC_NextBestAction();
        try {
            Response res = controller.executeAction(params);
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION test', e.getMessage());
        }
        Test.stopTest();
    }
}