// Created: Evgeniy Kravchuk
// Date: 15.01.2020
// Test for: Bot_CreateCase
@isTest
public class Bot_CreateCaseTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert TestDataFactory.getContact(doctor.Id);
    }

    @isTest
    static void createCaseTest() {
        Bot_CreateCase.CreateCaseRequestWrapper wrapper = new Bot_CreateCase.CreateCaseRequestWrapper();
        wrapper.recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' LIMIT 1].Id;
        wrapper.accountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].Id;
        wrapper.contactId = [SELECT Id FROM Contact LIMIT 1].Id;

        Test.startTest();
        Bot_CreateCase.createCase(new List<Bot_CreateCase.CreateCaseRequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void createCaseExceptionTest() {
        Bot_CreateCase.CreateCaseRequestWrapper wrapper = new Bot_CreateCase.CreateCaseRequestWrapper();
        wrapper.recordTypeId = '';

        Test.startTest();
        try {
            Bot_CreateCase.createCase(new List<Bot_CreateCase.CreateCaseRequestWrapper>{wrapper});
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void createCaseException2Test() {
        Test.startTest();
        try {
            Bot_CreateCase.createCase(new List<Bot_CreateCase.CreateCaseRequestWrapper>());
        } catch (Exception e) {}
        Test.stopTest();
    }
}