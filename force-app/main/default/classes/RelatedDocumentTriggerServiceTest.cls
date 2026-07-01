@isTest
private class RelatedDocumentTriggerServiceTest {
    
    @testSetup
    static void setup() {     
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        procedure.Reminder_required__c = true;
        procedure.Voice_Reminder__c = '3';
        procedure.SMS_Reminder__c = '1';
        procedure.Humen__c = '3';
        insert procedure;        
    }
    
    @isTest
    static void checkDuplicateRecordsTest () {
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Related_document__c rd1 = TestDataFactory.getRelatedDoc(procedure.Id, '84');
        Related_document__c rd2 = TestDataFactory.getRelatedDoc(procedure.Id, '84');
        insert rd1;        
        
        Test.startTest();
        try {
            insert rd2;
        } catch (Exception e) {
            if (e.getMessage().contains('רשומת מסמך נלווה זהה לא ניתן לשמור את הרשומה')) {
                System.debug('error message is good');
            }
        }
        rd1.FromHour__c = '1';
        update rd1;
        Test.stopTest();
    }

}