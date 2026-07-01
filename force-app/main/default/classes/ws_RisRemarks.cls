/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          25-03-2025
* @modified         DD-MM-YYYY
* @description      An interface for update remarks in the RIS System for waitinig list
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

public with sharing class ws_RisRemarks {
    
    public ws_RisRemarks() {}

     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive a list of notes according to Diary information
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    remark            contains :  "תור שמור SF"/ "תור שמור לזימון אוטומטי SF"
    * @param    activity          Medical_Procedure__r.Name
    * @param    activityCode      Medical_Procedure__r.Procedure_Code__c
    * @param    calendarCode      Calendar__r.ServiceId__c
    * @param    appDate           Appointment_Date_Time__c
    * @param    appDuration       Duration__c   
    * @return   result            Success/failer                         
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */    
    public static Map<String, Object> updateRemark(String remark, String activity, String activityCode, String calendarCode, String appDate, Integer appDuration) {
        ENV__c env = ENV__c.getInstance();               
        User user = obtainUser();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');        
        request.setEndpoint('callout:Ensemble_Rest_' + env.Env_value__c + '/SF2Ris/add-remark-to-appointment');        
        try {
            JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('UserId', user.User_AD__c);
                gen.writeStringField('Remark', remark);
                gen.writeStringField('Activity', activity);
                gen.writeStringField('ActivityCode', activityCode);
                gen.writeStringField('CalendarCode', calendarCode);
                gen.writeStringField('AppointmentDate', appDate);
                gen.writeNumberField('AppointmentDuration', appDuration);            
                gen.writeEndObject();                
            String jsonStr = gen.getAsString();
            request.setBody(jsonStr);
        
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('The status code returned: ' + response.getStatusCode() + ' ' + response.getStatus());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return results;
            }    
            return null;       
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to ws_RisRemarks: ' + e.getMessage());
            return null;
        }
    }
    
    private static User obtainUser() {
        return [SELECT Name
                     , User_AD__c                     
                  FROM User
                 WHERE Id = :UserInfo.getUserId()];
    }
}