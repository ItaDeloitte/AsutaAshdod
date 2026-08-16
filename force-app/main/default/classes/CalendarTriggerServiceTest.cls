@isTest
public class CalendarTriggerServiceTest {
    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        insert TestDataFactory.getENV();
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

    }
    @isTest
    static void onlineSummon() {
        Account doc = [SELECT Id FROM Account LIMIT 1];
        Calendar__c cal1 = new Calendar__c();
        cal1.AppointmentSys__c = 'QFLOW';
        cal1.IsexpertCalender__c = true;
        insert cal1;
		Calendar__c cal2 = new Calendar__c();
        cal2.AppointmentSys__c = 'QFLOW'; 
        cal2.IsexpertCalender__c = true;       
        cal2.Doctor__c = doc.Id;
        insert cal2;
        
        Test.startTest();
        cal1.Doctor__c = doc.Id;
        update cal1;
        cal1.Doctor__c = null;
        update cal1;
        cal1.Doctor__c = doc.Id;
        update cal1;
        Test.stopTest();
    }

}