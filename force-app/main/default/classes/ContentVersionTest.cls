@isTest
public class ContentVersionTest {

    @TestSetup
    static void setup() {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        cv.GateScaner_FileScanStatus__c = '2';
        cv.PathOnClient = 'filename.pdf';
        cv.GateScaner_Status__c = '2';
        cv.ContentLocation = 'S';
        cv.Title = 'title';
        insert cv;

        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        File__c file = new File__c(Name = 'test', Content_Version_Id__c = docId, IsMaccabi__c = true, file_type__c = '14');
        insert file;
    }

    @isTest
    static void updateDocFieldsTest1() {
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        File__c file = [SELECT Id FROM File__c LIMIT 1];
        file.IsMaccabi__c = false;
        update file;

        Test.startTest();
        cv.GateScaner_FileScanStatus__c = '3';
        update cv;
        Test.stopTest();
    }

    @isTest
    static void updateDocFieldsTest2() {
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        File__c file = [SELECT Id FROM File__c LIMIT 1];
        file.IsMaccabi__c = false;
        update file;

        Test.startTest();
        cv.GateScaner_Status__c = '1';
        update cv;
        Test.stopTest();
    }

    @isTest
    static void createFileAndSendToScanTest() {
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        File__c file = TestDataFactory.getFile();
        insert file;
        insert new List<ContentVersion>{
            new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true),
            new ContentVersion(Title = 'Dogs', PathOnClient = 'Dogs.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true, IsMaccabiFile__c = true)
        };
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>{
            new ContentDocumentLink(LinkedEntityId = patient.id, ContentDocumentId = documents.get(0).Id, shareType = 'V'),
            new ContentDocumentLink(LinkedEntityId = file.id, ContentDocumentId = documents.get(1).Id, shareType = 'V')
        };
        insert cdls;

        Test.startTest();
        update cdls;
        Test.stopTest();
    }
}