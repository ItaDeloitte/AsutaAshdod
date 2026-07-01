@isTest
private class Bot_CheckTransferPossibleTest {

    @isTest
    static void testCheckWorkingHours() {
        Calendar1__c calendar1 = TestDataFactory.getCalendar1();
        calendar1.Holiday_Description__c = 'hello';
        calendar1.business_day__c = true;
        insert calendar1;

        Test.startTest();
        Bot_CheckTransferPossible.BuisnessDayWrapper wrapper = new Bot_CheckTransferPossible.BuisnessDayWrapper();
        Bot_CheckTransferPossible.checkBuisnessIfno();
        Test.stopTest();
    }

    @isTest
    static void testWithoutCalendar1() {
        Test.startTest();
        Bot_CheckTransferPossible.BuisnessDayWrapper wrapper = new Bot_CheckTransferPossible.BuisnessDayWrapper();
        Bot_CheckTransferPossible.checkBuisnessIfno();
        Test.stopTest();
    }
}