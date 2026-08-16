/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          15-09-2019
* @modified         DD-MM-YYYY
* @description      An interface for IVR - PlayInstructions
                    URL: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_PlayInstructions         
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes 
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/IVR_PlayInstructions/*')
global class ws_IVR_PlayInstructions {

    public ws_IVR_PlayInstructions() {}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * getIVRLines
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    ----- 
    * @return   GetIVRLinesSalesForceResult          true/false                        
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)   
    public static boolean getIVRLines(){
        boolean res;
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/SF2IVRInterfaces/SFIVR/getIVRLines');
        try{
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                res = (Boolean) (results.get('GetIVRLinesSalesForceResult'));
            } 
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to getIVRLines:  ' + e.getMessage());
        }
         return res;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive  Instructions of  according to patient details
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    patientId                    Patient ID number  
    * @param    agentId                      agent ID number
    * @param    extension                    extension number
    * @param    aptSFID                      All appointment id of the Patient
    * @return   makeTransferIVRInfor..       Success/ Error                         
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=false)   
    public static String makeTransferIVRInfo(String patientId, String agentId, String extension, String [] aptSFID){
        ENV__c env = ENV__c.getInstance();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String res = '';

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_'+env.Env_value__c+'/SF2IVRInterfaces/SFIVR/playInstructions');
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
                if(patientId != null){
                    gen.writeStringField('PatientId', patientId);
                }
                if(agentId != null){
                    gen.writeStringField('AgentId', agentId);
                }
                if(extension != null){
                    gen.writeStringField('Extension', extension);
                }
                if(aptSFID != null){
                    gen.writeFieldName('AptSFID');
                    gen.writeStartArray();
                        for(String app_i:aptSFID){
                            gen.writeString(app_i);
                        } 
                    gen.writeEndArray(); 
                }     
            gen.writeEndObject();
        String sendMsg = gen.getAsString();
        System.debug('sendMsg ' + sendMsg);
        request.setBody(sendMsg);
        try{
            System.debug('request ' + request);
            HttpResponse response = http.send(request);
            System.debug('response: '+response);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                res = String.valueOf(results.get('makeTransferIVRInfoSalesFrcRslt')); 
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to playInstructions:  ' + e.getMessage());
        }
        return res;
    }

    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * get IVR Summary By Representative 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * URL:https://assutdev.my.salesforce.com/services/apexrest/IVR__PlayInstructions?ApptId=ApptId&IsApproved=IsApproved
    * @param    Json       {"ApptId":"SFID_IN_HERE",
                            "IsApproved":true}

    * @return   jsonRes   Success/ Failure   
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */

    @HttpGet
    global static void getIVRSummaryByRepresentative() {
        
        String apptId;
        Boolean isApproved;
        
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
       // Reading parametrs from URL
        apptId = restReq.params.get('ApptId');
        system.debug('*******IsApproved******' +  restReq.params.get('IsApproved'));
        isApproved = boolean.valueOf(restReq.params.get('IsApproved'));
        
        if(apptId != null) {
            List<Appointment__c> appList = [Select Id, Have_you_read_medical_instructors__c  FROM Appointment__c WHERE Id =:ApptId LIMIT 1];
            if(appList.Size() > 0){
                appList[0].Have_you_read_medical_instructors__c = isApproved;
                try{
                    update appList;
                    CommonService.createJsonResponse('1', 'Success'); 
                }catch(Exception e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    CommonService.createJsonResponse('0', e.getMessage()); 
                } 
            }else{
                CommonService.createJsonResponse('0', 'apptId doesnt exist'); 
            }
        }else{
            CommonService.createJsonResponse('0', 'apptId is null'); 
        }
    } 

    @AuraEnabled(cacheable=false)   
    public static void updateDateInstuctionReadField(List<Id> appIds){
        List<Appointment__c> appList = [Select Id, Date_Instuction_Read__c FROM Appointment__c WHERE Id IN :appIds];
        for (Appointment__c app_i : appList) {
            app_i.Date_Instuction_Read__c = datetime.now();
        }
        update appList;
    }
}