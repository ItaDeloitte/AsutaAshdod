@isTest
private class UpdateDoctorsScheduleBatchTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor1.Status__c = 'פ';
        doctor1.Show_in_Docadvisor__c = true;
        insert doctor1;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Settlement__c settlement1 = TestDataFactory.getSettlement();
        settlement1.Area__c = 'תל אביב';
        insert settlement1;
        Settlement__c settlement2 = TestDataFactory.getSettlement();
        settlement2.Area__c = 'רמלה';
        insert settlement2;
        Settlement__c settlement3 = TestDataFactory.getSettlement();
        settlement3.Area__c = 'אשקלון';
        insert settlement3;
        Settlement__c settlement4 = TestDataFactory.getSettlement();
        settlement4.Area__c = 'חיפה';
        insert settlement4;
        Site__c site1 = TestDataFactory.getSite(TestDataFactory.SITE_CODE, calendar.Id);
        site1.Settlement__c = settlement1.Id;
        site1.Site_Code__c = '33';
        insert site1;
        Clinic__c clinic1 = new Clinic__c(Name = 'test', Site__c = site1.Id, clinic_email__c = 'example@gmail.com'); 
        clinic1.Settlement__c = settlement2.Id;
        insert clinic1;
        Site__c site2 = TestDataFactory.getSite(TestDataFactory.SITE_CODE, calendar.Id);
        site2.Settlement__c = settlement3.Id;
        insert site2;
        Clinic__c clinic2 = new Clinic__c(Name = 'test', Site__c = site2.Id, clinic_email__c = 'example@gmail.com'); 
        clinic2.Settlement__c = settlement4.Id;
        insert clinic2;    
        insert new Doctor_in_Clinic__c(Clinic__c = clinic1.Id, Doctors__c = doctor1.Id, Email__c = 'example@gmail.com', Schedule_System__c = 'QFlow');
        insert new Doctor_in_site__c(Site__c = site1.Id, Account__c = doctor1.Id);
        insert new Doctor_in_Clinic__c(Clinic__c = clinic2.Id, Doctors__c = doctor1.Id, Email__c = 'example@gmail.com', Schedule_System__c = 'QFlow');
        insert new Doctor_in_site__c(Site__c = site2.Id, Account__c = doctor1.Id);
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(new UpdateDoctorsScheduleBatch());
        Test.stopTest();
    }
}