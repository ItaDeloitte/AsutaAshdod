@isTest
private class SendSMSHandlerTest {

    @testSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.Appointment_Date__c = Date.today();
    	insert appt;


        List<SmsTemplate__c> smsTemp = new List<SmsTemplate__c>();       
        smsTemp.add(TestDataFactory.getSmsTemplate());
        smsTemp.add(TestDataFactory.getSmsTemplate('General_Reminder', 'site__r.Name,day_date_hour__c', 'שלום רב, נקבע לך תור לבדיקה שתתקיים ב{0}. בתאריך {1}. יש להצטייד בת.ז. '));
        smsTemp.add(TestDataFactory.getSmsTemplate('IVR_Set_Appointment', null, 'להמשך זימון תור ל CT , MRI , PET CT ובריאות השד, יש ללחוץ על הקישור https://appointment.assutaashdod.co.il/'));
        smsTemp.add(TestDataFactory.getSmsTemplate('Mammography_Reminder_One', 'Patient_Account__r.FirstName,day_date_hour__c,formtitan_arrival_link__c', 'שלום {0}, להזכירך , נקבע לך תור שיתקיים  בתאריך {2}. לאישור הגעה יש להיכנס ללינק הבא: {3} בברכה , אסותא'));
        insert smsTemp;        
    }

    @isTest
    static void handleOutgoingSMSTest() { 
        Test.setMock(WebServiceMock.class, new OutboundSMSMock());
        Test.startTest();
        insert new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', Template_Text__c = 'CheckIn_Digital' + ',' + 'Test');
        Test.stopTest();
    }

    @isTest
    static void handleOutgoingSMSErrorEmailTest() {
        Test.startTest();
        insert new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', Template_Text__c = 'CheckIn_Digital' + ',' + 'Test');
        Test.stopTest();
    }

    @isTest
    static void editContentFieldBySmsTemplateTest() {
        Id appId = [SELECT Id FROM Appointment__c LIMIT 1].Id;
        Test.startTest();
        List<SMS__c> sms = new List<SMS__c>();
        sms.add(new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', smsTemplate__c = 'new_appointment', Appointment__c = appId));
        sms.add(new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', smsTemplate__c = 'IVR_Set_Appointment', Appointment__c = appId));
        sms.add(new SMS__c(Type__c = 'Outgoing', Phone_Number__c = '12345', smsTemplate__c = 'Mammography_Reminder_One', Appointment__c = appId));
        insert sms;
        Test.stopTest();
    }
   
}