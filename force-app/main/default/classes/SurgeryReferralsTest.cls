@isTest
public class SurgeryReferralsTest {

    @testSetup
    static void makeData() {
        insert TestDataFactory.getENV();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Doctor_Code__c = '556786';
        insert doctor;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);
        insert domain;
        
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '22.4');
        procedure.Name = 'א.א.ג-הזרקת חומר סינטטי למיתרי הקול';
        insert procedure;
        procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '20.5');
        procedure.Name = 'א.א.ג - אוסיקולופלסטי';
        insert procedure;
        procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '23.11');
        procedure.Name = 'אאג - תירואידקטומיה בגישה רובוטית';
        insert procedure;
        procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, '33.6');
        procedure.Name = 'א.א.ג -הרחבת תעלת השמע באמצעות בלון';
        insert procedure;

        Payer_Factor__c parentPFactor = TestDataFactory.getPFactor('333');
        parentPFactor.Insurance_Company__c = true;
        insert parentPFactor;
        Payer_Factor__c pFactor = TestDataFactory.getPFactor('8');
        pFactor.Name_of_parent__c = parentPFactor.Id;
        pFactor.Insurance_Company__c = true;
        insert pFactor;

        insert TestDataFactory.getDocProcedure(doctor.Id, procedure.Id);
        insert TestDataFactory.getSite('20');
    }
    
    static ws_SurgeryReferrals.spincalData createSpinCal() {
        ws_SurgeryReferrals.spincalData spincalData = new ws_SurgeryReferrals.spincalData();
        spincalData.patientId = TestDataFactory.P_ID_NUMBER;    //'999089717';
        spincalData.idType = '1';
        spincalData.fName = 'TASTY';
        spincalData.lName = 'TEST';
        spincalData.email = 'tastytest@gmail.com';
        spincalData.mainPhone = '0548756896';
        spincalData.otherPhone = '096783156';
        spincalData.birthDate = '1980-05-28';
        spincalData.gender = 'ז';
        spincalData.insurerCode = '8';
        spincalData.insurerName = 'מנורה';
        spincalData.status = '1';
        spincalData.medicalOp1 = '22.4';
        spincalData.medicalOp1Name = 'א.א.ג-הזרקת חומר סינטטי למיתרי הקול';
        spincalData.medicalOp2 = '20.5';
        spincalData.medicalOp2Name = 'א.א.ג - אוסיקולופלסטי';
        spincalData.medicalOp3 = '23.11';
        spincalData.medicalOp3Name = 'אאג - תירואידקטומיה בגישה רובוטית';
        spincalData.medicalOp4 = '33.6';
        spincalData.medicalOp4Name = 'א.א.ג -הרחבת תעלת השמע באמצעות בלון';
        spincalData.notes = 'בדיקה בדיקה';
        spincalData.siteCode = '20';
        spincalData.siteName = 'אסותא רמת החייל';
        spincalData.tafnitId = '657815328';
        spincalData.doctorId = TestDataFactory.D_ID_NUMBER;
        spincalData.doctorLicense = '556786';
        spincalData.surgeryDateTime = '2019-07-25 15:20:00';
        
        return spincalData;
    }

    static ws_SurgeryReferrals.referralData createReferral() {
        ws_SurgeryReferrals.referralData refData = new ws_SurgeryReferrals.referralData();
        refData.patientId = TestDataFactory.P_ID_NUMBER;
        refData.idType = '1';
        refData.fName = 'TASTY';
        refData.lName = 'TEST';
        refData.birthDate = '1980-05-28';
        refData.doctorLicense = '556786';
        refData.homePhone = '096783156';
        refData.mobilePhone = '0548756896';
        refData.workPhone = '036589745';
        refData.surgeryDateTime = '2019-07-25 15:20:00';
        refData.physicalCheck = 'All good';
        refData.findings = 'None';
        refData.refNumber = '1234567';
        refData.medications = 'Aspirin';
        refData.remarks = 'Nice guy';
        refData.allergies = 'Dust';
        refData.backgroundIllnesses = 'None';
        refData.anamnesis = 'TEST';
        refData.needEmergencyTreatment = false;
        refData.gender = 'ז';
        refData.anesthesiaType = '1';
        refData.hospType = '1';
        refData.status = '1';
        refData.statusDate = '2019-06-18';
        refData.insurerCode = '8';
        refData.resources = '4093,3046,4030';
        refData.medicalOp1 = '22.4';
        refData.medicalOp2 = '20.5';
        refData.medicalOp3 = '23.11';
        refData.medicalOp4 = '33.6';
        refData.siteCode = '20';
        refData.HMO = '1';
        refData.pathologist = true;
        refData.radiologist = true;
        refData.surgeries = createSurgeriesList();
        refData.isFeeRequired = true;
        refData.surgeonFee = 1500;
        refData.homeRehabilitation= true;
        refData.homeRehabilitationDate='2019-07-25 15:20:00';

        return refData;
    }

    static List<ws_SurgeryReferrals.surgery> createSurgeriesList() {
        List<String> opCodes = new List<String>{'04.2', '20.5', '23.11', '33.6'};
        List<String> opNames = new List<String>{'א.א.ג-הזרקת חומר סינטטי למיתרי הקול', 'א.א.ג - אוסיקולופלסטי', 'אאג - תירואידקטומיה בגישה רובוטית', 'א.א.ג -הרחבת תעלת השמע באמצעות בלון'};
        List<ws_SurgeryReferrals.surgery> surgeries = new List<ws_SurgeryReferrals.surgery>();
        ws_SurgeryReferrals.surgery surg = new ws_SurgeryReferrals.surgery();
        for(Integer i=0 ; i<4 ; i++) {
            surg.surgeryCode = opCodes[i];
            surg.surgeryName = opNames[i];
            surg.surgerySide = 'ימין';
            surg.organ = 'Arm';
            //surg.lensName;
            //surg.lensType;
            surgeries.add(surg);
        }
        return surgeries;
    }
    
    static Account insertPatient(){
        Account patient = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
        FirstName = 'TASTY',
        LastName = 'TEST',
        ID_Number__c = '999089717',
        ID_Type__c = '1',
        Gender__c = 'ז',
        Create_Tafnit_AC__c = true,
        DisableValidation__c = true);

        insert patient;
        return patient;
    }

    /*@isTest(SeeAllData=true)*/
    static Map<String, ID> fetchIds() {
        Map<String, ID> idMap = new Map<String, ID>();
        Account doc = [SELECT ID FROM Account WHERE Doctor_Code__c = '556786' LIMIT 1];
        idMap.put('doctor', doc.ID);
        Medical_Procedure__c procedure = [SELECT ID FROM Medical_Procedure__c WHERE Procedure_Code__c = '22.4' LIMIT 1];
        idMap.put('procedure', procedure.ID);
        Site__c site = [SELECT ID FROM Site__c WHERE Site_Code__c = '20' LIMIT 1];
        idMap.put('site', site.ID);
        return idMap;
    }

    static void insertPatientAptCaseJunc() {
        Account patient = insertPatient();
        Map<String, ID> idMap = fetchIds();
        Payer_Factor__c pf = [SELECT ID FROM Payer_Factor__c WHERE InsuranceCode__c = '8' LIMIT 1];

        Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surgery').getRecordTypeId(),
            Origin = 'מערכות מקור',
            Case_subject__c = 'טיפול אדמיניסטרטיבי טרום הניתוח',
            Payer_Factor__c = '8',
            AccountId = patient.ID,
            Opearator__c = idMap.get('doctor'),
            Medical_Procedure__c = idMap.get('procedure'));
        insert c;

        Appointment__c apt = new Appointment__c(
            Name = 'TEST',
            RecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Surgeries').getRecordTypeId(),
            Payer_factor__c = '8',
            PayerFactor__c = pf.Id,
            Appointment_Date_Time__c = DateTime.valueOf('2019-07-25 15:20:00'),
            Patient_Account__c = patient.ID,
            Doctor_Account__c = idMap.get('doctor'),
            Medical_Procedure__c = idMap.get('procedure'),
            Site__c = idMap.get('site'),
            Case__c = c.ID,
            Appointment_Status__c = 'NewAppointment');
        insert apt;

        cases_and_appoitments__c junction = new cases_and_appoitments__c();
        junction.Case__c = c.ID;
        junction.Appointment__c = apt.ID;
        junction.Is_it_the_main_case_for_surgery__c = true;
        insert junction;
    }

    @isTest
    static void fullSpinCalCheck() {
        Test.startTest();
        
        List<Medical_Procedure__c> procedures = [SELECT Id, Name FROM Medical_Procedure__c];
        System.debug('Procedure: ' + procedures[0] + procedures[1] + procedures[2]);
        
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        System.debug('Response: ' + response);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        //Check not allowing duplicate SpinCal record creation
        response = ws_SurgeryReferrals.getSpinkleData(spincal);
        // System.assertEquals(false, response.isSuccess);
        // System.assertEquals('Attempt to create an existing spincal record', response.message);
        //Check update of a SpinCal record
        spincal.status = '2';
        spincal.surgeryDateTime = '2019-07-26 15:20:00';
        response = ws_SurgeryReferrals.getSpinkleData(spincal);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data updated successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void faultySpinCal() {
        Test.startTest();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        String temp = spincal.patientId;
        //Check empty mandatory field
        spincal.patientId = '';
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('patientId is empty', response.message);
        spincal.patientId = temp;
        //Check non existing doctor
        temp = spincal.doctorLicense;
        spincal.doctorLicense = '0';
        response = ws_SurgeryReferrals.getSpinkleData(spincal);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('Doctor, site, payer factor or one of the medical procedures does not exist in Salesforce', response.message);
        Test.stopTest();
    }

    @isTest
    static void existingPatientSpinCal() {
        Test.startTest();
        insertPatient();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        //System.assertEquals(true, response.isSuccess);
        //System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void oneOpSpinCalNoMPhone() {
        Test.startTest();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        spincal.medicalOp2 = '';
        spincal.medicalOp3 = '';
        spincal.medicalOp4 = '';
        spincal.mainPhone = '';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void twoOpSpinCalNoOPhone() {
        Test.startTest();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        spincal.medicalOp3 = '';
        spincal.medicalOp4 = '';
        spincal.otherPhone = '';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void threeOpSpinCal() {
        Test.startTest();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        spincal.medicalOp4 = '';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void newSpinCalExistingPatientAptCaseJunc() {
        insertPatientAptCaseJunc();
        Test.startTest();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        //System.assertEquals(true, response.isSuccess);
        //System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void fullReferralCheck() {
        Test.startTest();
        ws_SurgeryReferrals.referralData referral = createReferral();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        //Check not allowing duplicate referral record creation
        response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        // System.assertEquals(false, response.isSuccess);
        // System.assertEquals('Attempt to create an existing referral record', response.message);
        //Check update of a referral record
        referral.status = '2';
        referral.surgeryDateTime = '2019-07-26 15:20:00';
        response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data updated successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void faultyReferral() {
        Test.startTest();
        ws_SurgeryReferrals.referralData referral = createReferral();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        String temp = referral.patientId;
        //Check empty mandatory field
        referral.patientId = '';
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('patientId is empty', response.message);
        referral.patientId = temp;
        //Check non existing doctor
        temp = referral.doctorLicense;
        referral.doctorLicense = '0';
        response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('Doctor, site, payer factor or one of the medical procedures does not exist in Salesforce', response.message);
        Test.stopTest();
    }

    @isTest
    static void existingPatientReferral() {
        Test.startTest();
        insertPatient();
        ws_SurgeryReferrals.referralData referral = createReferral();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        //System.assertEquals(true, response.isSuccess);
        //System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void oneOpReferralNoHPhone() {
        Test.startTest(); 
        ws_SurgeryReferrals.referralData referral = createReferral();
        referral.medicalOp2 = '';
        referral.medicalOp3 = '';
        referral.medicalOp4 = '';
        referral.surgeries.remove(3);
        referral.surgeries.remove(2);
        referral.surgeries.remove(1);
        referral.homePhone = '';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void twoOpReferralNoMPhone() {
        Test.startTest(); 
        ws_SurgeryReferrals.referralData referral = createReferral();
        referral.medicalOp3 = '';
        referral.medicalOp4 = '';
        referral.surgeries.remove(3);
        referral.surgeries.remove(2);
        referral.mobilePhone = '';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void threeOpReferralNoMAndHPhone() {
        Test.startTest(); 
        ws_SurgeryReferrals.referralData referral = createReferral();
        referral.medicalOp4 = '';
        referral.surgeries.remove(3);
        referral.mobilePhone = '';
        referral.homePhone = '';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        // System.assertEquals(true, response.isSuccess);
        // System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void newReferralExistingPatientAptCaseJunc() {
        insertPatientAptCaseJunc();
        Test.startTest();
        ws_SurgeryReferrals.referralData referral = createReferral();
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        //System.assertEquals(true, response.isSuccess);
        //System.assertEquals('Data inserted successfully', response.message);
        Test.stopTest();
    }

    @isTest
    static void noPatientRefferal(){
        Test.startTest();
        ws_SurgeryReferrals.referralData referral = createReferral();
        referral.patientId='999512486';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getDoctorReferralData(referral);
        Test.stopTest();
    }

    @isTest
    static void noPatientSpincal(){
        Test.startTest();
        ws_SurgeryReferrals.spincalData spincal = createSpinCal();
        spincal.patientId='999512486';
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        GeneralResponse response = ws_SurgeryReferrals.getSpinkleData(spincal);
        Test.stopTest();
    }
}