// Created: Evgeniy Kravchuk
// Date: 29.10.2019
// Test for: LC_BackendUtils
@IsTest
private class LC_BackendUtilsTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
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
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Accession_Number__c = 'Q12334';
        insert appt;
        Scheduler_parameters__c schParameters = TestDataFactory.getSchParameter(procedure.Id, domain.Id);
        schParameters.Action_Type__c = 'מניעת זימון';
        insert schParameters;
        Related_document__c relatedDoc = TestDataFactory.getRelatedDoc(procedure.Id, '84');
        insert relatedDoc;
    }

    @IsTest
    static void callCancelInAnsembleTest() {
        User u = TestDataFactory.getUser([SELECT Name FROM Profile LIMIT 1].Name);

        Test.startTest();
        System.runAs(u) {
            LC_BackendUtils.callCancelInAnsemble([SELECT Id, Accession_Number__c, Canceled_reason__c, Appointment_Date_Time__c, Duration__c, Medical_Procedure__c, Medical_Procedure__r.Name, Medical_Procedure__r.Procedure_Code__c, Calendar__c, Calendar__r.ServiceId__c, SourceSystem__c FROM Appointment__c]);
        }
        Test.stopTest();
    }

    @IsTest
    static void getSetAppointmentRequestTest() {
        User u = TestDataFactory.getUser([SELECT Name FROM Profile LIMIT 1].Name);
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];
        Account acct = [SELECT ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        ws_AppointmentNew.CalenderSlot slot = new ws_AppointmentNew.CalenderSlot();
        slot.StartTime = Datetime.now();
        slot.procedureCode = '147';
        slot.ModalityCode = 2;
        slot.Duration = 30;
        slot.SlotId = 0;

        Test.startTest();
        System.runAs(u) {
            LC_BackendUtils.getSetAppointmentRequest(slot, acct.ID_Number__c, acct.ID_Type__c, appt.Id, null, '2');
        }
        Test.stopTest();
    }

    @IsTest
    static void getAccountByPassportTest() {
        Account acctSF = [SELECT ID_Number__c, ID_Type__c FROM Account LIMIT 1];

        Test.startTest();
        try {
            LC_BackendUtils.getAccountByPassport('idNumber', 'idType');
        } catch (Exception e) {
            System.assertEquals('There is no account in sf (ID_Number__c = \'idNumber\', ID_Type__c = \'idType\')', e.getMessage());
        }
        LC_BackendUtils.getAccountByPassport(acctSF.ID_Number__c, acctSF.ID_Type__c);
        Test.stopTest();
    }

    @IsTest
    static void getUserForEnsembleTest() {
        User u = TestDataFactory.getUser([SELECT Name FROM Profile LIMIT 1].Name);

        Test.startTest();
        System.runAs(u) {
            LC_BackendUtils.getUserForEnsemble(26);
        }
        Test.stopTest();
    }

    @IsTest
    static void sendEmailAlertTest() {
        Test.startTest();
        try {
            LC_BackendUtils.sendEmailAlert(new List<Medical_Aid_Appointment__c>{new Medical_Aid_Appointment__c()});
        } catch (Exception e) {}
        Test.stopTest();
    }

    @IsTest
    static void getPatientAccountDataTest() {
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        
        Test.startTest();
        try {
            LC_BackendUtils.getPatientAccountData('idNumber', 'idType');
        } catch (Exception e) {
            System.assertEquals('There is no account in sf (ID_Number__c = \'idNumber\', ID_Type__c = \'idType\')', e.getMessage());
        }
        LC_BackendUtils.getPatientAccountData(patient.ID_Number__c, patient.ID_Type__c);
        Test.stopTest();
    }

    @IsTest
    static void throwEnsembleErrorTest() {
        Test.startTest();
        try {LC_BackendUtils.throwEnsembleError('error description');} catch (Exception e) {}
        ws_AppointmentNew.Result result = new ws_AppointmentNew.Result();
        result.ErrorCode = '1';
        result.ErrorDescription = 'test';
        try {LC_BackendUtils.throwEnsembleError(result, '2');} catch (Exception e) {}
        try {LC_BackendUtils.wrapEnsembleError(result, '2');} catch (Exception e) {}
        ws_AppointmentNew.Error error = new ws_AppointmentNew.Error();
        error.ErrorCode = '1';
        error.ErrorMessage = 'test';
        try {LC_BackendUtils.throwEnsembleError(new List<ws_AppointmentNew.Error>{error}, '2');} catch (Exception e) {}
        Test.stopTest();
    }

    @IsTest
    static void getPatientEmailTest() {
        Account patient = [SELECT ID_Type__c, ID_Number__c FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];

        Test.startTest();
        try {
            LC_BackendUtils.getPatientEmail('idNumber', 'idType');
        } catch (Exception e) {
            System.assertEquals('There is no account in sf (ID_Number__c = \'idNumber\', ID_Type__c = \'idType\')', e.getMessage());
        }
        LC_BackendUtils.getPatientEmail(patient.ID_Number__c, patient.ID_Type__c);
        Test.stopTest();
    }
}