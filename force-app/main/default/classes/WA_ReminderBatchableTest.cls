@IsTest
public class WA_ReminderBatchableTest {
    
    @TestSetup
    static void makeData() {        
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();
        
        cData.domain.sendingByWhatsApp__c = true;
        update cData.domain;

        cData.site.sendingByWhatsApp__c = true;
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
        procedure.remainder1WA__c = '1';
        procedure.remainder2WA__c = '1';
        procedure.Procedure_Code__c='53.0';
        procedure.Reminder_required__c = true;
        insert procedure;
    
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.Accession_Number__c = 'Q12345';
        appt.Remainder_status__c = 'אין מענה';
        appt.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appt.Appointment_Date_Time__c = date.today().adddays(+1); 
        appt.sendingByWhatsApp__c = true;
        appt.isRemainder1WAsent__c = false;
        appt.dateRemainder1WA__c = Date.today();
        insert appt;                
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Site__c = site.Id;
        appt2.PayerFactor__c = pFactor.Id;
        appt2.Accession_Number__c = 'Q123456';
        appt2.Remainder_status__c = 'אין מענה';               
        appt2.Appointment_Status__c = 'וידוא הגעה לפגישה';
        appt2.Appointment_Date_Time__c = System.now().addDays(1).addHours(3);
        appt2.sendingByWhatsApp__c = true;
        appt2.isRemainder1WAsent__c = false;
        appt2.dateRemainder1WA__c = Date.today();
        insert appt2;                 
    }

    @isTest
    static void firstReminderForBusDaySchedulableBatchTest() {
        System.debug('firstReminderForBusDaySchedulableBatchTest');
        Test.startTest();         
        Date currentDate = Date.today();        
        insert new Calendar1__c(Gregorian_Date__c = currentDate, business_day__c = true, Day__c = 'Friday', Weekend__c = false, Holiday__c = false, week_num__c = 12, Start_Time__c = Time.newInstance(13, 0,0,0), End_time__c = Time.newInstance(15, 0,0,0));
        String jobId = System.schedule('Test WA_FirstReminderSchedulableBatch job', '0 0 18 * * ?', new WA_FirstReminderSchedulableBatch());
        Test.stopTest();        
    }
    
    @isTest
    static void firstReminderForHolidaySchedulableBatchTest(){
        System.debug('firstReminderForHolidaySchedulableBatchTest');
        Test.startTest();
        Date currentDate = Date.today();        
        insert new Calendar1__c(Gregorian_Date__c = currentDate, business_day__c = true, Day__c = 'Friday', Holiday_Description__c = 'ערב בדיקה', Holiday__c = true, week_num__c = 12,  Start_Time__c = Time.newInstance(13, 0,0,0), End_time__c = Time.newInstance(15, 0,0,0));     
        String jobId = System.schedule('Test WA_FirstReminderSchedulableBatch job', '0 0 12 * * ?', new WA_FirstReminderSchedulableBatch());
        Test.stopTest();        
    }

    @isTest
    static void secondReminderSchedulableBatchTest() {
        System.debug('secondReminderSchedulableBatchTest');
        Test.startTest();
        String jobId = System.schedule('Test WA_SecondReminderSchedulableBatch job', '0 0 13 * * ?', new WA_SecondReminderSchedulableBatch());        
        Test.stopTest();
    }
    
    @isTest
    static void WA_ReminderWrapperTest () {
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Appointment__c appt = [SELECT Id FROM Appointment__c WHERE Accession_Number__c = 'Q123456'];
        Domain__c domain = [SELECT Id, DomainCode__c FROM Domain__c LIMIT 1];
        
        System.debug('WA_ReminderWrapper Test');
        Test.startTest();
        WA_ReminderWrapper Wrapper = new WA_ReminderWrapper(cas.Id, patient.Id, '', '', String.valueOf(domain.DomainCode__c), '', '', '', appt.Id, '', '', '', '', 'first', true, 'WA_ReminderBatchableTest');
        Test.stopTest();
    }
    
    @isTest
    static void WA_ReminderBatchableTest () {
        String query = 'SELECT Id'
                            + ', Site__c'                          
                            + ', Case__c'
                            + ', Calendar__c'                 
                            + ', First_Name__c'
                            + ', SMS_Address__c'
                            + ', Site__r.Name' 
                            + ', day_date_hour__c'
                            + ', Patient_Account__c'
                            + ', Medical_Procedure__c'
                            + ', preDateReminderWA__c'
                            + ', Domain__r.DomainCode__c'
                            + ', formtitan_arrival_link__c'  
                            + ', Exact_Location_In_Domain__c'                                                          
                            + ', Medical_Procedure_Marketing_Name__c'
                            + ', Patient_Account__r.SMS_Phone_Number__c' 
                            + ', Medical_Procedure__r.Virtual_Appointment__c '                                
                           + ' FROM Appointment__c';
        
        System.debug('WA_ReminderWrapper Test');
        Test.startTest();
        WA_ReminderBatchable batch = new WA_ReminderBatchable(query, 'Second');
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    
}