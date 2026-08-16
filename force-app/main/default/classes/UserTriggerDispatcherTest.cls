/*
* @author         Avraham Dasa   <adasa@deloitte.co.il>
* @Class Name     UserTriggerDispatcher
* @modifiedBy     
* @version        1.0
* @created        09-01-2020
* @modified       29-01-2020
* @description    update User Role and callcenter and permission set    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class UserTriggerDispatcherTest {
    
    @testSetup
    static void setup() {
        insert new UserRole(Name = 'נציג', RollupDescription = 'נציג');
        insert TestDataFactory.getUser('Agent 360');
    }

    @isTest
    static void assignPermissionSetTest() {
        Profile secretaryProfile = [SELECT Id FROM Profile WHERE Name = 'Secretary'];
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = TestDataFactory.getUser('Standard User');

        Test.startTest();
        insert u;
        u.ProfileId = secretaryProfile.Id;
        update u;
        u.ProfileId = standardProfile.Id;
        update u;
        Test.stopTest();
    }

    @isTest
    static void updateUserRoleTitleTest() {
        UserRole ur = [SELECT Id, Name FROM UserRole LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = TestDataFactory.getUser('System Administrator');
        user.ProfileId = p.Id;
        user.Title = null;

        Test.startTest();
   	    insert user;
        Test.StopTest();
    }

    @isTest
    static void updateRoleByTitleChangeTest() {
        Id profileId = [SELECT Id, UserType FROM Profile WHERE Name = 'Agent 360' LIMIT 1].Id;
        User user = [SELECT Id, Title FROM User WHERE ProfileId =: profileId LIMIT 1];
        user.Title = 'נציג בכיר';

        Test.startTest();
        update user;
        Test.stopTest();
    }
}