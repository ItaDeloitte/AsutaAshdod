// Test: GateScannerFileService, GateScannerFileTriggerDispatcher, GateScannerFileTriggerHandler
@isTest
private class GateScannerFileServiceTest {

    @testSetup
    static void setup() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Case cas = TestDataFactory.getCase(patient.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        insert TestDataFactory.getContentVersion();
        insert new EmailMessage(ParentId = cas.Id);
    }

    @isTest
    static void restoreFileLocation_Case_Test() {
        Account doctor = [SELECT Id, LastName FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        GateScanner_file__c gateScanner = new GateScanner_file__c(
            Original_location__c = [SELECT Id FROM Case LIMIT 1].Id,
            Status__c = 'Unscanned'
        );
        insert gateScanner;

        Test.startTest();
        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(doctor.Id);
        cDocLink.LinkedEntityId = gateScanner.Id;
        cDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;
        insert cDocLink;
        gateScanner.Status__c = 'Scanning passed';
        update gateScanner;
       	Test.stopTest();
    }

    @isTest
    static void restoreFileLocation_EmailMessage_Test() {
        Account doctor = [SELECT Id, LastName FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        GateScanner_file__c gateScanner = new GateScanner_file__c(
            Original_location__c = [SELECT Id FROM EmailMessage LIMIT 1].Id,
            Status__c = 'Unscanned'
        );
        insert gateScanner;

        Test.startTest();
        ContentDocumentLink cDocLink = TestDataFactory.getContentDocLink(doctor.Id);
        cDocLink.LinkedEntityId = gateScanner.id;
        cDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;
        insert cDocLink;
        gateScanner.Status__c = 'Scanning passed';
        update gateScanner;
       	Test.stopTest();
    }
}