@isTest
private class WA_SendingBarcodeIdentifyScheduleTest {

    @testSetup
    static void setupData() {
        TestDataFactory.CommonData cData = TestDataFactory.insertCommonData();
        Payer_Factor__c pFactor = [SELECT Id FROM Payer_Factor__c WHERE InsuranceCode__c = :TestDataFactory.PFACTOR_CODE];
        Account patient = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];
        patient.PersonBirthdate = Date.today().addYears(-19);
        update patient;
        Account doctor = [SELECT Id FROM Account WHERE ID_Number__c = :TestDataFactory.D_ID_NUMBER];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        cas.SMS_Phone_Number__c = '0999845467';
        insert cas;
        Domain__c domain = [SELECT Id FROM Domain__c LIMIT 1];
        domain.BarcodeIdentifyPatient__c = true;
        update domain;
        
        Sub_Expertise__c subExpertise = [SELECT Id FROM Sub_Expertise__c LIMIT 1];
        Calendar__c calendar = [SELECT Id FROM Calendar__c LIMIT 1];
        Site__c site = [SELECT Id FROM Site__c LIMIT 1];       
        site.BarcodeIdentifyPatient__c = true;
        update site;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);        
        insert procedure;

        Account acc = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        acc.SMS_Phone_Number__c = '05-1234567';
        insert acc;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.sendingByWhatsApp__c = true;
        appt.SendingMessage__c  = true;
        appt.Appointment_Date_Time__c = system.now();
        appt.BarcodeIdentifyTime__c = System.now().addHours(-3);
        insert appt;    
    }

    /*@isTest
    static void testBatchExecution() {
        Account patient = [SELECT Id, PersonBirthdate, Age_Number__c, SMS_Phone_Number__c   FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER LIMIT 1];
        System.debug('patient1 '+ patient.Age_Number__c );
        System.debug('patient2 '+ patient.PersonBirthdate );
        System.debug('patient3 '+ patient.SMS_Phone_Number__c );
        Appointment__c appt = [SELECT Id, sendingByWhatsApp__c, SendingMessage__c,  Appointment_Date_Time__c, Patient_Account__r.SMS_Phone_Number__c, Patient_Account__r.Age_Number__c, BarcodeIdentificationSent__c, BarcodeIdentifyTime__c, Appointment_Status__c  FROM Appointment__c LIMIT 1];
        System.debug('appt '+ appt);
        System.debug('appt.Patient_Account__r.Age_Number__c '+ appt.Patient_Account__r.Age_Number__c);
        System.debug('appt.BarcodeIdentifyTime__c '+ appt.BarcodeIdentifyTime__c);
        System.debug('appt.Patient_Account__r.SMS_Phone_Number__c '+ appt.Patient_Account__r.SMS_Phone_Number__c);
        Test.startTest();        
        WA_SendingBarcodeIdentifySchedule batch = new WA_SendingBarcodeIdentifySchedule();
        Database.executeBatch(batch, 1);
        Test.stopTest();
       
        Appointment__c updated = [SELECT Id, BarcodeIdentificationSent__c 
                                    FROM Appointment__c 
                                    WHERE sendingByWhatsApp__c = true 
                                    LIMIT 1];
        System.assertEquals(true, updated.BarcodeIdentificationSent__c, 'BarcodeIdentificationSent__c is true');
    }

    @isTest
    static void testSchedulableExecute() {
        Test.startTest();
        WA_SendingBarcodeIdentifySchedule sched = new WA_SendingBarcodeIdentifySchedule();
        sched.execute((SchedulableContext)null);
        Test.stopTest();
    } */  
    
    @isTest
    static void batchTest() {
        System.debug('batch test');
        Test.startTest();
        WA_SendingBarcodeIdentifySchedule batch = new WA_SendingBarcodeIdentifySchedule();
        Database.executeBatch(batch, 25); 
        Test.stopTest();      
    }

    
}