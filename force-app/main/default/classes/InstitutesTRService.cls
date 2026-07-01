public with sharing class InstitutesTRService {

    public static void checkExistingAppointments(List<Appointment__c> newList, Set<Id> patientIds, Set<Id> doctorIds, Datetime minDatetime, Datetime maxDatetime) {
        Boolean logicExecuted = false;
        Integer offsetMinutes = Integer.valueOf(Label.Same_appointment_Minutes);
        Map<Id, List<Datetime>> patientToDatetimes = new Map<Id, List<Datetime>>();
        Map<Id, List<Datetime>> doctorToDatetimes = new Map<Id, List<Datetime>>();

        if (!doctorIds.isEmpty()) {
            for (Appointment__c appt_i : [SELECT Doctor_Account__c, Appointment_Date_Time__c
                                            FROM Appointment__c
                                           WHERE Id NOT IN :newList
                                             AND Doctor_Account__c IN :doctorIds
                                             AND Appointment_Date_Time__c != null
                                             AND Appointment_Date_Time__c >= :minDatetime
                                             AND Appointment_Date_Time__c <= :maxDatetime
                                             AND Doctor_Account__r.Experts_center__c = true
                                             AND Appointment_Status__c != 'Canceled'
                                             AND SourceSystem__c != 'QFlow']) {
                if (!doctorToDatetimes.containsKey(appt_i.Doctor_Account__c)) {
                    doctorToDatetimes.put(appt_i.Doctor_Account__c, new List<Datetime>());
                }
                doctorToDatetimes.get(appt_i.Doctor_Account__c).add(appt_i.Appointment_Date_Time__c);
            }
        }
        System.debug('doctorToDatetimes: size: ' + doctorToDatetimes.size() + ' value: ' + doctorToDatetimes);

        if (!patientIds.isEmpty()) {
            for (Appointment__c appt_i : [SELECT Patient_Account__c, Appointment_Date_Time__c
                                            FROM Appointment__c
                                           WHERE Id NOT IN :newList
                                             AND Patient_Account__c IN :patientIds
                                             AND Appointment_Date_Time__c != null
                                             AND Appointment_Date_Time__c >= :minDatetime
                                             AND Appointment_Date_Time__c <= :maxDatetime
                                             AND Appointment_Status__c != 'Canceled']) {
                if (!patientToDatetimes.containsKey(appt_i.Patient_Account__c)) {
                    patientToDatetimes.put(appt_i.Patient_Account__c, new List<Datetime>());
                }
                patientToDatetimes.get(appt_i.Patient_Account__c).add(appt_i.Appointment_Date_Time__c);
            }
        }
        System.debug('patientToDatetimes: size: ' + patientToDatetimes.size() + ' value: ' + patientToDatetimes);

        for (Appointment__c appt_i : newList) {
            if (patientToDatetimes.containsKey(appt_i.Patient_Account__c) && Label.Enabled_for_profiles.contains(UserInfo.getProfileId())) {
                for (Datetime datetime_i : patientToDatetimes.get(appt_i.Patient_Account__c)) {
                    if (datetime_i >= appt_i.Appointment_Date_Time__c.addMinutes(-1 * offsetMinutes)
                            && datetime_i <= appt_i.Appointment_Date_Time__c.addMinutes(offsetMinutes)) {
                        appt_i.addError(Label.Patient_has_another_appointment);
                        logicExecuted = true;
                    }
                }
            } else if (doctorToDatetimes.containsKey(appt_i.Doctor_Account__c)) {
                for (Datetime datetime_i : doctorToDatetimes.get(appt_i.Doctor_Account__c)) {
                    if (datetime_i >= appt_i.Appointment_Date_Time__c.addMinutes(-1 * offsetMinutes)
                            && datetime_i <= appt_i.Appointment_Date_Time__c.addMinutes(offsetMinutes)) {
                        appt_i.addError(Label.Doctor_has_another_appointment);
                        logicExecuted = true;
                    }
                }
            }
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c checkExistingAppointments ... executed');
        }
    }

    public static void syncWithSiteDomain(List<Appointment__c> appts, Set<Id> domainIds, Set<Id> siteIds) {
        Map<String, Site_Domain__c> keyToJctMap = new Map<String, Site_Domain__c>();

        for (Site_Domain__c jct_i : [SELECT Site__c, Domain__c, accurate_site__c, Exact_Location_In_Domain__c
                                       FROM Site_Domain__c
                                      WHERE Site__c IN :siteIds
                                        AND Domain__c IN :domainIds]) {
            keyToJctMap.put(jct_i.Site__c + '' + jct_i.Domain__c, jct_i);
        }
        System.debug('keyToJctMap: size: ' + keyToJctMap.size() + ' value: ' + keyToJctMap);

        for (Appointment__c appt_i : appts) {
            Site_Domain__c jct_i = keyToJctMap.get(appt_i.Site__c + '' + appt_i.Domain__c);
            appt_i.accurate_site__c = appt_i.Site__c;
            if (jct_i != null) {
                appt_i.Exact_Location_In_Domain__c = jct_i.Exact_Location_In_Domain__c;
                if (jct_i.accurate_site__c != null) {
                    appt_i.accurate_site__c = jct_i.accurate_site__c;
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c syncWithSiteDomain ... executed');
    }

    public static void retAmbulatoryReferralsAndCommitments(Set<Id> apptIds) {
        System.debug('TR Appointment__c retAmbulatoryReferralsAndCommitments ... start');
        List<Appointment__c> appts = [
            SELECT Case__c
                 , ID_Type__c
                 , Patient_Account__c
                 , Appointment_Date__c
                 , IdNumberForMaccabi__c
                 , Site__r.Site_Code__c
                 , Medical_Procedure__r.Mabar_Code__c
                 , Medical_Procedure__r.Procedure_Code__c
                 , Medical_Procedure__r.Domain__r.MaccabiRefferal__c
              FROM Appointment__c
             WHERE Id IN :apptIds
               AND PayerFactor__r.Code_Parent_for_Interface__c = '3'
               AND Medical_Procedure__r.Ambulatory_not_attract_Reference__c != true];
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);


        for(Appointment__c appt_i : appts) {
            String idType_i = appt_i.ID_Type__c == 'דרכון' ? '9' : '0';
            String procedureCode_i = appt_i.Medical_Procedure__r.Mabar_Code__c == null
                    ? appt_i.Medical_Procedure__r.Procedure_Code__c
                    : appt_i.Medical_Procedure__r.Mabar_Code__c;
            String referralType = appt_i.Medical_Procedure__r.Mabar_Code__c == null ? appt_i.Medical_Procedure__r.Domain__r.MaccabiRefferal__c : 
                                appt_i.Medical_Procedure__r.Domain__r.MaccabiRefferal__c + '#' + appt_i.Medical_Procedure__r.Mabar_Code__c;
            if ((UserInfo.getProfileId() == Label.Integration_ProfileId || Test.isRunningTest())
                    && appt_i.Medical_Procedure__r.Domain__r.MaccabiRefferal__c != null) {
                MaccabiIntegration.retrievingReferralsFromInstitutesApp(
                    appt_i.IdNumberForMaccabi__c,
                    idType_i,
                    appt_i.Patient_Account__c,
                    referralType,
                    appt_i.Case__c,
                    appt_i.Id);
                System.debug('TR Appointment__c retAmbulatoryReferralsAndCommitments (getAmbulatoryReferral) ... executed');
            }

            if (appt_i.Appointment_Date__c != null && appt_i.Site__r.Site_Code__c != null) {
                ws_getAmbulatoryCommitmentREST.getAmbulatoryCommitment(
                    appt_i.Id,
                    appt_i.Patient_Account__c,
                    appt_i.IdNumberForMaccabi__c,
                    idType_i,
                    procedureCode_i,
                    appt_i.Appointment_Date__c,
                    appt_i.Site__r.Site_Code__c);
                System.debug('TR Appointment__c retAmbulatoryReferralsAndCommitments (getAmbulatoryCommitment) ... executed');
            }
        }
    }

    @future(callout=true)
    public static void relatedPreSurgeryToSurgery(Set<Id> apptIds) {
        System.debug('TR Appointment__c relatedPreSurgeryToSurgery ... future');
        Set<Id> patientIds = new Set<Id>();
        List<Appointment__c> surgeriesToUpdate = new List<Appointment__c>();
        Map<Id, Appointment__c> patientToSurgeryMap = new Map<Id, Appointment__c>();

        List<Appointment__c> appts = [
            SELECT Patient_Account__c
                 , Appointment_Date_Time__c
              FROM Appointment__c
             WHERE Id IN :apptIds
               AND Domain__r.DomainCode__c = 504];
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        for (Appointment__c appt_i : appts) {
            patientIds.add(appt_i.Patient_Account__c);
        }
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);

        for (Appointment__c appt_i : [SELECT Patient_Account__c, Date_of_appointment__c, Appointment_Date_Time__c
                                        FROM Appointment__c
                                       WHERE RecordType.DeveloperName = 'Surgeries'
                                         AND Patient_Account__c IN :patientIds
                                         AND Date_of_appointment__c >= TODAY
                                         AND Appointment_Status__c NOT IN ('1', '2', '3', '4', '5',  'Canceled', 'CanceledFailed')                                        
                                         AND (PreSurgery__c = null 
                                            OR PreSurgery__r.Appointment_Status__c IN ('Canceled', 'נדחה על ידי המנהל', 'RescheduleByClient', 'RescheduleByAssuta'))]) {
            if (!patientToSurgeryMap.containsKey(appt_i.Patient_Account__c)) {
                patientToSurgeryMap.put(appt_i.Patient_Account__c, appt_i);
            } else if (appt_i.Date_of_appointment__c < patientToSurgeryMap.get(appt_i.Patient_Account__c).Date_of_appointment__c) {
                patientToSurgeryMap.put(appt_i.Patient_Account__c, appt_i);
            }
        }
        System.debug('patientToSurgeryMap: size: ' + patientToSurgeryMap.size() + ' value: ' + patientToSurgeryMap);

        if (!patientToSurgeryMap.isEmpty()) {
            for (Appointment__c appt_i : appts) {
                if (patientToSurgeryMap.containsKey(appt_i.Patient_Account__c)
                        && (patientToSurgeryMap.get(appt_i.Patient_Account__c).Appointment_Date_Time__c > appt_i.Appointment_Date_Time__c
                        && appt_i.Appointment_Date_Time__c.date().daysBetween(patientToSurgeryMap.get(appt_i.Patient_Account__c).Appointment_Date_Time__c.date()) <= 40)) {
                    surgeriesToUpdate.add(new Appointment__c(Id = patientToSurgeryMap.get(appt_i.Patient_Account__c).Id, PreSurgery__c = appt_i.Id));
                }
            }
        }
        System.debug('surgeriesToUpdate: size: ' + surgeriesToUpdate.size() + ' value: ' + surgeriesToUpdate);

        if (!surgeriesToUpdate.isEmpty()) {
            update surgeriesToUpdate;
            System.debug('TR Appointment__c relatedPreSurgeryToSurgery ... executed');
        }
    }

    @future(callout=true)
    public static void cancelPreSurgery(Set<Id> apptIds) {
        System.debug('TR Appointment__c cancelPreSurgery ... future');
        List<Appointment__c> surgeriesToUpdate = new List<Appointment__c>();

        List<Appointment__c> appts = [
            SELECT Patient_Account__c
                 , Appointment_Date_Time__c
              FROM Appointment__c
             WHERE Id IN :apptIds
               AND Domain__r.DomainCode__c = 504];
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        for (Appointment__c appt_i : [SELECT Id
                                        FROM Appointment__c
                                       WHERE RecordType.DeveloperName = 'Surgeries'
                                         AND PreSurgery__c IN :appts]) {
            surgeriesToUpdate.add(new Appointment__c(Id = appt_i.Id, PreSurgery__c = null));
        }
        System.debug('surgeriesToUpdate: size: ' + surgeriesToUpdate.size() + ' value: ' + surgeriesToUpdate);

        if (!surgeriesToUpdate.isEmpty()) {
            update surgeriesToUpdate;
            System.debug('TR Appointment__c cancelPreSurgery ... executed');
        }
    }

    @future(callout=true)
    public static void updateForwardToRIS(Set<Id> apptIds) {
        System.debug('TR Appointment__c updateForwardToRIS ... future');
        List<File__c> filesToUpdate = new List<File__c>();

        for (File__c file_i :[SELECT Id
                                FROM File__c
                               WHERE RecordType.DeveloperName = 'Referral'
                                 AND Appointment__c IN :apptIds
                                 AND URL__c != null]) {
            filesToUpdate.add(new File__c(Id = file_i.Id, ForwardToRIS__c = true));
        }
        System.debug('filesToUpdate: size: ' + filesToUpdate.size() + ' value: ' + filesToUpdate);

        if (!filesToUpdate.isEmpty()) {
            update filesToUpdate;
            System.debug('TR Appointment__c updateForwardToRIS ... executed');
        }
    }
    
    @future(callout=true)
    public static void SendingWhatsApp(Set<Id> apptIds) {
        try {
            System.debug('TR Appointment__c SendingWhatsApp started...');                

            List<Appointment__c> appts = [
                SELECT Id,
                    Case__c,
                    Calendar__c,
                    SMS_Address__c,
                    kit_for_inst__c,
                    Order_Notes__c,
                    PaymentStatus__c,
                    Remainder_type__c,
                    Patient_Account__c,
                    AppointmentTime__c,
                    after_appointment__c,
                    Payer_Factor_Code__c,
                    Domain__r.DomainCode__c,
                    Calendar__r.ServiceId__c,
                    Calendar__r.Directions__c,
                    accurate_site__r.Address__c,
                    Appointment_Date_In_Text__c,
                    Exact_Location_In_Domain__c,
                    FT_PreSurgery_Upload_Files__c,
                    Site__r.Site_Code__c,
                    Site__r.Location_for_surgery__c,
                    PayerFactor__r.InsuranceCode__c,
                    Medical_Procedure__r.Quick_Check__c,
                    Medical_Procedure__r.Procedure_Code__c,
                    Medical_Procedure__r.Virtual_Appointment__c,
                    Patient_Account__r.SMS_Phone_Number__c,
                    Patient_Account__r.patient_full_name__c,
                    Patient_Account__r.FirstName,
                    Domain__r.Converted_To_Private_Zone__c,
                    Domain__r.Is_Doc_Required__c,
                    Medical_Procedure__r.Are_services_private__c,
                    Calendar__r.CalenderInClinic__r.Full_address_doc_clinic__c,
                    ReceiptNum__c
                FROM Appointment__c
                WHERE Id IN :apptIds
                AND Patient_Account__r.Mailing_approval__c != 'לא מאשר דיוור - הכל'
                AND Medical_Procedure__r.Confidentiality__c = false
            ];

            if (appts.isEmpty()) return;

            List<MedicalProcedurePlanService.MedicalPlanRequest> requests = new List<MedicalProcedurePlanService.MedicalPlanRequest>();

            for (Appointment__c appt_i : appts) {

                MedicalProcedurePlanService.MedicalPlanRequest req = new MedicalProcedurePlanService.MedicalPlanRequest();
                Boolean isAfter = appt_i.after_appointment__c != null;

                req.procedureCode1 = isAfter ? null : appt_i.Medical_Procedure__r.Procedure_Code__c;
                req.procedureCode2 = isAfter ? appt_i.Medical_Procedure__r.Procedure_Code__c : null;                                              
                req.siteCode       = appt_i.Site__r.Site_Code__c;
                
                System.debug('req ' + req);  
                requests.add(req);
            }

            Map<String, MedicalProcedurePlanService.MedicalPlanResponse> responseMap = new Map<String, MedicalProcedurePlanService.MedicalPlanResponse>();

            if (!requests.isEmpty()) {
                List<MedicalProcedurePlanService.MedicalPlanResponse> responses = MedicalProcedurePlanService.getMedicalPlanSettings(requests);
                
                System.debug('responses ' + responses);  
                for (MedicalProcedurePlanService.MedicalPlanResponse res : responses) {
                    String key = res.siteCode + '|' + res.procedureCode;
                    responseMap.put(key, res);
                }
            }
            
            Set<String> assutaOneProcedures = getAssutaOneProcedures();
            List<MessagingChannel> assutaChannel = WhatAppUtils.getMessagingChannel('Assuta_Enhanced_Bot');
            List<MessagingChannel> assutaOneChannel = WhatAppUtils.getMessagingChannel('WHATSAPP_US_594522617086919');

            if (assutaChannel.isEmpty() || assutaOneChannel.isEmpty()) return;

            MessagingChannel defaultChannel = assutaChannel.get(0);
            MessagingChannel oneChannel = assutaOneChannel.get(0);

            List<WA_scheduleAppointmentWrapper> wrapperList = new List<WA_scheduleAppointmentWrapper>();
            
            for (Appointment__c appt_i : appts) {                 

                if (isNotValidPayment(appt_i)) {
                    continue;
                }

                System.debug('check Medical Procedure Plan');
                String procedureCode = appt_i.Medical_Procedure__r.Procedure_Code__c;                
                String siteCode      = appt_i.Site__r.Site_Code__c;
                String key = siteCode + '|' + procedureCode;
                
                MedicalProcedurePlanService.MedicalPlanResponse res = responseMap.get(key);

                Boolean shouldSend = res != null && (!res.found || res.sendMessage);
                System.debug('shouldSend ' + shouldSend);  
                if (!shouldSend) {
                    continue;
                }                 

                Boolean isAssutaOne = assutaOneProcedures.contains(procedureCode);
                String channelName = isAssutaOne 
                                    ? cleanChannelName(oneChannel.MasterLabel) 
                                    : cleanChannelName(defaultChannel.MasterLabel);

                String channelId = isAssutaOne ? oneChannel.Id : defaultChannel.Id;
                wrapperList.add(buildWrapper(appt_i, channelName, channelId, isAssutaOne));
            }

            if (wrapperList.isEmpty()) return;

            Map<String, Object> params = new Map<String, Object>{
                'Values_from_New_App' => wrapperList
            };

            Flow.Interview.Appointment_Schedule_WhatsApp flow = 
                new Flow.Interview.Appointment_Schedule_WhatsApp(params);

            flow.start();

            System.debug('TR Appointment__c SendingWhatsApp executed successfully.');              

        } catch (Exception e) {
            System.debug('Error in SendingWhatsApp: ' + e.getMessage() + ' | ' + e.getStackTraceString());
        }
    }
        
    private static Boolean isNotValidPayment(Appointment__c appointment) {        
        return appointment.PaymentStatus__c != 'Valid'
            && (appointment.Order_Notes__c != null && appointment.Order_Notes__c.contains('internet_site')) 
            && appointment.Medical_Procedure__r.Quick_Check__c ==  true
            && (appointment.PayerFactor__r.InsuranceCode__c == '0' || appointment.PayerFactor__r.InsuranceCode__c == '1' || appointment.PayerFactor__r.InsuranceCode__c == '165');  
    }

    private static Set<String> getAssutaOneProcedures() {
        Set<String> codeSet = new Set<String>();
        for (AssutaOne_Procedures__mdt mdt_i : AssutaOne_Procedures__mdt.getAll().values()) {           
            codeSet.add(mdt_i.ProcedureCode__c);            
        }
        return codeSet;
    }

    private static WA_scheduleAppointmentWrapper buildWrapper(Appointment__c appt, 
                                                              String channelName, 
                                                              String channelId, 
                                                              Boolean isAssutaOne
                                                              ) {
        return new WA_scheduleAppointmentWrapper(
            appt.Case__c,
            appt.Appointment_Date_In_Text__c,
            String.valueOf(appt.Domain__r.DomainCode__c),
            appt.SMS_Address__c,
            appt.Patient_Account__r.SMS_Phone_Number__c,
            appt.kit_for_inst__c,
            appt.after_appointment__c != null,
            appt.Remainder_type__c,
            appt.Id,
            appt.Patient_Account__c,
            appt.AppointmentTime__c,
            appt.Medical_Procedure__r.Are_services_private__c,
            appt.Calendar__r.Directions__c,
            appt.accurate_site__r.Address__c,
            appt.Exact_Location_In_Domain__c,
            appt.Domain__r.Converted_To_Private_Zone__c,
            appt.Medical_Procedure__r.Procedure_Code__c,
            channelName,
            channelId, 
            isAssutaOne,
            appt.FT_PreSurgery_Upload_Files__c,
            appt.Domain__r.Is_Doc_Required__c,
            appt.Medical_Procedure__r.Virtual_Appointment__c,            
            appt.Patient_Account__r.patient_full_name__c,
            appt.PayerFactor__r.InsuranceCode__c,
            appt.Patient_Account__r.FirstName,
            appt.ReceiptNum__c,
            'InstitutesTRService.SendingWhatsApp' + ' ||| ' + UserInfo.getUserName()
        );
    }

    private static String cleanChannelName(String name) {
        return name != null ? name.replaceAll('[^\\d+]', '') : '';
    }
    
        @future (callout=true)
    public static void checkUrgentAppointments(Set<Id> appointmentIdSet, Set<Id> calendarIdSet, Set<Id> procedureIdSet) {
        System.debug('TR Appointment__c checkUrgentAppointments ...');
        Datetime currentTime = System.now();
        Set<Id> lockSlotAppts = new Set<Id>(); 
        List<Appointment__c> appointmentsToUpdate = new List<Appointment__c>();       
        Map<String, Map<Id, Appointment__c>> keyToApptsMap = new Map<String, Map<Id, Appointment__c>>();
        
        for (Appointment__c appt_i : [SELECT Id
                                        , Is_Urgent__c
                                        , Calendar__c
                                        , Patient_Account__c
                                        , Medical_Procedure__c
                                        , UrgentApptStatus__c                                       
                                        , Appointment_Date_Time__c 
                                        , UrgentApptMessageDate__c                                                                                                
                                        , Days_Until_Appointment__c            
                                    FROM Appointment__c
                                    WHERE Is_Urgent__c = true                                                        
                                        AND UrgentAppointment__c = null                                     
                                        AND Appointment_Date_Time__c > :currentTime
                                        AND Calendar__c IN :calendarIdSet
                                        AND Medical_Procedure__c IN :procedureIdSet
                                        AND Medical_Procedure__r.Confidentiality__c = false
                                        AND (UrgentApptMessageDate__c = null OR UrgentApptMessageDate__c != TODAY )
                                        AND Appointment_Status__c NOT IN ('2', '3', 'Canceled', 'CanceledFailed') 
                                    ORDER BY UrgentPointNum__c DESC]) {
            if (!keyToApptsMap.containsKey(String.valueOf(appt_i.Medical_Procedure__c) + ' ' + String.valueOf(appt_i.Calendar__c))) {
                keyToApptsMap.put(String.valueOf(appt_i.Medical_Procedure__c) + ' ' + String.valueOf(appt_i.Calendar__c), new Map<Id, Appointment__c>());
            }
            keyToApptsMap.get(String.valueOf(appt_i.Medical_Procedure__c) + ' ' + String.valueOf(appt_i.Calendar__c)).put(appt_i.Id, appt_i);                            
        }

        System.debug('keyToApptsMap: [' + keyToApptsMap.size() + '] value: ' + keyToApptsMap);                 
        List<Appointment__c> appointmentLocks = new List<Appointment__c> (
            [SELECT Id
                , Duration__c
                , Calendar__c
                , Appointment_Date_Time__c
                , Calendar__r.ServiceId__c
                , Medical_Procedure__c
                , Medical_Procedure__r.Name
                , Medical_Procedure__r.Procedure_Code__c             
            FROM Appointment__c
            WHERE Id IN :appointmentIdSet]);
        if (!keyToApptsMap.isEmpty()) {
            for(Appointment__c appt_i :appointmentLocks) {
                if (keyToApptsMap.containsKey(String.valueOf(appt_i.Medical_Procedure__c) + ' ' + String.valueOf(appt_i.Calendar__c))) {  
                    Map<Id, Appointment__c> apptMap = keyToApptsMap.get(String.valueOf(appt_i.Medical_Procedure__c) + ' ' + String.valueOf(appt_i.Calendar__c));
                    for (Appointment__c appt_j : apptMap.values()) {
                        if(appt_j.Appointment_Date_Time__c >  appt_i.Appointment_Date_Time__c) {
                            appointmentsToUpdate.add(new Appointment__c (
                                                                Id = appt_j.Id,
                                                                UrgentAppointment__c = appt_i.Id,
                                                                UrgentApptStatus__c = null,
                                                                UrgentApptMessageDate__c = null                                                                                                                                                                              
                                            		));
                            lockSlotAppts.add(appt_i.Id);                 
                            keyToApptsMap.get(String.valueOf(appt_i.Medical_Procedure__c) + ' ' + String.valueOf(appt_i.Calendar__c)).remove(appt_j.Id);
                            break;
                        }                                                
                    }                                                                    
                } 
            }
        }
        
        System.debug('lockSlotAppts: [' + lockSlotAppts.size() + '] value: ' + lockSlotAppts);    
        for (Appointment__c lockApp_i: appointmentLocks) {
            if (!lockSlotAppts.contains(lockApp_i.Id)) {
                ws_RisRemarks.updateRemark('unlockSlotSF'
                                            , lockApp_i.Medical_Procedure__r.Name
                                            , lockApp_i.Medical_Procedure__r.Procedure_Code__c
                                            , lockApp_i.Calendar__r.ServiceId__c
                                            , String.valueOf(lockApp_i.Appointment_Date_Time__c) 
                                            , Integer.valueOf(lockApp_i.Duration__c));                                   
            }                                                     
        }        
       
        System.debug('appointmentsToUpdate: [' + appointmentsToUpdate.size() + '] value: ' + appointmentsToUpdate);                 
        if (!appointmentsToUpdate.isEmpty()) {
            update appointmentsToUpdate;
            System.debug('TR Appointment__c checkUrgentAppointments ... executed');
        }         
    } 
    
    @future (callout=true)
    public static void changeUrgentStatus(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c changeUrgentStatus ...');  
        List<Appointment__c> appointmentsToUpdate = new List<Appointment__c>();        

        try {
            for (Appointment__c appt_i : [
                SELECT Id
                    , Site__c
                    , Site__r.Site_Code__c
                    , Calendar__c  
                    , Calendar__r.ServiceId__c
                    , Medical_Procedure__c 
                    , Medical_Procedure__r.Procedure_Code__c
                    , Appointment_Status__c
                    , Days_Until_Appointment__c                  
                    , Patient_Account__r.ID_Type__c
                    , Patient_Account__r.ID_Number__c
                    , PayerFactor__r.InsuranceCode__c                                                                                                       
                    , UrgentAppointment__c 
                    , UrgentAppointment__r.Duration__c
                    , UrgentAppointment__r.Calendar__c
                    , UrgentAppointment__r.Appointment_Date__c                                                                               
                    , UrgentAppointment__r.Appointment_Date_Time__c 
                    , UrgentAppointment__r.Calendar__r.ServiceId__c
                    , UrgentAppointment__r.Medical_Procedure__c
                    , UrgentAppointment__r.Medical_Procedure__r.Name
                    , UrgentAppointment__r.Medical_Procedure__r.Procedure_Code__c                                                  
                FROM Appointment__c
                WHERE Id IN :appointmentIdSet
            ]) {    

                try {
                    Response res = new Response(
                        LC_AppointmentScreenService.getInstance(appt_i.Id)
                            .rescheduleAppointments(
                                null,
                                appt_i.Patient_Account__r.ID_Number__c,
                                appt_i.Patient_Account__r.ID_Type__c,
                                null,
                                appt_i.PayerFactor__r.InsuranceCode__c,
                                new List<String>{appt_i.Id},
                                getCalendar(appt_i)
                            )
                    );

                    System.debug('res ' + res);  

                    ws_RisRemarks.updateRemark(
                        'unlockSlotSF',
                        appt_i.UrgentAppointment__r.Medical_Procedure__r.Name,
                        appt_i.UrgentAppointment__r.Medical_Procedure__r.Procedure_Code__c,
                        appt_i.UrgentAppointment__r.Calendar__r.ServiceId__c,
                        String.valueOf(appt_i.UrgentAppointment__r.Appointment_Date_Time__c),
                        Integer.valueOf(appt_i.UrgentAppointment__r.Duration__c)
                    );                             

                    appointmentsToUpdate.add(new Appointment__c(
                        Id = appt_i.Id,
                        Is_Urgent__c = false
                    ));

                } catch (Exception ex) {
                    System.debug('Error processing Appointment Id: ' + appt_i.Id);
                    System.debug('Error message: ' + ex.getMessage());
                    System.debug('Stack trace: ' + ex.getStackTraceString());
                }
            } 

            System.debug('appointmentsToUpdate: [' + appointmentsToUpdate.size() + '] value: ' + appointmentsToUpdate);                 

            if (!appointmentsToUpdate.isEmpty()) {
                try {
                    update appointmentsToUpdate;
                    System.debug('TR Appointment__c checkUrgentAppointments ... executed');
                } catch (DmlException dmlEx) {
                    System.debug('DML Error: ' + dmlEx.getMessage());
                }
            }

        } catch (Exception e) {
            System.debug('General error in changeUrgentStatus: ' + e.getMessage());
        }
    }

    private static List<ws_AppointmentNew.CalenderSlot> getCalendar(Appointment__c appt) {
        ws_AppointmentNew.CalenderSlot calendar = new ws_AppointmentNew.CalenderSlot();
        calendar.SlotId = 0;
        calendar.StartTime = appt.UrgentAppointment__r.Appointment_Date_Time__c;
        calendar.EndTime = appt.UrgentAppointment__r.Appointment_Date_Time__c.addMinutes(Integer.valueOf(appt.UrgentAppointment__r.Duration__c));
        calendar.Duration = Long.valueOf(String.valueOf(appt.UrgentAppointment__r.Duration__c));
        calendar.ModalityCode = Long.valueOf(appt.Calendar__r.ServiceId__c);
        calendar.procedureCode = appt.Medical_Procedure__r.Procedure_Code__c;
        calendar.siteCode = appt.Site__r.Site_Code__c;  
        System.debug('calendar ' + calendar );
        return new List<ws_AppointmentNew.CalenderSlot>{calendar};	        
    } 
    
    public static void setBarcodeIdentifyTime(List<Appointment__c> appointmentSet, Set<Id> domainIds, Set<Id> siteIds) {
        Set<Id> sites = new Set<Id>();
        Set<Id> domains = new Set<Id>();
        for (Site__c site_i : [SELECT Id
                                    , BarcodeIdentifyPatient__c
                                FROM Site__c
                                WHERE Id IN :siteIds
                                AND BarcodeIdentifyPatient__c = true]) {
            sites.add(site_i.Id);
        }
        for (Domain__c domain_i : [SELECT Id
                                        , BarcodeIdentifyPatient__c
                                    FROM Domain__c
                                    WHERE Id IN :domainIds
                                    AND BarcodeIdentifyPatient__c = true]) {
            domains.add(domain_i.Id);
        }
        System.debug('sites: size: ' + sites.size() + ' value: ' + sites);
        System.debug('domains: size: ' + domains.size() + ' value: ' + domains);

        for (Appointment__c appt_i : appointmentSet) {
            if(sites.contains(appt_i.Site__c) && domains.contains(appt_i.Domain__c)) {           
                appt_i.BarcodeIdentifyTime__c =  calculateRunningTime(appt_i.Appointment_Date_Time__c);  
                System.debug('TR Appointment__c calculateRunningTime ... executed');           
            }
        }       
    }

    private static Datetime calculateRunningTime(Datetime apptDateTime) {        
        System.debug('calculateRunningTime  apptDateTime: ' + apptDateTime);       
        Integer hour = apptDateTime.hour();
        Integer minute = apptDateTime.minute();        
        
        // אם השעה בין 00:00 ל-02:59
        Set<Integer> allowedValues = new Set<Integer>{0, 1, 2};
        if (allowedValues.contains(hour)) {              
            Date dayBefore = apptDateTime.date().addDays(-1);
            return Datetime.newInstance(dayBefore, Time.newInstance(hour - 3, 30, 0, 0));
        } else {           
            return Datetime.newInstance(apptDateTime.date(), Time.newInstance(hour - 3, 30, 0, 0));
        }
    }

    @future(callout=true)
    public static void createCpapSurvey(Set<Id> appointmentIdSet) {
        Boolean logicExecuted = false;
        List<SMS__c> smssToInsert = new List<SMS__c>();
        List<Agent_survey__c> surveiesToInsert = new List<Agent_survey__c>();
        Survey_Assuta__c cpapSurvey = [SELECT Id, Name FROM Survey_Assuta__c WHERE Name = 'cpap_survey' LIMIT 1];

        if (cpapSurvey == null) {
            return;
        }

        for (Appointment__c appt_i : [ SELECT Id
                                            , case__c                                    
                                            , Patient_Account__r.SMS_Phone_Number__c                                                                                                                                                                                                                                            
                                        FROM Appointment__c
                                        WHERE Id IN : appointmentIdSet]) {       
            if (appt_i.Patient_Account__r.SMS_Phone_Number__c != null)  {
                surveiesToInsert.add(prepareAgentSurvey(appt_i, cpapSurvey.Id));               
            }                               
        }   
        
        System.debug('surveiesToInsert: size: ' + surveiesToInsert.size() + ' value: ' + surveiesToInsert);
        if(!surveiesToInsert.isEmpty()) {
            Set<Id> insertedSurveyIdSet = AsyncUtil.doInsert(surveiesToInsert);

            for (Agent_survey__c survey_i : [SELECT Id
                                        , Related_Appointment__c                                         
                                        , Account_Survived__c
                                        , Account_Survived__r.SMS_Phone_Number__c
                                        , Survey__c
                                        , link__c
                                    FROM Agent_survey__c 
                                    WHERE Id IN :insertedSurveyIdSet]) {
                if (survey_i.link__c != null) {
                    smssToInsert.add(prepareSurveySMS(survey_i.Id, survey_i.Related_Appointment__c, survey_i.Account_Survived__c, survey_i.Account_Survived__r.SMS_Phone_Number__c ));           
                }                                                       
            }
                       
            System.debug('smssToInsert: size: ' + smssToInsert.size() + ' value: ' + smssToInsert);
            if (!smssToInsert.isEmpty()) {
                AsyncUtil.doInsert(smssToInsert);
                logicExecuted = true; 
            }
            if (logicExecuted) {
                System.debug('TR Appointment__c createCpapSurvey ... executed');
            }     
        }
    }

    private static Agent_survey__c prepareAgentSurvey(Appointment__c appointment, String survey) {
        return new Agent_survey__c(
            Account_Survived__c = appointment.Patient_Account__c,
            Related_Appointment__c = appointment.Id,
            Survey__c = survey
        );
    }

    private static SMS__c prepareSurveySMS(Id agentSurveyId, Id appointmentId, Id accountId, String phoneNumber) {
        return new SMS__c(
            Account__c = accountId,           
            Appointment__c = appointmentId, 
            smsTemplate__c = 'CPAPSurvey',
            Phone_Number__c = phoneNumber,                      
            Type__c = 'Outgoing',
            AgentSurvey__c = agentSurveyId 
        );
    }  
        
    public static void linkAppointments(Map<Id, Appointment__c> appointmentMap, Set<Id> patientIdSet,  Map<String, List<Medical_Procedure_Link__mdt>> medicalProcedureLinkMap) {
        List<Appointment__c> AppointmentToUpdate = new List<Appointment__c>();
        Map<String, Appointment__c> procedureToAppointmentMap = new Map<String, Appointment__c>();
        Map<String, Appointment__c> domainToAppointmentMap = new Map<String, Appointment__c>();          
        String key = null;

        //search for appointments that are related to the current appointment
        for (Appointment__c appt_i : [SELECT Id, Patient_Account__c , Appointment_Date_Time__c, after_appointment__c
                                             , Medical_Procedure__r.Procedure_Code__c, Domain__r.DomainCode__c
                                        FROM Appointment__c
                                       WHERE RecordType.DeveloperName = 'Institutes'
                                         AND Patient_Account__c IN :patientIdSet
                                         AND Date_of_appointment__c >= TODAY
                                         AND Appointment_Status__c NOT IN ('Canceled', 'CanceledFailed')                                        
                                         AND after_appointment__c = null                                        
                                         AND Id NOT IN: appointmentMap.keySet()
                                         AND Domain__r.DomainCode__c != null  
                                         AND Medical_Procedure__r.Procedure_Code__c != null                                                                              
                                         ORDER BY Appointment_Date_Time__c DESC]) {                        
            key = appt_i.Patient_Account__c + '-' + appt_i.Medical_Procedure__r.Procedure_Code__c;
            if (!procedureToAppointmentMap.containsKey(key)) {
                procedureToAppointmentMap.put(key, appt_i);
            }
                        
            key = appt_i.Patient_Account__c + '-' + appt_i.Domain__r.DomainCode__c;
            if (!domainToAppointmentMap.containsKey(key)) {
                domainToAppointmentMap.put(key, appt_i);
            }            
        }
                
        System.debug('domainToAppointmentMap: size: ' + domainToAppointmentMap.size() + ' value: ' + domainToAppointmentMap);
        System.debug('procedureToAppointmentMap: size: ' + procedureToAppointmentMap.size() + ' value: ' + procedureToAppointmentMap);
                
        for (Appointment__c appt_i : appointmentMap.values()) {           
            if (medicalProcedureLinkMap.containsKey(appt_i.MP_code__c)) {                            
                for (Medical_Procedure_Link__mdt medicalProcedureLink :medicalProcedureLinkMap.get(appt_i.MP_code__c)) {
                    Appointment__c relatedAppointment = null;
                    if (medicalProcedureLink.ProcedureCode2__c != null) {
                        key = appt_i.Patient_Account__c + '-' + medicalProcedureLink.ProcedureCode2__c;                        
                        relatedAppointment = procedureToAppointmentMap.get(key);
                        System.debug('relatedAppointment: ' + relatedAppointment);
                    }    
                    if (relatedAppointment == null && medicalProcedureLink.DomainCode__c != null) {
                        key = appt_i.Patient_Account__c + '-' + medicalProcedureLink.DomainCode__c;                        
                        relatedAppointment = domainToAppointmentMap.get(key);
                        System.debug('relatedAppointment: ' + relatedAppointment);
                    }

                    if (relatedAppointment != null) {
                        if (appt_i.after_appointment__c == null) {                           
                            AppointmentToUpdate.add(new Appointment__c(
                                Id = appt_i.Id,
                                after_appointment__c = relatedAppointment.Id
                            ));                           
                        }
                        if (relatedAppointment.after_appointment__c == null) {                           
                            relatedAppointment.after_appointment__c = appt_i.Id;
                            AppointmentToUpdate.add(relatedAppointment);
                        }
                    }                         
                }                
            }
        }
        System.debug('AppointmentToUpdate: size: ' + AppointmentToUpdate.size() + ' value: ' + AppointmentToUpdate);
        if (!AppointmentToUpdate.isEmpty()) {
            update AppointmentToUpdate;
        }
    } 
}