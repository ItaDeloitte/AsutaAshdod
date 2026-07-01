@isTest
private class schedule_DeleteDocumentTest {

    @IsTest
    static void scheduleTest() {
        File__c file = TestDataFactory.getFile();
        file.URL__c = 'http://blabal.blla';
        file.file_type__c = '13';
        insert file;
        ContentVersion cVersion = TestDataFactory.getContentVersion();
        cVersion.IsNeedToBeDeleted__c = true;
        insert cVersion;
        Id cDocId = [SELECT ContentDocumentId FROM contentVersion WHERE Id =: cVersion.Id].contentDocumentId;
        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(file.Id);
        cDocLink.ContentDocumentId = cDocId;
        insert cDocLink;
        file.Content_Version_Id__c = cDocId;
        update file;

        Test.startTest();
        System.schedule('DeleteDoc_', '0 0 0 1 1 ? 2055', new schedule_DeleteDocument());
        Test.stopTest();
    }
}