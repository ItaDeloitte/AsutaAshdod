@isTest
private class CommitmentReminderScheduleBatchTest {
    
    @TestSetup
    static void makeData() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();

        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        pFactor.Name = 'לאומית';
        update pFactor;
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
        insert procedure;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Date.today();        
        appt.Appointment_Status__c = 'בטיפול אדמיניסטרטיבי';                
        appt.hitchayvut_was_recieved__c = false;  
        appt.SendDate4DaysBefore__c = Date.today();
        //appt.PayerFactor__c = pFactor.Id;    
        insert appt;        
    }              

    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        Database.executeBatch(new CommitmentReminderScheduleBatch());
        Test.stopTest();
    }

    @isTest
    static void scheduleTest() {
        System.debug('schedule test');
        Test.startTest();
        System.schedule('Test Job Commitment Reminder', '20 30 8 10 2 ?', new CommitmentReminderScheduleBatch());
        Test.stopTest();
    }
}