/*
    * @author         Ortal Kazum   <ortalk@assuta.co.il>
    * @Test           SendSMSHandlerTest
    * @modifiedBy     
    * @version        1.0
    * @created        24-12-2019
    * @modified       DD-MM-YYYY
    * @description    Call out to ensemble for send SMS
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class SMSTriggerDispatcher {

    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Checking SMS - Incoming/OutComing if Outgoing send data to Ensemeble
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newList     List of SMS__c
    * @return   ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleOutgoingSMS(List<SMS__c> newList, Map<Id, SMS__c> oldMap) {
        Set<Id> outgoingSMSIds = new Set<Id>();

        for (SMS__c sms_i : newList) {
            if (sms_i.Type__c == 'Outgoing' &&
                sms_i.Content__c != null &&
                sms_i.Phone_Number__c != null &&
                sms_i.ExpectedSendingDateTime__c == null &&
                (oldMap == null || sms_i.Content__c != oldMap.get(sms_i.Id).Content__c)) {
                outgoingSMSIds.add(sms_i.Id);
            }
        }
        System.debug('outgoingSMSIds: size: ' + outgoingSMSIds.size() + ' value: ' + outgoingSMSIds);

        if (!outgoingSMSIds.isEmpty()) {
            System.enqueueJob(new SendSMSHandler(outgoingSMSIds));
        }
    }

    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * In OutComing SMS - edit Content field by templateText field 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newList     List of SMS__c
    * @return   ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void editContentField(List<SMS__c> newList) {
        System.debug('********BEFORE PROCESS OF editContentField: '+newList);
        System.debug('editContentField:');
        Set<Id> SMSIds = new Set<Id>();
        List<String> templateText = new List<String>();
        List<String> eventNames = new List<String>();
        Map<String, String> SMSContentMap = new Map<String, String>();
        Map<String,String> SMSFromMap = new Map<String,String>();

        for (SMS__c sms_i : newList) {
            if (sms_i.Type__c == 'Outgoing' && sms_i.Phone_Number__c != null && sms_i.Template_Text__c != null) {
                templateText.add(sms_i.Template_Text__c.split(',').remove(0));
            }
            if (sms_i.Type__c == 'Outgoing' && sms_i.Phone_Number__c != null && sms_i.Event_Name__c != null){
                eventNames.add(sms_i.Event_Name__c);
            }
        }

        System.debug('templateText: size: ' + templateText.size() + ' value: ' + templateText +' , eventNames:size: '+eventNames.size() + ' value: '+eventNames);
        if (!templateText.isEmpty() || !eventNames.isEmpty()){
            for (SMS_Message__mdt metadata_i : [SELECT Id, DeveloperName, SMS_Content__c,SMS_From__c FROM SMS_Message__mdt WHERE (DeveloperName IN: templateText OR DeveloperName IN:eventNames)]) {
                SMSContentMap.put(metadata_i.DeveloperName, metadata_i.SMS_Content__c);
                System.debug('metadata_i.DeveloperName: ' +metadata_i.DeveloperName+ 'metadata_i.SMS_From__c: '+metadata_i.SMS_From__c);
                SMSFromMap.put(metadata_i.DeveloperName,metadata_i.SMS_From__c); // save 'from' number inside a map to avoid quering the metadata later again 
            }
        }

        System.debug('SMSFromMap: '+SMSFromMap);
        if (!SMSContentMap.isEmpty() || !SMSFromMap.isEmpty()){
            for (SMS__c sms_i : newList) {
                if(sms_i.Template_Text__c != null){
                    String content;
                    System.debug('sms_i.Template_Text__c: ' + sms_i.Template_Text__c);
                    List<String> text = sms_i.Template_Text__c.split(',');
                    System.debug('text: ' + text);
                    String smsName = text.remove(0);
                    if(SMSContentMap.containsKey(smsName)){
                        content = String.format(SMSContentMap.get(smsName), text);                        
                        sms_i.Content__c = content;
                  		sms_i.Content2__c = content;
                        System.debug('sms_i.Content__c: ' + sms_i.Content__c);
                    }
                }
                System.debug('sms_i.Event_Name__c: '+sms_i.Event_Name__c);
                if(sms_i.Event_Name__c != null){ // only if event name exists , take the required From number from the metadata
                    if(SMSFromMap.containsKey(sms_i.Event_Name__c)){
                        sms_i.From_Phone__c = SMSFromMap.get(sms_i.Event_Name__c);
                    }
                }    
            }
        }
        System.debug('********AFTER PROCESS OF editContentField: '+newList);
    }            

    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * In OutComing SMS - edit Content field by smsTemplate__c field 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newList     List of SMS__c
    * @return   ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */ 
    public static void editContentFieldBySmsTemplate(List<SMS__c> newList) {
        System.debug('SMSTriggerDispatcher.editContentFieldBySmsTemplate:');
        Set<String> SMSTemplate = new Set<String>();        
        for (SMS__c sms_i : newList) {
            if (sms_i.Type__c == 'Outgoing' && sms_i.Phone_Number__c != null && sms_i.smsTemplate__c != null) {                
                SMSTemplate.add(sms_i.smsTemplate__c);                
            }
        }
        System.debug('SMSTemplate: size: ' + SMSTemplate.size() + ' value: ' + SMSTemplate);

        if (!SMSTemplate.isEmpty()){
            Map<String, SmsTemplate__c> SMSTemplateMap = new Map<String, SmsTemplate__c>();                            
            for (SmsTemplate__c smsTemp_i : [SELECT developerName__c , Sms_content__c, apiNames__c, ObjectName__c, FromPhone__c 
                                             FROM SmsTemplate__c WHERE developerName__c IN: SMSTemplate]) {                                                
                SMSTemplateMap.put(smsTemp_i.developerName__c, smsTemp_i);             
            }
            System.debug('SMSTemplateMap.size: ' + SMSTemplateMap.size() + ' SMSTemplateMap: ' + SMSTemplateMap);
            if(!SMSTemplateMap.isEmpty()){
                Map<String, List<String>> objApiNameMap = new Map<String, List<String>>();
                Map<String, Set<Id>> objRecordIdMap = new Map<String, Set<Id>>();                        
                Map<Id, Id> smsRecIdMap = new Map<Id, Id>();
                Map<Id, SObject> sObjList = new Map<Id, SObject>(); 
                List<SMS__c> smsToUpdate = new List<SMS__c>(); 
                Set<String> smsTempSet = new Set<String>();
                for (SMS__c sms_i : newList) {
                    SObject objRecord = sms_i;                                      
                    if(SMSTemplateMap.containsKey(sms_i.smsTemplate__c)) { 
                        SmsTemplate__c smsTemp = SMSTemplateMap.get(sms_i.smsTemplate__c); 
                        Id recordId =  (Id)objRecord.get(smsTemp.ObjectName__c);  
                        if(recordId != null) {                              
                            String sObjName = String.valueOf(recordId.getSObjectType());
                            if(smsTemp.apiNames__c != null){
                                if(!smsTempSet.contains(sms_i.smsTemplate__c)) {
                                    if (!objApiNameMap.containsKey(sObjName)) {
                                        objApiNameMap.put(sObjName, new List<String>());
                                        objApiNameMap.get(sObjName).add(smsTemp.apiNames__c);
                                    } else{
                                        System.debug('objApiNameMap.size: ' + objApiNameMap.size() + ' objApiNameMap: ' + objApiNameMap);
                                        String objApiName = String.join(objApiNameMap.get(sObjName), ',');                                        
                                        String apiString = null;                                    
                                        for (String api_i:smsTemp.apiNames__c.split(',')) {                                            
                                            if(!(objApiName.contains(api_i))) {                                        
                                                apiString = apiString == null ? api_i : apiString +  ',' +  api_i; 
                                            }
                                        }
                                        if (apiString!= null) {                      
                                            objApiNameMap.get(sObjName).add(apiString);
                                        }
                                    } 
                                    smsTempSet.add(sms_i.smsTemplate__c);
                                }
                                if(!objRecordIdMap.containsKey(sObjName)){
                                    objRecordIdMap.put(sObjName, new Set<Id>());
                                } 
                                objRecordIdMap.get(sObjName).add(recordId); 
            
                                smsRecIdMap.put(sms_i.Id, recordId);   
                            } 
                        }                    
                    }                               
                }

                System.debug('objApiNameMap.size: ' + objApiNameMap.size() + ' objApiNameMap: ' + objApiNameMap);
                System.debug('objRecordIdMap.size: ' + objRecordIdMap.size() + ' objRecordIdMap: ' + objRecordIdMap);  
                System.debug('smsRecIdMap.size: ' + smsRecIdMap.size() + ' smsRecIdMap: ' + smsRecIdMap);

                if(!objApiNameMap.isEmpty()){
                    for(String obj_i : objApiNameMap.keySet()) {                
                        Set<Id> recordIds = objRecordIdMap.get(obj_i);
                        String soql = String.format(
                        'SELECT {0} FROM {1} WHERE Id IN :{2}', new List<String> {
                            String.join(objApiNameMap.get(obj_i), ','), obj_i, 'recordIds'
                        });                
                        System.debug('query fields: ' + soql.substringBefore(' WHERE'));
                        System.debug('query conditions: ' + soql.substringAfter('WHERE '));                
                        sObjList.putAll(Database.query(soql));
                        System.debug('sObjList: ' + sObjList);
                    }
                }
                                    
                for (SMS__c sms_i: newList) {
                    String content;
                    String content2;
                    SMS__c sms = new SMS__c (Id = sms_i.Id);
                    if (SMSTemplateMap.get(sms_i.smsTemplate__c).apiNames__c != null) {
                        List<String> values = getValuesByApiNames(sObjList.get(smsRecIdMap.get(sms_i.Id)), SMSTemplateMap.get(sms_i.smsTemplate__c).apiNames__c);
                        content = String.format(SMSTemplateMap.get(sms_i.smsTemplate__c).Sms_content__c, values);                        
                        content2 = content;
                        if (SMSTemplateMap.get(sms_i.smsTemplate__c).apiNames__c.contains('formtitan_arrival_link__c')) {
                            content2 = content.substringBefore('https') + content.substringAfter('בברכה,');                         
                        }
                    } else{
                        content = SMSTemplateMap.get(sms_i.smsTemplate__c).Sms_content__c;
                        content2 = content;
                    }
                    sms.Content__c = content;
                    sms.Content2__c = content2;
                    
                    System.debug('sms.From_Phone__c : ' + SMSTemplateMap.get(sms_i.smsTemplate__c).FromPhone__c);
                    sms.From_Phone__c = SMSTemplateMap.get(sms_i.smsTemplate__c).FromPhone__c;                  
                    smsToUpdate.add(sms);                
                    System.debug('sms.Content__c: ' + sms.Content__c);                                                       
                }  
                update smsToUpdate;                                              
            }
        }
    }

    public static List<String> getValuesByApiNames(SObject obj, String apiNames) {        
        System.debug('getValuesByApiNames: ');
        List<String> values = new List<String>();        
        for(String apiName : apiNames.split(',')){
            if(apiName.contains('.')){
                SObject relatedObject = obj;
                List<String> relationsList = apiName.split('\\.');               
                for(Integer i = 0; i < relationsList.size(); i++ ){
                    if(i < relationsList.size() -1){ //it's still an object 
                        if(relatedObject.getSObject(relationsList[i]) != null) {
                        	relatedObject = relatedObject.getSObject(relationsList[i]); 
                        }else {
                           values.add('');
                           break; 
                        }
                    }else{                                                                  
                        values.add(String.valueOf(relatedObject.get(relationsList[i])) != null ? String.valueOf(relatedObject.get(relationsList[i])) : '');                        
                    }
                }
            }else{               
                values.add(String.valueOf(obj.get(apiName)) != null ? String.valueOf(obj.get(apiName)) : '');
            }
        }
        System.debug('values: ' + values);
        return values;
    }
}