// Created: Evgeniy Kravchuk
// Date: 29.10.2019
// Description: backend methods called many times
// Test: search test or create LC_BackendUtilsTest
public without sharing class LC_BackendUtils {

    public class LC_BackendUtilsException extends Exception {}

    // CANCEL APPOINTMENTS IN ENSEMBLE
    public static ws_AppointmentNew.CancelAppointmentResponse callCancelInAnsemble(List<Appointment__c> appointments) {
        System.debug('LC_BackendUtils.callCancelInAnsemble...\nappointments: ' + appointments);
        String systemKey = '26';
        if (!appointments.isEmpty()) {
            Appointment__c appt = appointments.get(0);

            if (appt.SourceSystem__c == 'QFlow') {
                systemKey = '29';
            }
            if (appt.SourceSystem__c == 'Shidurit') {
                systemKey = '86';
            }
        }

        ws_AppointmentNew.CancelAppointmentRequest request = new ws_AppointmentNew.CancelAppointmentRequest();
        request.TargetSystem = systemKey;
        request.CancelAppointmentDetails = new ws_AppointmentNew.ArrayOfCancelAppointmentDetailsCancelAppointmentDetails();
        request.CancelAppointmentDetails.CancelAppointmentDetails = new List<ws_AppointmentNew.CancelAppointmentDetails>();

        for (Appointment__c appointment_i : appointments) {
            ws_AppointmentNew.CancelAppointmentDetails details_i = new ws_AppointmentNew.CancelAppointmentDetails();
            details_i.UserId = getUserForEnsemble(request.TargetSystem).replace('prodint', 'BotSFOrder_ProdUsr');
            details_i.ProcessId = appointment_i.Accession_Number__c;
            details_i.CancelationReasonCode = appointment_i.Canceled_reason__c;
            details_i.AppointmentDate = String.valueOf(appointment_i.Appointment_Date_Time__c);
            details_i.AppointmentDuration = String.valueOf(appointment_i.Duration__c);
            details_i.CalendarCode = appointment_i.Calendar__r.ServiceId__c;
            details_i.ActivityCode = appointment_i.Medical_Procedure__r.Procedure_Code__c;
            details_i.Activity = appointment_i.Medical_Procedure__r.Name;
            request.CancelAppointmentDetails.CancelAppointmentDetails.add(details_i);
        }

        System.debug('request: ' + JSON.serialize(request));
        ws_AppointmentNew.CancelAppointmentResponse response;
        if (!Test.isRunningTest()) {
            response = new ws_AppointmentNew.AppointmentOperationsSoap().CancelAppointment(request);
            System.debug('response: ' + JSON.serialize(response));
        }

        return response;
    }

    // CREATE SET APPOINTMENT REQUEST
    public static ws_AppointmentNew.SetAppointmentRequest getSetAppointmentRequest(ws_AppointmentNew.CalenderSlot incommingSlot, String idNumber, String idType, String apptId, String pFactorCode, String forcedCode) {
        System.debug('LC_BackendUtils.getSetAppointmentRequest...\nincommingSlot: ' + incommingSlot + '\nidNumber: ' + idNumber + '\nidType: ' + idType + '\napptId: ' + apptId + '\npFactorCode: ' + pFactorCode + '\nforcedCode: ' + forcedCode);
        Account patient = getAccountByPassport(idNumber, idType);

        ws_AppointmentNew.SetAppointmentRequest request = new ws_AppointmentNew.SetAppointmentRequest();
        request.TargetSystem = String.valueOf(getTargetSystem(incommingSlot.procedureCode));
        request.UserId = getUserForEnsemble(request.TargetSystem);
        request.SourceSystem = '16';

        // patient details
        request.PatientDetails = new ws_AppointmentNew.PatientDetails();
        request.PatientDetails.BirthDate = patient.PersonBirthdate != null ? patient.PersonBirthdate : System.now();
        request.PatientDetails.HomelTel = patient.PersonOtherPhone != null ? patient.PersonOtherPhone : null;
        request.PatientDetails.MobilePhoneNumber = patient.Phone != null ? patient.Phone : null;
        request.PatientDetails.GenderCode = patient.Gender__c;
        request.PatientDetails.FirstName = patient.FirstName;
        request.PatientDetails.LastName = patient.LastName;
        request.PatientDetails.PatientId = idNumber;
        request.PatientDetails.IdType = idType;

        // appointment details
        request.AppointmentDetails = new ws_AppointmentNew.ArrayOfSetAppointmentDetailsSetAppointmentDetails();
        ws_AppointmentNew.SetAppointmentDetails details = new ws_AppointmentNew.SetAppointmentDetails();
        details.ScheduledStartDate = localizeDateTime(incommingSlot.StartTime, TimeZone.getTimeZone('Asia/Tel_Aviv'), 1);
        details.ModalityCode = String.valueOf(incommingSlot.ModalityCode);
        details.Duration = String.valueOf(incommingSlot.Duration);
        details.SlotId = String.valueOf(incommingSlot.SlotId);
        details.ProcedureCode = incommingSlot.procedureCode;
        details.SchedulingSystem = 'SalesForce';
        details.IsProcessRecycable = false;
        details.AppointmentKey = 1;
        details.Guid = apptId;
        if (String.isNotBlank(forcedCode)) {
            details.ForceAppointmentCode = forcedCode;
        }
        request.AppointmentDetails.SetAppointmentDetails = new List<ws_AppointmentNew.SetAppointmentDetails>{details};

        // order
        request.Order = new ws_AppointmentNew.Order();
        request.Order.InsurerId = pFactorCode != null ? Long.valueOf(pFactorCode) : 2;
        request.Order.HospitalName = 'אסותא';

        return request;
    }

    // TIME LOCALIZATION
    public static DateTime localizeDateTime(Datetime originalTime, TimeZone toTimeZone, Integer modifier) {
        System.debug('**originalTime' + originalTime);
        System.debug('**originalTime.AddSeconds...' + originalTime.AddSeconds(modifier * toTimeZone.getOffset(originalTime) / 1000));
        return originalTime.AddSeconds(modifier * toTimeZone.getOffset(originalTime) / 1000);
    }

    // GET ACCOUNT BY ID NUMBER AND ID TYPE
    public static Account getAccountByPassport(String idNumber, String idType) {
        System.debug('LC_BackendUtils.getAccountByPassport...\nidNumber: ' + idNumber + '\nidType: ' + idType);
        List<Account> accounts = [SELECT Id, FirstName, LastName, Gender__c, Sabbath_keeping__c, PersonBirthdate, ID_Number__c, ID_Type__c, Phone, PersonOtherPhone FROM Account WHERE ID_Number__c =: idNumber AND ID_Type__c =: idType];
        if (accounts.isEmpty()) {
            throw new LC_BackendUtilsException('There is no account in sf (ID_Number__c = \'' + idNumber + '\', ID_Type__c = \'' + idType + '\')');
        }
        return accounts.get(0);
    }

    // GET TARGET SYSTEM FOR ENSEMBLE
    public static Integer getTargetSystem(String procedureCode) {
        System.debug('LC_BackendUtils.getTargetSystem...\nprocedureCode: ' + procedureCode);
        List<Medical_Procedure__c> procedures = [SELECT Id, Domain__r.Appointment_Coordination_System__c, ScheduleAppointmentSystem__c FROM Medical_Procedure__c
                                                 WHERE Procedure_Code__c =: procedureCode AND (Domain__r.Appointment_Coordination_System__c != null OR ScheduleAppointmentSystem__c != null)];

        if (procedures.isEmpty()) {
            return 26; // RIS as default
        } else {
            String systemName = String.isNotBlank(procedures.get(0).ScheduleAppointmentSystem__c) ? procedures.get(0).ScheduleAppointmentSystem__c : procedures.get(0).Domain__r.Appointment_Coordination_System__c;
            if (systemName == 'QFlow') {
                return 29;
            } else {
                return 26;
            }
        }
    }

    // GET USER ID FOR ENSEMBLE
    public static String getUserForEnsemble(Object targetSystem) {
        System.debug('LC_BackendUtils.getUserForEnsemble...\ntargetSystem: ' + targetSystem);
        User u = [SELECT Id, Name, User_AD__c FROM User WHERE Id =: UserInfo.getUserId()];
        if (u.Name == 'Platform Integration User') {
            return Integer.valueOf(targetSystem) == 26 ? Label.AD_Number_for_PIU : 'ASUTA\\' + Label.AD_Number_for_PIU;
        } else if (String.isNotBlank(u.User_AD__c)) {
            return Integer.valueOf(targetSystem) == 26 ? u.User_AD__c : 'ASUTA\\' + u.User_AD__c;
        } else {
            throw new LC_BackendUtilsException(Label.User_AD_is_blank);
        }
    }

    // THROW ENSEMBLE ERROR LABEL (LC_BaseController uses if CalloutException)
    public static void throwEnsembleError(String description) {
        System.debug('Callout Ensemble ERROR Description: ' + description);
        throw new LC_BackendUtilsException(System.Label.Ensemble_error);
    }

    // THROW ENSEMBLE ERROR WITH MESSAGE AND DESCRIPTION DEPENDENT ON ERROR CODE
    public static void throwEnsembleError(ws_AppointmentNew.Result result, String interfaceType) {
        throwEnsembleError(new List<String>{result.ErrorCode}, new List<String>{result.ErrorDescription}, interfaceType);
    }

    public static void throwEnsembleError(List<ws_AppointmentNew.Error> errors, String interfaceType) {
        List<String> codes = new List<String>();
        List<String> descriptions = new List<String>();
        for (ws_AppointmentNew.Error error_i : errors) {
            codes.add(error_i.ErrorCode);
            descriptions.add(error_i.ErrorMessage);
        }
        throwEnsembleError(codes, descriptions, interfaceType);
    }

    public static void throwEnsembleError(List<String> codes, List<String> descriptions, String interfaceType) {
        System.debug('LC_BackendUtils.throwEnsembleError...');
        SObjectCustomWrapper.EnsembleError ensembleError = (SObjectCustomWrapper.EnsembleError) LC_BackendUtils.wrapEnsembleError(codes, descriptions, interfaceType).responseObj;
        throw new LC_BackendUtilsException(ensembleError.message);
    }

    // RETURN ENSEMBLE ERROR WITH MESSAGE AND DESCRIPTION DEPENDENT ON ERROR CODE
    public static Response wrapEnsembleError(ws_AppointmentNew.Result result, String interfaceType) {
        return wrapEnsembleError(new List<String>{result.ErrorCode}, new List<String>{result.ErrorDescription}, interfaceType);
    }

    public static Response wrapEnsembleError(List<String> codes, List<String> descriptions, String interfaceType) {
        System.debug('LC_BackendUtils.wrapEnsembleError...\ncodes: ' + codes + '\ndescriptions: ' + descriptions + '\ninterfaceType: ' + interfaceType);
        Map<String, String> messagesMap = new Map<String, String>();
        List<String> messages = new List<String>();

        for (Ensemble_Error_Mapping__mdt metadata_i : [SELECT ErrorCode__c, ErrorMessage__c FROM Ensemble_Error_Mapping__mdt WHERE InterfaceType__c =: interfaceType]) {
            messagesMap.put(metadata_i.ErrorCode__c, metadata_i.ErrorMessage__c);
        }

        for (String code_i : codes) {
            messages.add(messagesMap.containsKey(code_i) ? messagesMap.get(code_i) : System.Label.Ensemble_error);
        }   

        return new Response(false, new SObjectCustomWrapper.EnsembleError(String.join(messages, '<br/>'), String.join(descriptions, '<br/>')));
    }

    // SEND EMAIL ALERT FOR CANCELED MEDICAL AIDS WITH 80 ASSIST
    public static void sendEmailAlert(List<Medical_Aid_Appointment__c> medicalAids) {
        System.debug('LC_DisabilityController.sendEmailAlert...\nmedicalAids: ' + medicalAids);
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Medical_Aid_SpecificAId_cancel'].Id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> status = new List<String>();

        for (Medical_Aid_Appointment__c aid_i : medicalAids) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{aid_i.Email_MedicalAidManager__c});
            mail.setTargetObjectId(aid_i.Patient__r.PersonContactId);
            mail.setSenderDisplayName('Assuta Non Reply'); 
            mail.setReplyTo('nonreply@assuta.co.il');
            mail.setTemplateId(templateId);
            mail.setWhatId(aid_i.Id);
            mails.add(mail);
        }
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);

        Integer i = 0;
        for (Messaging.SendEmailResult result_i : results) {
            if (result_i.success) {
                status.add('success (' + medicalAids.get(i).Email_MedicalAidManager__c + ')');
            } else {
                status.add('fail (' + medicalAids.get(i).Email_MedicalAidManager__c + ') message: ' + result_i.errors.get(0).message);
            }
            i++;
        }
        System.debug('status: size: ' + status.size() + ' values: ' + status);
    }

    // GET PATIENT ACCOUNT BY ID NUMBER AND ID TYPE
    public static Account getPatientAccountData(String patientId, String idType) {
        System.debug('LC_BackendUtils.getPatientAccountData...\npatientId: ' + patientId + '\nidType: ' + idType);
        List<Account> accounts = [SELECT Id, Name, ID_Number__c, ID_Type__c, Asthma__c, Metals_in_body__c, Iodine_sensitivity__c,
                                  Diabetic__c, Dust__c, Blood_Dilution__c, Weight__c, Gender__c FROM Account 
                                  WHERE RecordType.DeveloperName = 'PersonAccount' AND ID_Number__c =:patientId AND ID_Type__c =: idType];
        if (accounts.isEmpty()) {
            throw new LC_BackendUtilsException('There is no account in sf (ID_Number__c = \'' + patientId + '\', ID_Type__c = \'' + idType + '\')');
        }
        return accounts.get(0);
    }

    // GET PATIENT Email BY ID NUMBER AND ID TYPE
    public static Account getPatientEmail(String patientId, String idType) {
        System.debug('LC_BackendUtils.getPatientEmail...\npatientId: ' + patientId + '\nidType: ' + idType);
        List<Account> accounts = [SELECT Id, ID_Number__c, ID_Type__c, PersonEmail 
                                  FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' 
                                  AND ID_Number__c =: patientId AND ID_Type__c =: idType];
        if (accounts.isEmpty()) {
            throw new LC_BackendUtilsException('There is no account in sf (ID_Number__c = \'' + patientId + '\', ID_Type__c = \'' + idType + '\')');
        }
        return accounts.get(0);
    }
}