@IsTest
private class Bot_BusinessHoursServiceTest {

    private static BusinessHours getAnyBusinessHours() {
        List<BusinessHours> bhList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
        return bhList.isEmpty() ? null : bhList[0];
    }

    @IsTest
    static void test_WithExistingBH() {

        BusinessHours bh = getAnyBusinessHours();

        Calendar1__c cal = TestDataFactory.getCalendar1();
        cal.Gregorian_Date__c = Date.today();
        cal.business_day__c = true;
        insert cal;

        Bot_Business_Hours__c dbh = new Bot_Business_Hours__c(
            Name = 'TestBot',
            Is_active__c = true,
            Business_Hours__c = bh != null ? bh.Id : null
        );
        insert dbh;

        Bot_BusinessHoursService.BotRequest req = new Bot_BusinessHoursService.BotRequest();
        req.botName = 'TestBot';

        Test.startTest();
        List<Bot_BusinessHoursService.BotAvailabilityResult> results =
            Bot_BusinessHoursService.evaluateBotsAvailability(
                new List<Bot_BusinessHoursService.BotRequest>{req}
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(Date.today(), results[0].day);        
        System.assertNotEquals(null, results[0].isAvailable);
    }

    @IsTest
    static void testNotBusinessDay() {
        Calendar1__c cal = TestDataFactory.getCalendar1();
        cal.Gregorian_Date__c = Date.today();
        cal.business_day__c = false;
        insert cal;        

        Bot_Business_Hours__c dbh = new Bot_Business_Hours__c(
            Name = 'TestBot',
            Is_active__c = true
        );
        insert dbh;

        Bot_BusinessHoursService.BotRequest req = new Bot_BusinessHoursService.BotRequest();
        req.botName = 'TestBot';

        Test.startTest();
        List<Bot_BusinessHoursService.BotAvailabilityResult> results =
            Bot_BusinessHoursService.evaluateBotsAvailability(
                new List<Bot_BusinessHoursService.BotRequest>{req}
            );
        Test.stopTest();

        System.assertEquals(false, results[0].isAvailable);
    }

    @IsTest
    static void testInactiveDBH() {

         Calendar1__c cal = TestDataFactory.getCalendar1();
        cal.Gregorian_Date__c = Date.today();
        cal.business_day__c = true;
        insert cal;

        Bot_Business_Hours__c dbh = new Bot_Business_Hours__c(
            Name = 'TestBot',
            Is_active__c = false
        );
        insert dbh;

        Bot_BusinessHoursService.BotRequest req = new Bot_BusinessHoursService.BotRequest();
        req.botName = 'TestBot';

        Test.startTest();
        List<Bot_BusinessHoursService.BotAvailabilityResult> results =
            Bot_BusinessHoursService.evaluateBotsAvailability(
                new List<Bot_BusinessHoursService.BotRequest>{req}
            );
        Test.stopTest();

        System.assertEquals(false, results[0].isAvailable);
    }

    @IsTest
    static void testNoRequests() {

        Test.startTest();
        List<Bot_BusinessHoursService.BotAvailabilityResult> results =
            Bot_BusinessHoursService.evaluateBotsAvailability(null);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isAvailable);
    }

    @IsTest
    static void testNoDBHRecord() {

         Calendar1__c cal = TestDataFactory.getCalendar1();
        cal.Gregorian_Date__c = Date.today();
        cal.business_day__c = true;
        insert cal;

        Bot_BusinessHoursService.BotRequest req = new Bot_BusinessHoursService.BotRequest();
        req.botName = 'NotExistBot';

        Test.startTest();
        List<Bot_BusinessHoursService.BotAvailabilityResult> results =
            Bot_BusinessHoursService.evaluateBotsAvailability(
                new List<Bot_BusinessHoursService.BotRequest>{req}
            );
        Test.stopTest();

        System.assertEquals(false, results[0].isAvailable);
    }
}