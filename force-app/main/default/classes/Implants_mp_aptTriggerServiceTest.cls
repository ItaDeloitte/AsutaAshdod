@isTest
private class Implants_mp_aptTriggerServiceTest {
    @testSetup
    static void setup() {
        Account doctor1 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor1.Picture__c = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        doctor1.Picture_URL__c = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';
        doctor1.Doctor_Code__c = '0012661';
        doctor1.Experts_center__c = true;
        Account doctor2 = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor2.Picture__c = '<p><img src="https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&amp;feoid=00N8E000001loA3&amp;refid=0EM8E0000000sZy" alt="emergency_operation_surgery_medical_execution_doctor_knife_cooking_treatment-512.png"></img></p>';
        doctor2.Picture_URL__c = 'https://assuta--dev--c.documentforce.com/servlet/rtaImage?eid=0018E00001BSMTP&feoid=00N8E000001loA3&refid=0EM8E0000000qtL';
        doctor2.ID_Number__c = '999657950';
        doctor2.Doctor_Code__c = '0012662';
        doctor2.Experts_center__c = true;
        insert new List<Account>{doctor1, doctor2};
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.ID_Number__c = '852986371';
        patient.Asthma__c = 'כן';
        patient.PersonBirthdate = Date.valueOf('1980-10-10');
        insert patient;

        Medical_Procedure__c ultrasound = new Medical_Procedure__c(Procedure_Code__c = '760904');
        insert ultrasound;
        Calendar__c calendar = TestDataFactory.getCalendar('test');
        insert calendar;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('1');
        insert pFactor;
        Agreement__c agreement = TestDataFactory.getAgreement(doctor1.Id, pFactor.Id);
        agreement.Type_of_agreement__c = 'Surgery';
        insert agreement;
        Contact con = TestDataFactory.getContact(doctor1.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor1.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;
    }
    
    @isTest
    static void calculateImplantsForApp () {
        Account patient = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Payer_Factor__c payer =  [SELECT Id FROM Payer_Factor__c LIMIT 1];
       
        Appointment__c app = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        app.PayerFactor__c = payer.Id;
        app.Agreement_with_assuta__c = 'Y';
        insert app;
        
        Appointment__c appWithFormula = [SELECT Id, Help_Parent_Code_in__c, Agreement_with_assuta__c, implantsMinPrice__c, implantsMaxPrice__c 
                                        FROM Appointment__c WHERE ID = :app.Id];
        Implants_mp_apt__c implant1 = TestDataFactory.getImplantMpApt(appWithFormula.Id);
        Implants_mp_apt__c implant2 = TestDataFactory.getImplantMpApt(appWithFormula.Id);
        Test.startTest();
        insert new List<Implants_mp_apt__c>{implant1, implant2};
        Appointment__c appResult = [SELECT Id, Help_Parent_Code_in__c, Agreement_with_assuta__c, implantsMinPrice__c, implantsMaxPrice__c 
                                        FROM Appointment__c WHERE ID = :appWithFormula.Id];
        System.assertEquals(40, appResult.implantsMinPrice__c);
        System.assertEquals(100, appResult.implantsMaxPrice__c);
        Test.stopTest();
    }
}