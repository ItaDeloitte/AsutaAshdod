// Test for: ClinicTrigger, ClinicTriggerHandler, ClinicTriggerDispatcher, ClinicServices
// Created: Evgeniy Kravchuk
// Date: 31.01.2020
@isTest
private class ClinicServicesTest {

    @testSetup static void setup() {
        Account acc =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc.Promoted_doctor__c = 'Other';
        insert acc;
        
        Account acc2 =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc2.Promoted_doctor__c = 'Clinic';
        acc2.ID_Number__c = '999393879';
        insert acc2;
        
        Account acc3 =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc3.Promoted_doctor__c = null;
        acc3.ID_Number__c = '999958572';
        insert acc3;
        
        
    }

    @isTest static void updateMedProceduresOnAccountTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME LIMIT 1];
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        insert clinic;
        Doctor_in_Clinic__c junction = TestDataFactory.getDocClinic(doctor.Id, clinic.Id);

        Test.startTest();
        insert junction;
        clinic.Area__c = 'new area';
        update clinic;
        delete clinic;
        Test.stopTest();
    }

    @isTest static void updatePromotedDoctorTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c=null LIMIT 1];
        Account doctor2 = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c='Other' LIMIT 1];
        Account doctor3 = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c= 'Clinic' LIMIT 1];
        
        Clinic__c clinic = TestDataFactory.getClinic('QFlow');
        Clinic__c clinic2 = TestDataFactory.getClinic('QFlow');
        Clinic__c clinic3 = TestDataFactory.getClinic('QFlow');
        
        insert clinic;
        insert clinic2;
        insert clinic3;
        
        Doctor_in_Clinic__c junction = TestDataFactory.getDocClinic(doctor.Id, clinic.Id);
        insert junction;
        Doctor_in_Clinic__c junction2 = TestDataFactory.getDocClinic(doctor2.Id, clinic2.Id);
        insert junction2;
        Doctor_in_Clinic__c junction3 = TestDataFactory.getDocClinic(doctor3.Id, clinic3.Id);
        insert junction3;

        Test.startTest();
        clinic2.Promoted_Clinic__c = true;
        update clinic2;
        //doctor = [SELECT ID,Counting_Promoted_doctor_values__c FROM Account WHERE Id =: doctor.ID LIMIT 1];
        //System.assertEquals(doctor.Counting_Promoted_doctor_values__c, 1);
        clinic.Promoted_Clinic__c = false;
        update clinic;
        
        clinic3.Promoted_Clinic__c = false;
        update clinic3;
        //doctor = [SELECT ID,Counting_Promoted_doctor_values__c FROM Account WHERE Id =: doctor.ID LIMIT 1];
        //System.assertEquals(doctor.Counting_Promoted_doctor_values__c, 0);
 
        Test.stopTest();
    }
}