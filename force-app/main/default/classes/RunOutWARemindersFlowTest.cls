@isTest
class RunOutWARemindersFlowTest {
    @isTest
    static void WAFirstReminderTest() {
        Datetime curDateTime = Datetime.now();
        
        Test.startTest();               
        String jobId = System.schedule('Test job', '0 0 12 * * ?', new RunOutWAFirstReminderFlow());        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);

        Datetime myDate = Datetime.newInstance(curDateTime.year(), curDateTime.month(), curDateTime.day(), 12, 0, 0);
        if (curDateTime.time() > Time.newInstance(12,0,0,0)) {
            myDate = myDate.addDays(1);
        }
        
        System.assertEquals(String.valueOf(myDate), String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

    @isTest
    static void WASecondReminderTest() {
        Datetime curDateTime = Datetime.now();

        Test.startTest();
        String jobId = System.schedule('Test RunReportForExpertProcess job', '0 0 13 * * ?', new RunOutWASecondReminderFlow());
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