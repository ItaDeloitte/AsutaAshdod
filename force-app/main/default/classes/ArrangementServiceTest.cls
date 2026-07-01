// Test for: ArrangementTriggerService, ArrangementTriggerHandler, ArrangementTriggerDispatcher
// Created: Max Feldman
// Date: 02.05.2021

@isTest
public class ArrangementServiceTest {

    @testSetup static void setup() {
        Account acc =  TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        acc.Promoted_doctor__c = 'Arrangement';
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
        Account doctor = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c='Arrangement' LIMIT 1];
        Account doctor2 = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c='Other' LIMIT 1];
        Account doctor3 = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: TestDataFactory.ACCT_D_RT_NAME AND Promoted_doctor__c=null LIMIT 1];
        
        Payer_Factor__c pFactorChild1 = TestDataFactory.getPFactor('12345');
        insert pFactorChild1;
        Arrangements__c arrangement = TestDataFactory.getArrangements(pFactorChild1.Id);
        Arrangements__c arrangement2 = TestDataFactory.getArrangements(pFactorChild1.Id);
        Arrangements__c arrangement3 = TestDataFactory.getArrangements(pFactorChild1.Id);
        insert arrangement;
        insert arrangement2;
        insert arrangement3;
        
        Doctor_Arrangement__c docArrangement = TestDataFactory.getDocArrangement(doctor.Id, arrangement.Id);
        Doctor_Arrangement__c docArrangement2 = TestDataFactory.getDocArrangement(doctor2.Id, arrangement2.Id);
        Doctor_Arrangement__c docArrangement3 = TestDataFactory.getDocArrangement(doctor3.Id, arrangement3.Id);
        
        insert docArrangement;
        insert docArrangement2;
        insert docArrangement3;

        Test.startTest();
        arrangement.Promoted_arrangement__c = true;
        arrangement2.Promoted_arrangement__c = true;
        arrangement3.Promoted_arrangement__c = false;
        
        update arrangement;
        update arrangement2;
        update arrangement3;
        
        //doctor = [SELECT ID,Counting_Promoted_doctor_values__c FROM Account WHERE Id =: doctor.ID LIMIT 1];
        //System.assertEquals(doctor.Counting_Promoted_doctor_values__c, 1);
        arrangement.Promoted_arrangement__c = false;
        update arrangement;
        //doctor = [SELECT ID,Counting_Promoted_doctor_values__c FROM Account WHERE Id =: doctor.ID LIMIT 1];
        //System.assertEquals(doctor.Counting_Promoted_doctor_values__c, 0);
        Test.stopTest();
    }
}