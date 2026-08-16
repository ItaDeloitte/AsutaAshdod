// Test for: AgreementTriggerService, AgreementTriggerHandler, AgreementTriggerDispatcher
// Created: Max Feldman
// Date: 02.05.2021

@isTest
public class AgreementServiceTest {

    @testSetup static void setup() {
        Account acc =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc.Promoted_doctor__c = 'Agreement';
        insert acc;
        
        Account acc2 =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc2.Promoted_doctor__c = 'Other';
        acc2.ID_Number__c = '999393879';
        insert acc2;
        
        Account acc3 =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc3.Promoted_doctor__c = null;
        acc3.ID_Number__c = '999958572';
        insert acc3;
    }

    @isTest static void updatePromotedDoctorTest() {
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c='Agreement' LIMIT 1];
        Account doctor2 = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c='Other' LIMIT 1];
        Account doctor3 = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c=null LIMIT 1];
        Payer_Factor__c pFactorChild1 = TestDataFactory.getPFactor('12345');
        insert pFactorChild1;
        
        Agreement__c agreement = TestDataFactory.getAgreement(doctor.Id, pFactorChild1.Id);
        insert agreement;
        Agreement__c agreement2 = TestDataFactory.getAgreement(doctor2.Id, pFactorChild1.Id);
        insert agreement2;
        Agreement__c agreement3 = TestDataFactory.getAgreement(doctor3.Id, pFactorChild1.Id);
        insert agreement3;

        Test.startTest();
        agreement.Promoted_Agreement__c = true;
        agreement2.Promoted_Agreement__c = true;
        agreement3.Promoted_Agreement__c = false;
        update agreement;
        update agreement2;
        update agreement3;
        //doctor = [SELECT ID,Counting_Promoted_doctor_values__c FROM Account WHERE Id =: doctor.ID LIMIT 1];
        //System.assertEquals(doctor.Counting_Promoted_doctor_values__c, 1);
        agreement.Promoted_Agreement__c = false;
        update agreement;
        
        
        //doctor = [SELECT ID,Counting_Promoted_doctor_values__c FROM Account WHERE Id =: doctor.ID LIMIT 1];
        //System.assertEquals(doctor.Counting_Promoted_doctor_values__c, 0);
        Test.stopTest();
    }
}