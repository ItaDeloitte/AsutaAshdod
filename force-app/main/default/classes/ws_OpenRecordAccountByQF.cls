/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          21-11-2019
* @modified         DD-MM-YYYY
* @description      An interface for QF - POP record Account in SF 
                    URL: https://assuta--dev.my.salesforce.com/services/apexrest/OpenRecordAccountByQF     
* @test             ws_OpenRecordAccountByQFTest
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

@RestResource(urlMapping='/OpenRecordAccountByQF/*')
global with sharing class ws_OpenRecordAccountByQF {
    
    public ws_OpenRecordAccountByQF() {}
    public static Map<String, Object> jsonMap = new Map<String, Object> ();
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Post Json From Ensemble In the open screen Account by QF interface.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Json            
    * @return   Success       True/False
                ErrorMessage  Exception/Success
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPost
    global static void getDetailsForOpenAccount() {
        RestRequest req = RestContext.request;
        String jsonRequest = req.requestBody.toString();

        jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
        System.debug('***jsonMap***' + jsonMap); 

        List<Account> account = [SELECT ID FROM Account WHERE ID_Number__c = :String.valueOf(jsonMap.get('PatientId')) AND ID_Type__c = :String.valueOf(jsonMap.get('PatientIdType')) LIMIT 1];
        List<User> user = [SELECT ID , Username FROM User WHERE Username LIKE :String.valueOf(jsonMap.get('UserName')) + '@%' LIMIT 1];

        if(account.size() > 0 && user.size() > 0){
            List<Pop_Record__e> listpopRecord = new List<Pop_Record__e>();
            listpopRecord.add(new  Pop_Record__e(Record_ID__c = account[0].ID, User_ID__c = user[0].ID, Is_Clos_Tab__c = True));
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(listpopRecord);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                        createJsonResponse('0', 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }       
            }
            updateStatusAppointment();
        }else{
            createJsonResponse('1', 'PatientId or UserName parameter not found in System');
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * updateStatusAppointment
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    AppointmentID , AccsionNumber           
    * @return   ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateStatusAppointment() {
        String appId = String.valueOf(jsonMap.get('AppointmentID'));
        String acctNumber = String.valueOf(jsonMap.get('AccsionNumber'));
        List<Appointment__c> appointment = new List<Appointment__c>();

        if(String.isNotBlank(appId)){
            appointment = [SELECT ID ,Appointment_Status__c  FROM Appointment__c WHERE ID = :appId LIMIT 1];
        }else if(String.isNotBlank(acctNumber)){
            appointment = [SELECT ID ,Appointment_Status__c  FROM Appointment__c WHERE Accession_Number__c =:acctNumber LIMIT 1];
        }
            
        if(appointment.size() >0 ){
            appointment[0].Appointment_Status__c = '1';
            try{
                Update appointment;
                createJsonResponse('1', 'Success'); 
            }catch(Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
                createJsonResponse('0', e.getMessage()); 
            }
        }else{
            createJsonResponse('1', 'appointmentID or accsionNumber parameter not found in System');
        } 
    }
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * create Json Response
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Json
    * @return   ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void createJsonResponse (String Success, String ErrorMessage){
        JSONGenerator jsGen = JSON.createGenerator(true);
        RestContext.response.addHeader('Content-Type', 'application/json');
        // Create a JSONGenerator object
        jsGen.writeStartObject();
            jsGen.writeStringField('Success', Success);
            jsGen.writeStringField('ErrorMessage', ErrorMessage);
        jsGen.writeEndObject();
        RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString());
    } 
}