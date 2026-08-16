@isTest
public class WA_AshdodColonoscopySchedulableBatchTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();        
        cData.site.Site_Code__c = '33';
        update cData.site;

        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);        
        insert cas;

        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        
        
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);        
        procedure.Colonoscopy1DayBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.Colonoscopy2DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.Colonoscopy3DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.Colonoscopy4DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.ColonoscopyKid2DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.ColonoscopyKid3DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.ColonoscopyParent2DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure.ColonoscopyParent3DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        insert procedure;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Date.today();
        appt.SendDate4DaysBefore__c = Date.today();
        appt.SendDate3DaysBefore__c = Date.today();
        appt.SendDate2DaysBefore__c = Date.today();
        appt.SendDate1DayBefore__c = Date.today();
        appt.Site__c = site.Id;
        insert appt;
		
		Medical_Procedure__c procedure2 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '760904');       
        procedure2.Colonoscopy1DayBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.Colonoscopy2DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.Colonoscopy3DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.Colonoscopy4DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.ColonoscopyKid2DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.ColonoscopyKid3DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.ColonoscopyParent2DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        procedure2.ColonoscopyParent3DaysBeforeLink__c = 'https://www.youtube.com/watch?v=K6-VUULklPE&list=RDCMUCTzF0VQiCXsZ_41fjVuX7UA&index=7';
        insert procedure2;  
        
        Appointment__c appt2 = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure2.Id, patient.Id, calendar.Id, cas.Id);
        appt2.Appointment_Date_Time__c =  Date.today().addDays(2);
        appt2.SendDate4DaysBefore__c = Date.today();
        appt2.SendDate3DaysBefore__c = Date.today();
        appt2.SendDate2DaysBefore__c = Date.today();
        appt2.SendDate1DayBefore__c = Date.today();
        appt2.Site__c = site.Id;
        insert appt2;
    }    

    @isTest
    static void testBatchExecution() {
        Test.startTest();              
        WA_AshdodColonoscopySchedulableBatch batch = new WA_AshdodColonoscopySchedulableBatch();
        Database.executeBatch(batch, 50);
        Map<Integer, String> templateByDay = WA_AshdodColonoscopySchedulableBatch.getTemplateByDay(true);
        Test.stopTest();
    }

    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        System.schedule('TestSchedulable', '0 0 18 * * ?', new WA_AshdodColonoscopySchedulableBatch());
        Test.stopTest();        
    }
}