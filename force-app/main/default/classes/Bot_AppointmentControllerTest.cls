@isTest
public with sharing class Bot_AppointmentControllerTest {

    @isTest 
    static void initTest() {
        Test.startTest();
        Bot_AppointmentController controller = new Bot_AppointmentController();
        Test.stopTest();  
    }   

}