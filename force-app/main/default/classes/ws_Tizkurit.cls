/*
* @author         Ortal Kazum   <ortalk@assuta.co.il>
* @Test           ws_TizkuritTest
* @modifiedBy     
* @version        1.0
* @created        01-07-2019
* @modified       DD-MM-YYYY
* @description    An interface for remember a appointment in Tizkurit system              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/Reminder__c/*')
global class ws_Tizkurit {

    global class StatusTizkuritRequest{
        public String methodName; 
        public Record[] records;
    }

    global class Record{
        public String accessionNumber;    
        public String followUpTypeCode;
        public Integer numOfDialTries;
        public Time timeOfCallTry;
        public Date dateOfCallTry;
    }
    
    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Post Json From Ensemble In the Tizkurit interface.
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    Json
        * @return   ---
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    @HttpPost
    global static void getJsonFromEnsemble() {
        RestRequest req = RestContext.request;
        String jsonRequest = req.requestBody.toString();

        try{
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest); 
        
            if(String.valueof(jsonMap.get('methodName')) == 'updateIsReminderField'){
                UpdateIsReminderField(String.valueof(jsonMap.get('reminderIds'))); 
            }
            else if(String.valueof(jsonMap.get('methodName')) == 'UpdateReminderObj'){
                UpdateReminderObj(jsonRequest);
            }
        }catch(Exception e){
            //System.debug('The following exception has occurred: ' + e.getMessage());
            JSONGenerator jsGen = JSON.createGenerator(true);
            RestContext.response.addHeader('Content-Type', 'application/json');
            jsGen.writeStartObject();
                jsGen.writeStringField('Success','0');
                jsGen.writeStringField('ErrorMessage',e.getMessage());
            jsGen.writeEndObject();
            RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString()); 
        } 
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Update field Is_Reminder__c = True about  all records that select from ensembele to Tizkurit 
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    ReminderIds       All Ids that will send to Tizkurit
        * @return   JsonResponse      Success, ErrorMessage
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    public static void UpdateIsReminderField(String reminderIds){
        Set<Id> reminderIdSet = new Set<Id>();
        List<Reminder__c> isReminderToUpdate = new List<Reminder__c>();

        List<String> reminderIdLst = reminderIds.split(',');  
        for(String rem_i :reminderIdLst){
            reminderIdSet.add(Id.valueOf(rem_i));
        }
        
        for(Reminder__c reminder_i :[SELECT Id, Is_Reminder__c FROM Reminder__c WHERE ID IN :reminderIdSet]){
            reminder_i.Is_Reminder__c = True;
            isReminderToUpdate.add(reminder_i);
        }
        if(!isReminderToUpdate.isEmpty()){
            updateRecordsAndcreateJsonResponse(isReminderToUpdate);
        }
    } 
    
    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Update followUpTypeCode, numOfDialTries, timeOfCallTry, dateOfCallTry fields in Reminder Obj
        * according to Tizkurit system.
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jsonRequest       List of Reminder__c
        * @return   JsonResponse      Success, ErrorMessage
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    public static void UpdateReminderObj(String jsonRequest){
        Map<String, Record> remindersMap = new Map<String, Record>();
        List<Record> recordReminder = new List<Record>();
        List<Reminder__c> reminderStatusToUpdate = new List<Reminder__c>();

        StatusTizkuritRequest statusTizkuritReq= (StatusTizkuritRequest)JSON.deserialize(jsonRequest,StatusTizkuritRequest.class);
        System.debug('statusTizkuritReq' + statusTizkuritReq);
        for(Integer i = 0; i<statusTizkuritReq.records.Size(); i++){
            remindersMap.put(statusTizkuritReq.records[i].accessionNumber, statusTizkuritReq.records[i]);
        }
        System.debug('remindersMap  '+ remindersMap);
        List<Reminder__c> RemindLst = [SELECT Accession_Number__c, Reminder_Status__c, num_of_dial_tries__c, time_of_call_try__c, date_of_call_try__c
                                        FROM Reminder__c WHERE Accession_Number__c IN :remindersMap.keySet() ORDER BY CreatedDate  DESC];
        System.debug('****Size of list****' + RemindLst.Size());
        if(!RemindLst.isEmpty()){
            for(Reminder__c Reminder_i :RemindLst){
                System.debug('****remindersMap****' + remindersMap.get(Reminder_i.Accession_Number__c));
                if(remindersMap.get(Reminder_i.Accession_Number__c) != null){
                    Reminder_i.Reminder_Status__c = remindersMap.get(Reminder_i.Accession_Number__c).followUpTypeCode;
                    Reminder_i.num_of_dial_tries__c = remindersMap.get(Reminder_i.Accession_Number__c).numOfDialTries;
                    Reminder_i.time_of_call_try__c = remindersMap.get(Reminder_i.Accession_Number__c).timeOfCallTry;
                    Reminder_i.date_of_call_try__c = remindersMap.get(Reminder_i.Accession_Number__c).dateOfCallTry;
                    reminderStatusToUpdate.add(Reminder_i); 
                }
            }
            if(!reminderStatusToUpdate.isEmpty()){
                updateRecordsAndcreateJsonResponse(reminderStatusToUpdate);
            }
        } 
    }    
    
	/**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * Update Reminder obj and return json success/fail.
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    reminderToUpdateLst       List of Reminder__c
        * @return   json                      Success                         
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    public static void updateRecordsAndcreateJsonResponse (List<Reminder__c> reminderToUpdateLst){
        JSONGenerator jsGen = JSON.createGenerator(true);
        RestContext.response.addHeader('Content-Type', 'application/json');
        Database.SaveResult [] updateLst = Database.update(reminderToUpdateLst, false);
        jsGen.writeStartArray();
        for (Database.SaveResult ur : updateLst){
            if (ur.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                jsGen.writeStartObject();
                    jsGen.writeStringField('Success','1');
                    jsGen.writeStringField('ErrorMessage','Successfully updated reminder. Reminder ID: ' + ur.getId());
                jsGen.writeEndObject();
            } 
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : ur.getErrors()) {                  
                    jsGen.writeStartObject();
                        jsGen.writeStringField('Success','0');
                        jsGen.writeStringField('ErrorMessage',  'The following error has occurred. ' 
                                                                + err.getStatusCode() + ': ' + err.getMessage() +
                                                                '. Reminder fields that affected this error:' + err.getFields());
                    jsGen.writeEndObject();
                }
            }
        }
        jsGen.writeEndArray();             
        // Create a JSONGenerator object
        RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString());
    } 
}