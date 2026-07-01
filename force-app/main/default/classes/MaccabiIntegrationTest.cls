@isTest
private class MaccabiIntegrationTest {

    @TestSetup
    static void prepareData() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;

        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);
		procedure.Reminder_required__c = true;
        procedure.SMS_Reminder__c = '0';
        insert procedure;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);
        insert site;
        Payer_Factor__c pFactorParent = TestDataFactory.getPFactor('333');
        pFactorParent.Insurance_Company__c = true;
        insert pFactorParent;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        pFactor.Name_of_parent__c = pFactorParent.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;
        Payer_Factor__c pFactorChild = TestDataFactory.getPFactor('333');
        pFactorChild.Name_of_parent__c = pFactor.Id;
        insert pFactorChild;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        insert calendar;

        Case cas = TestDataFactory.getCase(patient.Id, patient.Id, con.Id, pFactor.Id);
        cas.RecordTypeId = TestDataFactory.getRTId('Appointments', 'Case');
        insert cas;

        File__c file = TestDataFactory.getFile();
        file.ReferralNumber__c = '12345';
        file.file_type__c = 'Referral';
        file.Account__c = patient.Id;
        file.Case__c = cas.Id;
        insert file;

        Medical_Procedure__c mdP = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '70.5');
        mdP.Marketing_Procedure_Name__c = '';
        mdP.Name = '';
        insert mdP;
        Medical_Procedure__c mdP1 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '67.2');
        mdP1.Marketing_Procedure_Name__c = '';
        mdP1.Name = '';
        insert mdP1;
        Medical_Procedure__c mdP2 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '68.25');
        mdP2.Marketing_Procedure_Name__c = '';
        mdP2.Name = '';
        insert mdP2;
        Medical_Procedure__c mdP3 = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '10');
        mdP3.Marketing_Procedure_Name__c = '';
        mdP3.Name = '';
        insert mdP3;

        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_S_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Status__c = 'WaitingForAppointment';
        appt.Medical_Procedure_Text__c = 'test';
        appt.PayerFactor__c = pFactorChild.Id;
        appt.Accession_Number__c = '234567';
        appt.Doctor_Account__c = doctor.Id;
        appt.Name = 'Appointment app1234';
        appt.Calendar_Text__c = 'test';
        appt.Site_Text__c = 'test';
        appt.Site__c = site.Id;
        insert appt;
    }

    @isTest
    static void testRetServiceReferrals() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRetrievingServiceRef_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c FROM Appointment__c LIMIT 1];
        Id patientId = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].Id;
        String doctorCode = [SELECT Id, Doctor_Code_Seven__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1].Doctor_Code_Seven__c;        	               
        Id pfId = [SELECT Id FROM Payer_Factor__c LIMIT 1].Id;
        Domain__c domain = [SELECT Id , DomainCode__c FROM Domain__c LIMIT 1];

        Test.startTest();
        MaccabiIntegration.RetServiceReferrals(new Map<Id, Map<String, String>>{appt.Id => new Map<String, String>{'memberID' => '1234567', 'IDNumber__c' => String.valueOf(appt.IDNumber__c), 'ID_Type__c'  => '1',
        'PayerFactor__c' => String.valueOf(pfId), 'Patient_Account__c' => String.valueOf(patientId), 'Site' => '10750', 'DoctorLicense' => doctorCode, 'MedicalProcedure' => String.valueOf(domain.DomainCode__c)}});
        Test.stopTest();
    }

    @isTest
    static void testRetServiceReferrals1() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRetrievingServiceRef_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c FROM Appointment__c LIMIT 1];
        Id patientId = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].Id;
        String doctorCode = [SELECT Id, Doctor_Code_Seven__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1].Doctor_Code_Seven__c;        	               
        Id pfId = [SELECT Id FROM Payer_Factor__c LIMIT 1].Id;
        Domain__c domain = [SELECT Id , DomainCode__c FROM Domain__c LIMIT 1];
        Test.startTest();
        MaccabiIntegration.retrievingServiceReferrals(appt.Id, appt.IDNumber__c, '1', pfId, patientId, '10750', doctorCode, String.valueOf(domain.DomainCode__c));            
        Test.stopTest();
    }

    @isTest
    static void testRetServiceReferralsFromAccount() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRetrievingServiceRef_Mock());
        Account acct = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        Id apptId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        Test.startTest();
        MaccabiIntegration.retrievingReferralsFromAccount(acct.ID_Number__c, acct.ID_Type__c, acct.Id, '12345', caseId, apptId);
        Test.stopTest();
    }

    @isTest
    static void testRetServiceReferralsGreenWay() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRetrievingServiceRef_Mock());
        Account acct = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c FROM Appointment__c LIMIT 1];
        String procedureCode = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1].Procedure_Code__c;
        List<String> codeConversions = new List<String>{procedureCode};
        String docId = [SELECT Id, ID_Number__c FROM Account WHERE Id =: appt.Doctor_Account__c LIMIT 1].ID_Number__c;

        Test.startTest();
        MaccabiIntegration.getCommitmentGreenWay(acct.Id, 'חיוב ישיר', acct.ID_Number__c,  acct.ID_Type__c, appt.Id, '3', codeConversions, docId, 'name', '12345', '10102020', '107105');
        MaccabiIntegration.getCommitmentGreenWay(acct.Id, 'ביצוי פעולה', acct.ID_Number__c,  acct.ID_Type__c,  appt.Id, '3', codeConversions, docId, 'name', '12345', '10102020', '107105');
        Test.stopTest();
    }

    @isTest
    static void testIsReqLiabilityAuto() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRequestLiabilityAuto_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c FROM Appointment__c LIMIT 1];
        Account acct = [SELECT Id, ID_Number__c, ID_Type__c FROM Account WHERE ID_Number__c=: appt.IDNumber__c LIMIT 1];
        String procedureCode = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1].Procedure_Code__c;
        List<String> codeConversions = new List<String>{procedureCode};
        Account doc = [SELECT Id, ID_Number__c, Doctor_Code_Seven__c FROM Account WHERE Id =: appt.Doctor_Account__c LIMIT 1];
        Id fileID = [SELECT Id FROM File__c LIMIT 1].Id;
        Domain__c domain = [SELECT Id , DomainCode__c FROM Domain__c LIMIT 1];

        Test.startTest();
        //MaccabiIntegration.retrievingServiceReferralsHandler(appt.IDNumber__c, acct.ID_Type__c, appt.Id, '3', acct.Id, '17015', doc.Doctor_Code_Seven__c, String.valueOf(domain.DomainCode__c));
        MaccabiIntegration.isReqLiabilityAuto(appt.Id, fileID, appt.IDNumber__c, acct.ID_Type__c, codeConversions, doc.ID_Number__c, '12345', '10102020', '107105');
        MaccabiIntegration.getCommitmentGreenWay(acct.Id, 'חיוב ישיר', appt.IDNumber__c, acct.ID_Type__c, appt.Id, '3', codeConversions, doc.ID_Number__c, 'doctorName', '123456', '10102020', '107105');
        MaccabiIntegration.getCommitmentGreenWay(acct.Id, 'ביצוע פעולה', appt.IDNumber__c, acct.ID_Type__c, appt.Id, '3', codeConversions, doc.ID_Number__c, 'doctorName', '123456', '10102020', '107105');
        Test.stopTest();
    }

    @isTest
    static void testIsReqLiabilityAutoRed() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRequestLiabilityAuto_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c, Patient_Account__c FROM Appointment__c LIMIT 1];
        Id medProId = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1].Id;
        String docId = [SELECT Id, ID_Number__c FROM Account WHERE Id =: appt.Doctor_Account__c LIMIT 1].ID_Number__c;
        Id siteId = [SELECT Id FROM Site__c LIMIT 1].Id;

        Test.startTest();
        MaccabiIntegration.retServiceReferralsRedHandler(appt.Patient_Account__c, appt.IDNumber__c, '1', docId, 'doc name', appt.Id, medProId, siteId, 'sJSkldns-Efz6-Fe9U-SWG9-5N0y7ib5R6ZX');
        Test.stopTest();
    }

    @isTest
    static void testIsReqLiabilityManagement() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsLiabilitiesManag_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c FROM Appointment__c LIMIT 1];
        Account acct = [SELECT Id, ID_Number__c, ID_Type__c FROM Account WHERE ID_Number__c=: appt.IDNumber__c LIMIT 1];
        Medical_Procedure__c procedure = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1];
        List<String> codeConversions = new List<String>{procedure.Procedure_Code__c};
        String docId = [SELECT Id, ID_Number__c FROM Account WHERE Id =: appt.Doctor_Account__c LIMIT 1].ID_Number__c;
        Id fileID = [SELECT Id FROM File__c LIMIT 1].Id;

        Test.startTest();
        MaccabiIntegration.retrieveServiceRefRED(acct.Id, acct.ID_Number__c, acct.ID_Type__c, docId, 'doc name', appt.Id, procedure.Id, '17015', 'sJSkldns-Efz6-Fe9U-SWG9-5N0y7ib5R6ZX');
        MaccabiIntegration.getCommitmentGreenWay(acct.Id, 'ביצוע פעולה', acct.ID_Number__c, acct.ID_Type__c, appt.Id, '3', codeConversions, docId, 'doctorName', '123456', '10102020', '107105');
        MaccabiIntegration.isLiabilityManagement(appt.Id, fileID, acct.ID_Number__c, acct.ID_Type__c, codeConversions, docId, 'yagov', '107105','sJSkldns-Efz6-Fe9U-SWG9-5N0y7ib5R6ZX');
        Test.stopTest();
    }

    @isTest
    static void testIsServiceReturnsAnswers() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsServiceRetAns_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c FROM Appointment__c LIMIT 1];

        Test.startTest();
        MaccabiIntegration.isServiceReturnsAnswers(appt.IDNumber__c, '1', '123456', appt.Id, Date.today());
        Test.stopTest();
    }

    @isTest
    static void testIsReceiveDocumentFromArc() {
        Test.setMock(WebServiceMock.class, new ws_maccabiIsReceiveDocFromArc_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c FROM Appointment__c LIMIT 1];

        Test.startTest();
        MaccabiIntegration.isReceiveDocumentFromArc(appt.IDNumber__c, '1', '123456', false);
        Test.stopTest();
    }

    @isTest
    static void testInsertDocumentToArchive() {
        Test.setMock(WebServiceMock.class, new ws_maccabiInsertDocumentToArchive_Mock());
        Appointment__c appt = [SELECT Id, IDNumber__c, Doctor_Account__c FROM Appointment__c LIMIT 1];
        File__c file = [SELECT Id, Name FROM File__c LIMIT 1];
        ContentVersion cv = new ContentVersion(
            VersionData = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI='),
            PathOnClient = 'myFileName',
            Title = 'myFileName',
            TEST__c = true
        );
        insert cv;
        Id contDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        Test.startTest();
        MaccabiIntegration.insertDocumentToArchive(contDocId, appt.IDNumber__c, '1', '123456', appt.Id, Date.today(), String.valueOf(file), 'הפניה');
        Test.stopTest();
    }

    @isTest
    static void testcreateComData() {
        ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput commitment = new ws_maccabiRequestLiabilityAuto.IsRequestLiabilityAutoOutput();
        commitment.LiabilityID = '123458463';
        commitment.Deductible = '322';
        commitment.AmountDoctor = '100';
        commitment.AmountImplants = '10';
        commitment.AttachLink = '51565232313565';
        commitment.DateCreateLiability = '11-11-2020';
        commitment.DateSofLiability = '11-11-2020';
        Map<String, String> myTestMam = new Map<String, String>();
        Test.startTest();
        myTestMam = MaccabiIntegration.createComData(commitment);
        Test.stopTest();
    }

    @isTest
    static void testcreateComData1() {
        ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput commitment = new ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput();
        commitment.ErrorCode = '0';
        commitment.LiabilityID = '12345';
        commitment.Deductible = 'grfa';
        commitment.AmountDoctor = '100';
        commitment.AmountImplants = '10';
        commitment.DateCreateLiability = '2019-11-11';
        commitment.DateSofLiability = '2019-11-11';
        Map<String, String> myTestMam = new Map<String, String>();
        Test.startTest();
        myTestMam = MaccabiIntegration.createComData(commitment);
        Test.stopTest();
    }

    @isTest
    static void testInsertAttachment() {
        File__c file = [SELECT Id, Name FROM File__c LIMIT 1];
        Blob attachBody = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        Id patientAccountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1].Id;
        Test.startTest();
        MaccabiIntegration.insertAttachment (file.Id, file.name, attachBody, patientAccountId);
        Test.stopTest();
    }

    @isTest
    static void testInsertAttachment1() {
        Id accId = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].Id;
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        Medical_Procedure__c procedure = [SELECT Id, Procedure_Code__c FROM Medical_Procedure__c LIMIT 1];
        List<String> codeConversions = new List<String>{procedure.Procedure_Code__c};
        List<String> descConversions = new List<String>{'shgafdhgf', 'shgafdhgf', 'shgafdhgf'};

        Map<String, String> refData = new Map<String, String>{'referralNumber' => '12345', 'accountID' => accId, 'parentObjName' => 'Case', 'caseID' => caseId};
        File__c file = [SELECT Id, Name FROM File__c LIMIT 1];
        file.Account__c = accId;
        update file;

        Blob attachBody = EncodingUtil.base64Decode('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        Id patientAccountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1].Id;
        Test.startTest();
        MaccabiIntegration.insertFileReferral(refData, codeConversions, descConversions);
        Test.stopTest();
    }

    @isTest
    static void testRefSort() {
        String doceCode = [SELECT Id, ID_Number__c, Doctor_Code_Seven__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1].Doctor_Code_Seven__c;
        Domain__c domain = [SELECT Id , DomainCode__c FROM Domain__c LIMIT 1];

        ws_maccabiHitchayvuyotReferrals.Treatments[] arrOftreatments= new ws_maccabiHitchayvuyotReferrals.Treatments[]{};
        ws_maccabiHitchayvuyotReferrals.Treatments treatments = new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments.TreatmentCode = '70.5';
        treatments.TreatmentDescription = 'shgafdhgf';
        ws_maccabiHitchayvuyotReferrals.Treatments treatments1 = new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments1.TreatmentCode = '67.2';
        treatments1.TreatmentDescription = 'shgafdhgf';
        ws_maccabiHitchayvuyotReferrals.Treatments treatments2 = new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments2.TreatmentCode = '68.25';
        treatments2.TreatmentDescription = 'shgafdhgf';
        ws_maccabiHitchayvuyotReferrals.Treatments treatments3= new ws_maccabiHitchayvuyotReferrals.Treatments();
        treatments3.TreatmentCode = '10';
        treatments3.TreatmentDescription = 'shgafdhgf';
        arrOftreatments.add(treatments);
        arrOftreatments.add(treatments1);
        arrOftreatments.add(treatments2);
        arrOftreatments.add(treatments3);
        
        ws_maccabiHitchayvuyotReferrals.Referral ref = new ws_maccabiHitchayvuyotReferrals.Referral();
        ref.DoctorID = '999228083';
        ref.DoctorName = 'היעשי הירא';
        ref.DoctorPhoneNumber = 'str';
        ref.DoctorAddress = 'str';
        ref.DoctorSpecialization = 'str';
        ref.DoctorLicense = '111';
        ref.ReferralDate = '05052018';
        ref.ReferralNumber = '125487951';
        ref.ObligationNumber = '0';
        ref.ObligationBranch = 'str';
        ref.BranchPhone = 'str';
        ref.ServiceType = 'str';
        ref.AssutaDeptDescription = 'str';
        ref.TreatmentDate = '10102019';
        ref.TreatmentInstruction = 'str';
        ref.TypeReferral = 'מכון	';
        ref.Urgency = 'str';
        ref.Moked = 'str';
        ref.Findings = 'str';
        ref.Complaints = 'str';
        ref.Treatments = arrOftreatments;

        ws_maccabiHitchayvuyotReferrals.Referral ref2 = new ws_maccabiHitchayvuyotReferrals.Referral();
        ref2.DoctorID = '999228083';
        ref2.DoctorName = 'היעשי הירא';
        ref2.DoctorPhoneNumber = 'str';
        ref2.DoctorAddress = 'str';
        ref2.DoctorSpecialization = 'str';
        ref2.DoctorLicense = '111';
        ref2.ReferralDate = '05052020';
        ref2.ReferralNumber = '125487952';
        ref2.ObligationNumber = '0';
        ref2.ObligationBranch = 'str';
        ref2.BranchPhone = 'str';
        ref2.ServiceType = 'str';
        ref2.AssutaDeptDescription = 'str';
        ref2.TreatmentDate = '10102019';
        ref2.TreatmentInstruction = 'str';
        ref2.TypeReferral = 'Hospitalization	';
        ref2.Urgency = 'str';
        ref2.Moked = 'str';
        ref2.Findings = 'str';
        ref2.Complaints = 'str';
        ref2.Treatments = arrOftreatments;

        ws_maccabiHitchayvuyotReferrals.Referral ref3 = new ws_maccabiHitchayvuyotReferrals.Referral();
        ref3.DoctorID = '999228083';
        ref3.DoctorName = 'היעשי הירא';
        ref3.DoctorPhoneNumber = 'str';
        ref3.DoctorAddress = 'str';
        ref3.DoctorSpecialization = 'str';
        ref3.DoctorLicense = '111';
        ref3.referralDate = '05052021';
        ref3.referralNumber = '125487953';
        ref3.ObligationNumber = '0';
        ref3.ObligationBranch = 'str';
        ref3.BranchPhone = 'str';
        ref3.ServiceType = 'str';
        ref3.AssutaDeptDescription = 'str';
        ref3.TreatmentDate = '10102019';
        ref3.TreatmentInstruction = 'str';
        ref3.Typereferral = 'Hospitalization	';
        ref3.Urgency = 'str';
        ref3.Moked = 'str';
        ref3.Findings = 'str';
        ref3.Complaints = 'str';
        ref3.Treatments = arrOftreatments;
        ws_maccabiHitchayvuyotReferrals.Referral[] Referral = new ws_maccabiHitchayvuyotReferrals.Referral[]{};
        Referral.add(ref);
        Referral.add(ref2);
        Referral.add(ref3);
        ws_maccabiHitchayvuyotReferrals.ArrayOfReferralReferral arrRef = new ws_maccabiHitchayvuyotReferrals.ArrayOfReferralReferral();
        arrRef.Referral = Referral;
        ws_maccabiHitchayvuyotLiabilityAuto.ResultMessage resMessage = new ws_maccabiHitchayvuyotLiabilityAuto.ResultMessage();
        resMessage.Message = '';
        resMessage.Description = '';
        resMessage.Code = 0;
        ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput RetOutput = new ws_maccabiHitchayvuyotReferrals.RetrievingServiceReferralsOutput();
        RetOutput.ErrorCode = '0';
        RetOutput.Referrals = arrRef;
        RetOutput.ResultMessage = resMessage;
        
        Test.startTest();
        MaccabiIntegration.getReferralSorted(RetOutput, doceCode, String.valueOf(domain.DomainCode__c));
        Test.stopTest();
    }

    @isTest
    static void testRetrievingReferralsFromInstitutesApp() {
        Test.setMock(WebServiceMock.class, new ws_maccabiRetrievingServiceRef_Mock());
        Account acct = [SELECT Id, ID_Number__c, ID_Type__c FROM Account LIMIT 1];
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        Id apptId = [SELECT Id FROM Appointment__c LIMIT 1].Id;

        Test.startTest();
        MaccabiIntegration.retrievingReferralsFromInstitutesApp(acct.ID_Number__c, acct.ID_Type__c, acct.Id, '12345', caseId, apptId);
        Test.stopTest();
    }
}