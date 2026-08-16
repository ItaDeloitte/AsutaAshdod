@isTest
public class ResetAmbulatoryLimitationScheduleTest {

    @testSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();

        //include in Batch
        Account patient1 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient1.SMS_Phone_Number__c = '00000000004';
        patient1.ID_Number__c = '999380298';        
        patient1.Patient_not_entitled_for_ambulatory__c = true;
        patient1.List_of_Prohibitions__c = null;
        patient1.AmbulatoryLimitationEndDate__c = Date.today();
        accounts.add(patient1);
        
        //include in Batch
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.SMS_Phone_Number__c = '00000000005';
        patient2.ID_Number__c = '999824352';       
        patient2.Patient_not_entitled_for_ambulatory__c = false;
        patient2.List_of_Prohibitions__c = 'מרפאה פנימית';
        patient2.AmbulatoryLimitationEndDate__c = Date.today();
        accounts.add(patient2);

        //not include in Batch
        Account patient3 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient3.SMS_Phone_Number__c = '00000000006';
        patient3.ID_Number__c = '999549553';       
        patient3.Patient_not_entitled_for_ambulatory__c = false;
        patient3.List_of_Prohibitions__c = null;
        patient3.AmbulatoryLimitationEndDate__c = Date.today();
        accounts.add(patient3);

        //for send email
        Account patient4 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient4.SMS_Phone_Number__c = '00000000007';
        patient4.ID_Number__c = '999053572';       
        patient4.Patient_not_entitled_for_ambulatory__c = true;
        patient4.List_of_Prohibitions__c = 'מרפאה פנימית';
        patient4.AmbulatoryLimitationEndDate__c = Date.today().addDays(1);
        accounts.add(patient4);
        insert accounts;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        ResetAmbulatoryLimitationScheduleBatch batch = new ResetAmbulatoryLimitationScheduleBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();
        
        List<Account> updatedAccounts = [
            SELECT ID_Number__c,                   
                   List_of_Prohibitions__c,
                   AmbulatoryLimitationEndDate__c,
                   Patient_not_entitled_for_ambulatory__c
            FROM Account
            WHERE ID_Number__c IN ('345678902', '123456782')
        ];

        for (Account acc : updatedAccounts) {
            System.assertEquals(false, acc.Patient_not_entitled_for_ambulatory__c, 'CB field should be false');
            System.assertEquals(null, acc.List_of_Prohibitions__c, 'Prohibition list should be cleared');
            System.assertEquals(null, acc.AmbulatoryLimitationEndDate__c, 'End date should be cleared');
        }
    }

    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        ResetAmbulatoryLimitationScheduleBatch schedulable = new ResetAmbulatoryLimitationScheduleBatch();
        schedulable.execute(null); // simulate scheduler
        Test.stopTest();        
    }
}