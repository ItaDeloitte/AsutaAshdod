@isTest
class RunKillSmsAfterAptExpertTest {
    @isTest
    static void testScheduler() {
        Test.startTest();
        String CRON_EXP = '0 0 13 * * ?';
        Datetime curDateTime = Datetime.now();
        String jobId = System.schedule('Test job', CRON_EXP, new RunKillSmsAfterAptExpert());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(0, ct.TimesTriggered);

        Datetime myDate = Datetime.newInstance(curDateTime.year(), curDateTime.month(), curDateTime.day(), 13, 0, 0);

        if (curDateTime.time() > Time.newInstance(13,0,0,0)) {
            myDate = myDate.addDays(1);
        }
        
        System.assertEquals(String.valueOf(myDate), String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}