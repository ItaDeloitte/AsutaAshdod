// Created: Ortal kazum
// Date: 27.11.2025
// Test: PreventMessagingUtilsTest
public with sharing class PreventMessagingUtils {

    public class PreventMessagingException extends Exception {}

    public static Map<Id, Boolean> isMessagingPrevented(List<Appointment__c> appointments) {
        Map<Id, Boolean> results = new Map<Id, Boolean>();

        if (appointments == null || appointments.isEmpty())
            return results;
       
        Set<Id> siteIds = new Set<Id>();
        Set<Id> calendarIds = new Set<Id>();        
        Set<Id> procedureIds = new Set<Id>();

        for (Appointment__c appointment_i : appointments) {
            if (appointment_i.Medical_Procedure__c != null)
                procedureIds.add(appointment_i.Medical_Procedure__c);
            if (appointment_i.Calendar__c != null)
                calendarIds.add(appointment_i.Calendar__c);
            if (appointment_i.Site__c != null)
                siteIds.add(appointment_i.Site__c);
        }
        return checkMessagingPrevented(appointments, siteIds, calendarIds, procedureIds);
    }   

    // ----------------------------------------------------
    // Core logic – Shared by Flow + Apex
    // ----------------------------------------------------
    private static Map<Id, Boolean> checkMessagingPrevented(List<Appointment__c> appointments, Set<Id> siteIds, Set<Id> calendarIds, Set<Id> procedureIds) {
        Boolean isPreventMessage;
        Map<Id, Boolean> results = new Map<Id, Boolean>();
        Map<Id, List<Appointment_Manager__c>> pMessages = new Map<Id, List<Appointment_Manager__c>>();
        
        try{             
            List<Appointment_Manager__c> prevMessages = [
                SELECT Id
                    , Action_Type__c
                    , Site__c
                    , Calendar__c
                    , Medical_Procedure__c                
                    , Exclude_Messages_From__c
                    , Exclude_Messages_Until__c                 
                FROM Appointment_Manager__c
                WHERE RecordType.DeveloperName = 'PreventMessaging'
                AND Status__c = 'Active'
                AND Action_Type__c = 'PreventMessaging'
                AND (Exclude_Messages_From__c <= TODAY AND Exclude_Messages_Until__c >= TODAY)
                AND Site__c IN :siteIds
                AND (Calendar__c = null OR Calendar__c IN :calendarIds)
                AND (Medical_Procedure__c = null OR Medical_Procedure__c IN :procedureIds)
            ];
            System.debug('prevMessages: size: ' + prevMessages.size() + ' value: ' + prevMessages);

            if (!prevMessages.isEmpty()) {
                for (Appointment_Manager__c prevMessage_i : prevMessages) {
                    if (prevMessage_i.Site__c != null) {
                        if (!pMessages.containsKey(prevMessage_i.Site__c)) {
                            pMessages.put(prevMessage_i.Site__c, new List<Appointment_Manager__c>());
                        }
                        pMessages.get(prevMessage_i.Site__c).add(prevMessage_i);
                    }                  
                }
            }
            
            for (Appointment__c appointment_i : appointments) {
                isPreventMessage = false;
                if (!pMessages.isEmpty()) {
                    List<Appointment_Manager__c> pMessageslst = pMessages.containsKey(appointment_i.Site__c)
                      ? pMessages.get(appointment_i.Site__c) : null;
                    if (pMessageslst != null) {
                        for (Appointment_Manager__c prev_i : pMessageslst) {
                            if ((prev_i.Medical_Procedure__c == null
                                        || prev_i.Medical_Procedure__c == appointment_i.Medical_Procedure__c)
                                    && (prev_i.Calendar__c == null
                                        || prev_i.Calendar__c == appointment_i.Calendar__c)) {
                                isPreventMessage = true;
                                break;
                            }
                        }
                    }
                }
                results.put(appointment_i.Id, isPreventMessage);             
            }           
        } catch(Exception e){
            throw new PreventMessagingException(e.getMessage());            
        } 
        return results;       
    }
    
    public class PreventMessage_Request {
        @InvocableVariable(label='appointmentId' description='appointment record (not just id!)' required=true) 
        public Appointment__c appointment;
    }

    public class PreventMessage_Response {
        @InvocableVariable(label='is_prevented' description='if not sent a whatsapp or SMS message, if success')
        public Boolean isPrevented;
        @InvocableVariable(label='is_success' description='Is Sucess?')
        public Boolean isSuccses;      
        @InvocableVariable(label='errorText' description='Error if not success')
        public String errorText;

        public PreventMessage_Response(Boolean isPrevented) {
            this.isPrevented = isPrevented;
            this.isSuccses = true;
            this.errorText = '';            
        }

        public PreventMessage_Response(Exception e) {
            this.isPrevented = false;
            this.isSuccses = false;
            this.errorText = e.getMessage();           
        }
    }    

    @InvocableMethod(label='Check Prevent Messaging' description='Checks if appointment is within excluded messaging range')
    public static List<PreventMessage_Response> preventMessageFlow(List<PreventMessage_Request> requests) {
        List<PreventMessage_Response> responseList = new List<PreventMessage_Response>();
                    
        try{
            for (PreventMessage_Request req : requests) {
                Map<Id, Boolean> results = isMessagingPrevented(new List<Appointment__c>{ req.appointment });             
                responseList.add(new PreventMessage_Response(results.get(req.appointment.Id)));
            }
        } catch(Exception e){            
            responseList.add(new PreventMessage_Response(e));           
        }
        return responseList;
    }


}