//Test AssignPermissionSetBatch
@IsTest
public with sharing class AssignPermissionSetBatchTest {
    
    @IsTest
    public static void test() {
        Profile secretaryProfile = [SELECT Id FROM Profile WHERE Name = 'Secretary - IVF'];
        User u = TestDataFactory.getUser('Standard User');
        u.ProfileId = secretaryProfile.Id;
        insert u;

        String query = 'SELECT Id, ProfileId, UserPermissionsSupportUser FROM User WHERE Id =\'' +  u.Id + '\'';
        Test.startTest();
        Database.executeBatch(new AssignPermissionSetBatch(query));
        Test.stopTest();
    }
}