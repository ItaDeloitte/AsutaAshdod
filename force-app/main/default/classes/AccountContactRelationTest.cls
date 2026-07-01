//Test for AccountContactRelationTrigger, AccConRelationHandler, AccConRelationDispatcher, AccConRelationServices
@isTest
public class AccountContactRelationTest {
    @TestSetup
    static void makeData(){
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());

        Account patientAcct = TestDataFactory.createPersonAccount();
        patientAcct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName ='PersonAccount' AND SObjectType = 'Account' LIMIT 1].Id;
        patientAcct.ID_Number__c = '852986371';   //852986371
        //patientAcct.Id_Type__c = '2';
        insert patientAcct;

        Account doctorAcct = TestDataFactory.createAccount();
        doctorAcct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Doctor_Account' AND SObjectType = 'Account' LIMIT 1].Id;
        insert doctorAcct;

        Contact cont = TestDataFactory.createContact(doctorAcct.Id);
        insert cont;
    }

    @isTest
    static void accConRelationTest() {
        Id docAccRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Doctor_Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account doctorAcct = [SELECT Id FROM Account WHERE RecordTypeId = :docAccRTId LIMIT 1];
        Id patAccRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SObjectType = 'Account' LIMIT 1].Id;
        Account patientAcct = [SELECT Id FROM Account WHERE RecordTypeId = :patAccRTId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        AccountContactRelation relations = new AccountContactRelation(AccountId = doctorAcct.Id,
                                                                        ContactId = con.Id, 
                                                                        isActive = true, 
                                                                        Roles = 'ייפוי כח',
                                                                        Status__c = 'מאושר'/*'OTP'*/);
        Test.startTest();
        insert relations;
        relations.status__c = 'מאושר';
        update relations;
        Test.stopTest();
    }
}