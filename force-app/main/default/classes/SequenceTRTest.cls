@isTest
private class SequenceTRTest {

    @TestSetup
    static void makeData() {}

    @isTest
    static void createGeneralRecordTest() {
        Test.startTest();
        Sequence__c sequence1 = new Sequence__c(Site_Codes__c = '33');
        insert sequence1;

        // the general sequence was created additionally to the specific one
        System.assert([SELECT Id FROM Sequence__c].size() == 2);

        Sequence__c sequence2 = new Sequence__c(Site_Codes__c = '33');
        insert sequence2;

        // the general sequence was not created additionally to the specific one because it's already in the system
        System.assert([SELECT Id FROM Sequence__c].size() == 3);

        Sequence__c sequenceGeneral = [SELECT Site_Codes__c FROM Sequence__c WHERE IsGeneral__c = true LIMIT 1];
        sequenceGeneral.Site_Codes__c = '33';
        update sequenceGeneral;

        // the general sequence was created additionally to the specific one because the previous general sequence was updated to specific
        System.assert([SELECT Id FROM Sequence__c].size() == 4);
        Test.stopTest();
    }
}