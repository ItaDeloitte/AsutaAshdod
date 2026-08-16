//Test AppointmentTriggerServiceTest
public with sharing class AppointmentTriggerDispatcher {

    public static Boolean isFirstTime = true;

    /**
     * Mark Prevent_Automation__c and No_Automation__c checkboxes if a Medical Procedure linked via Medical_Procedure__c/-2/-3/-4
     * is changed and Confidentiality__c, Cancel_Auto_Leumit__c, Cancel_Auto_Mehudet__c, Cancel_Auto_Maccabi__c is true
     */
    public static void disableAutomation(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c disableAutomation ... start');
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> procedureIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if ((appt_i.RecordTypeId == institutesRTId || appt_i.RecordTypeId == surgeriesRTId) &&
                    (oldMap == null ||
                        oldMap.get(appt_i.Id).Medical_Procedure__c != appt_i.Medical_Procedure__c ||
                        oldMap.get(appt_i.Id).Medical_Procedure2__c != appt_i.Medical_Procedure2__c ||
                        oldMap.get(appt_i.Id).Medical_Procedure3__c != appt_i.Medical_Procedure3__c ||
                        oldMap.get(appt_i.Id).Medical_Procedure4__c != appt_i.Medical_Procedure4__c)) {
                appts.add(appt_i);
                for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                    if (appt_i.get(procedureLookup_i) != null) {
                        procedureIds.add(Id.valueOf((String) appt_i.get(procedureLookup_i)));
                    }
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.disableAutomation(appts, procedureIds);
        }
    }

    /**
     * Fill Appointment_Date__c and appointment_hour__c fields
     */
    public static void fillAppointmentDateAndHour(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c fillAppointmentDateAndHour ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Date_Time__c != null &&
                    (oldMap == null || oldMap.get(appt_i.Id).Appointment_Date_Time__c != appt_i.Appointment_Date_Time__c)) {
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.fillAppointmentDateAndHour(appts);
        }
    }

    /**
     * Fill Medical_Procedure__c and Calendar__c lookups on an Appointment from integration based on filled Calendar_Text__c and
     * Medical_Procedure_Text__c text fields
     */
    public static void fillProcedureAndCalendarLookups(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c fillProcedureAndCalendarLookups ... start');

        if (UserInfo.getProfileId() == Label.Integration_ProfileId || Test.isRunningTest()) {
            List<Appointment__c> appts = new List<Appointment__c>();
            Set<String> procedureCodes = new Set<String>();
            Set<String> calendarCodes = new Set<String>();

            for (Appointment__c appt_i : newList) {
                String newProcedureCode = normalize(appt_i.Medical_Procedure_Text__c);
                String oldProcedureCode= oldMap != null && oldMap.containsKey(appt_i.Id)
                    ? normalize(oldMap.get(appt_i.Id).Medical_Procedure_Text__c)
                    : null;

                if (newProcedureCode != null && newProcedureCode != oldProcedureCode) {
                    appts.add(appt_i);
                    procedureCodes.add(newProcedureCode);

                    String newCalendar = normalize(appt_i.Calendar_Text__c);
                    String oldCalendar = oldMap != null && oldMap.containsKey(appt_i.Id)
                        ? normalize(oldMap.get(appt_i.Id).Calendar_Text__c)
                        : null;

                    if (newCalendar != null && newCalendar != oldCalendar) {
                        calendarCodes.add(newCalendar);
                    }
                }
            }
            System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
            System.debug('procedureCodes: size: ' + procedureCodes.size() + ' value: ' + procedureCodes);
            System.debug('calendarCodes: size: ' + calendarCodes.size() + ' value: ' + calendarCodes);

            if (!appts.isEmpty()) {
                AppointmentTriggerService.fillProcedureAndCalendarLookups(appts, procedureCodes, calendarCodes);
            }
        }
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? null : value.trim().toLowerCase();
    }

    /**
     * Fill Site__c lookup on an Appointment from integration based on filled Site_Text__c text field
     */
    public static void fillSiteLookup(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c fillSiteLookup ... start');

        if (UserInfo.getProfileId() == Label.Integration_ProfileId || Test.isRunningTest()) {
            List<Appointment__c> appts = new List<Appointment__c>();
            Set<String> siteCodes = new Set<String>();

            for (Appointment__c appt_i : newList) {
                if (appt_i.Site_Text__c != null &&
                        (oldMap == null || oldMap.get(appt_i.Id).Site_Text__c != appt_i.Site_Text__c)) {
                    appts.add(appt_i);
                    siteCodes.add(appt_i.Site_Text__c);
                }
            }
            System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
            System.debug('siteCodes: size: ' + siteCodes.size() + ' value: ' + siteCodes);

            if (!appts.isEmpty()) {
                AppointmentTriggerService.fillSiteLookup(appts, siteCodes);
            }
        }
    }

    /**
     * Fill PayerFactor__c lookup on an Appointment from integration based on filled Payer_Factor_Code__c text field
     */
    public static void fillPayerFactorLookup(List<Appointment__c> newList) {
        System.debug('TR Appointment__c fillPayerFactorLookup ... start');

        if (UserInfo.getProfileId() == Label.Integration_ProfileId || Test.isRunningTest()) {
            List<Appointment__c> appts = new List<Appointment__c>();
            Set<String> pfCodes = new Set<String>();

            for (Appointment__c appt_i : newList) {
                if (appt_i.Payer_Factor_Code__c != null) {
                    appts.add(appt_i);
                    pfCodes.add(appt_i.Payer_Factor_Code__c);
                }
            }
            System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
            System.debug('pfCodes: size: ' + pfCodes.size() + ' value: ' + pfCodes);

            if (!appts.isEmpty()) {
                AppointmentTriggerService.fillPayerFactorLookup(appts, pfCodes);
            }
        }
    }

    /**
     * Fill Appointment_Status__c and Remainder_type__c with appropriate values (from עריכת פגישה - ליאור process builder)
     */
    public static void updateReminderType(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateReminderType ... start');
        Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.RecordTypeId != surgeriesRTId &&
                    (appt_i.Appointment_Status__c == 'NewAppointment' || appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה') &&
                    !appt_i.more_than_14_days__c &&
                    (oldMap == null ||
                        oldMap.get(appt_i.Id).Appointment_Status__c != appt_i.Appointment_Status__c ||
                        oldMap.get(appt_i.Id).more_than_14_days__c != appt_i.more_than_14_days__c ||
                        oldMap.get(appt_i.Id).Remainder_time__c != appt_i.Remainder_time__c ||
                        oldMap.get(appt_i.Id).Date_for_human_reminder__c != appt_i.Date_for_human_reminder__c ||
                        oldMap.get(appt_i.Id).Date_for_tizkorit_reminder__c != appt_i.Date_for_tizkorit_reminder__c ||
                        oldMap.get(appt_i.Id).dateRemainder1WA__c != appt_i.dateRemainder1WA__c ||
                        oldMap.get(appt_i.Id).dateRemainder2WA__c != appt_i.dateRemainder2WA__c)) {
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.updateReminderType(appts);
        }
    }

    /**
     * Fill formtitan_id_2__c field by generated randomly key via CommonService.generateRandomKey(15)
     */
    public static void fillFormtitanId(List<Appointment__c> newList) {
        System.debug('TR Appointment__c fillFormtitanId ... start');

        // no criteria
        System.debug('appts: size: ' + newList.size() + ' value: ' + newList);
        AppointmentTriggerService.fillFormtitanId(newList);
    }

    /**
     * Fill Remainder_status__c with appropriate value (immediate action from reminders process builders)
     */
    public static void updateReminderStatus(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateReminderStatus ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> procedureIds = new Set<Id>();
        Set<Id> patientIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה' &&
                    appt_i.Remainder_status__c != 'השיב להודעה בשלילה' &&
                    appt_i.Remainder_status__c != 'השיב להודעה בחיוב' &&
                    appt_i.Medical_Procedure__c != null &&
                    appt_i.Patient_Account__c != null &&
                    appt_i.Case__c != null &&
                    (oldMap == null ||
                        oldMap.get(appt_i.Id).Appointment_Status__c != appt_i.Appointment_Status__c ||
                        oldMap.get(appt_i.Id).Remainder_status__c != appt_i.Remainder_status__c ||
                        oldMap.get(appt_i.Id).Medical_Procedure__c != appt_i.Medical_Procedure__c ||
                        oldMap.get(appt_i.Id).Patient_Account__c != appt_i.Patient_Account__c ||
                        oldMap.get(appt_i.Id).Case__c != appt_i.Case__c)) {
                procedureIds.add(appt_i.Medical_Procedure__c);
                patientIds.add(appt_i.Patient_Account__c);
                caseIds.add(appt_i.Case__c);
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('caseIds: size: ' + caseIds.size() + ' value: ' + caseIds);
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.updateReminderStatus(appts, caseIds, patientIds, procedureIds);
        }
    }

    /**
     * Create cases_and_appoitments__c junction object between an Appointment and its Case
     */
    public static void createJunction(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c createJunction ... start');
        Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if ((appt_i.RecordTypeId == surgeriesRTId || appt_i.RecordTypeId == expertsRTId) &&
                    (appt_i.Case__c != null || appt_i.Case_Hidden__c != null) &&
                    appt_i.Created_from_appointment_screen__c == false &&
                    (oldMap == null ||
                        oldMap.get(appt_i.Id).Case__c != appt_i.Case__c ||
                        oldMap.get(appt_i.Id).Case_Hidden__c != appt_i.Case_Hidden__c)) {
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.createJunction(appts);
        }
    }

    /**
     * Set Payment Source and Payment Status based on Payer Factor value
     */
    public static void setPaymentStatus(List<Appointment__c> newList) {
        System.debug('TR Appointment__c setPaymentStatus ... start');
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        Map<Id, Medical_Procedure__c> procedureMap = new Map<Id, Medical_Procedure__c>();        
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        Set<Id> pfIdSet = new Set<Id>();
        Boolean isInstitutes = false;        

        for (Appointment__c appt_i : newList) {
            if (appt_i.RecordTypeId == institutesRTId) {
                isInstitutes = true;
                break;
            }
        }

        if (isInstitutes) {
            procedureMap = new Map<Id, Medical_Procedure__c>([
                SELECT Id
                  FROM Medical_Procedure__c
                 WHERE IsCancelIfNotPayed__c = true]);
        }       
        
        for (Appointment__c appt_i : newList) {
            if ((appt_i.RecordTypeId == expertsRTId
                        || (appt_i.RecordTypeId == institutesRTId && procedureMap.containsKey(appt_i.Medical_Procedure__c)))
                    && appt_i.Order_Notes__c != null    
                    && AppointmentTriggerUtil.containsInternetKeyword(appt_i.Order_Notes__c)) {
                appointmentList.add(appt_i);
                pfIdSet.add(appt_i.PayerFactor__c);
            }
        }

        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);
        System.debug('pfIdSet: size: ' + pfIdSet.size() + ' value: ' + pfIdSet);

        if (!appointmentList.isEmpty()) {
            AppointmentTriggerService.setPaymentStatus(appointmentList, pfIdSet);
        }
    }

    /**
     * Schedule payment status check 25 minutes ahead if Payment Status is 2
     */
    public static void schedulePaymentStatusCheck(List<Appointment__c> newList) {
        System.debug('TR Appointment__c schedulePaymentStatusCheck ... start');
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();        
        Set<Id> appointmentIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if ((appt_i.RecordTypeId == expertsRTId || appt_i.RecordTypeId == institutesRTId)
                    && appt_i.PaymentStatus__c == 'Yet_Done'
                    && appt_i.Order_Notes__c != null
                    && AppointmentTriggerUtil.containsInternetKeyword(appt_i.Order_Notes__c)) {
                appointmentIdSet.add(appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            Datetime dt = Datetime.now().addMinutes(25);
            String CRONEXP = '' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            System.schedule('Payment Status Checker #' + dt.getTime(), CRONEXP, new CheckPaymentStatusSchedule(appointmentIdSet));
            System.debug('TR Appointment__c schedulePaymentStatusCheck ... executed');
        }
    }

    /**
     * Catch Ultrasound appointments which are a part of a procedure plan and do the following: update the lookup from the
     * ultrasound appointment to the mammography one; link the ultrasound appointment to the case of the mammography via a
     * junction of cases to appointments.
     */
    public static void linkProcedurePlan(List<Appointment__c> newList) {
        System.debug('TR Appointment__c linkProcedurePlan ... start');

        if (UserInfo.getProfileId() == Label.Integration_ProfileId || Test.isRunningTest()) {
            Map<String, Appointment__c> orderKeyToApptMap = new Map<String, Appointment__c>();

            // query ultrasound procedure by procedure code
            List<Medical_Procedure__c> ultrasoundList = [SELECT Id FROM Medical_Procedure__c WHERE Procedure_Code__c = '760904'];

            // populate appointments map by order key
            for (Appointment__c appt_i : newList) {
                if (appt_i.OrderKey__c != null &&
                        !ultrasoundList.isEmpty() &&
                        appt_i.Medical_Procedure__c == ultrasoundList.get(0).Id) {
                    orderKeyToApptMap.put(appt_i.OrderKey__c, appt_i);
                }
            }
            System.debug('orderKeyToApptMap: size: ' + orderKeyToApptMap.size() + ' value: ' + orderKeyToApptMap);

            if (!orderKeyToApptMap.isEmpty()) {
                AppointmentTriggerService.linkProcedurePlan(orderKeyToApptMap);
            }
        }
    }

    /**
     * Cancel Appointment in future if the Appointment_Status__c equals 'WaitingForCanceled' and the status was changed
     */
    public static void cancelAppointment(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c cancelAppointment ... start');
        Set<Id> apptIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Status__c == 'WaitingForCanceled' &&
                    oldMap.get(appt_i.id).Appointment_Status__c != appt_i.Appointment_Status__c) {
                apptIds.add(appt_i.id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            CancelApptInFuture.execute(apptIds, '4', 'ביטול המטופל');
            System.debug('TR Appointment__c cancelAppointment ... executed');
        }
    }

    /**
     * Update payment status after payment completed
     */
    public static void updatePaymentStatus(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updatePaymentStatus ... start');
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();        
        List<Appointment__c> appointmentList = new List<Appointment__c>();        
        
        for (Appointment__c appt_i : newList) {
            if ((appt_i.RecordTypeId == expertsRTId || appt_i.RecordTypeId == institutesRTId)
                    && appt_i.PaymentStatus__c == 'Yet_Done'                    
                    && appt_i.ReceiptNum__c != null
                    && oldMap.get(appt_i.Id).ReceiptNum__c == null
                    && appt_i.Order_Notes__c != null
                    && AppointmentTriggerUtil.containsInternetKeyword(appt_i.Order_Notes__c)) {
                appointmentList.add(appt_i);
            }
        }
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);

        if (!appointmentList.isEmpty()) {
            AppointmentTriggerService.updatePaymentStatus(appointmentList);
        }
    }    

    // ====================================================================================================
    // ====================================== approved methods above ======================================
    // =================================== please create a new one below ==================================
    // ====================================================================================================

    public static void cancelRejectedAppointments(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c cancelRejectedAppointments ... start');
        Set<Id> appointmentIdSet = new Set<Id>();
        
        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Status__c == 'נדחה על ידי המנהל'
                    && appt_i.Appointment_Status__c != oldMap.get(appt_i.Id).Appointment_Status__c) {
                appointmentIdSet.add(appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.cancelRejectedAppointments(appointmentIdSet);
            System.debug('TR Appointment__c cancelRejectedAppointments ... future');
        }
    }

    public static void waitingForReschedule(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        for (Appointment__c appt_i : newList) {
            if (appt_i.Accession_Number__c != null
                    && appt_i.Appointment_Date_Time__c != null
                    && appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c) {
                appt_i.Appointment_Status__c = 'NewAppointment';
            }
        }
    }

    /**
     * Modified to avoid a loop inside a loop in service class. Added oldMap conditions
     */
    public static void sourceSystemCanceledReason(Map<Id, Appointment__c> oldMap, List<Appointment__c> newList) {
        // System.debug('TR Appointment__c sourceSystemCanceledReason ... start');

        // if (UserInfo.getProfileId() == Label.Integration_ProfileId || Test.isRunningTest()) {
        //     List<Appointment__c> appointments = new List<Appointment__c>();
        //     Set<String> cancelReasons = new Set<String>();

        //     Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();

        //     for (Appointment__c appointment_i : newList) {
        //         if (appointment_i.Appointment_Status__c == 'Canceled' && String.isNotBlank(appointment_i.Canceled_Reason__c) && appointment_i.RecordTypeId != surgeriesRTId
        //             && (oldMap == null || (oldMap.get(appointment_i.Id).Appointment_Status__c != appointment_i.Appointment_Status__c || oldMap.get(appointment_i.Id).Canceled_Reason__c != appointment_i.Canceled_Reason__c))) {
        //                 cancelReasons.add(appointment_i.Canceled_Reason__c);
        //                 appointments.add(appointment_i);
        //             }
        //     }
        //     System.debug('appointments: size: ' + appointments.size() + ' value: ' + appointments);
        //     System.debug('cancelReasons: size: ' + cancelReasons.size() + ' value: ' + cancelReasons);

        //     if (!appointments.isEmpty() && !cancelReasons.isEmpty()) {
        //         AppointmentTriggerService.updateCancellationReasonField(appointments, cancelReasons);
        //     }
        // }
    }

    /**
     * Check business day or holiday in calendar and update reminder date. Update Date_for_tizkorit_reminder__c,
     * Date_for_human_reminder__c, Remainder_time__c in Appointment__c It is rewritten to query only the necessary
     * procedures and calendars. Should check the logic to improve work.
     */
    public static void updateReminderDate(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('AppointmentTriggerDispatcher.updateReminderDate...\nnewList: ' + newList + '\noldMap: ' + oldMap);
        Map<String, MedicalProcedurePlanService.MedicalPlanResponse> responseMap = new Map<String, MedicalProcedurePlanService.MedicalPlanResponse>();
        List<Appointment__c> filteredAppointmentList = new List<Appointment__c>();
        Set<String> medicalProcedureIdSet = new Set<String>();                
        Set<Date> dateSet = new Set<Date>{};

        for (Appointment__c appointment_i : newList) {
            if (!String.isEmpty(appointment_i.Medical_Procedure__c)
                    && appointment_i.Appointment_Date_Time__c != null
                    && appointment_i.Appointment_Date_Time__c.date() >= Date.today()
                    && (oldMap == null
                        || oldMap.get(appointment_i.Id).Site__c != appointment_i.Site__c
                        //|| oldMap.get(appointment_i.Id).manualRunWAR__c != appointment_i.manualRunWAR__c
                        || oldMap.get(appointment_i.Id).Medical_Procedure__c != appointment_i.Medical_Procedure__c
                        || oldMap.get(appointment_i.Id).sendingByWhatsApp__c != appointment_i.sendingByWhatsApp__c
                        || oldMap.get(appointment_i.Id).Appointment_Date_Time__c != appointment_i.Appointment_Date_Time__c)) {
                filteredAppointmentList.add(appointment_i);                               
                medicalProcedureIdSet.add(appointment_i.Medical_Procedure__c);

            }
        }
        System.debug('filteredAppointmentList: size: ' + filteredAppointmentList.size() + ' value: ' + filteredAppointmentList);
        System.debug('medicalProcedureIdSet: size: ' + medicalProcedureIdSet.size() + ' value: ' + medicalProcedureIdSet);
        if (filteredAppointmentList.isEmpty()) {
            return;
        }        

        Map<String, Medical_Procedure__c> medicalProcedureMap = new Map<String, Medical_Procedure__c>(obtainMedicalProcedureList(medicalProcedureIdSet));
        System.debug('medicalProcedureMap: size: ' + medicalProcedureMap.size() + ' value: ' + medicalProcedureMap);
        
        responseMap = getMedicalProcedurePlan(filteredAppointmentList, medicalProcedureMap);

        for (Appointment__c appointment_i : filteredAppointmentList) {
            Medical_Procedure__c procedure_i = medicalProcedureMap.get(appointment_i.Medical_Procedure__c);
            String procedureCode = procedure_i.Procedure_Code__c;
            String siteCode      = appointment_i.Site_Code__c;

            if (!responseMap.isEmpty()) {
                System.debug('check Medical Procedure Plan');                 
                String key = siteCode + '|' + procedureCode;                    
                MedicalProcedurePlanService.MedicalPlanResponse res = responseMap.get(key);                     
                Boolean shouldSend =  res != null && (!res.found || res.sendMessage);
                
                System.debug('shouldSend ' + shouldSend);  
                if (!shouldSend) {
                    continue;
                }                                 
            }
              
            if (procedure_i.Humen__c != null && !appointment_i.sendingByWhatsApp__c) {
                addDateToSet(dateSet, procedure_i.Humen__c, appointment_i.Appointment_Date_Time__c.date(), false);
            }

            switch on siteCode {
                when '33'{
                    if (!appointment_i.sendingByWhatsApp__c) {
                        addDateToSet(dateSet, procedure_i.SMS_Reminder_Ashdod__c, appointment_i.Appointment_Date_Time__c.date(), false);
                        addDateToSet(dateSet, procedure_i.Voice_Reminder_Ashdod__c, appointment_i.Appointment_Date_Time__c.date(), false);
                    }
                }
                when else {
                    if (appointment_i.sendingByWhatsApp__c) {
                        addDateToSet(dateSet, procedure_i.remainder1WA__c, appointment_i.Appointment_Date_Time__c.date(), false);
                        addDateToSet(dateSet, procedure_i.remainder2WA__c, appointment_i.Appointment_Date_Time__c.date(), false);
                        addDateToSet(dateSet, procedure_i.preRemainderWA__c, Date.today(), true);
                        addDateToSet(dateSet, procedure_i.Voice_Reminder_WA__c, appointment_i.Appointment_Date_Time__c.date(), false);
                        addDateToSet(dateSet, procedure_i.Human_Reminder_WA__c, appointment_i.Appointment_Date_Time__c.date(), false);


                    } else {
                        addDateToSet(dateSet, procedure_i.SMS_Reminder__c, appointment_i.Appointment_Date_Time__c.date(), false);
                        addDateToSet(dateSet, procedure_i.Voice_Reminder__c, appointment_i.Appointment_Date_Time__c.date(), false);
                    }
                }
            }
        }
        System.debug('dateSet: size: ' + dateSet.size() + ' value: ' + dateSet);
        if (dateSet.isEmpty()) {
            return;
        }
        Date startDate;
        Date endDate;

        for (Date date_i : dateSet) {
            startDate = (startDate == null || date_i < startDate) ? date_i : startDate;
            endDate = (endDate == null || date_i > endDate) ? date_i : endDate;
        }
        System.debug('startDate: ' + startDate);
        System.debug('endDate: ' + endDate);
        List<Calendar1__c> calendarList = obtainCalendarList(startDate, endDate);
        Map<Date, Calendar1__c> dateToCalendarMap = new Map<date, Calendar1__c>();

        for (Calendar1__c calendar_i : calendarList) {
            startDate = calendar_i.Gregorian_Date__c < startDate ? calendar_i.Gregorian_Date__c : startDate;
            dateToCalendarMap.put(calendar_i.Gregorian_Date__c, calendar_i);
        }
        System.debug('dateToCalendarMap: size: ' + dateToCalendarMap.size() + ' value: ' + dateToCalendarMap);

        for (Appointment__c appointment_i : filteredAppointmentList) {
            Date reminderDate_i;
            Date humanReminderDate_i;
            Date tizkoritReminderDate_i;
            Date reminder1WADate_i;
            Date reminder2WADate_i;
            Date preReminderWADate_i;
            Medical_Procedure__c procedure_i = medicalProcedureMap.get(appointment_i.Medical_Procedure__c);
            String siteCode = appointment_i.Site_Code__c;

            if (procedure_i.Humen__c != null && !appointment_i.sendingByWhatsApp__c) {
                humanReminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(),startDate, Integer.valueOf(procedure_i.Humen__c), dateToCalendarMap, false);
            }

            switch on siteCode {
                when '33'{
                    if (!appointment_i.sendingByWhatsApp__c) {
                        if (procedure_i.SMS_Reminder_Ashdod__c != null) {
                            reminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate,Integer.valueOf(procedure_i.SMS_Reminder_Ashdod__c), dateToCalendarMap, false);
                        }
                        if (procedure_i.Voice_Reminder_Ashdod__c != null) {
                            tizkoritReminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, Integer.valueOf(procedure_i.Voice_Reminder_Ashdod__c), dateToCalendarMap, false);
                        }
                    }
                }
                when else {
                    if (appointment_i.sendingByWhatsApp__c) {
                        if (procedure_i.remainder1WA__c != null) {
                            reminder1WADate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, Integer.valueOf(procedure_i.remainder1WA__c), dateToCalendarMap, false);
                        }
                        if (procedure_i.remainder2WA__c != null) {
                            reminder2WADate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, Integer.valueOf(procedure_i.remainder2WA__c), dateToCalendarMap, false);
                        }
                        if (procedure_i.preRemainderWA__c != null && (Date.today().daysBetween(appointment_i.Appointment_Date_Time__c.date())) >= 90 ) {
                            preReminderWADate_i = getReminderDate(Date.today(), startDate, Integer.valueOf(procedure_i.preRemainderWA__c), dateToCalendarMap, true);
                        }
                        if (procedure_i.Voice_Reminder_WA__c != null) {
                            tizkoritReminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, Integer.valueOf(procedure_i.Voice_Reminder_WA__c), dateToCalendarMap, false);
                        }
                        if (procedure_i.Human_Reminder_WA__c != null) {
                            humanReminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, Integer.valueOf(procedure_i.Human_Reminder_WA__c), dateToCalendarMap, false);
                        }
                        
                     } else {
                        if (procedure_i.SMS_Reminder__c != null) {
                            reminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, Integer.valueOf(procedure_i.SMS_Reminder__c), dateToCalendarMap, false);
                        }
                        if (procedure_i.Voice_Reminder__c != null) {
                            tizkoritReminderDate_i = getReminderDate(appointment_i.Appointment_Date_Time__c.date(),startDate, Integer.valueOf(procedure_i.Voice_Reminder__c), dateToCalendarMap, false);
                        }
                    }
                }
            }

            appointment_i.dateRemainder1WA__c = reminder1WADate_i;
            appointment_i.dateRemainder2WA__c = reminder2WADate_i;
            appointment_i.preDateReminderWA__c = preReminderWADate_i;
            appointment_i.Remainder_time__c = reminderDate_i;
            appointment_i.Date_for_tizkorit_reminder__c = tizkoritReminderDate_i;
            appointment_i.Date_for_human_reminder__c = humanReminderDate_i;
        }
    }

    private static Map<String, MedicalProcedurePlanService.MedicalPlanResponse> getMedicalProcedurePlan(List<Appointment__c> appointment, Map<String, Medical_Procedure__c> medicalProcedureMap) {        
        
        List<MedicalProcedurePlanService.MedicalPlanRequest> requests = new List<MedicalProcedurePlanService.MedicalPlanRequest>();

        for (Appointment__c appointment_i : appointment) {

            Medical_Procedure__c procedure_i = medicalProcedureMap.get(appointment_i.Medical_Procedure__c);
            if (procedure_i == null) continue;

            MedicalProcedurePlanService.MedicalPlanRequest req = new MedicalProcedurePlanService.MedicalPlanRequest();
            Boolean isAfter = appointment_i.after_appointment__c != null;
            
            req.procedureCode1 = isAfter ? null : medicalProcedureMap.get(appointment_i.Medical_Procedure__c).Procedure_Code__c;
            req.procedureCode2 = isAfter ? medicalProcedureMap.get(appointment_i.Medical_Procedure__c).Procedure_Code__c : null;             
            req.siteCode       = appointment_i.Site_Code__c;
            
            if((req.procedureCode1 != null || req.procedureCode2 != null ) && req.siteCode != null) {
                requests.add(req);
            }            
        }

        Map<String, MedicalProcedurePlanService.MedicalPlanResponse> responseMap = new Map<String, MedicalProcedurePlanService.MedicalPlanResponse>();

        if (!requests.isEmpty()) {
            List<MedicalProcedurePlanService.MedicalPlanResponse> responses = MedicalProcedurePlanService.getMedicalPlanSettings(requests);
            for (MedicalProcedurePlanService.MedicalPlanResponse res : responses) {
                String key = res.siteCode + '|' + res.procedureCode;
                responseMap.put(key, res);
            }
        }
        return responseMap;
    }

    private static void addDateToSet(Set<Date> dateSet, String fieldValue, Date appointmentDate, Boolean isForward) {
        if(fieldValue != null) {
            dateSet.add(appointmentDate);
            if (!isForward) {
                dateSet.add(appointmentDate.addDays(-Integer.valueOf(fieldValue)));
            } else{
                dateSet.add(appointmentDate.addDays(Integer.valueOf(fieldValue)));
            }
            
        }
    }

    private static List<Medical_Procedure__c> obtainMedicalProcedureList(Set<String> recordIdSet) {
        return [SELECT Id
                     , Humen__c
                     , remainder1WA__c
                     , remainder2WA__c
                     , SMS_Reminder__c
                     , Voice_Reminder__c
                     , preRemainderWA__c
                     , SMS_Reminder_Ashdod__c
                     , Voice_Reminder_Ashdod__c
                     , Voice_Reminder_WA__c
                     , Human_Reminder_WA__c
                     , Procedure_Code__c
                  FROM Medical_Procedure__c
                 WHERE ID IN :recordIdSet];
    }       

    private static List<Calendar1__c> obtainCalendarList(Date startDate, Date endDate) {
        Integer daysBeetween = startDate.daysBetween(endDate) + 1;

        return [SELECT Id
                     , business_day__c
                     , Gregorian_Date__c
                  FROM Calendar1__c
                 WHERE business_day__c = true
                   AND Gregorian_Date__c <= :endDate
              ORDER BY Gregorian_Date__c DESC
                 LIMIT :daysBeetween];
    }

    public static Date getReminderDate(Date startDate, Date minDate, Integer numOfDays, Map<Date, Calendar1__c> calendarMap, Boolean isForward) { 
        Integer counter = 0;
        Integer day = 1;
        Date endDay;
        
        System.debug('numOfDays ' + numOfDays);       
        do {
            if (!isForward) {
                endDay = startDate.addDays(-day); 
            } else {
                endDay = startDate.addDays(day); 
            }
            Calendar1__c calendar_i = calendarMap.get(endDay);
            
            if (calendar_i != null) {
                counter +=1;
            }
            day+=1;
            
            if (endDay < minDate) {
                return null;                
            }
        } while (counter < numOfDays);      
        return endDay;
	}    
    /**
     * Delete (change status if less 7 days) all medical aid records on canceled appointment
     */
    public static void resetMedicalAids(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c resetMedicalAids ... start');
        Set<Id> appointmentIdSet = new Set<Id>();
        Date maxAppointmentDate = Date.today();
        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('resetMedicalAids', appt_i.Id)
                    && appt_i.Appointment_Status__c == 'Canceled'
                    && appt_i.Appointment_Status__c != oldMap.get(appt_i.Id).Appointment_Status__c) {
                appointmentIdSet.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('resetMedicalAids', appt_i.Id);
                if (maxAppointmentDate < appt_i.Appointment_Date_Time__c) {
                    maxAppointmentDate = appt_i.Appointment_Date_Time__c.date();
                }
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);
        System.debug('maxAppointmentDate: ' + maxAppointmentDate);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.resetMedicalAids(appointmentIdSet, maxAppointmentDate);
            System.debug('TR Appointment__c resetMedicalAids ... future');
        }
    }

    /**
     * Reset reminders if any of reminders' date updated
     */
    public static void resetReminders(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c resetReminders ... start');
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if ((appt_i.RecordTypeId == institutesRTId || appt_i.RecordTypeId == expertsRTId)
                    && appt_i.Medical_Procedure__c != null
                    && appt_i.Appointment_Date_Time__c != null
                    && appt_i.Appointment_Date_Time__c > System.now()
                    && (appt_i.Remainder_time__c != null
                        || appt_i.Date_for_human_reminder__c != null
                        || appt_i.Date_for_tizkorit_reminder__c != null
                        || appt_i.dateRemainder1WA__c != null
                        || appt_i.dateRemainder2WA__c != null)
                    && (oldMap.get(appt_i.Id).Medical_Procedure__c != appt_i.Medical_Procedure__c
                        || oldMap.get(appt_i.Id).Site__c != appt_i.Site__c
                        //|| oldMap.get(appt_i.Id).manualRunWAR__c != appt_i.manualRunWAR__c
                        || oldMap.get(appt_i.Id).Appointment_Date_Time__c != appt_i.Appointment_Date_Time__c)
                    && (oldMap.get(appt_i.Id).Remainder_time__c != appt_i.Remainder_time__c
                        || oldMap.get(appt_i.Id).Date_for_human_reminder__c != appt_i.Date_for_human_reminder__c
                        || oldMap.get(appt_i.Id).Date_for_tizkorit_reminder__c != appt_i.Date_for_tizkorit_reminder__c
                        || oldMap.get(appt_i.Id).dateRemainder1WA__c!= appt_i.dateRemainder1WA__c
                        || oldMap.get(appt_i.Id).dateRemainder2WA__c!= appt_i.dateRemainder2WA__c)) {
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.resetReminders(appts);
        }
    }

    /**
     * Unmark the SMS_Reminder_Process__c checkbox if it's true and user isn't Deloitte Admin
     */
    public static void unmarkSMSReminderProcess(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c unmarkSMSReminderProcess ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        if (UserInfo.getUserId() != Id.valueOf(Label.Deloitte_Admin_Id)) {
            for (Appointment__c appt_i : newList) {
                if (appt_i.SMS_Reminder_Process__c) {
                    appts.add(appt_i);
                }
            }
            System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

            if (!appts.isEmpty()) {
                AppointmentTriggerService.unmarkSMSReminderProcess(appts);
            }
        }
    }

    /**
     * Update reminder status in source system by web service
     */
    public static void updateRemindersInSourceSystem(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('AppointmentTriggerDispatcher.updateRemindersInSourceSystem...\nnewList: ' + newList + ' \noldMap: ' + oldMap);
        System.debug('isFirstTime ' + isFirstTime);
        Set<String> jsonInputs = new Set<String>();

        for (Appointment__c appt_i : newList) {
            Appointment__c apptOld_i = oldMap.get(appt_i.Id);
            if (
                isFirstTime &&
                (
                    appt_i.Remainder_status__c != null && apptOld_i.Remainder_status__c != appt_i.Remainder_status__c ||
                    appt_i.manual_arrival__c && apptOld_i.manual_arrival__c != appt_i.manual_arrival__c ||
                    appt_i.sms_reminder_sent__c && apptOld_i.sms_reminder_sent__c != appt_i.sms_reminder_sent__c ||
                    appt_i.human_reminder_transferred__c && apptOld_i.human_reminder_transferred__c != appt_i.human_reminder_transferred__c
                ) &&
                (
                    appt_i.RecordTypeId == AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId() ||
                    appt_i.RecordTypeId == AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId()
                ) &&
                appt_i.Accession_Number__c != null
            ) {
                String statusCode;
                isFirstTime = false;
                System.debug('appt_i.Remainder_status__c ' + appt_i.Remainder_status__c);
                if (appt_i.manual_arrival__c && apptOld_i.manual_arrival__c != appt_i.manual_arrival__c) {
                    statusCode = '17';
                } else if (appt_i.Remainder_status__c == 'אין מענה') {
                    if (appt_i.sms_reminder_sent__c && apptOld_i.sms_reminder_sent__c != appt_i.sms_reminder_sent__c) {
                        statusCode = '11';
                    } else if (appt_i.human_reminder_transferred__c && apptOld_i.human_reminder_transferred__c != appt_i.human_reminder_transferred__c) {
                        statusCode = '12';
                    }
                } else if (appt_i.Remainder_status__c != null && apptOld_i.Remainder_status__c != appt_i.Remainder_status__c) {
                    if(appt_i.Remainder_type__c == 'SMS' || appt_i.Remainder_type__c == 'WhatsApp'){
                        if (appt_i.Remainder_status__c == 'השיב להודעה בחיוב') {
                            statusCode = '13';
                        } else if (appt_i.Remainder_status__c == 'השיב להודעה בשלילה') {
                            statusCode = '14';
                        }
                    } 
                }
                if (statusCode != null) {
                    jsonInputs.add(
                        JSON.serialize(
                            new Map<String, String>{
                                'accessionNumber' => appt_i.Accession_Number__c,
                                'followUpTypeCode' => statusCode
                            }
                        )
                    );
                }
            }
        }  
        System.debug('jsonInputs: size: ' + jsonInputs.size() + ' value: ' + jsonInputs);

        if (!jsonInputs.isEmpty() && !System.isFuture() && !System.isBatch()) {
            ws_UpdateReminderStatus.sendUpdateRemindersRequest(jsonInputs);
        }
    }

    /**
     * In update dateTime of app (Institutes, Experts), have to update reminder record of this app to inActive
     */
    public static void updateReminderRecordToInActive(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('AppointmentTriggerDispatcher.updateReminderRecordToInActive...nnewList: ' + newList + ' \noldMap: ' + oldMap);
        Set<Id> appIds = new Set<Id>();
        for (Appointment__c appt_i : newList) {
            if (
                appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c &&
                (
                    appt_i.RecordTypeId == AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId() ||
                    appt_i.RecordTypeId == AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId()
                ) &&
                (
                    appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה' ||
                    appt_i.Appointment_Status__c == 'WaitingForAppointment' ||
                    appt_i.Appointment_Status__c == 'RescheduleByClient' ||
                    appt_i.Appointment_Status__c == 'RescheduleByAssuta' ||
                    appt_i.Appointment_Status__c == 'Canceled'
                )
            )
            appIds.add(appt_i.Id);
        }
        System.debug('appIds: size: ' + appIds.size() + ' value: ' + appIds);

        if (!appIds.isEmpty()) {
            AppointmentTriggerService.updateReminderRecordToInActive(appIds);
        }
    }

    /**
     * Creating new Survey for each new Appointment
     */
    /*public static void createSurvey(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c createSurvey ... start');
        Set<Id> apptIds = new Set<Id>();

        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id surgeryRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('createSurvey', appt_i.Id)
                    && ((oldMap == null && (appt_i.RecordTypeId == surgeryRTId || (appt_i.RecordTypeId == institutesRTId && appt_i.Accession_Number__c != null))) ||
                (oldMap != null && appt_i.Accession_Number__c != null && oldMap.get(appt_i.Id).Accession_Number__c == null))) {
                AppointmentTriggerUtil.addExecutedRecordId('createSurvey', appt_i.Id);
                apptIds.add(appt_i.Id);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        if (!apptIds.isEmpty()) {
            AppointmentTriggerService.createSurvey(apptIds);
            System.debug('TR Appointment__c createSurvey ... future');
        }
    }*/

    /**
     * When creating/updating sales Appointment, need to check what is the lastest Appointment that releted to the caseAfterSale
     */
    public static void findLatestSalesApp(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c findLatestSalesApp ... start');
        Set<Id> appIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('findLatestSalesApp', appt_i.Id)
                    && appt_i.Case__c != null
                    && appt_i.Opportunity__c != null
                    && (Trigger.isInsert
                        || oldMap.get(appt_i.Id).Appointment_Date_Time__c != appt_i.Appointment_Date_Time__c
                        || (appt_i.Appointment_Status__c == 'Canceled'
                            && oldMap.get(appt_i.Id).Appointment_Status__c != appt_i.Appointment_Status__c))) {
                appIds.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('findLatestSalesApp', appt_i.Id);
            }
        }
        System.debug('appIds: size: ' + appIds.size() + ' value: ' + appIds);

        if (!appIds.isEmpty()) {
            AppointmentTriggerService.findLatestSalesApp(appIds);
            System.debug('TR Appointment__c findLatestSalesApp ... future');
        }
    }

    /**
     * find relevant related document and wmail it
     */
    public static void fillRelatedDocument(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c fillRelatedDocument ... start');
        Set<Id> appointmentIdSet = new Set<Id>();
        Set<Id> procedureIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('fillRelatedDocument', appt_i.Id)
                    && appt_i.Accession_Number__c != null
                    && appt_i.Medical_Procedure__c != null
                    && (appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה' || appt_i.Appointment_Status__c == 'WaitingForAppointment')
                    && (oldMap == null
                        || appt_i.RecordTypeId != oldMap.get(appt_i.Id).RecordTypeId
                        || appt_i.Site__c != oldMap.get(appt_i.Id).Site__c
                        || appt_i.Accession_Number__c != oldMap.get(appt_i.Id).Accession_Number__c
                        || appt_i.Medical_Procedure__c != oldMap.get(appt_i.Id).Medical_Procedure__c
                        || appt_i.Appointment_Status__c != oldMap.get(appt_i.Id).Appointment_Status__c
                        || appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c)) {
                appointmentIdSet.add(appt_i.Id);
                procedureIdSet.add(appt_i.Medical_Procedure__c);
                AppointmentTriggerUtil.addExecutedRecordId('fillRelatedDocument', appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);
        System.debug('procedureIdSet: size: ' + procedureIdSet.size() + ' value: ' + procedureIdSet);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.fillRelatedDocument(appointmentIdSet, procedureIdSet);
            System.debug('TR Appointment__c fillRelatedDocument ... future');
        }
    }

    /**
     * Set Appointment Status based on manual_arrival__c value
     */
    public static void manualArrivalConfirm(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c manualArrivalConfirm ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה' && 
                    appt_i.manual_arrival__c == true && 
                    appt_i.manual_arrival__c != oldMap.get(appt_i.Id).manual_arrival__c) {
                appts.add(appt_i);
            }
        }

        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        if (!appts.isEmpty()) {
            AppointmentTriggerService.manualArrivalConfirm(appts);
        }
    }

    /**
     * Set SignedDoctor based on SignedBy__c value
     */
    public static void updateSignedDoctor(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateSignedDoctor ... start');
        List<Appointment__c> appts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.SignedBy__c != null &&
                    appt_i.SignedBy__c != appt_i.SignedDoctor__c && 
                    appt_i.SignedBy__c != oldMap.get(appt_i.Id).SignedBy__c ) {
                appts.add(appt_i);
            }
        }

        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        if (!appts.isEmpty()) {
            AppointmentTriggerService.updateSignedDoctor(appts);
        }
    }

    /**
     * Set Dateofcredit__c and Dateofarequestforcredit__c fields to current date when the Creditwasmade__c and 
     * applicationforcredit__c fields update to true
     */
    public static void fillCreditDetails(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c FillCreditDetails ... start');
        List<Appointment__c> creditAppts = new List<Appointment__c>();
        List<Appointment__c> applicationAppts = new List<Appointment__c>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Creditwasmade__c == true &&
                    appt_i.Creditwasmade__c != oldMap.get(appt_i.Id).Creditwasmade__c) {
                creditAppts.add(appt_i);
            }

            if (appt_i.applicationforcredit__c == true && 
                    appt_i.applicationforcredit__c != oldMap.get(appt_i.Id).applicationforcredit__c) {
                applicationAppts.add(appt_i);
            }
        }

        System.debug('creditAppts: size: ' + creditAppts.size() + ' value: ' + creditAppts); 
        System.debug('applicationAppts: size: ' + applicationAppts.size() + ' value: ' + applicationAppts);
        if (!creditAppts.isEmpty() || !applicationAppts.isEmpty()) {
            AppointmentTriggerService.FillCreditDetails(creditAppts, applicationAppts);
        }
    }

    /**
     * Update the related Case's Domain__c, date_of_appointment222__c, site_of_appointment__c and Adress_for_app__c fields with
     * values from the Domain__c, Site__c and Appointment_Date_Time__C fields on an Appointment
     */
    public static void updateRelatedCase(List<Appointment__c> newList) {
        System.debug('TR Appointment__c updateRelatedCase ... start');
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        Set<Id> appointmentIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('updateRelatedCase', appt_i.Id)
                    && appt_i.RecordTypeId != expertsRTId
                    && appt_i.Site__c != null
                    && appt_i.Case__c != null
                    && appt_i.Domain__c != null) {
                appointmentIdSet.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('updateRelatedCase', appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.updateRelatedCase(appointmentIdSet);
            System.debug('TR Appointment__c updateRelatedCase ... future');
        }
    }

    /**
     * Update Mailing Approval and Email Approval Date fields 
     */
    public static void updatePatientMailingApproval(List<Appointment__c> pNewList, Map<Id, Appointment__c> pOldMap) {
        System.debug('TR Appointment__c updatePatientMailingApproval ... start');
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        Set<Id> appointmentIdSet = new Set<Id>();

        for (Appointment__c appointment_i : pNewList) {
            if (!AppointmentTriggerUtil.isMethodRun('updatePatientMailingApproval', appointment_i.Id)
                    && (appointment_i.RecordTypeId == expertsRTId || appointment_i.RecordTypeId == institutesRTId)
                    && appointment_i.after_appointment__c == null
                    && appointment_i.Medical_Procedure__c != null
                    && appointment_i.Patient_Account__c != null
                    && ((pOldMap == null
                            && appointment_i.Accession_Number__c != null)
                        || (pOldMap != null
                            && appointment_i.Accession_Number__c != null
                            && pOldMap.get(appointment_i.Id).Accession_Number__c == null))) {
                appointmentIdSet.add(appointment_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('updatePatientMailingApproval', appointment_i.Id);
            }
        }
        System.debug('appointmentIdSet [' + appointmentIdSet.size() + ']: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.updatePatientMailingApproval(appointmentIdSet);
            System.debug('TR Appointment__c updatePatientMailingApproval ... future');
        }
    }

    /**
     * Send cancel sms to patient when Remainder_status__c == 'השיב להודעה בשלילה'
     */
    public static void sendCancelAppSMS(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c sendCancelAppSMS... start');
        Set<Id> appointmentIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('sendCancelAppSMS', appt_i.Id)
                    && appt_i.Case__c != null
                    && appt_i.Patient_Account__c != null
                    && appt_i.Medical_Procedure__c != null
                    && appt_i.Prevent_Automation__c == false
                    && appt_i.cancel_via_reminder__c == false
                    && appt_i.SMS_Reminder_Process__c == false
                    && (appt_i.Clinic__c != null || appt_i.Site__c != null)
                    && appt_i.Remainder_status__c == 'השיב להודעה בשלילה'
                    && appt_i.Remainder_status__c != oldMap.get(appt_i.Id).Remainder_status__c) {
                appointmentIdSet.add(appt_i.Id); 
                AppointmentTriggerUtil.addExecutedRecordId('sendCancelAppSMS', appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.sendCancelAppSMS(appointmentIdSet);
            System.debug('TR Appointment__c sendCancelAppSMS ... future');
        }
    }

    /**
     * Update SurveyTaker sms sending time
     */
    public static void updateSurveyTakerSmsSendingTime(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateSurveyTakerSmsSendingTime... start');
        Set<Id> appointmentIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('updateSurveyTakerSmsSendingTime', appt_i.Id)
                    && appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c) {
                appointmentIdSet.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('updateSurveyTakerSmsSendingTime', appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' values: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            AppointmentTriggerService.updateSurveyTakerSmsSendingTime(appointmentIdSet);
            System.debug('TR Appointment__c updateSurveyTakerSmsSendingTime ... future');
        }
    }
    
    
     /**
       Set SendingbyWhatsApp field to true when site and domain setting for whatsApp
       and SendingMessage__c field to true when procedure not Confidentiality__c
    **/
    public static void updateSendingbyWhatsApp(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateSendingbyWhatsApp... start');
        Set<Id> patientIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> procedureIds = new Set<Id>();
        List<Appointment__c> appts = new List<Appointment__c>();        
        
        for (Appointment__c appt_i : newList) {
            if (appt_i.Site__c != null &&
                    appt_i.Patient_Account__c != null &&
                    appt_i.Medical_Procedure__c != null &&
                    (oldMap == null ||
                        oldMap.get(appt_i.Id).Site__c != appt_i.Site__c ||
                        //oldMap.get(appt_i.Id).manualRunWAR__c!= appt_i.manualRunWAR__c||
                        oldMap.get(appt_i.Id).Medical_Procedure__c != appt_i.Medical_Procedure__c)) {                                                    
                appts.add(appt_i);
                siteIds.add(appt_i.Site__c);
                patientIds.add(appt_i.Patient_Account__c);                                     

                for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                    if (appt_i.get(procedureLookup_i) != null) {
                        procedureIds.add(Id.valueOf((String) appt_i.get(procedureLookup_i)));
                    } else {
                        break;
                    }
                }
            }
        }
        System.debug('appts: [' + appts.size() + '] values: ' + appts);
        System.debug('siteIds: [' + siteIds.size() + '] values: ' + siteIds);
        System.debug('patientIds: [' + patientIds.size() + '] values: ' + patientIds);
        System.debug('procedureIds: [' + procedureIds.size() + '] values: ' + procedureIds);

        if (!appts.isEmpty()) {
            AppointmentTriggerService.updateSendingbyWhatsApp(appts, patientIds, siteIds, procedureIds);
            System.debug('TR Appointment__c updateSendingbyWhatsApp ...');
        }
    }
    
    public static void createConFormAndSurvey(List<Appointment__c> newList) {
        System.debug('TR Appointment__c createConFormAndSurvey... start');
        Set<Id> siteIds = new Set<Id>();
        Set<Id> procedureIds = new Set<Id>();
        Set<Id> appointmentIds = new Set<Id>(); 

        for (Appointment__c appt_i : newList) {
            if (appt_i.Site__c != null 
                    && appt_i.Patient_Account__c != null
                    && appt_i.Medical_Procedure__c != null) {
                siteIds.add(appt_i.Site__c);
                appointmentIds.add(appt_i.Id);                
                procedureIds.add(appt_i.Medical_Procedure__c);
            }     
        }                                                                               
        
        System.debug('siteIds: [' + siteIds.size() + '] values: ' + siteIds);                
        System.debug('procedureIds: [' + procedureIds.size() + '] values: ' + procedureIds);
        System.debug('appointmentIds: [' + appointmentIds.size() + '] values: ' + appointmentIds);

        if (!appointmentIds.isEmpty()) {
            AppointmentTriggerService.createConFormAndSurvey(appointmentIds, siteIds, procedureIds);            
        }   
    } 
    
    /**
     * Update GuidanceKMS__c on Apoointment when specefied fileds have changed
     */
    public static void updateGuidelines(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        Set<Id> procedureIdSet = new Set<Id>();
        Set<Id> patientIdSet = new Set<Id>();
        Set<Id> pfIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Appointment_Status__c != 'Canceled'
                    && appt_i.Appointment_Status__c != 'Urgent_WaitingList'
                    && appt_i.Patient_Account__c != null
                    && appt_i.Medical_Procedure__c != null
                    && (Trigger.isInsert
                        || appt_i.Site__c != oldMap.get(appt_i.Id).Site__c
                        || appt_i.Protocol__c != oldMap.get(appt_i.Id).Protocol__c
                        || appt_i.PayerFactor__c != oldMap.get(appt_i.Id).PayerFactor__c
                        || appt_i.Medical_Procedure__c != oldMap.get(appt_i.Id).Medical_Procedure__c
                        || appt_i.Guidance_Scenario__c != oldMap.get(appt_i.Id).Guidance_Scenario__c)
                    && (appt_i.RecordTypeId == AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId() 
                        || (appt_i.Appointment_Type__c == 'Excellent'
                            && appt_i.RecordTypeId == AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId()))) {
                appointmentList.add(appt_i);
                if (appt_i.PayerFactor__c != null) {
                    pfIdSet.add(appt_i.PayerFactor__c);
                }
                patientIdSet.add(appt_i.Patient_Account__c);
                procedureIdSet.add(appt_i.Medical_Procedure__c);
            }
        }
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);
        System.debug('pfIdSet: size: ' + pfIdSet.size() + ' value: ' + pfIdSet);
        System.debug('patientIdSet: size: ' + patientIdSet.size() + ' value: ' + patientIdSet);
        System.debug('procedureIdSet: size: ' + procedureIdSet.size() + ' value: ' + procedureIdSet);

        if (!appointmentList.isEmpty()) {
            AppointmentTriggerService.updateGuidelines(appointmentList, patientIdSet, procedureIdSet, pfIdSet);
        }
    }

}