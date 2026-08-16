// Test for: AssutaEmployeeTriggerDispatcher
// Created: Ortal kazum
// Date: 01.07.2021
@isTest
public class AssutaEmployeeTriggerDispatcherTest {
    @testSetup
    static void setup() {                
        Account generalAccount = new Account();
        generalAccount.Name = 'General Account';
        generalAccount.ID_Number__c = null;
        generalAccount.RecordTypeId = TestDataFactory.getRTId('General_Account', 'Account');        
        insert generalAccount;       
        
        insert TestDataFactory.getAssutaEmployee();
    }
    
    @isTest
    static void fillFormtitanId() {
        Assuta_Employee__c emp = TestDataFactory.getAssutaEmployee();
        Test.startTest();
        insert emp;
       	Test.stopTest();
    }

    @isTest
    static void validateIdNumberTest() {
        Assuta_Employee__c emp = [SELECT Id, ID_Assuta_Employee__c FROM Assuta_Employee__c LIMIT 1];
        emp.ID_Assuta_Employee__c = '1234';
        Test.startTest();
        try {
            update emp;
        } catch (Exception e) {
            if (e.getMessage().contains('Person Id is incorrect') || e.getMessage().contains('תעודת זהות אינה תקינה')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void createContactTest() {
        Assuta_Employee__c emp = [SELECT Id, First_Name__c, Last_Name__c, ID_Assuta_Employee__c FROM Assuta_Employee__c LIMIT 1];
        System.debug('emp' + emp);
        emp.First_Name__c = 'Test1';
        emp.Last_Name__c = 'Test1';        
        Test.startTest();
        update emp;
        Test.stopTest();
    }
}