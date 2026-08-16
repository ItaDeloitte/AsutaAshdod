@IsTest
private class CreateSurveyToAppScheduleBatchTest {

    @TestSetup
    static void setupData() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();

        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
        insert procedure;
        Survey__c survey =  TestDataFactory.getSurvey();
        insert survey;
        ConsentForm__c consentForm = TestDataFactory.getConsentForm();
        insert consentForm;
        Medical_Procedure_in_Sites__c medPInSite = new Medical_Procedure_in_Sites__c(Medical_Procedure__c = procedure.Id, 
                                                                                    Site__c = site.Id, 
                                                                                    DigitalSignConsentForm__c = consentForm.Id,
                                                                                    DigitalSignConsentForm1__c = consentForm.Id,
                                                                                    Digital_Survey1__c = survey.Id);
        insert medPInSite;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Site__c = site.Id;
        appt.PayerFactor__c = pFactor.Id;
        appt.appointment_hour__c = appt.Appointment_Date_Time__c.time();
        appt.Appointment_Status__c = 'וידוא הגעה לפגישה';
        insert appt;
    }

    // --------------------------------------------------
    // Batch execution test
    // --------------------------------------------------
   @IsTest
    static void testScheduleExecution() {                
        Test.startTest();
        ConsentForm__c consentForm = [SELECT Id FROM ConsentForm__c LIMIT 1];              
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];      
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];       
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        Medical_Procedure_in_Sites__c medPInSite = new Medical_Procedure_in_Sites__c(Medical_Procedure__c = procedure.Id, 
                                                                                    Site__c = site.Id, 
                                                                                    DigitalSignConsentForm__c = consentForm.Id,
                                                                                    DigitalSignConsentForm1__c = consentForm.Id,
                                                                                    Digital_Survey1__c = survey.Id);
        String cron = '0 0 12 * * ?';
        System.schedule(
            'CreateSurveyToAppSchedule_Test',
            cron,
            new CreateSurveyToAppSchedule()
        );
        Test.stopTest();
    }

       

    // --------------------------------------------------
    // Schedulable execution test
    // --------------------------------------------------
   
    @IsTest
    static void testBatchExecutio() {       
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];        
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];       
        Medical_Procedure__c procedure = [SELECT Id FROM Medical_Procedure__c LIMIT 1];
        
        Test.startTest();
        Database.executeBatch(
            new CreateSurveyToAppScheduleBatch(
                site.Id,
                procedure.Id,
                survey.Id
            ),
            1
        );
        Test.stopTest();
        System.assert(true, 'Batch executed successfully');    
    }
}