/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          15-05-2022
* @modified         DD-MM-YYYY
* @description      An interface for Ris Statues  
* @test             ws_RisStatusesTest
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

@RestResource(urlMapping='/RIS_Statuses/*')
global class ws_RisStatuses {

    private static List<Appointment__c> apps;
    private static Map<String, Object> jsonMap;

    @HttpPost
    global static void getRisStatues() {        
        RestRequest req = RestContext.request;
        String jsonRequest = req.requestBody.toString();
        List<RisStatus__e> risStatusEvents = new List<RisStatus__e>();

        try{
            system.debug('ws_RisAppStatuses.getRisStatues');
            jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            System.debug('jsonMap: ' + jsonMap);

            String accNumber = String.valueOf(jsonMap.get('AccessionNumber'));
            apps = [SELECT Id, Accession_Number__c, Patient_Account__c 
                                        FROM Appointment__c 
                                        WHERE  Accession_Number__c = :accNumber 
                                        LIMIT 1];
            
            if (!apps.isEmpty())  {                
                risStatusEvents.add(
                    new RisStatus__e(
                        AnswerStatus__c = String.valueOf(jsonMap.get('AnswerStatus')),
                        RecommendationCode__c = String.valueOf(jsonMap.get('RecommendationCode')),
                        AccessionNumber__c = accNumber,
                        HasFinding__c = String.valueOf(jsonMap.get('HasFinding')),
                        Birad__c = String.valueOf(jsonMap.get('Birad')),
                        RecommendationDescription__c = String.valueOf(jsonMap.get('RecommendationDescription'))
                    )
                );         
                System.debug('risStatusEvents: size: ' + risStatusEvents.size() + ' value: ' + risStatusEvents);
                EventBus.publish(risStatusEvents); 
                updateAppointment();
                updateAccount();
                createJsonResponse('true', '');    
            } else {
                createJsonResponse('false', 'Appointment not exist');  
            } 
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            createJsonResponse('false', e.getMessage());  
        }                
    }

    private static void updateAppointment () {
        Boolean isUpdate = false;
        Appointment__c app = apps[0];
        if (String.valueOf(jsonMap.get('SignatureDateTime')) != null) {
            app.RIS_Signature_date_time__c = DateTime.valueOf(String.valueOf(jsonMap.get('SignatureDateTime')));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('SignedDoctorNumber')) != null) {
            String signedDoctor = String.valueOf(jsonMap.get('SignedDoctorNumber'));
            List<Account> doctorAcc = [SELECT Id, Doctor_Code__c 
                                      FROM Account 
                                      WHERE Doctor_Code__c  =: signedDoctor 
                                      LIMIT 1];
            if(!doctorAcc.isEmpty()){
                app.SignedBy__c = doctorAcc[0].Id;
                isUpdate = true;
            }
        }
        if (String.valueOf(jsonMap.get('TypistName')) != null) {
             app.TypedBy__c  = String.valueOf(jsonMap.get('TypistName'));
             isUpdate = true;
        }              
        if (String.valueOf(jsonMap.get('RecommendationNotes')) != null) {
           app.Remarks__c = String.valueOf(jsonMap.get('RecommendationNotes'));
           isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('AnswerStatus')) != null) {
            app.RisAnswerStatus__c = String.valueOf(jsonMap.get('AnswerStatus'));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('StatusChangeDateTime')) != null) {
           app.RISStatusChangeDateTime__c = DateTime.valueOf(String.valueOf(jsonMap.get('StatusChangeDateTime')));
           isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('ReferringDoctorNumber')) != null) {
            app.Referral_Doctor_Text__c =  String.valueOf(jsonMap.get('ReferringDoctorNumber'));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('OrderNotes')) != null) {
            app.Order_Notes__c = String.valueOf(jsonMap.get('OrderNotes'));
             isUpdate = true;
        }        
        if (String.valueOf(jsonMap.get('AppointmentNotes')) != null){
           app.RisAppointmentNotes__c = String.valueOf(jsonMap.get('AppointmentNotes'));
           isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('TechnicianNotes')) != null) {
            app.TechnicianNotes__c = String.valueOf(jsonMap.get('TechnicianNotes'));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('TypistNotes')) != null) {
            app.Typing_Notes__c = String.valueOf(jsonMap.get('TypistNotes'));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('RadiologistNotes')) != null) {
            app.RadioLogistNotes__c = String.valueOf(jsonMap.get('RadiologistNotes'));
            isUpdate = true;
        }
        if(String.valueOf(jsonMap.get('TypistDateTime')) != null) {
            System.debug('TypistDateTime ' + String.valueOf(jsonMap.get('TypistDateTime')));
            app.Typing_Date__c = DateTime.valueOf(String.valueOf(jsonMap.get('TypistDateTime')));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('Technician')) != null) {
            System.debug('Technician ' + String.valueOf(jsonMap.get('Technician')));
            app.Technician__c = String.valueOf(jsonMap.get('Technician'));
            isUpdate = true;
        }
        if (String.valueOf(jsonMap.get('TechnicianDateTime')) != null) {
            System.debug('TechnicianDateTime ' + String.valueOf(jsonMap.get('TechnicianDateTime')));
            app.Technician_Date__c = DateTime.valueOf(String.valueOf(jsonMap.get('TechnicianDateTime')));
            isUpdate = true;
        }
        if (isUpdate) {
            update app;
        }        
    }

    private static void updateAccount () {
        Boolean isUpdate = false;
        Account acc = new Account();
        List<Account> accounts = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' AND Id =:apps[0].Patient_Account__c LIMIT 1];
        if (!accounts.isEmpty()) {
            acc = accounts[0];
            if (String.valueOf(jsonMap.get('Dust')) != null) {
                acc.Dust__c = String.valueOf(jsonMap.get('Dust'));
                isUpdate = true;
            }
            if (String.valueOf(jsonMap.get('Asthma')) != null) {
                acc.Asthma__c = String.valueOf(jsonMap.get('Asthma'));
                isUpdate = true;
            }
            if (String.valueOf(jsonMap.get('IodineSensitivity')) != null) {
                acc.Iodine_sensitivity__c  = String.valueOf(jsonMap.get('IodineSensitivity'));
                isUpdate = true;
            }
        }
        if (isUpdate) {
            update acc;
        }                    
    }

    public static void createJsonResponse (String success, String errorMessage){
        JSONGenerator jsGen = JSON.createGenerator(true);
        RestContext.response.addHeader('Content-Type', 'application/json');
        // Create a JSONGenerator object
        jsGen.writeStartObject();
        jsGen.writeStringField('Success', success);
        jsGen.writeStringField('Error', errorMessage); 
        jsGen.writeEndObject();
        RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString());
    } 
}