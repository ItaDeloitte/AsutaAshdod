/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          16-09-2019
* @modified         DD-MM-YYYY
* @description      An interface for IVR - Get Preffer Channel         
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes 
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/IVR_GetPreferredChannel/*')
global with sharing class ws_IVR_GetPreferredChannel {

    public ws_IVR_GetPreferredChannel() {}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Send indication if the patient get a data in  Preffer Channel to IVR
    * URL: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_GetPreferredChannel?ApptId=sfID    
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    SFId                    Id of appointment
    * @return   HasPreferredChannel     true/false : True - send data in Preffer Channel ,
                                        False - Not send data in Preffer Channel
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPost
    global static void SendDataInPreferredChannel() {
        String appointmentId;
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        
        try{
            // Reading parametr from URL
            appointmentId = restReq.params.get('ApptId');
            if(appointmentId != null){
                List<Appointment__c> appDetails = [SELECT Id, SendPreferredChannel__c, Case__r.preferd_chanal_case__c
                                                   FROM Appointment__c WHERE ID = :appointmentId Limit 1];
                appDetails[0].SendPreferredChannel__c = true;
                Update appDetails[0];

                List<Appointment__c> appAfterUpdate = [SELECT Id, SendPreferredChannel__c FROM Appointment__c WHERE ID = :appointmentId Limit 1];
                if(appAfterUpdate.Size()>0 && !appAfterUpdate[0].SendPreferredChannel__c){
                    CommonService.createJsonResponse('1', 'HasPreferredChannel');
                }else{
                   CommonService.createJsonResponse('0', 'HasPreferredChannel'); 
                }
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            CommonService.createJsonResponse('0', 'HasPreferredChannel');
        } 
    } 

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Send sms to patient for begin chat session
    * URL: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_GetPreferredChannel?PatientId=PatientId&MobilePhone=MobilePhone    
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    PatientId               Id of patient
    * @param    MobilePhone             MobilePhone   of patient
    * @return   Success                 true/false : True - send SMS to patient,
                                        False - Not send SMS to patient
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpGet
    global static void sendSMSForChat() {
        String patientId;
        String mobilePhone;
        String smsType;
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        
        try{
            // Reading parametr from URL       
            patientId = restReq.params.get('PatientId');
            mobilePhone = restReq.params.get('MobilePhone');
            smsType = restReq.params.get('SMSType');  
            Id accountId = null;
            Set<String> templateName = new Set<String>{
                    'IVR_Surgery',
                    'IVR_Chat_General',
                    'IVR_Chat_Expert',
                    'IVR_Chat_WhatsappURL'
            };

            if (!templateName.contains(smsType) && patientId != null && !String.isBlank(patientId)) {
                List<Account> account = [SELECT Id 
                                            FROM Account 
                                            WHERE  ID_Number__c = :patientId 
                                            AND ID_Type__c = '1' 
                                            AND RecordType.DeveloperName = 'PersonAccount' 
                                            LIMIT 1];
                if (!account.isEmpty()) {
                    accountId = account[0].Id; 
                }    
            }         
            if (mobilePhone != null && smsType != null ){
                SMS__c sms= new SMS__c (
                    status__c = '1',                
                    Type__c = 'Outgoing',
                    Account__c = accountId,
                    Phone_Number__c = mobilePhone,
                    SmsTemplate__c = smsType,
                    Received_Sent_Date_Time__c = datetime.now(),                
                    Automation_name__c = 'ws_IVR_GetPreferredChannel'
                );
                insert sms;
            }
            CommonService.createJsonResponse('1', 'Success');
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            CommonService.createJsonResponse('0', e.getMessage());  
        } 
    } 
}