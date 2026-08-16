@isTest
public with sharing class FilesOpenTogether_LWCtrlTest {

        @TestSetup
    static void prepareData() {
        insert TestDataFactory.getENV();
        Map<String, Schema.RecordTypeInfo> fileRTMap = Schema.SObjectType.File__c.getRecordTypeInfosByDeveloperName();
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.SMS_Phone_Number__c = null;
        insert patient;

        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cVersion.PathOnClient = 'filename.pdf';
        cVersion.ContentLocation = 'S';
        cVersion.Title = 'title';
        insert cVersion;

        File__c accountFile = TestDataFactory.getFile();
        accountFile.Account__c = patient.Id;
        accountFile.RecordTypeId = TestDataFactory.getRTId('Doctor_Photo','File__c');
        accountFile.Content_Version_Id__c = cVersion.ContentDocumentId;        
        insert accountFile;

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocId;
        cDocLink.LinkedEntityId = accountFile.Id;
        cDocLink.Visibility = 'AllUsers';
        cDocLink.ShareType = 'I';
        insert cDocLink;
        
    }

    @isTest
    public static void getFilesTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<FilesOpenTogether_LWCtrl.FileWrapper> files = FilesOpenTogether_LWCtrl.getFilesForAccount(acc.Id);
    }
}