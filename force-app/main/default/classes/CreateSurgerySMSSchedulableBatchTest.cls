@isTest
public class CreateSurgerySMSSchedulableBatchTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();

        cData.domain.DomainReminderCode__c = '12345';
        update cData.domain;

        cData.calendar.ReminderId__c = '12345';
        update cData.calendar;

        cData.site.Code_Tizkurit__c = '12345';
        update cData.site;

        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.SMS_Phone_Number__c = '0999845467';
        insert cas;
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        domain.ReferenceDigitalLobby__c = true;
        update domain;
        
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        procedure.Reminder_required__c = true;
        procedure.SMS_Reminder__c = '1';
        procedure.Procedure_Code__c='53.0';
        insert procedure;

        Account acc = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        acc.SMS_Phone_Number__c = '05-1234567';
        insert acc;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.sendingByWhatsApp__c = true;
        appt.SendingMessage__c  = true;
        appt.Patient_Account__C = acc.Id;
        insert appt;
    }

    @isTest
    public static void batchTest() {
        Test.startTest();
        String query = 'SELECT Id, Case__c, Patient_Account__r.Phone, sendingByWhatsApp__c, SendingMessage__c, Patient_Account__r.SMS_Phone_Number__c FROM Appointment__c';
        Database.executeBatch(new CreateSurgerySMSSchedulableBatch(query));
        Test.stopTest();
    }
}