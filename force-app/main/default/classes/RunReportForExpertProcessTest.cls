@isTest
public class RunReportForExpertProcessTest {

    @TestSetup
    static void setup() {
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        doctor.Email__c = 'test@test.com';
        doctor.Experts_center__c = true;
        insert doctor;
    }

    @isTest
    static void testSchedulerAndCheckbox() {
        Datetime curDateTime = Datetime.now();

        Test.startTest();
        String jobId = System.schedule('Test RunReportForExpertProcess job', '0 0 13 * * ?', new RunReportForExpertProcess());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(0, ct.TimesTriggered);

        Datetime myDate = Datetime.newInstance(curDateTime.year(), curDateTime.month(), curDateTime.day(), 13, 0, 0);
        if (curDateTime.time() > Time.newInstance(13, 0, 0, 0)) {
            myDate = myDate.addDays(1);
        }

        System.assertEquals(String.valueOf(myDate), String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}