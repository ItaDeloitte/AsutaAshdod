// Created: Evgeniy Kravchuk
// Date: 27.05.2019
@isTest
public class ContactServicesTest {

    @TestSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        insert TestDataFactory.getContact(doctor.Id);

        Account generalAccount = new Account();
        generalAccount.Name = 'General Account';
        generalAccount.ID_Number__c =null;
        generalAccount.RecordTypeId = TestDataFactory.getRTId('General_Account','Account');
        System.debug('value is: '+TestDataFactory.getRTId('General_Account','Account'));
        insert generalAccount;
        System.debug('acc id is :'+generalAccount.Id);
    }

    @isTest
    static void checkIdNumberUniquenessTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];

        Test.startTest();
        try {
            insert new List<Contact>{TestDataFactory.getContact(doctor.Id)};
        } catch (Exception e) {
            if (e.getMessage().contains('Id number should be unique') || e.getMessage().contains('מספר זיהוי זה כבר קיים במערכת')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void checkIdNumberUniquenessBulkTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];

        Test.startTest();
        try {
            insert new List<Contact>{TestDataFactory.getContact(doctor.Id), TestDataFactory.getContact(doctor.Id)};
        } catch (Exception e) {
            if (e.getMessage().contains('Id number should be unique') || e.getMessage().contains('מספר זיהוי זה כבר קיים במערכת')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void validateIdNumberTest() {
        Contact con = [SELECT Id, ID_Number__c FROM Contact LIMIT 1];
        con.ID_Number__c = '12345';

        Test.startTest();
        try {
            update con;
        } catch (Exception e) {
            if(e.getMessage().contains('Person Id is incorrect') || e.getMessage().contains('תעודת זהות אינה תקינה')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void AssignGeneralAccountTest(){
        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName ='General Account';
        Account generalAccount = [SELECT Id FROM Account WHERE RecordType.Developername = 'General_Account' AND Name='General Account' AND ID_Number__c =null LIMIT 1];
        Test.startTest();
        try {
            insert newContact;
        } catch (Exception e) {
            System.debug(e);
        }
        Contact con = [SELECT Id,AccountId FROM Contact WHERE FirstName='Test' LIMIT 1];
        System.assertEquals(generalAccount.Id, con.AccountId);
        Test.stopTest();
    }
}