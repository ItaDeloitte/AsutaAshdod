/*
* @author           Ortal Kazum   <ortalk@assuta.co.il>
* @modifiedBy     
* @version          1.0
* @created          06-10-2019
* @modified         DD-MM-YYYY
* @description      An interface for IVR - OTP + Cancel Appointment  
* @Test             ws_IVR_CancelAppointmentTest
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/

@RestResource(urlMapping='/IVR_CancelAppointment/*')
global class ws_IVR_CancelAppointment {

    public ws_IVR_CancelAppointment() {}

    /*
    * URL: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_CancelAppointment?PatientId=PatientId  
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get Json From Ensemble In the  IVR - OTP interface - check if exist phone to patient
    * and send OTP for identification
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    patientId      Id of patient
    * @return   OTP            4-digit number
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpGet
    global static void createOTP() {
        String patientId = '';
        String phoneNumber;
        String OTP;
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        Integer length = 4;

        try{
            patientId = restReq.params.get('PatientId');
            if(patientId != ''){
                List<Account> accountLst = [SELECT Id, Phone FROM Account WHERE ID_Number__c = :patientId And RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
                System.debug(' ****accountLst*** ' + accountLst);
                if(accountLst.Size()>0){
                    phoneNumber = accountLst[0].Phone;
                    if(String.isNotBlank(phoneNumber)){
                        OTP = CommonService.generateRandomNumber(length);
                        sendSMSWithOTP(phoneNumber, OTP);
                        CommonService.createJsonResponse(OTP, 'OTP');
                    }
                    else{
                        CommonService.createJsonResponse('0', 'There is no patient phone in the system'); 
                    }
                }
                else{
                    CommonService.createJsonResponse('0', 'This patient does not exist in the system'); 
                }
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            CommonService.createJsonResponse('0', e.getMessage()); 
        } 
        
    }

    public static void sendSMSWithOTP(String phoneNumber,  String OTP) {
        SMS__c smsOTP= new SMS__c(
        Type__c = 'Outgoing',
        Phone_Number__c = phoneNumber,
        Content__c = 'קוד האימות החד פעמי לביטול התור הוא ' + OTP,
        Received_Sent_Date_Time__c = datetime.now(),
        status__c = '1');
        insert smsOTP;
    }

    /*
    * url: https://assuta--dev.my.salesforce.com/services/apexrest/IVR_CancelAppointment?ApptId=ApptId
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Post Json From Ensemble In the  IVR - canceleAppointment interface - After the patient enter
    * the password, the IVR system ask for appointment cancellation.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    ApptId        SFID of Appointment          
    * @return   Success       True/False
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPost
    global static void canceleAppointment() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        try {
            Id apptId = restReq.params.get('ApptId');
            if (apptId != null) {
                List<Appointment__c> apptList = [
                    SELECT Case__c
                         , Patient_Account__r.X360_patient_checkbox__c
                      FROM Appointment__c
                     WHERE Id = :apptId];
                System.debug(' ****appointment*** ' + apptList);

                if (!apptList.isEmpty()) {
                    Appointment__c appt = apptList.get(0);

                    if (!appt.Patient_Account__r.X360_patient_checkbox__c) {
                        Id caseId = createCase(appt.Id, appt.Patient_Account__c);
                        createJunctionCaseAppointment(appt.Id, caseId);
                        appt.Case__c = caseId;
                    }
                    update appt;

                    CancelApptInFuture.execute(new Set<Id>{appt.Id}, '5', 'ביטול המטופל');

                    CommonService.createJsonResponse('1', 'Success');
                } else {
                    CommonService.createJsonResponse('0', 'This Appointment does not exist in the system');
                }
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            CommonService.createJsonResponse('0', e.getMessage());
        }
    }

    public static Id createCase (Id appointmentId, Id accountId) {
        Id RTCaseId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Appointments' AND SObjectType = 'case' LIMIT 1].Id;
        Case newCase = new Case(
            RecordTypeId = RTCaseId,
            Status = 'Closed',
            AccountId = accountId,
            Case_subject__c = 'עדכון תור קיים',
            sub_case_subject__c = 'ביטול תור קיים'
        );
        insert newCase;
        return newCase.Id;
    }

    public static void createJunctionCaseAppointment(Id appointmentId, Id CaseId) {
        cases_and_appoitments__c newJunction = new cases_and_appoitments__c(
            Case__c = CaseId,
            Appointment__c = appointmentId,
            type__c = 'ביטול תור'
            );
        insert newJunction;  
    }
}