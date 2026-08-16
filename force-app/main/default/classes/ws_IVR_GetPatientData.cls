/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          27-08-2019
* @modified         DD-MM-YYYY
* @description      An interface for IVR - GetPatientData 
                    URL: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_getPatientData?PatientId=PatientId          
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

@RestResource(urlMapping='/IVR_getPatientData/*')
global  class ws_IVR_GetPatientData {

    public ws_IVR_GetPatientData() {}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrive appointments details and agentId for Disease management according to Id of patient
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    PatientId       Id of patient
    * @return   jsonRes         patient data : all appointment and agentId for Disease management 
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpGet
    global static void getPatientData() {
        RestRequest restReq = RestContext.request;
        String patientId = restReq.params.get('PatientId');
        
        String agentId = '';
        Boolean fourthAge = false;
        List<Appointment__c> appLst = new List<Appointment__c>();
        Map<Id, String> recordingCodeMap = new Map<Id, String>();
        
        if (String.isNotBlank(patientId)) {           
            List<Account> account360 = [SELECT Id
                                            , Age_Number__c 
                                            , X360_patient_checkbox__c
                                            , X360_Coordinator__r.Agent_ID__c                                            
                                        FROM Account 
                                        WHERE ID_Number__c = :patientId 
                                        LIMIT 1];
            if (!account360.isEmpty()) {
                if (account360.get(0).X360_patient_checkbox__c && 
                        account360.get(0).X360_Coordinator__r != null && 
                        account360.get(0).X360_Coordinator__r.Agent_ID__c != null) {
                    agentId = account360.get(0).X360_Coordinator__r.Agent_ID__c;
                } 
                if (account360.get(0).Age_Number__c != null && account360.get(0).Age_Number__c >= Integer.valueOf(System.Label.Fourth_Age)) {
                    fourthAge = true;
                } 
            }
            appLst = getInstitutesAppointment(patientId);
            recordingCodeMap = setRecordingCode(appLst);        
            createPatientDataResponse(getInstitutesAppointment(patientId), recordingCodeMap, agentId, fourthAge);
        }
    }

    public static List<Appointment__c> getInstitutesAppointment(String patientId) {
        Datetime currentDatetime = System.now();
        return [SELECT Id, Appointment_Date_Time__c , Time_of_appointment__c, Week_Day__c, Date_of_appointment__c,Site__r.Site_Code__c, 
                        Guidance_Scenario__r.Recording_Code_1__c, Guidance_Scenario__r.Recording_Code_2__c, Guidance_Scenario__r.Recording_Code_3__c,
                        Guidance_Scenario__r.Recording_Code_4__c, Guidance_Scenario__r.Recording_Code_5__c, Guidance_Scenario__r.Recording_Code_6__c,
                        Medical_Procedure__r.Domain__r.Recording_Code__c, Medical_Procedure__r.Confidentiality__c, Patient_Account__r.ID_Number__c, 
                        Domain__r.VDN__r.CodeVDN__c, Medical_Procedure__r.Domain__r.VDN__r.CodeVDN__c 
                FROM Appointment__c 
                WHERE Patient_Account__r.ID_Number__c = :patientId 
                AND (Appointment_Status__c = 'WaitingForAppointment' OR Appointment_Status__c = 'וידוא הגעה לפגישה')
                AND RecordType.DeveloperName = 'Institutes'
                AND Medical_Procedure__r.Confidentiality__c = False
                //AND Medical_Procedure__r.Recording_Code__c != null
                //AND Medical_Procedure__r.Domain__r.Recording_Code__c != null
                AND Site__c != null
                AND Appointment_Date_Time__c >= :currentDatetime
                ORDER BY Appointment_Date_Time__c
                LIMIT 4];
    }

    public static Map<Id, String> setRecordingCode(List<Appointment__c> appLst) {
        Map<Id, String> recordingCodeMap = new Map<Id, String>();

        for (Appointment__c app_i : appLst) {
            if (app_i.Guidance_Scenario__c != null) {
                Integer  counter = 0;
                String recordingCode = null;
                System.debug('app_i... ' +  app_i);
                if (app_i.Guidance_Scenario__r.Recording_Code_1__c != null){
                    counter ++;
                } 
                if (app_i.Guidance_Scenario__r.Recording_Code_2__c != null){
                    counter ++;
                }
                if (app_i.Guidance_Scenario__r.Recording_Code_3__c != null){
                    counter ++;
                }
                if (app_i.Guidance_Scenario__r.Recording_Code_4__c != null){
                    counter ++;
                }
                if (app_i.Guidance_Scenario__r.Recording_Code_5__c != null){
                    counter ++;
                }
                if (app_i.Guidance_Scenario__r.Recording_Code_6__c != null){
                    counter ++;
                }
                System.debug('counter... ' +  counter);
                for (integer i = 1; i <= counter; i++) {
                    switch on i {
                        when 1{
                            recordingCode = app_i.Guidance_Scenario__r.Recording_Code_1__c + ',';
                            Continue; 
                        }
                        when 2 {
                            recordingCode += app_i.Guidance_Scenario__r.Recording_Code_2__c + ',';
                            Continue;
                        }
                        when 3 {
                            recordingCode += app_i.Guidance_Scenario__r.Recording_Code_3__c  + ',';
                            Continue; 
                        }
                        when 4 {
                            recordingCode += app_i.Guidance_Scenario__r.Recording_Code_4__c  + ',';
                            Continue; 
                        }
                        when 5 {
                            recordingCode += app_i.Guidance_Scenario__r.Recording_Code_5__c  + ',';
                            Continue; 
                        }
                        when else{
                            recordingCode += app_i.Guidance_Scenario__r.Recording_Code_6__c  + ',';
                            Continue; 
                        } 
                    }
                }

                System.debug('recordingCode ' + recordingCode);   
                recordingCodeMap.put(app_i.Id, recordingCode != null ? recordingCode.removeEnd(',') : ''); 
            }else{
                recordingCodeMap.put(app_i.Id, ''); 
            }
        }
        System.debug('recordingCodeMap...' + recordingCodeMap);
        return recordingCodeMap;
    }  

    public static void createPatientDataResponse(List<Appointment__c> appLst, Map<Id, String> recordingCodeMap, String agentId, Boolean fourthAge) { 
        RestResponse restRes = RestContext.response;

        JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject(); 
                    gen.writeFieldName('Appointments');
                        gen.writeStartArray();
                        if(appLst.Size()> 0){
                            for (Appointment__c app_i : appLst) {
                                gen.writeStartObject();
                                    //(app_i.Time_of_appointment__c.hour() + ':' + app_i.Time_of_appointment__c.minute()));
                                    gen.writeStringField('Hour', app_i.Appointment_Date_Time__c.format('HH:mm'));
                                    gen.writeStringField('Day', app_i.Week_Day__c); 
                                    gen.writeStringField('Date', String.valueOf(app_i.Date_of_appointment__c));
                                    if(app_i.Site__r != null && app_i.Site__r.Site_Code__c != null) {
                                        gen.writeStringField('SiteCode', app_i.Site__r.Site_Code__c);
                                    }else{
                                        gen.writeStringField('SiteCode','');
                                    }
                                    gen.writeStringField('ApptId', String.valueOf(app_i.Id));
                                    if(app_i.Medical_Procedure__r != null && app_i.Medical_Procedure__r.Domain__r != null && app_i.Medical_Procedure__r.Domain__r.Recording_Code__c != null) {
                                        gen.writeStringField('AreaIvrCode', app_i.Medical_Procedure__r.Domain__r.Recording_Code__c);
                                    }else{
                                        gen.writeStringField('AreaIvrCode','');
                                    }
                                    gen.writeStringField('Annc', recordingCodeMap.get(app_i.Id));
                                    if(app_i.Medical_Procedure__r != null && app_i.Medical_Procedure__r.Domain__r != null && app_i.Medical_Procedure__r.Domain__r.VDN__r != null 
                                       && app_i.Medical_Procedure__r.Domain__r.VDN__r.CodeVDN__c != null){
                                        gen.writeStringField('VDN', app_i.Medical_Procedure__r.Domain__r.VDN__r.CodeVDN__c);
                                    }else{
                                        gen.writeStringField('VDN','');
                                    }  
                                gen.writeEndObject(); 
                            } 
                        }                          
                        gen.writeEndArray(); 
                        gen.writeStringField('360AgentId', agentId); 
                        gen.writeBooleanField('FourthAge', fourthAge);
                gen.writeEndObject();
        try{
            String jsonStr = gen.getAsString();
            System.debug('jsonStr: '+ jsonStr);
            restRes.addHeader('Content-Type', 'application/json');
            restRes.responseBody = Blob.valueOf(jsonStr);       
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling to getPatientData:  ' + e.getMessage());
        }
    }
}