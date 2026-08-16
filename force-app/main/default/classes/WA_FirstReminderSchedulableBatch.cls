//Test:WA_ReminderBatchableTest
global with sharing class WA_FirstReminderSchedulableBatch implements Schedulable{
        
    global void execute(SchedulableContext SC) { 
        Integer runTime =  WhatAppUtils.checkBusinessDay(Date.today());      
        if ((runTime != null && datetime.now().hour() == runTime) || Test.isRunningTest()) { 
            String query = 'SELECT Id'
                            + ', Site__c'                          
                            + ', Case__c'
                            + ', Calendar__c'                 
                            + ', First_Name__c'
                            + ', SMS_Address__c'
                            + ', Site__r.Name'
                            + ', day_date_hour__c'
                            + ', Patient_Account__c'
                            + ', Medical_Procedure__c'
                            + ', Domain__r.DomainCode__c'
                            + ', formtitan_arrival_link__c'  
                            + ', Exact_Location_In_Domain__c'                                                          
                            + ', Medical_Procedure_Marketing_Name__c'
                            + ', Patient_Account__r.SMS_Phone_Number__c' 
                            + ', Medical_Procedure__r.Virtual_Appointment__c'                                 
                           + ' FROM Appointment__c'
                            + ' WHERE sendingByWhatsApp__c = true'
                            + ' AND Outbound_WA_Allow__c = true'
                            + ' AND isRemainder1WAsent__c = false'
                            + ' AND dateRemainder1WA__c = TODAY'
                            + ' AND Appointment_Date_Time__c >= TODAY'
                            + ' AND Patient_Account__r.SMS_Phone_Number__c != null'
                            + ' AND Appointment_Status__c IN (\'WaitingForAppointment\', \'וידוא הגעה לפגישה\')'
                            + ' ORDER BY CreatedDate DESC';
            WA_ReminderBatchable batch = new WA_ReminderBatchable(query, 'First');
            Database.executeBatch(batch, 25);
        }
    }
}