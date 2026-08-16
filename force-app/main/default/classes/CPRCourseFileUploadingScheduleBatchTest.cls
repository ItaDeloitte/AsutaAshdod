/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * * CPR Course Files Schedule Batch Test Apex class
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-11-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public with sharing class CPRCourseFileUploadingScheduleBatchTest {

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
    static void batchTest() {
        Test.setMock(HttpCalloutMock.class, new ws_UploadCPRCourseFileToTafnit.ws_UploadCPRCourseFileToTafnitHttpMock());

        Test.startTest();
        Database.executeBatch(new CPRCourseFileUploadingScheduleBatch());
        Test.stopTest();
    }
}