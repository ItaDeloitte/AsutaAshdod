//Created by Ortal k.
@isTest
public class ws_TizkuritTest {

    @testSetup
    static void testSetup() {
        insert TestDataFactory.getENV();
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        con.Birthdate = Date.today();
        insert con;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        domain.DomainReminderCode__c = '12345';
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '99400');
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.ReminderId__c = '12345';
        insert calendar;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PROCEDURE_CODE);
        pFactor.Code_Payer_Tizkurit__c = '12345';
        insert pFactor;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        site.Code_Tizkurit__c = '12345';
        insert site;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_E_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Time_of_Tizkorit__c = Time.newInstance(12, 13, 00, 00);
        appt.Date_for_tizkorit_reminder__c = Date.today();
        appt.Appointment_Date_Time__c = DateTime.now();
        appt.Accession_Number__c = 'Q8522059';
        appt.Remainder_status__c = 'אין מענה';
        appt.PayerFactor__c = pFactor.Id;
        appt.Site__c = site.Id;
        insert appt;

        Reminder__c reminder = TestDataFactory.getReminder(appt.Id);
        insert reminder;

        User user = TestDataFactory.getUser('System Administrator');
        System.runAs(user) {
            reminder.Reminder_Status__c = '3';
            update reminder;
        }
    }
    
    @isTest
    static void UpdateIsReminderFieldTest() {
        Id reminderId = [SELECT Id FROM Reminder__c LIMIT 1].Id;
        String jsonMsg = '{"methodName":"updateIsReminderField","reminderIds":"' + reminderId + ',' + reminderId + '"}';
         
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Reminder__c';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ws_Tizkurit.getJsonFromEnsemble();
        Test.StopTest();   
    }

    @isTest
    static void UpdateReminderObjTest() {
        String accessionNumber = [SELECT Id, Accession_Number__c FROM Reminder__c LIMIT 1].Accession_Number__c;
        String jsonMsg = '{"methodName":"UpdateReminderObj","records":[{"accessionNumber":"' + accessionNumber + '","followUpTypeCode":"9","numOfDialTries":"3","timeOfCallTry":"12:00:00",' +
        '"dateOfCallTry":"2019-07-23"},{"accessionNumber":"' + accessionNumber + '","followUpTypeCode":"10","numOfDialTries":"4","timeOfCallTry":"13:00:00","dateOfCallTry":"2019-07-23"}]}';
         
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Reminder__c';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ws_Tizkurit.getJsonFromEnsemble();
        Test.StopTest();
    }

    @isTest
    static void UpdateReminderObjTestWithError() {
        String accessionNumber = [SELECT Id, Accession_Number__c FROM Reminder__c LIMIT 1].Accession_Number__c;
        String jsonMsg = '{"methodName":"UpdateReminderObj","records":[{"accessionNumber":"' + accessionNumber + '","followUpTypeCode":"error","numOfDialTries":"3","timeOfCallTry":"12:00:00",' + 
        '"dateOfCallTry":"2019-07-23"},{"accessionNumber":"' + accessionNumber + '","followUpTypeCode":"10","numOfDialTries":"4","timeOfCallTry":"13:00:00","dateOfCallTry":"2019-07-23"]}';
         
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Reminder__c';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);

        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ws_Tizkurit.getJsonFromEnsemble();
        Test.StopTest();
    }
}