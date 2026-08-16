/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          10-10-2019
* @modified         DD-MM-YYYY
* @description      An interface for display Diaries of RIS/QFLOW 
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class ws_Diaries {
    public ws_Diaries() {}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive a list of notes according to Diary information
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Date            Current Date
    * @param    SiteCode        Site Code of Appointment
    * @param    AppointmentSys  Diary system code
    * @param    CalendarCode    Site Code of Appointment
    * @return   result          Diary notes list                           
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)   
    public static List<Map<String, Object>> GetDiaries (Date diaryDate, String siteCode, String appointmentSys, String diaryCode, Boolean restrictionsOnly) {
        ENV__c env = ENV__c.getInstance();       
        List<Map<String, Object>> data = new List<Map<String, Object>>();
        List<Map<String, Object>> dataRecords = new List<Map<String, Object>>();
        Map<String, Calendar__c> calendarMap = new Map<String, Calendar__c>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');        
        request.setEndpoint('callout:Ensemble_Rest_' + env.Env_value__c + '/Diaries/SFDiaries/GetDiaries');
       
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('Date', String.valueOf(diaryDate));
            gen.writeStringField('SiteCode', siteCode);
            gen.writeStringField('AppointmentSys', appointmentSys);
            gen.writeStringField('CalendarCode', diaryCode);
            gen.writeBooleanField('RestrictionsOnly', restrictionsOnly);            
            gen.writeEndObject();
        String sendMsg = gen.getAsString();
        request.setBody(sendMsg);
        try{
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> record_i;
                for (Object record : (List<Object>)results.get('diaryRecords')) {
                    record_i = (Map<String, Object>)record;
                    if (record_i.get('calendarCode') != null) {
                        calendarMap.put(String.valueOf(record_i.get('calendarCode')), null);
                    }
                    data.add((Map<String, Object>)record_i);
                }
                if (!calendarMap.isEmpty()) {
                    calendarMap = getCalendarName(calendarMap);
                }
                dataRecords = (!data.isEmpty()) ? checkColorRow(data, calendarMap) : data;
            }      
            
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to GetDiaries: ' + e.getMessage());
        }
        return dataRecords;
    }

    private static List<Map<String, Object>> checkColorRow(List<Map<String, Object>> data, Map<String, Calendar__c> calendarMap){
        System.debug('ws_Diaries.checkColorRow: data' + data); 
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        if(data.size() != 1){
            for(Integer i = 0; i < data.size() ; i++){
                Map<String, Object> record_i = data[i];
                record_i.put('name', data[i].get('firstName') + ' ' + data[i].get('lastName'));
                record_i.put('calenderName', calendarMap.get(String.valueOf(data[i].get('calendarCode'))).Name); 
                record_i.put('siteCode', calendarMap.get(String.valueOf(data[i].get('calendarCode'))).BranchName__r.Site_Code__c);
                if(i+1 != data.size()){
                    if(checkTimeOfRecord(data[i], data[i+1])){
                        record_i.put('dateColorCSSClass', 'color-grey');
                        record_i.put('startTimeColorCSSClass', 'color-grey');
                        record_i.put('endTimeColorCSSClass', 'color-grey');
                        record_i.put('typeColorCSSClass', 'color-grey');
                        record_i.put('descriptionColorCSSClass', 'color-grey');
                        record_i.put('nameColorCSSClass', 'color-grey');
                        record_i.put('patientIdColorCSSClass', 'color-grey');
                    }
                }
                records.add(record_i);   
            } 
        }else{
            Map<String, Object> record_i = data[0];
            record_i.put('name', data[0].get('firstName') + ' ' + data[0].get('lastName'));
            records.add(record_i);  
        }
        return records;
    } 
    
    private static Boolean checkTimeOfRecord(Map<String, Object> firsRecord, Map<String, Object> secondRecord){
        System.debug('ws_Diaries.checkTimeOfRecord'); 
        Time endTimeFirsRecord = convertObjectToTime(String.valueOf(firsRecord.get('endTime')));
        Time startTimeSecondRecord = convertObjectToTime(String.valueOf(secondRecord.get('endTime')));
        if(((firsRecord.get('startTime') == secondRecord.get('startTime')) || 
            endTimeFirsRecord > startTimeSecondRecord ||
            (endTimeFirsRecord.hour() == 0 && startTimeSecondRecord.hour() < 24)
            ) &&
            (firsRecord.get('type') != secondRecord.get('type'))){
            return true;
        }
        return false;
    }

    private static Time convertObjectToTime(String timeRecord){
        System.debug('ws_Diaries.convertObjectToTime'); 
        String[] objTimeSplit = timeRecord.split(':');
        Time timeCheck = Time.newInstance(Integer.valueOf(objTimeSplit[0])
                                        ,Integer.valueOf(objTimeSplit[1])
                                        ,0
                                        ,0);
        return timeCheck;
    }

    private static Map<String, Calendar__c> getCalendarName(Map<String, Calendar__c> calendarMap) {
        for(Calendar__c  calendar_i : [SELECT Id, Name, ServiceId__c, BranchName__r.Site_Code__c FROM Calendar__c WHERE ServiceId__c IN: calendarMap.keySet() AND AppointmentSys__c = 'RIS' ]) {
            calendarMap.put(calendar_i.ServiceId__c, calendar_i);
        }
        return calendarMap;
    }    
}