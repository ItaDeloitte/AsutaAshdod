//Test:WA_ReminderBatchableTest
global with sharing class WA_SecondReminderSchedulableBatch implements Schedulable{
        
    global void execute(SchedulableContext SC) {
        String query = 'SELECT Id'
                        + ', Site__c' 
                        + ', Case__c'      
                        + ', First_Name__c'
                        + ', SMS_Address__c'                         
                        + ', Calendar__c'                                                 
                        + ', Site__r.Name'                        
                        + ', day_date_hour__c'
                        + ', Patient_Account__c'            
                        + ', preDateReminderWA__c'
                        + ', Medical_Procedure__c'
                        + ', isPreReminderWASent__c'
                        + ', Domain__r.DomainCode__c' 
                        + ', formtitan_arrival_link__c'
                        + ', Exact_Location_In_Domain__c'                                                                               
                        + ', Medical_Procedure_Marketing_Name__c'                                                  
                        + ', Patient_Account__r.SMS_Phone_Number__c'  
                        + ', Medical_Procedure__r.Virtual_Appointment__c'           			                        
                    + ' FROM Appointment__c'
                        + ' WHERE sendingByWhatsApp__c = true'
                        + ' AND Outbound_WA_Allow__c = true'
                        + ' AND Appointment_Date_Time__c >= TODAY'
                        + ' AND Patient_Account__r.SMS_Phone_Number__c != null'
                        + ' AND ((dateRemainder2WA__c = TODAY AND isRemainder2WAsent__c = false)'
                        + ' OR (preDateReminderWA__c = TODAY AND isPreReminderWASent__c = false))'
                        + ' AND Appointment_Status__c IN (\'WaitingForAppointment\', \'וידוא הגעה לפגישה\')'
                        + ' AND Remainder_status__c NOT IN (\'השיב להודעה בחיוב\', \'השיב להודעה בשלילה\')'                        
                        + ' ORDER BY CreatedDate DESC';                               
        WA_ReminderBatchable batch = new WA_ReminderBatchable(query, 'Second');
        Database.executeBatch(batch, 25);
    }
}