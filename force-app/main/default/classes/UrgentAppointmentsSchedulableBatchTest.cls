@isTest
private class UrgentAppointmentsSchedulableBatchTest {
    
    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();    
        Test.setMock(HttpCalloutMock.class, new ws_RisRemarksTest.updateRemark_Mock());
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);        
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);        
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);       
        procedure.Confidentiality__c = false;
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);        
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);       
        insert site;       
		
        List<Appointment__c> appointments = new List<Appointment__c>();
        Appointment__c appt1 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);         
        insert appt1;
        appt1.UrgentApptSaveSlot__c = true;
        update appt1;
      	
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Appointment_Date_Time__c = Date.today().addDays(3);
        appt2.Is_Urgent__c = true;
        appt2.UrgentReason__c = '10';
        appt2.UrgentApptStatus__c = 'NotEarly';
        appt2.UrgentAppointment__c = appt1.Id;
        appointments.add(appt2);
        
        Appointment__c appt3 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt3.Appointment_Date_Time__c = Date.today().addDays(5);
        appt3.Is_Urgent__c = true;
        appt3.UrgentReason__c = '2';
        appt3.UrgentApptStatus__c = 'Unsubscribe';
        appt3.UrgentAppointment__c = appt1.Id;
        appointments.add(appt3);
        
        Appointment__c appt4 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt4.Appointment_Date_Time__c = Date.today().addDays(6);
        appt4.Is_Urgent__c = true;
        appt4.UrgentReason__c = '3';
        appt4.UrgentApptStatus__c = 'MessSent';
        appt4.UrgentApptMessageDate__c = Datetime.now().addMinutes(-30);
        appt4.UrgentAppointment__c = appt1.Id;
        appointments.add(appt4);
        
        Appointment__c appt5 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt5.Appointment_Date_Time__c = Date.today().addDays(30);
        appt5.Is_Urgent__c = true;    
        appt5.UrgentReason__c = '4';
        appt5.UrgentAppointment__c = appt1.Id;
        appointments.add(appt5);
        
        Appointment__c appt6 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt6.Appointment_Date_Time__c = Date.today().addDays(50);        
        appt6.Is_Urgent__c = true;         
        appt6.UrgentReason__c = '4';       
        appointments.add(appt6);        
        insert appointments;
      
        SmsTemplate__c smsTemp = TestDataFactory.getSmsTemplate('WaitingListApptProposalSMS', 'Patient_Account__r.FirstName,UrgentApptTitanLink__c', '{1} שלום {0},בהמשך לבקשתך להירשם ברשימת ההמתנה, ברצוננו לעדכן כי התפנה עבורך תור במועד קרוב יותר.תור זה יישמר עבורך למשך 15 דקות ממועד קבלת הודעה זו');
        insert smsTemp; 
    }
    
 
    @isTest
    static void testBatchableFlow() {
        System.debug('test Batchable Flow');
        List<Appointment__c> appts = [ SELECT Id FROM Appointment__c];
        System.assert(!appts.isEmpty(), 'one or more appointment for Batch'); 
        Test.startTest();
        Database.executeBatch(new UrgentAppointmentsSchedulableBatch());
        Test.stopTest();
    } 
    
    @isTest
    static void testSchedulable() {
        Test.startTest();
        String cron = '0 0 0 1 1 ? 2099'; 
        System.schedule('TestUrgentAppointmentsSchedulableBatch', cron, new UrgentAppointmentsSchedulableBatch());
        Test.stopTest();
    }          
}