// Test for: SLACounterScheduler
@isTest
private class SLACounterSchedulerTest {
	
    @testSetup
    private static void testSetup() {
        Date currentDate = Date.today();
        insert new QualityControl__c(Related_User__c = UserInfo.getUserId(), SLA_start_date__c = currentDate.addDays(-5), Target_date_qa__c = currentDate.addDays(5));
        insert new List<Calendar1__c>{new Calendar1__c(Gregorian_Date__c = currentDate.addDays(-1), business_day__c = true),
                                      new Calendar1__c(Gregorian_Date__c = currentDate, business_day__c = true)};
    }
    
    @isTest
    private static void schedulerTest() {
        Test.startTest();
        Datetime workTime = System.now().addMinutes(1);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour() + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
        System.debug('CRONEXP ' + CRONEXP);
        System.schedule('SLA Counter Scheduler Test', CRONEXP, new SLACounterScheduler());
        Test.stopTest();
    }
}