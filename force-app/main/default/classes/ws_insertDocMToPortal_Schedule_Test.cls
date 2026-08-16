@isTest
public with sharing class ws_insertDocMToPortal_Schedule_Test {

    @isTest
    static void scheduleTest() {
        Test.startTest();
        System.schedule('InsertDoc job test', '0 0 0 1 1 ? 2055', new ws_insertDocMToPortal_Schedule());
        Test.stopTest();
    }
}