@isTest
private class ClearMailingApprovalBatchTest {

    @TestSetup
    static void makeData() {        
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME); 
        patient.Status__c = 'פ';              
        insert patient;        
    }            

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)) {
            Account patient = [SELECT Id FROM Account LIMIT 1];
            patient.Mailing_approval__c = 'מאשר דיוור - שיווקי'; 
            patient.SMS_Phone_Number__c = '0999845477';
            patient.Preferred_Channel__c = 'SMS';
            patient.Insurer_factor__c = '3';
            update patient;        
          

            AccountHistory[] accHistory = [SELECT AccountId
                                            , Field
                                            , OldValue
                                            , NewValue 
                                            FROM AccountHistory 
                                            WHERE AccountId = :patient.Id];
            System.debug('accHistory ' + accHistory);
            //System.assertEQuals(1, accHistory.size());  
        }

        Database.executeBatch(
            new ClearMailingApprovalBatch(
                'SELECT AccountId'                            
                + ', MAX(CreatedDate) maxDate'                            
            + ' FROM AccountHistory'
            + ' GROUP BY AccountId'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void batchTest_1() {
        System.debug('batch test 1');
        Test.startTest();
        Database.executeBatch(new ClearMailingApprovalBatch(1));
        Test.stopTest();
    }

    @isTest
    static void batchTest_2() {
        System.debug('batch test 2');
        Test.startTest();
        Database.executeBatch(new ClearMailingApprovalBatch(2));
        Test.stopTest();
    }
}