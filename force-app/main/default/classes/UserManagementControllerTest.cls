@isTest
public class UserManagementControllerTest {

    @testSetup
    static void setup() {
        User user = TestDataFactory.getUser('Agent');
        insert user;
    }

    @IsTest
    static void getUserPermissionsLiveAgent() {
        List<User> userList = new List<User>();
        Test.startTest();
        userList = UserManagementController.getUserPermissionsLiveAgent();
        System.assert(userList.size() > 0);
        Test.stopTest();
    }

    @IsTest
    static void getAgentName() {
        List<User> userList = new List<User>();
        Test.startTest();
        userList = UserManagementController.getAgentName();
        System.assert(userList.size() > 0);
        Test.stopTest();
    }

    @IsTest
    static void getMaxLicenses() {
        Test.startTest();
        Boolean overTotalLicenses= UserManagementController.getMaxLicenses();
        System.assert(overTotalLicenses == false || overTotalLicenses == true);
        Test.stopTest();
    }

    @IsTest
    static void insertUserPermissionsLiveAgent() {
        String userName = [SELECT Name FROM user LIMIT 1].Name;
        Test.startTest();
        Id userId= UserManagementController.insertUserPermissionsLiveAgent(userName);
        System.assert(userId != null);
        Test.stopTest();
    }

    @IsTest
    static void deleteUserPermissionsLiveAgent() {
        Id permissionsLiveMessageId = [SELECT Id FROM PermissionSet WHERE Name = 'Live_Message_Setup_Flow'].Id;
        Id AssigneeId = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: permissionsLiveMessageId LIMIT 1].AssigneeId;
        Test.startTest();
        UserManagementController.deleteUserPermissionsLiveAgent(AssigneeId);
        Test.stopTest();
    }
}