//Test for AccountContactRelationTrigger, AccConRelationHandler, AccConRelationDispatcher, AccConRelationServices, CreatePatientTafnitIntegration, ws_CreatePatient
@isTest
public class AccConRelationServicesTest {

    @TestSetup
    static void setup() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Phone = '0526641223';
        insert patient;
        
        /*Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.Phone = '0526641223';
        patient2.ID_Number__c = '999849169';

        insert new List<Account>{patient, patient2};*/
    }

    @isTest
    static void updatePatientTest() {
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        //Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Account generalAccount = new Account();
        generalAccount.Name = 'General Account';
        generalAccount.ID_Number__c = null;
        generalAccount.RecordTypeId = TestDataFactory.getRTId('General_Account','Account');
        insert generalAccount;
        Contact con = new Contact(LastName = 'LastName', AccountId = generalAccount.Id, RecordTypeId = TestDataFactory.getRTId('Escort', 'Contact')); 
        insert con;
        AccountContactRelation accContRel = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id);

        Test.startTest();
        //update con;
        //insert con;
        insert accContRel;
        //delete [SELECT Id FROM AccountContactRelation LIMIT 1];
        Test.stopTest();
    }
}