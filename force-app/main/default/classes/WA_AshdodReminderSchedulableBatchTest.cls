// Test for: WA_AshdodReminderSchedulableBatch
@isTest
private class WA_AshdodReminderSchedulableBatchTest {

    @testSetup
    static void setup() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();
        
        cData.domain.DomainReminderCode__c = '12345';
        update cData.domain;

        cData.calendar.ReminderId__c = '12345';
        update cData.calendar;

        cData.site.Code_Tizkurit__c = '12345';
        cData.site.Site_Code__c = '33';
        update cData.site;

        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.SMS_Phone_Number__c = '0999845467';
        insert cas;
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        procedure.Reminder_required__c = true;
        procedure.SMS_Reminder__c = '1';
        procedure.Procedure_Code__c='53.0';
        insert procedure;
    
        List<Appointment__c> appts = new List<Appointment__c>();
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_status__c = 'אין מענה';
        appt.Remainder_time__c = Date.today();
        appt.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt.Date_for_tizkorit_reminder__c = Date.today();
        appt.Date_for_human_reminder__c = Date.today();
        appt.appointment_hour__c = appt.Appointment_Date_Time__c.time();
        appt.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appts.add(appt);                
        
        Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        procedure2.Reminder_required__c = true;
        procedure2.SMS_Reminder__c = '1';
        procedure2.Procedure_Code__c='760907';
        insert procedure2;
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure2.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Site__c = site.Id;
        appt2.PayerFactor__c = pFactor.Id;
        appt2.Accession_Number__c = 'Q12346';
        appt2.Remainder_status__c = 'אין מענה';
        appt2.Remainder_time__c = Date.today();
        appt2.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt2.Date_for_tizkorit_reminder__c = Date.today();
        appt2.Date_for_human_reminder__c = Date.today();
        appt2.appointment_hour__c = appt.Appointment_Date_Time__c.time();
        DateTime todayPlus3Days = date.today().adddays(+3);
        appt2.Appointment_Date_Time__c = todayPlus3Days;
        appt2.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appts.add(appt2);        

        Medical_Procedure__c procedure3 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        procedure3.Reminder_required__c = true;
        procedure3.SMS_Reminder__c = '1';
        procedure3.Procedure_Code__c= '99153';
        procedure3.Telemedicine_Action__c = true;
        insert procedure3;
        
        Appointment__c appt3 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure3.Id, patient.Id, calendar.Id, cas.Id);
        appt3.Site__c = site.Id;
        appt3.PayerFactor__c = pFactor.Id;
        appt3.Accession_Number__c = 'Q12346';
        appt3.Remainder_status__c = 'אין מענה';
        appt3.Remainder_time__c = Date.today();
        appt3.Time_of_Tizkorit__c = Time.newInstance(1, 0, 0, 0);
        appt3.Date_for_tizkorit_reminder__c = Date.today();
        appt3.Date_for_human_reminder__c = Date.today();
        appt3.appointment_hour__c = appt.Appointment_Date_Time__c.time();        
        appt3.Appointment_Date_Time__c = date.today().adddays(+2);
        appt3.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appts.add(appt3); 
        insert appts;
        
        SmsTemplate__c smsTemp1 = TestDataFactory.getSmsTemplate('Mammography_Reminder_Three_Ashdod', 'site__r.Name,day_date_hour__c', 'test{0}');
        insert smsTemp1;

        SmsTemplate__c smsTemp2 = TestDataFactory.getSmsTemplate('General_Reminder_Institutes', 'site__r.Name,day_date_hour__c', 'test{0}');
        insert smsTemp2;

        SMSReminder__c smsReminder = TestDataFactory.getSMSReminder(procedure3.Id, smsTemp2.Id);
        smsReminder.Site__c = '33'; 
        insert smsReminder;

        SMSReminder__c smsReminder2 = TestDataFactory.getSMSReminder(procedure2.Id, smsTemp2.Id);
        smsReminder2.Site__c = '33';
        smsReminder2.SiteType__c = 'Public';
        smsReminder2.SMSVersion__c = '0;1;2;3'; 
        insert smsReminder2;
    }

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(
            new WA_AshdodReminderSchedulableBatch(
                'SELECT Id'
                      + ', IDNumber__c'
                      + ', doc_from_try__c'
                      + ', link_memo_text__c'
                      + ', Remainder_type__c'
                      + ', AppointmentTime__c'
                      + ', day_date_hour__c'                       
                      + ', formtitan_arrival_link__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', Days_Until_Appointment__c'
                      + ', RecordType.DeveloperName'
                      + ', Site__c'
                      + ', Site__r.Name'
         			  + ', Site__r.Site_Code__c'
                      + ', Clinic__r.Name'
                      + ', Case__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Patient_Account__r.Number_not_Kosher__c'                      
                      + ', Patient_Account__r.AshdodPreferredChannel__c'
                      + ', Medical_Procedure__r.Procedure_Code__c'                                         
                + ' FROM Appointment__c'
            )
        );
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job WA', '20 30 8 10 2 ?', new WA_AshdodReminderSchedulableBatch());
        Test.stopTest();
    }
}