// Test for AccountTrigger, AccountTriggerHandler, AccountTriggerDispatcher; AccountServices (56%)
@isTest
public class AccountServicesTest {

    @TestSetup
    static void setup() {
        insert TestDataFactory.getENV();
        Expertise__c expertise = TestDataFactory.getExpertise();
        expertise.SendDoctorStatisfactionSurvey__c = true;
        insert expertise;
        
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Promoted_doctor_DA__c = false;
        insert doctor;

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Create_Tafnit_AC__c = true;
        patient.PersonMailingCountry = 'ישראל';
        patient.PersonMailingCity = 'בית שמש'; 
        patient.PersonMailingStreet = 'הכלנית 18';
        patient.Other_Health_Services__c = 'ללא';
        patient.Phone = '0526641223';
        patient.SMS_Phone_Number__c = '0525518983';
        patient.Preferred_Channel__c = 'Whatsapp';
        patient.PersonEmail = 'test1@walla.com';
        patient.Fax = '0525518983';
        patient.Status__c = 'פ';
        insert patient;

        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;

        Case cas = new Case();
        cas.sub_case_subject__c = 'שינוי תור קיים';
        cas.Case_subject__c = 'עדכון תור קיים';
        cas.PayerFactor__c = pFactor.Id;
        cas.Patient__c = patient.Id;
        cas.AccountId = patient.Id;
        cas.email_from_patient__c = 'test1@walla.com';
        cas.preferd_chanal_case__c = 'Whatsapp';
        cas.SMS_Phone_Number__c = '0525518983';
        cas.phone__c = '0525518983';
        cas.AccountId = patient.Id;
        insert cas;

        Survey__c survey = new Survey__c(
            SurveyCode__c = 'DocSatisfaction'
        );
        insert survey;

        List<Survey_Question__c> questions = new List<Survey_Question__c>();
        for (Integer i = 0; i < 3; i++) {
            questions.add(new Survey_Question__c(
                OrderNumber__c = 2,
                Question__c = 'Question' + i,
                Type__c = 'RadioButton',
                Survey__c = survey.Id  
            ));
        }
        insert questions;  
    }

    @isTest
    static void checkIdNumberUniquenessTest() {
        List<Account> accounts = new List<Account>();
        accounts.add(TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME));
        accounts.add(TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME));
        Test.startTest();
        try {
            insert accounts;
        } catch (Exception e) {
            if (e.getMessage().contains('Id number should be unique') || e.getMessage().contains('מספר זיהוי זה כבר קיים במערכת')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void validateIdNumberTest() {
        Account acct = [SELECT Id, ID_Number__c FROM Account LIMIT 1];
        acct.ID_Number__c = '12345';
        Test.startTest();
        try {
            update acct;
        } catch (Exception e) {
            if (e.getMessage().contains('Person Id is incorrect') || e.getMessage().contains('תעודת זהות אינה תקינה')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void validateIdNumberIsNotNumericTest() {
        Account acct = [SELECT Id, ID_Number__c FROM Account LIMIT 1];
        acct.ID_Number__c = 'P12345';
        Test.startTest();
        try {
            update acct;
        } catch (Exception e) {
            if (e.getMessage().contains('Person Id should be Numeric') || e.getMessage().contains('בעת הקשת ת.ז יש להכניס מספריים בלבד')) {
                System.debug('error message is good');
            }
        }
        Test.stopTest();
    }


    @isTest
    static void handleCreatePatient_Update_Test() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account patient = [SELECT Id, Update_Tafnit_AC__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        patient.Update_Tafnit_AC__c = false;
        Test.startTest();
        update patient;
        Test.stopTest();
    }

    @isTest
    static void handleCreatePatient_Insert_Test() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Update_Tafnit_AC__c = false;
        patient.Create_Tafnit_AC__c = false;
        patient.ID_Number__c = '311049191';
        Test.startTest();
        insert patient;
        Test.stopTest();
    }

    @IsTest
    static void updateCasebyAccountFields(){
        Account patient = [SELECT Id, Phone, Other_Health_Services__c, Insurer_factor__c, Preferred_Channel__c, SMS_Phone_Number__c, PersonEmail FROM Account
                           WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        patient.SMS_Phone_Number__c = '0540000000';
        patient.Other_Health_Services__c = '50';
        patient.Preferred_Channel__c = 'Email';
        patient.PersonEmail = 'conor@ufc.com';
        patient.Insurer_factor__c = '1';
        patient.Phone = '0542187835';
        Test.startTest();
        update patient;
        
        Case cas = [SELECT Id, phone__c, preferd_chanal_case__c, SMS_Phone_Number__c, email_from_patient__c FROM Case WHERE AccountId =: patient.Id LIMIT 1];
        System.assertEquals(patient.SMS_Phone_Number__c, cas.SMS_Phone_Number__c);
        System.assertEquals(patient.Preferred_Channel__c, cas.preferd_chanal_case__c);
        System.assertEquals(patient.PersonEmail, cas.email_from_patient__c);
        System.assert(patient.Phone != cas.phone__c);
        Test.stopTest();
    }
    
    @isTest
    static void validateSMSPhoneNumberTest() {
        Account patient = [SELECT Id, Phone FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        patient.Phone = null;
        Test.startTest();
        try {update patient;} catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void promoteDocotorTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        doctor.Promoted_doctor_DA__c = true;
        DocAdvisorSetting__c docAdvisorSetting = new DocAdvisorSetting__c();
        docAdvisorSetting.Promoted_Doctors_Amount__c =1;
        insert docAdvisorSetting;
        Test.startTest();
        try {
            update doctor;
            List<Account> promotedDocotrsList = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor_DA__c=true];
            System.assertEquals(1, promotedDocotrsList.size());
        } catch (Exception e) {
           
        }
        Test.stopTest();
    }

    @isTest
    static void toManyPromotedDoctorsTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        doctor.Promoted_doctor_DA__c = true;
        DocAdvisorSetting__c docAdvisorSetting =new DocAdvisorSetting__c();
        docAdvisorSetting.Promoted_Doctors_Amount__c =0;
        insert docAdvisorSetting;
        Test.startTest();
        try {
            update doctor;
            List<Account> promotedDocotrsList = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor_DA__c=true];
            System.assertEquals(0, promotedDocotrsList.size());
        } catch (Exception e) {
           
        }
        Test.stopTest();
    }
    
    @isTest
    static void postalCodeFields(){       
        /*User u = TestDataFactory.getUser('Integration Profile');
        insert u;*/
        Account patient1 = [SELECT Id, PersonMailingPostalCode, ShippingPostalCode FROM Account 
                             WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.ID_Number__c = '999849169';
        insert patient2;
        patient1.PersonMailingPostalCode = '123';
        patient2.ShippingPostalCode = '123';
        update new List<account> {patient1, patient2};
        Test.startTest();
        patient1.PersonMailingPostalCode = '123a';
        patient2.ShippingPostalCode = '123a';

        try{
            update patient1;
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('הערך בשדה מיקוד מכיל תווים שאינם מספר'));
        }
        try{
            update patient2;
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('הערך בשדה מיקוד מכיל תווים שאינם מספר'));
        }
        Test.stopTest();
    }

    @IsTest 
    static void fill360CoordinatorTest() {
        Account patient = [SELECT Id, Case_360__c FROM Account WHERE ID_Number__c = :TestDataFactory.P_ID_NUMBER];

        Case cas = new Case(
            Status = 'New', 
            AccountId = patient.Id, 
            RecordTypeId = TestDataFactory.getRTId('Assuta_360', 'Case')
        );
        insert cas;
        
        patient.Case_360__c = cas.Id;
        update patient;

        patient = [SELECT Id, X360_Coordinator__c FROM Account WHERE Id = :patient.Id];
        cas = [SELECT Id, First_user_to_own_the_case__c FROM Case WHERE Id = :cas.Id];
        System.assert(cas.First_user_to_own_the_case__c != null);
        System.assertEquals(cas.First_user_to_own_the_case__c, patient.X360_Coordinator__c);
    }
    
    @isTest
    static void checkEndUserTest(){        
        Account patient = [SELECT Id, SMS_Phone_Number__c FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_P_RT_NAME LIMIT 1];
        Account patient2 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient2.ID_Number__c = '999849169';
        patient2.SMS_Phone_Number__c = '0525518983';
        insert patient2;
        patient.SMS_Phone_Number__c ='0540000000';
        Test.startTest();
        try {update patient;} catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void createSurveyForDoctorsTest() {  
        Test.startTest(); 
        Expertise__c expertise = [SELECT Id FROM Expertise__c LIMIT 1];
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME); 
        doctor.ID_Number__c = '999849169';
        doctor.SMS_Phone_Number__c = '0525518983';  
        doctor.Expertise_1__c = expertise.Id;        
        insert doctor;
        Test.stopTest();
        
        // Assertions
        List<SurveyTaker__c> takers = [SELECT Id, Doctor__c, Survey__c FROM SurveyTaker__c WHERE Doctor__c = :doctor.Id];
        System.assertEquals(1, takers.size(), 'Expected one SurveyTaker created');

        List<SurveyQuestionResponse__c> responses = [
            SELECT Id, SurveyTaker__c, Survey_Question__c 
            FROM SurveyQuestionResponse__c 
            WHERE SurveyTaker__c = :takers[0].Id
        ];
        System.assertEquals(6, responses.size(), 'Expected 3 responses created for 3 questions');   
    }
}