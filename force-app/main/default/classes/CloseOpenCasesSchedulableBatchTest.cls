@isTest
public class CloseOpenCasesSchedulableBatchTest {
    @TestSetup
    static void makeData() {
        Id docExpertRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DOC_expert').getRecordTypeId();

        List<Case> caseToInsertList = new List<Case>();

        for (Integer i = 0; i < 25; i++) {
            caseToInsertList.add(new Case(
                Case_subject__c = 'זימון רופא מומחה',
                sub_case_subject__c = 'זימון תור לאחר המלצה',
                Status = 'New',
                RecordTypeId = docExpertRT
            ));
        }

        insert caseToInsertList;
    }

    @isTest
    public static void batchTest() {
        Test.startTest();
        Database.executeBatch(new CloseOpenCasesSchedulableBatch());
        Test.stopTest();
        List<Case> updatedCaseList = [SELECT Id FROM Case WHERE Status = 'Closed'];
        System.assertEquals(updatedCaseList.size(), 25, 'Some cases weren`t updated');
    }

    @isTest
    static void scheduleTest() {
        Test.startTest();
        System.schedule('job test', '20 30 8 10 2 ?', new CloseOpenCasesSchedulableBatch());
        Test.stopTest();
    }
}