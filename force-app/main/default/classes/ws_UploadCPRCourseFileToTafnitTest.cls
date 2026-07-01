/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * {PostFiles} REST Apex Test
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-11-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
private with sharing class ws_UploadCPRCourseFileToTafnitTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.DataBuilder dBuilder = TestDataFactory.buildCommonData();
        dBuilder.initCommonData();

        insert new File__c(
            RecordTypeId = SObjectType.File__c.getRecordTypeInfosByDeveloperName().get('DoctorsFiles').getRecordTypeId(),
            DoctorName__c = dBuilder.doctor.Id,
            Approved_date__c = Date.today(),
            DocDateBegin__c = Date.today(),
            DocDateEnd__c = Date.today(),
            IsApproved__c = true,
            file_type__c = '36');
    }

    @IsTest
    static void postFilesTest() {
        Test.setMock(HttpCalloutMock.class, new ws_UploadCPRCourseFileToTafnit.ws_UploadCPRCourseFileToTafnitHttpMock());

        File__c file = [
            SELECT Remarks__c
                 , file_type__c
                 , DocDateEnd__c
                 , DocDateBegin__c
                 , FileExtension__c
                 , is_succeed_CPR_Tafnit__c
                 , Case__r.Approval_Topic__c
                 , Case__r.Approval_Sub_Topic__c
                 , DoctorName__r.Doctor_Code__c
                 , (SELECT ContentDocumentId
                      FROM ContentDocumentLinks)
              FROM File__c
             WHERE RecordType.DeveloperName = 'DoctorsFiles'
               AND file_type__c = '36'
               AND IsApproved__c = true
               AND is_succeed_CPR_Tafnit__c = false
               AND Approved_date__c = LAST_N_DAYS:6
             LIMIT 1];

        Test.startTest();
        ws_UploadCPRCourseFileToTafnit.postFiles(file.DoctorName__r.Doctor_Code__c, new List<File__c>{file});
        Test.stopTest();
    }
}