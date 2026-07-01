//Test AppointmentTriggerServiceTest
public class AppointmentTriggerService {

    public static void disableAutomation(List<Appointment__c> appts, Set<Id> procedureIds) {
        Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        Map<Id, Medical_Procedure__c> proceduresMap = new Map<Id, Medical_Procedure__c>();

        if (!procedureIds.isEmpty()) {
            proceduresMap = new Map<Id, Medical_Procedure__c>([
                SELECT Id
                     , Confidentiality__c
                     , Cancel_Auto_Leumit__c
                     , Cancel_Auto_Mehudet__c
                     , Cancel_Auto_Maccabi__c
                  FROM Medical_Procedure__c
                 WHERE Id IN: procedureIds]);
        }
        System.debug('proceduresMap: size: ' + proceduresMap.size() + ' value: ' + proceduresMap);

        for (Appointment__c appt_i : appts) {
            appt_i.Prevent_Automation__c = false;
            appt_i.No_Automation__c = false;

            for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                if (appt_i.get(procedureLookup_i) == null) {
                    continue;
                }
                Medical_Procedure__c procedure_i = proceduresMap.get(String.valueOf(appt_i.get(procedureLookup_i)));

                if (procedure_i.Confidentiality__c) {
                    appt_i.Prevent_Automation__c = true;
                }

                if (appt_i.RecordTypeId == surgeriesRTId &&
                        (procedure_i.Cancel_Auto_Maccabi__c ||
                            procedure_i.Cancel_Auto_Mehudet__c ||
                            procedure_i.Cancel_Auto_Leumit__c)) {
                    appt_i.No_Automation__c = true;
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c disableAutomation ... executed');
    }

    public static void fillAppointmentDateAndHour(List<Appointment__c> appts) {
        for (Appointment__c appt_i : appts) {
            appt_i.Appointment_Date__c = appt_i.Appointment_Date_Time__c.date();
            appt_i.appointment_hour__c = appt_i.Appointment_Date_Time__c.time();
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c fillAppointmentDateAndHour ... executed');
    }

    public static void fillProcedureAndCalendarLookups(List<Appointment__c> appts, Set<String> procedureCodes, Set<String> calendarCodes) {
        Boolean logicExecuted = false;
        Map<String, Medical_Procedure__c> proceduresMap = new Map<String, Medical_Procedure__c>();
        Map<String, Calendar__c> calendarsMap = new Map<String, Calendar__c>();

        // Procedures
        for (Medical_Procedure__c procedure_i : [SELECT Id, Procedure_Code__c, ScheduleAppointmentSystem__c, Domain__c, Domain__r.Appointment_Coordination_System__c FROM Medical_Procedure__c WHERE Procedure_Code__c IN: procedureCodes]) {
            proceduresMap.put(normalize(procedure_i.Procedure_Code__c), procedure_i);
        }
        System.debug('proceduresMap: size: ' + proceduresMap.size() + ' value: ' + proceduresMap);

        // Calendars
        if (!calendarCodes.isEmpty()) {
            for (Calendar__c calendar_i : [SELECT Id, ServiceId__c, AppointmentSys__c FROM Calendar__c WHERE ServiceId__c IN: calendarCodes]) {
                if (calendar_i.ServiceId__c != null && calendar_i.AppointmentSys__c != null) {
                    calendarsMap.put(normalize(calendar_i.ServiceId__c) + normalize(calendar_i.AppointmentSys__c), calendar_i);
                }
            }
        }
        System.debug('calendarsMap: size: ' + calendarsMap.size() + ' value: ' + calendarsMap);

        for (Appointment__c appt_i : appts) {
            String procedureKey = normalize(appt_i.Medical_Procedure_Text__c);
            if (proceduresMap.containsKey(procedureKey)) {
                Medical_Procedure__c procedure_i = proceduresMap.get(procedureKey);
                appt_i.Medical_Procedure__c = procedure_i.Id;
                appt_i.Domain__c = procedure_i.Domain__c;
                logicExecuted = true;

                if (String.isNotBlank(appt_i.Calendar_Text__c)) {                    
                    String key_i = normalize(appt_i.Calendar_Text__c);
                    if (procedure_i.ScheduleAppointmentSystem__c != null) {
                        key_i += normalize(procedure_i.ScheduleAppointmentSystem__c);
                    } else if (procedure_i.Domain__c != null && procedure_i.Domain__r.Appointment_Coordination_System__c != null) {
                        key_i += normalize(procedure_i.Domain__r.Appointment_Coordination_System__c);
                    }

                    if (calendarsMap.containsKey(key_i)) {
                        appt_i.Calendar__c = calendarsMap.get(key_i).Id;
                    }
                }
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c fillProcedureAndCalendarLookups ... executed');
        }
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? null : value.trim().toLowerCase();
    }

    public static void fillSiteLookup(List<Appointment__c> appts, Set<String> siteCodes) {
        Boolean logicExecuted = false;
        Map<String, Site__c> sitesMap = new Map<String, Site__c>();

        for (Site__c site_i : [SELECT Id, Site_Code__c FROM Site__c WHERE Site_Code__c IN: siteCodes]) {
            sitesMap.put(site_i.Site_Code__c, site_i);
        }
        System.debug('sitesMap: size: ' + sitesMap.size() + ' value: ' + sitesMap);

        for (Appointment__c appt_i : appts) {
            if (sitesMap.containsKey(appt_i.Site_Text__c)) {
                appt_i.Site__c = sitesMap.get(appt_i.Site_Text__c).Id;
                logicExecuted = true;
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c fillSiteLookup ... executed');
        }
    }

    public static void fillPayerFactorLookup(List<Appointment__c> appts, Set<String> pfCodes) {
        Boolean logicExecuted = false;
        Map<String, Payer_Factor__c> pfMap = new Map<String, Payer_Factor__c>();

        for (Payer_Factor__c pf_i : [SELECT Id, InsuranceCode__c FROM Payer_Factor__c WHERE InsuranceCode__c IN: pfCodes]) {
            pfMap.put(pf_i.InsuranceCode__c, pf_i);
        }
        System.debug('pfMap: size: ' + pfMap.size() + ' value: ' + pfMap);

        for (Appointment__c appt_i : appts) {
            if (pfMap.containsKey(appt_i.Payer_Factor_Code__c)) {
                appt_i.PayerFactor__c = pfMap.get(appt_i.Payer_Factor_Code__c).Id;
                logicExecuted = true;
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c fillPayerFactorLookup ... executed');
        }
    }

    public static void updateReminderType(List<Appointment__c> appts) {
        Boolean logicExecuted = false;

        for (Appointment__c appt_i : appts) {
            if(appt_i.sendingByWhatsApp__c) {
               appt_i.Appointment_Status__c = 'וידוא הגעה לפגישה';
               appt_i.sent_kit_confirmation__c = false;
               appt_i.Remainder_type__c = 'WhatsApp';
               logicExecuted = true;
            } else {
                if (appt_i.Remainder_time__c != null && appt_i.Remainder_time__c >= System.today()) {
                    appt_i.Appointment_Status__c = 'וידוא הגעה לפגישה';
                    appt_i.sent_kit_confirmation__c = false;
                    appt_i.Remainder_type__c = 'SMS';
                    logicExecuted = true;
                } else if (appt_i.Date_for_tizkorit_reminder__c != null && appt_i.Date_for_tizkorit_reminder__c >= System.today()) {
                    appt_i.Appointment_Status__c = 'וידוא הגעה לפגישה';
                    appt_i.sent_kit_confirmation__c = false;
                    appt_i.Remainder_type__c = 'תזכורית';
                    logicExecuted = true;
                } else if (appt_i.Date_for_human_reminder__c != null) {
                    appt_i.Appointment_Status__c = 'וידוא הגעה לפגישה';
                    appt_i.sent_kit_confirmation__c = false;
                    appt_i.Remainder_type__c = 'אנושי';
                    logicExecuted = true;
                } else if (appt_i.Remainder_time__c == null && appt_i.Date_for_tizkorit_reminder__c == null && appt_i.Date_for_human_reminder__c == null) {
                    appt_i.Appointment_Status__c = 'WaitingForAppointment';
                    appt_i.sent_kit_confirmation__c = false;
                    logicExecuted = true;
                }
            }

        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c updateReminderType ... executed');
        }
    }

    public static void fillFormtitanId(List<Appointment__c> appts) {
        for (Appointment__c appt_i : appts) {
            appt_i.formtitan_id_2__c = CommonService.generateRandomKey(15);
        }
        System.debug('TR Appointment__c fillFormtitanId ... executed');
    }

    public static void updateReminderStatus(List<Appointment__c> appts, Set<Id> caseIds, Set<Id> patientIds, Set<Id> procedureIds) {
        List<Appointment__c> apptsFiltered = new List<Appointment__c>();
        Boolean logicExecuted = false;
        Date today = System.today();

        Map<Id, Case> casesMap = new Map<Id, Case>([
            SELECT Id
              FROM Case
             WHERE Id IN: caseIds
               AND SMS_Phone_Number__c != null]);
        System.debug('casesMap: size: ' + casesMap.size() + ' value: ' + casesMap);

        for (Appointment__c appt_i : appts) {
            if ((!appt_i.sms_reminder_sent__c && casesMap.containsKey(appt_i.Case__c) && !appt_i.Dont_send_reminder__c && appt_i.Remainder_time__c >= today) ||
                    (!appt_i.sent_to_tizkurit__c && appt_i.Date_for_tizkorit_reminder__c >= today) ||
                    (!appt_i.human_reminder_transferred__c && appt_i.Date_for_human_reminder__c >= today) ||
                    (!appt_i.isRemainder1WAsent__c && appt_i.dateRemainder1WA__c >= today) ||
                    (!appt_i.isRemainder2WAsent__c && appt_i.dateRemainder2WA__c >= today)){
                apptsFiltered.add(appt_i);
            }
        }

        if (!apptsFiltered.isEmpty()) {
            Map<Id, Medical_Procedure__c> proceduresMap = new Map<Id, Medical_Procedure__c>([
                SELECT Id
                  FROM Medical_Procedure__c
                 WHERE Id IN: procedureIds
                   AND Confidentiality__c = false
                   AND Reminder_required__c = true]);
            System.debug('proceduresMap: size: ' + proceduresMap.size() + ' value: ' + proceduresMap);

            Map<Id, Account> patientsMap = new Map<Id, Account>([
                SELECT Id
                  FROM Account
                 WHERE Id IN: patientIds
                   AND (Mailing_approval__c = 'מאשר דיוור - הכל' OR Mailing_approval__c = 'מאשר דיוור - שירותי')]);
            System.debug('patientsMap: size: ' + patientsMap.size() + ' value: ' + patientsMap);

            for (Appointment__c appt_i : apptsFiltered) {
                if (proceduresMap.containsKey(appt_i.Medical_Procedure__c) && patientsMap.containsKey(appt_i.Patient_Account__c)) {
                    appt_i.Remainder_status__c = 'אין מענה';
                    logicExecuted = true;
                }
            }
        }
        System.debug('appts: size: ' + apptsFiltered.size() + ' value: ' + apptsFiltered);

        if (logicExecuted) {
            System.debug('TR Appointment__c updateReminderStatus ... executed');
        }
    }

    public static void createJunction(List<Appointment__c> appts) {
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        List<cases_and_appoitments__c> junctionsToInsert = new List<cases_and_appoitments__c>();

        for (Appointment__c appt_i : appts) {
            cases_and_appoitments__c junction_i = new cases_and_appoitments__c(
                Case__c = appt_i.Case_Hidden__c != null ? appt_i.Case_Hidden__c : appt_i.Case__c,
                Appointment__c = appt_i.Id,
                Is_it_the_main_case_for_surgery__c = true
            );
            if (appt_i.RecordTypeId == expertsRTId) {
                junction_i.type__c = 'זימון תור חדש';
            }
            junctionsToInsert.add(junction_i);
        }
        System.debug('junctionsToInsert: size: ' + junctionsToInsert.size() + ' value: ' + junctionsToInsert);

        if (!junctionsToInsert.isEmpty()) {
            insert junctionsToInsert;
            System.debug('TR Appointment__c createJunction ... executed');
        }
    }

    public static void linkProcedurePlan(Map<String, Appointment__c> orderKeyToApptMap) {
        Boolean logicExecuted = false;
        Map<String, cases_and_appoitments__c> orderKeyToJunctionMap = new Map<String, cases_and_appoitments__c>();
        List<cases_and_appoitments__c> junctionsToInsert = new List<cases_and_appoitments__c>();
        List<Appointment__c> apptsToUpdate = new List<Appointment__c>();

        // collect the earliest junction between first appointment and case
        for (cases_and_appoitments__c junction_i : [SELECT Case__c
                                                         , Appointment__c
                                                         , Appointment__r.OrderKey__c
                                                      FROM cases_and_appoitments__c
                                                     WHERE Appointment__r.OrderKey__c IN: orderKeyToApptMap.keySet()
                                                  ORDER BY CreatedDate]) {
            if (!orderKeyToJunctionMap.containsKey(junction_i.Appointment__r.OrderKey__c)) {
                orderKeyToJunctionMap.put(junction_i.Appointment__r.OrderKey__c, junction_i);
            }
        }
        System.debug('orderKeyToJunctionMap: size: ' + orderKeyToJunctionMap.size() + ' value: ' + orderKeyToJunctionMap);

        // go through second appointments and populate their fields and create junction for them
        for (String orderKey_i : orderKeyToApptMap.keySet()) {
            if (orderKeyToJunctionMap.containsKey(orderKey_i)) {
                apptsToUpdate.add(
                    new Appointment__c(
                        Id = orderKeyToApptMap.get(orderKey_i).Id,
                        Case__c = orderKeyToJunctionMap.get(orderKey_i).Case__c,
                        after_appointment__c = orderKeyToJunctionMap.get(orderKey_i).Appointment__c,
                        Is_hidden_appointment__c = true
                    )
                );
                junctionsToInsert.add(
                    new cases_and_appoitments__c(
                        Appointment__c = orderKeyToApptMap.get(orderKey_i).Id,
                        Case__c = orderKeyToJunctionMap.get(orderKey_i).Case__c
                    )
                );
            }
        }
        System.debug('apptsToUpdate: size: ' + apptsToUpdate.size() + ' value: ' + apptsToUpdate);
        System.debug('junctionsToInsert: size: ' + junctionsToInsert.size() + ' value: ' + junctionsToInsert);

        if (!apptsToUpdate.isEmpty()) {
            update apptsToUpdate;
            logicExecuted = true;
        }

        if (!junctionsToInsert.isEmpty()) {
            insert junctionsToInsert;
            logicExecuted = true;
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c linkProcedurePlan ... executed');
        }
    }

    public static void setPaymentStatus(List<Appointment__c> appts, Set<Id> pfIds) {
        Set<String> pfFor2Codes = new Set<String>{'0', '1', '3', '8', '9', '10', '11', '24', '41', '42', '86', '165'};
        Set<String> pfFor0Codes = new Set<String>{'35', '81', '89'};

        Map<Id, Payer_Factor__c> pfMap = new Map<Id, Payer_Factor__c>([
            SELECT InsuranceCode__c
              FROM Payer_Factor__c
             WHERE Id IN :pfIds]);
        System.debug('pfMap: size: ' + pfMap.size() + ' value: ' + pfMap);

        for (Appointment__c appt_i : appts) {
            appt_i.PaymentSource__c = 'Website';
            if (pfFor0Codes.contains(pfMap.get(appt_i.PayerFactor__c)?.InsuranceCode__c)) {
                appt_i.PaymentStatus__c = 'Unrequired';
            } else if (pfFor2Codes.contains(pfMap.get(appt_i.PayerFactor__c)?.InsuranceCode__c)) {
                appt_i.PaymentStatus__c = 'Yet_Done';
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('TR Appointment__c setPaymentStatus ... executed');
    }

    public static void updatePaymentStatus(List<Appointment__c> appointmentList) {
        for (Appointment__c appt_i : appointmentList) {
            appt_i.Appointment_Status__c = 'WaitingForAppointment';
            appt_i.PaymentStatus__c = 'Valid';
        }
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);
        System.debug('TR Appointment__c updatePaymentStatus ... executed');
    }

    // ====================================================================================================
    // ====================================== approved methods above ======================================
    // =================================== please create a new one below ==================================
    // ====================================================================================================

    /*public static void updateCancellationReasonField(List<Appointment__c> appointments, Set<String> cancelReasons) {
        System.debug('AppointmentTriggerService.updateCancellationReasonField...\nappointments: ' + appointments + '\ncancelReasons: ' + cancelReasons);
        Map<String, String> reasonToLabelMap = new Map<String, String>();

        for (Cancellation_Reason__mdt metadata_i : [SELECT Id, Label, Canceled_Reason_Code__c FROM Cancellation_Reason__mdt WHERE Canceled_Reason_Code__c IN: cancelReasons]) {
            reasonToLabelMap.put(metadata_i.Canceled_Reason_Code__c, metadata_i.Label);
        }

        if (!reasonToLabelMap.isEmpty()) {
            for (Appointment__c appt_i : appointments) {
                if (reasonToLabelMap.containsKey(appt_i.Canceled_Reason__c)) {
                    appt_i.Canceled_Reason__c = reasonToLabelMap.get(appt_i.Canceled_Reason__c);
                }
            }
        }
    }*/

    @future(callout=true)
    public static void cancelRejectedAppointments(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c cancelRejectedAppointments ... future');
        List<cases_and_appoitments__c> junctionToInsertList = new List<cases_and_appoitments__c>();

        List<Appointment__c> appointmentList = [
            SELECT Case__c
                 , Case_Hidden__c
                 , Canceled_reason__c
              FROM Appointment__c
             WHERE Id IN :appointmentIdSet];
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);

        for (Appointment__c appt_i : appointmentList) {
            // appt_i.Appointment_Status__c = 'Canceled';
            appt_i.Canceled_reason__c = 'בוטל עי נציג';

            junctionToInsertList.add(
                new cases_and_appoitments__c(
                    Case__c = appt_i.Case__c != null ? appt_i.Case__c : appt_i.Case_Hidden__c,
                    Appointment__c = appt_i.Id,
                    type__c = 'ביטול תור'));
        }
        System.debug('junctionToInsertList: size: ' + junctionToInsertList.size() + ' value: ' + junctionToInsertList);

        if (!appointmentList.isEmpty()) {
            update appointmentList;
        }
        if (!junctionToInsertList.isEmpty()) {
            insert junctionToInsertList;
        }

        if (!appointmentList.isEmpty() || !junctionToInsertList.isEmpty()) {
            System.debug('TR Appointment__c cancelRejectedAppointments ... executed');
        }
    }

    @future(callout=true)
    public static void resetMedicalAids(Set<Id> appointmentIdSet, Date maxAppointmentDate) {
        System.debug('TR Appointment__c resetMedicalAids ... future');
        List<Medical_Aid_Appointment__c> aidsToSendEmail = new List<Medical_Aid_Appointment__c>();
        List<Medical_Aid_Appointment__c> aidsToUpsert = new List<Medical_Aid_Appointment__c>();
        List<Medical_Aid_Appointment__c> aidsToDelete = new List<Medical_Aid_Appointment__c>();
        Map<Date, Integer> dateToWorkingDaysMap = new Map<Date, Integer>();

        // prepare map with working days by date
        Integer workingDays = 0;
        for (Calendar1__c calendar_i : [SELECT business_day__c
                                             , Gregorian_Date__c
                                          FROM Calendar1__c
                                         WHERE Gregorian_Date__c >= TODAY
                                           AND Gregorian_Date__c <= :maxAppointmentDate
                                      ORDER BY Gregorian_Date__c]) {
            if (calendar_i.business_day__c) {
                workingDays++;
            }
            dateToWorkingDaysMap.put(calendar_i.Gregorian_Date__c, workingDays);
        }
        System.debug('dateToWorkingDaysMap: size: ' + dateToWorkingDaysMap.size() + ' value: ' + dateToWorkingDaysMap);

        System.debug('process: start');
        for (Medical_Aid_Appointment__c aid_i : [SELECT Type_of_Assist__c
                                                      , Email_MedicalAidManager__c
                                                      , Patient__r.PersonContactId
                                                      , Appointment__r.Appointment_Date_Time__c
                                                   FROM Medical_Aid_Appointment__c
                                                  WHERE Appointment__c IN :appointmentIdSet]) {
            // if more than 7 working days update records, else cancel old records and create new ones
            if (aid_i.Appointment__r.Appointment_Date_Time__c != null &&
                dateToWorkingDaysMap.get(aid_i.Appointment__r.Appointment_Date_Time__c.date()) < 7) {
                System.debug('process: working days < 7: cancel (' + aid_i.Id + ')');
                aidsToUpsert.add(new Medical_Aid_Appointment__c(Id = aid_i.Id, Status__c = 'בוטל'));
            } else {
                System.debug('process: working days >= 7: delete (' + aid_i.Id + ')');
                aidsToDelete.add(aid_i);
            }

            // send an email if assist 80 was canceled
            if (aid_i.Type_of_Assist__c.split(';').contains('80') && aid_i.Email_MedicalAidManager__c != null) {
                System.debug('process: send email (' + aid_i.Id + ')');
                aidsToSendEmail.add(aid_i);
            }
        }
        System.debug('process: end');
        System.debug('aidsToSendEmail: size: ' + aidsToSendEmail.size() + ' value: ' + aidsToSendEmail);
        System.debug('aidsToUpsert: size: ' + aidsToUpsert.size() + ' value: ' + aidsToUpsert);
        System.debug('aidsToDelete: size: ' + aidsToDelete.size() + ' value: ' + aidsToDelete);

        // send emails if specified assist was canceled/deleted
        if (!aidsToSendEmail.isEmpty()) {
            LC_BackendUtils.sendEmailAlert(aidsToSendEmail);
        }

        // do dml
        if (!aidsToUpsert.isEmpty()) {
            upsert aidsToUpsert;
        }
        if (!aidsToDelete.isEmpty()) {
            delete aidsToDelete;
        }

        if (!aidsToUpsert.isEmpty() || !aidsToDelete.isEmpty()) {
            System.debug('TR Appointment__c resetMedicalAids ... executed');
        }
    }

    public static void resetReminders(List<Appointment__c> appts) {
        for (Appointment__c appt_i : appts) {
            appt_i.Appointment_Status__c = 'וידוא הגעה לפגישה';
            appt_i.Remainder_status__c = 'אין מענה';
            appt_i.sms_reminder_sent__c = false;
            appt_i.sent_to_tizkurit__c = false;
            appt_i.human_reminder_transferred__c = false;
            appt_i.isRemainder1WAsent__c = false;
            appt_i.isRemainder2WAsent__c = false;
        }
        System.debug('TR Appointment__c resetReminders ... executed');
    }

    public static void unmarkSMSReminderProcess(List<Appointment__c> appts) {
        for (Appointment__c appt_i : appts) {
            appt_i.SMS_Reminder_Process__c = false;
        }
        System.debug('TR Appointment__c unmarkSMSReminderProcess ... executed');
    }

    public static void updateReminderRecordToInActive(Set<Id> appIds) {
        System.debug('AppointmentTriggerService.updateReminderRecordToInActive...');
        try {
            List<Reminder__c> remindersToUpdate = [SELECT Id, Active__c FROM Reminder__c WHERE Appointment__c IN: appIds];
            if(!remindersToUpdate.isEmpty()){
                for(Reminder__c reminder_i :remindersToUpdate){
                    reminder_i.Active__c = false;
                }
                update remindersToUpdate;
            }
        } catch (Exception ex) {
            System.debug('AppointmentTriggerService.updateReminderRecordToInActive fuc fail: '+ ex);
        }
    }

    /*@future(callout=true)
    public static void createSurvey(Set<Id> apptIds) {
        System.debug('SURVEY: future logic is starting ...');
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);

        Set<Id> siteIds = new Set<Id>();
        Set<Id> surveyIds = new Set<Id>();
        Set<Id> patientIds = new Set<Id>();
        Set<String> pCodes = new Set<String>();

        List<ApptWrp> appts = new List<ApptWrp>();
        Map<Id, SurveyWrp> surveyMap = new Map<Id, SurveyWrp>();
        Map<String, List<SurveyWrp>> pCodeToSurveysMap = new Map<String, List<SurveyWrp>>();
        Map<Id, Map<Id, List<SurveyTaker__c>>> patientIdToSurveyIdToTakersMap = new Map<Id, Map<Id, List<SurveyTaker__c>>>();
        Map<Id, Map<Id, Set<String>>> apptIdToSurveyIdToAnswerMap = new Map<Id, Map<Id, Set<String>>>();
        Map<Id, Map<String, Map<Id, List<SurveyTaker__c>>>> apptIdToPCodeToSurveyIdToTakersMap = new Map<Id, Map<String, Map<Id, List<SurveyTaker__c>>>>();

        List<SurveyTaker__c> takersToInsert = new List<SurveyTaker__c>();
        List<SurveyTaker__c> takersToUpdate = new List<SurveyTaker__c>();
        List<SurveyQuestionResponse__c> qResponsesToInsert = new List<SurveyQuestionResponse__c>();
        Map<String, Appointment_To_Survey__c> atssMapToInsert = new Map<String, Appointment_To_Survey__c>();


        for (Appointment__c appt_i : [SELECT Case__c
                                           , Site__c
                                           , IDNumber__c
                                           , Accession_Number__c
                                           , Appointment_Date_Time__c
                                           , Patient_Account__r.Gender__c
                                           , Patient_Account__r.Age_Number__c
                                           , Medical_Procedure__r.Procedure_Code__c
                                           , Medical_Procedure2__r.Procedure_Code__c
                                           , Medical_Procedure3__r.Procedure_Code__c
                                           , Medical_Procedure4__r.Procedure_Code__c
                                        FROM Appointment__c
                                       WHERE Id IN :apptIds]) {
            ApptWrp wrp_i = new ApptWrp(appt_i);
            appts.add(wrp_i);
            siteIds.add(wrp_i.siteId);
            patientIds.add(wrp_i.patient.id);
            pCodes.addAll(wrp_i.pCodes);
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('siteIds: size: ' + siteIds.size() + ' value: ' + siteIds);
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);
        System.debug('pCodes: size: ' + pCodes.size() + ' value: ' + pCodes);

        for (Doc_to_action__c dta_i : Database.query('SELECT status__c'
                                                        + ', activity_code__c'
                                                        + ', SendToPatient__c'
                                                        + ', View_in_portal__c'
                                                        + ', Signature_with_secretary__c'
                                                        + ', survey__r.Gender__c'
                                                        + ', survey__r.SurveyCode__c'
                                                        + ', survey__r.Survey_Version__c'
                                                        + ', survey__r.Maximum_submission__c'
                                                        + ', survey__r.days_to_send_survey__c'
                                                        + ', survey__r.QueryForAnswersRequired__c'
                                                    + ' FROM Doc_to_action__c'
                                                   + ' WHERE status__c = true'
                                                     + ' AND activity_code__c IN :pCodes')) {
            SurveyWrp wrp_i = new SurveyWrp(dta_i);
            surveyMap.put(wrp_i.id, wrp_i);
            surveyIds.add(wrp_i.id);

            if (!pCodeToSurveysMap.containsKey(dta_i.activity_code__c)) {
                pCodeToSurveysMap.put(dta_i.activity_code__c, new List<SurveyWrp>());
            }
            pCodeToSurveysMap.get(dta_i.activity_code__c).add(wrp_i);
        }
        System.debug('surveyIds: size: ' + surveyIds.size() + ' value: ' + surveyIds);
        System.debug('surveyMap: size: ' + surveyMap.size() + ' value: ' + surveyMap);
        System.debug('pCodeToSurveysMap: size: ' + pCodeToSurveysMap.size() + ' value: ' + pCodeToSurveysMap);

        for (Survey_Question__c question_i : [SELECT Name, Survey__c, UnShow__c FROM Survey_Question__c
                                               WHERE status_question__c = true AND Survey__c IN :surveyIds]) {
            if (surveyMap.containsKey(question_i.Survey__c)) {
                surveyMap.get(question_i.Survey__c).addQuestion(question_i);
            }
        }

        for (survey_to_site__c sts_i : [SELECT site__c, Survey__c FROM survey_to_site__c
                                         WHERE Survey__c IN :surveyIds AND site__c IN :siteIds]) {
            if (surveyMap.containsKey(sts_i.Survey__c)) {
                surveyMap.get(sts_i.Survey__c).addSite(sts_i);
            }
        }

        for (SurveyTaker__c taker_i : [SELECT Account__c, survey__c FROM SurveyTaker__c
                                        WHERE survey__c IN :surveyIds AND Account__c IN :patientIds AND activity_code__c IN :pCodes AND CreatedDate = LAST_N_DAYS:7]) {
            if (!patientIdToSurveyIdToTakersMap.containsKey(taker_i.Account__c)) {
                patientIdToSurveyIdToTakersMap.put(taker_i.Account__c, new Map<Id, List<SurveyTaker__c>>());
            }
            if (!patientIdToSurveyIdToTakersMap.get(taker_i.Account__c).containsKey(taker_i.survey__c)) {
                patientIdToSurveyIdToTakersMap.get(taker_i.Account__c).put(taker_i.survey__c, new List<SurveyTaker__c>());
            }
            patientIdToSurveyIdToTakersMap.get(taker_i.Account__c).get(taker_i.survey__c).add(taker_i);
        }
        System.debug('patientIdToSurveyIdToTakersMap: size: ' + patientIdToSurveyIdToTakersMap.size() + ' value: ' + patientIdToSurveyIdToTakersMap);

        for (ApptWrp appt_i : appts) {
            System.debug('SURVEY: ' + appt_i.id);
            apptIdToPCodeToSurveyIdToTakersMap.put(appt_i.id, new Map<String, Map<Id, List<SurveyTaker__c>>>());

            for (String pCode_j : appt_i.pCodes) {
                System.debug('SURVEY: ' + appt_i.id + ' -> ' + pCode_j);
                apptIdToPCodeToSurveyIdToTakersMap.get(appt_i.id).put(pCode_j, new Map<Id, List<SurveyTaker__c>>());

                if (!pCodeToSurveysMap.containsKey(pCode_j)) {
                    System.debug('SURVEY: ' + appt_i.id + ' -> ' + pCode_j + ': no Surveys found for the Procedure');
                    continue;
                }

                for (SurveyWrp survey_k : pCodeToSurveysMap.get(pCode_j)) {
                    System.debug('SURVEY: ' + appt_i.id + ' -> ' + pCode_j + ' -> ' + survey_k.id);

                    if (!survey_k.siteIds.contains(appt_i.siteId) || (survey_k.gender != null && survey_k.gender != appt_i.patient.gender)) {
                        System.debug('SURVEY: ' + appt_i.id + ' -> ' + pCode_j + ' -> ' + survey_k.id + ': no Survey to Site or Doc to Action record found');
                        continue;
                    }

                    if (patientIdToSurveyIdToTakersMap.get(appt_i.patient.id)?.get(survey_k.id) != null) {
                        System.debug('SURVEY: ' + appt_i.id + ' -> ' + pCode_j + ' -> ' + survey_k.Id + ': updating existing Survey Takers');
                        for (SurveyTaker__c taker_l : patientIdToSurveyIdToTakersMap.get(appt_i.patient.id).get(survey_k.id)) {
                            takersToUpdate.add(fillSurveyTaker(appt_i, survey_k, taker_l));
                            atssMapToInsert.put(appt_i.id + '-' + taker_l.Id, new Appointment_To_Survey__c(
                                Survey_patient__c = taker_l.Id,
                                Appointment__c = appt_i.id,
                                status__c = true));
                        }
                        patientIdToSurveyIdToTakersMap.get(appt_i.patient.id).remove(survey_k.id);
                    } else {
                        System.debug('SURVEY: ' + appt_i.id + ' -> ' + pCode_j + ' -> ' + survey_k.Id + ': creating a brand new Survey Taker');
                        SurveyTaker__c taker_k = initSurveyTaker(appt_i, survey_k);

                        if (appt_i.accession != null && survey_k.isRisAnswersRequired) {
                            apptIdToSurveyIdToAnswerMap = obtainRisSurveyAnswersMap(appt_i, survey_k);
                        }

                        if (!apptIdToPCodeToSurveyIdToTakersMap.get(appt_i.id).get(pCode_j).containsKey(survey_k.id)) {
                            apptIdToPCodeToSurveyIdToTakersMap.get(appt_i.id).get(pCode_j).put(survey_k.id, new List<SurveyTaker__c>());
                        }
                        apptIdToPCodeToSurveyIdToTakersMap.get(appt_i.id).get(pCode_j).get(survey_k.id).add(taker_k);

                        takersToInsert.add(taker_k);
                    }
                }
            }
        }
        System.debug('takersToInsert: size: ' + takersToInsert.size() + ' value: ' + takersToInsert);
        System.debug('takersToUpdate: size: ' + takersToUpdate.size() + ' value: ' + takersToUpdate);

        if (!takersToUpdate.isEmpty()) {
            update takersToUpdate;
        }

        if (!takersToInsert.isEmpty()) {
            insert takersToInsert;
            for (Id apptId_i : apptIdToPCodeToSurveyIdToTakersMap.keySet()) {
                for (String pCode_j : apptIdToPCodeToSurveyIdToTakersMap.get(apptId_i).keySet()) {
                    for (Id surveyId_k : apptIdToPCodeToSurveyIdToTakersMap.get(apptId_i).get(pCode_j).keySet()) {
                        for (SurveyTaker__c taker_l : apptIdToPCodeToSurveyIdToTakersMap.get(apptId_i).get(pCode_j).get(surveyId_k)) {
                            atssMapToInsert.put(apptId_i + '-' + taker_l.Id, new Appointment_To_Survey__c(
                                Survey_patient__c = taker_l.Id,
                                Appointment__c = apptId_i,
                                status__c = true));
                        }
                    }
                }
            }
            System.debug('atssMapToInsert: size: ' + atssMapToInsert.size() + ' value: ' + atssMapToInsert.values());
            if (!atssMapToInsert.isEmpty()) {
                insert atssMapToInsert.values();
            }

            for (ApptWrp appt_i : appts) {
                for (String pCode_j : appt_i.pCodes) {
                    qResponsesToInsert.addAll(initSurveyQuestions(
                        appt_i,
                        surveyMap,
                        apptIdToPCodeToSurveyIdToTakersMap.get(appt_i.id).get(pCode_j),
                        apptIdToSurveyIdToAnswerMap));
                }
            }
            System.debug('qResponsesToInsert: size: ' + qResponsesToInsert.size() + ' value: ' + qResponsesToInsert);

            if (!qResponsesToInsert.isEmpty()) {
                insert qResponsesToInsert;
            }
        } else {
            System.debug('atssMapToInsert: size: ' + atssMapToInsert.size() + ' value: ' + atssMapToInsert.values());
            if (!atssMapToInsert.isEmpty()) {
                insert atssMapToInsert.values();
            }
        }
    }

    private class ApptWrp {
        private String id {get;set;}
        private String caseId {get;set;}
        private String siteId {get;set;}
        private String patientId {get;set;}
        private String pCodeMain {get;set;}
        private String accession {get;set;}
        private Datetime apptDate {get;set;}
        private Set<String> pCodes {get;set;}
        private AcctWrp patient {get;set;}

        private ApptWrp(Appointment__c appt) {
            this.id = appt.Id;
            this.caseId = appt.Case__c;
            this.siteId = appt.Site__c;
            this.accession = appt.Accession_Number__c;
            this.apptDate = appt.Appointment_Date_Time__c;
            this.patient = new AcctWrp(appt.Patient_Account__r);

            this.pCodes = new Set<String>();
            for (String pRelationship_j : AppointmentTriggerUtil.PROCEDURE_RELATIONSHIPS) {
                if (appt.getSObject(pRelationship_j) != null) {
                    this.pCodes.add((String) appt.getSObject(pRelationship_j).get('Procedure_Code__c'));
                }
            }
            this.pCodeMain = new List<String>(this.pCodes).get(0);
        }
    }

    private class AcctWrp {
        private String id {get;set;}
        private Integer age {get;set;}
        private String gender {get;set;}

        private AcctWrp(Account acct) {
            this.id = acct.Id;
            this.age = Integer.valueOf(acct.Age_Number__c);
            this.gender = acct.Gender__c;
        }
    }

    private class SurveyWrp {
        private String id {get;set;}
        private String code {get;set;}
        private String gender {get;set;}
        private String version {get;set;}
        private Integer daysToSend {get;set;}
        private Integer maxSubmission {get;set;}
        private Boolean isRisAnswersRequired {get;set;}
        private Set<String> siteIds {get;set;}
        private Doc_to_action__c dta {get;set;}
        private List<Survey_Question__c> questions {get;set;}

        private SurveyWrp(Survey__c survey) {
            this.id = survey.Id;
            this.code = survey.SurveyCode__c;
            this.gender = survey.Gender__c;
            this.version = survey.Survey_Version__c;
            this.isRisAnswersRequired = survey.QueryForAnswersRequired__c;
            this.daysToSend = Integer.valueOf(survey.days_to_send_survey__c);
            this.maxSubmission = Integer.valueOf(survey.Maximum_submission__c);
        }

        private SurveyWrp(Doc_to_action__c dta) {
            this(dta.survey__r);

            this.siteIds = new Set<String>();
            this.dta = dta;
            this.questions = new List<Survey_Question__c>();
        }

        private void addQuestion(Survey_Question__c question) {
            this.questions.add(question);
        }

        private void addSite(survey_to_site__c sts) {
            this.siteIds.add(sts.site__c);
        }
    }

    private static SurveyTaker__c initSurveyTaker(ApptWrp appt, SurveyWrp survey) {
        return fillSurveyTaker(appt, survey, null);
    }

    private static SurveyTaker__c fillSurveyTaker(ApptWrp appt, SurveyWrp survey, SurveyTaker__c taker) {
        if (taker == null) {
            taker = new SurveyTaker__c(
                RecordTypeId = AppointmentTriggerUtil.S_TAKER_RT_MAP.get('Digital_Forms').getRecordTypeId(),
                activity_code__c = appt.pCodeMain,
                Account__c = appt.patient.id,
                Case__c = appt.caseId,
                Site__c = appt.siteId);
        } else {
            taker = new SurveyTaker__c(
                Id = taker.Id,
                IsSent__c = false,
                SendTime__c = null);
        }

        Doc_to_action__c dta = survey.dta;

        if (dta.SendToPatient__c) {
            taker.sms_send_time__c = getSurveySendDate(appt.apptDate, survey.daysToSend);
        }

        taker.Survey__c = survey.id;
        taker.Appointment__c = appt.id;
        taker.visit_date__c = appt.apptDate;
        taker.Survey_Version__c = survey.version;
        taker.IsGuardian__c = appt.patient.age < 18;
        taker.Taker_Maximum_submission__c = survey.maxSubmission;
        taker.Signature_with_secretary__c = dta.Signature_with_secretary__c;
        taker.DisplayOnPortal__c = dta.View_in_portal__c;
        taker.is_sms_sent__c = !dta.SendToPatient__c;
        taker.QuickReceiptFlow__c = true;

        return taker;
    }

    
    private static DateTime getSurveySendDate(Datetime apptDate, Integer daysToSend) {
        if (daysToSend == null) {
            return apptDate;
        } else {
            Datetime convertedDate = apptDate.addDays(-daysToSend);
            return daysToSend == 999 || convertedDate < System.now() ? System.now() : convertedDate;
        }
    }

    private static Map<Id, Map<Id, Set<String>>> obtainRisSurveyAnswersMap(ApptWrp appt, SurveyWrp survey) {
        Map<Id, Map<Id, Set<String>>> apptIdToSurveyIdToAnswerMap = new Map<Id, Map<Id, Set<String>>>();

        ws_RisSurvey_REST.GetSurveyFromRisResponse response = ws_RisSurvey_REST.getSurveyFromRis(appt.accession, survey.code);
        System.debug('Ris Survey Interface returned: ' + response);

        if (response?.ListOfQuestionStatus == null) {
            return apptIdToSurveyIdToAnswerMap;
        }

        for (ws_RisSurvey_REST.QuestionStatus qStatus_l : response.ListOfQuestionStatus) {
            if (qStatus_l.IsQuestionAnswered) {
                if (!apptIdToSurveyIdToAnswerMap.containsKey(appt.id)) {
                    apptIdToSurveyIdToAnswerMap.put(appt.id, new Map<Id, Set<String>>());
                }
                if (!apptIdToSurveyIdToAnswerMap.get(appt.id).containsKey(survey.id)) {
                    apptIdToSurveyIdToAnswerMap.get(appt.id).put(survey.id, new Set<String>());
                }
                apptIdToSurveyIdToAnswerMap.get(appt.id).get(survey.id).add(qStatus_l.QuestionName);
            }
        }

        return apptIdToSurveyIdToAnswerMap;
    }

    private static List<SurveyQuestionResponse__c> initSurveyQuestions(ApptWrp appt, Map<Id, SurveyWrp> surveyMap, Map<Id, List<SurveyTaker__c>> surveyIdToTakersMap, Map<Id, Map<Id, Set<String>>> apptIdToSurveyIdToAnswerMap) {
        List<SurveyQuestionResponse__c> qResponses = new List<SurveyQuestionResponse__c>();

        for (Id surveyId_i : surveyIdToTakersMap.keySet()) {
            SurveyWrp survey_i = surveyMap.get(surveyId_i);

            for (Survey_Question__c question_k : survey_i.questions) {
                for (SurveyTaker__c taker_l : surveyIdToTakersMap.get(survey_i.id)) {
                    qResponses.add(new SurveyQuestionResponse__c(
                            IsForAvg__c = survey_i.code == 'DocAdvisor' && question_k.IsForAvg__c,
                            Survey_Question__c = question_k.Id,
                            SurveyTaker__c = taker_l.Id,
                            UnShow__c = (apptIdToSurveyIdToAnswerMap.containsKey(appt.id)
                                && apptIdToSurveyIdToAnswerMap.get(appt.id).containsKey(survey_i.id)
                                && apptIdToSurveyIdToAnswerMap.get(appt.id).get(survey_i.id).contains(question_k.Name)) || question_k.UnShow__c));
                }
            }
        }

        return qResponses;
    }*/

    @future(callout=true)
    public static void findLatestSalesApp(Set<Id> appIds) {
        System.debug('TR Appointment__c findLatestSalesApp ... future');
        Set<Id> caseCanUpdId = new Set<Id>();
        Set<Id> caseLatestApp = new Set<Id>();
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        Map<Id, Appointment__c> apptsToUpdateMap = new Map<Id, Appointment__c>();

        List<Appointment__c> appts = [
            SELECT Appointment_Status__c
                 , theLatestAppointment__c
                 , Appointment_Date_Time__c
                 , Case__r.latestAppointment__c
              FROM Appointment__c
             WHERE Id IN :appIds FOR UPDATE];

        for (Appointment__c appt_i : appts) {
            if (appt_i.theLatestAppointment__c) {
                if (appt_i.Appointment_Status__c == 'Canceled' || appt_i.Appointment_Date_Time__c < appt_i.Case__r.latestAppointment__c) {
                    apptsToUpdateMap.put(appt_i.Id, new Appointment__c(Id = appt_i.Id, theLatestAppointment__c = false));
                    caseCanUpdId.add(appt_i.Case__c);
                } else if (appt_i.Appointment_Date_Time__c > appt_i.Case__r.latestAppointment__c) {
                    casesToUpdateMap.put(appt_i.Case__c, new Case(Id = appt_i.Case__c, latestAppointment__c = appt_i.Appointment_Date_Time__c));
                }
            } else if (appt_i.Case__r.latestAppointment__c == null || appt_i.Appointment_Date_Time__c > appt_i.Case__r.latestAppointment__c) {
                if (appt_i.Appointment_Date_Time__c > appt_i.Case__r.latestAppointment__c) {
                    caseLatestApp.add(appt_i.Case__c);
                }
                apptsToUpdateMap.put(appt_i.Id, new Appointment__c(Id = appt_i.Id, theLatestAppointment__c = true));
                casesToUpdateMap.put(appt_i.Case__c, new Case(Id = appt_i.Case__c, latestAppointment__c = appt_i.Appointment_Date_Time__c));
            }
        }
        System.debug('caseLatestApp: size: ' + caseLatestApp.size() + ' values: ' + caseLatestApp);

        if (!caseLatestApp.isEmpty()) {
            for (Appointment__c appt_i : [SELECT Id FROM Appointment__c WHERE Case__c IN :caseLatestApp AND theLatestAppointment__c = true]) {
                apptsToUpdateMap.put(appt_i.Id, new Appointment__c(Id = appt_i.Id, theLatestAppointment__c = false));
            }
        }
        System.debug('caseCanUpdId: size: ' + caseCanUpdId.size() + ' values: ' + caseCanUpdId);

        if (!caseCanUpdId.isEmpty()) {
            Map<Id, List<Appointment__c>> caseIdToLatestApptMap = new Map<Id, List<Appointment__c>>();

            List<Appointment__c> apptsOfCases = [SELECT Case__c
                                                      , Appointment_Date_Time__c
                                                   FROM Appointment__c
                                                  WHERE Case__c IN :caseCanUpdId
                                                    AND Appointment_Status__c != 'Canceled'
                                               ORDER BY Appointment_Date_Time__c DESC];
            System.debug('apptsOfCases: size: ' + apptsOfCases.size() + ' values: ' + apptsOfCases);

            if (!apptsOfCases.isEmpty()) {
                for (Appointment__c appt_i : apptsOfCases) {
                    if (!caseIdToLatestApptMap.containsKey(appt_i.Case__c)) {
                        caseIdToLatestApptMap.put(appt_i.Case__c, new List<Appointment__c>());
                    }
                    caseIdToLatestApptMap.get(appt_i.Case__c).add(appt_i);
                }
                System.debug('caseIdToLatestApptMap: size: ' + caseIdToLatestApptMap.size() + ' values: ' + caseIdToLatestApptMap);

                for (Id caseId_i : caseIdToLatestApptMap.keySet()) {
                    Appointment__c latestAppt_i = caseIdToLatestApptMap.get(caseId_i).get(0);
                    casesToUpdateMap.put(caseId_i, new Case(Id = caseId_i, latestAppointment__c = latestAppt_i.Appointment_Date_Time__c));
                    apptsToUpdateMap.put(latestAppt_i.Id, new Appointment__c(Id = latestAppt_i.Id, theLatestAppointment__c = true));
                }
            } else {
                for (Id caseId_i : caseCanUpdId) {
                    casesToUpdateMap.put(
                        caseId_i,
                        new Case(
                            Id = caseId_i,
                            Status = 'Closed',
                            latestAppointment__c = null,
                            subStatus__c = 'Didn\'t execute'));
                }
            }
        }
        System.debug('casesToUpdateMap: size: ' + casesToUpdateMap.size() + ' value: ' + casesToUpdateMap);
        System.debug('apptsToUpdateMap: size: ' + apptsToUpdateMap.size() + ' value: ' + apptsToUpdateMap);

        if (!casesToUpdateMap.isEmpty()) {
            update casesToUpdateMap.values();
        }

        if (!apptsToUpdateMap.isEmpty()) {
            update apptsToUpdateMap.values();
        }

        if (!casesToUpdateMap.isEmpty() || !apptsToUpdateMap.isEmpty()) {
            System.debug('TR Appointment__c findLatestSalesApp ... executed');
        }
    }

    @future(callout=true)
    public static void fillRelatedDocument(Set<Id> appointmentIdSet, Set<Id> procedureIdSet) {
        System.debug('TR Appointment__c fillRelatedDocument ... future');
        List<Appointment__c> appointmentListToUpdate = new List<Appointment__c>();
        Related_document__c rdLanguage;
        Related_document__c rdHebrew;

        Map<Id, List<Related_document__c>> procedureIdToDocumentsMap = new Map<Id, List<Related_document__c>>();

        List<Appointment__c> appointmentList = [
            SELECT Related_document__c
                    , Medical_Procedure__c
                    , Appointment_Date_Time__c
                    , RecordType.DeveloperName
                    , Site__r.Site_Code__c
                    , Patient_Account__r.Asthma__c
                    , Patient_Account__r.Iodine_sensitivity__c
                    , Patient_Account__r.Preferred_Language_Service__c
                FROM Appointment__c
                WHERE Id IN :appointmentIdSet];
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);

        for (Related_document__c doc_i : [SELECT Site__c
                                               , Asthma__c
                                               , ToHour__c
                                               , FromHour__c
                                               , Language__c
                                               , Medical_Procedure__c
                                               , Iodine_sensitivity__c
                                               , AppointmentRecordType__c
                                            FROM Related_document__c
                                           WHERE Active__c = true
                                             AND GastroGuidelines__c = false
                                             AND Medical_Procedure__c IN :procedureIdSet]) {
            if (!procedureIdToDocumentsMap.containskey(doc_i.Medical_Procedure__c)) {
                procedureIdToDocumentsMap.put(doc_i.Medical_Procedure__c, new List<Related_document__c>());
            }
            procedureIdToDocumentsMap.get(doc_i.Medical_Procedure__c).add(doc_i);
        }
        System.debug('procedureIdToDocumentsMap: size: ' + procedureIdToDocumentsMap.size() + ' values: ' + procedureIdToDocumentsMap);

        for (Appointment__c appt_i : appointmentList) {
            if (!procedureIdToDocumentsMap.containsKey(appt_i.Medical_Procedure__c)) {
                continue;
            }

            for (Related_document__c doc_i : procedureIdToDocumentsMap.get(appt_i.Medical_Procedure__c)) {
                if (doc_i.AppointmentRecordType__c.split(';').contains(appt_i.RecordType.DeveloperName)
                        && doc_i.Site__c.split(';').contains(appt_i.Site__r.Site_Code__c)
                        && (doc_i.Asthma__c == null
                            || (doc_i.Asthma__c != null
                                && doc_i.Asthma__c.split(';').contains(appt_i.Patient_Account__r.Asthma__c)))
                        && (doc_i.Iodine_Sensitivity__c == null
                            || (doc_i.Iodine_Sensitivity__c != null
                                && doc_i.Iodine_Sensitivity__c.split(';').contains(appt_i.Patient_Account__r.Iodine_sensitivity__c)))
                        && ((doc_i.FromHour__c == null
                                && doc_i.ToHour__c == null)
                            || (doc_i.FromHour__c != null
                                && doc_i.ToHour__c != null
                                && appt_i.Appointment_Date_Time__c.hour() >= Integer.valueOf(doc_i.FromHour__c)
                                && appt_i.Appointment_Date_Time__c.hour() < Integer.valueOf(doc_i.ToHour__c)))) {
                    if (doc_i.Language__c.split(';').contains(appt_i.Patient_Account__r.Preferred_Language_Service__c)) {
                        rdLanguage = doc_i;
                        break;
                    } else if (doc_i.Language__c.split(';').contains('1')) {
                        rdHebrew = doc_i;
                    }
                }
            }

            if (rdLanguage != null && appt_i.Related_document__c != rdLanguage.Id) {
                appt_i.Related_document__c = rdLanguage.Id;
                appointmentListToUpdate.add(appt_i);
            } else if (rdHebrew != null && appt_i.Related_document__c != rdHebrew.Id) {
                appt_i.Related_document__c = rdHebrew.Id;
                appointmentListToUpdate.add(appt_i);
            }
        }
        System.debug('appointmentListToUpdate: size: ' + appointmentListToUpdate.size() + ' value: ' + appointmentListToUpdate);

        if (!appointmentListToUpdate.isEmpty()) {
            update appointmentListToUpdate;
            System.debug('TR Appointment__c fillRelatedDocument ... executed');
        }
    }

    @testVisible
    private static Messaging.SingleEmailMessage prepareMail(Appointment__c appt, EmailTemplate template, String links) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{appt.Patient_Account__r.PersonEmail});
        mail.setOrgWideEmailAddressId('0D24J000000CbQm');
        mail.setHtmlBody((template.HtmlValue).replace('{LINKS}', links));
        mail.setPlainTextBody((template.Body).replace('{LINKS}', links));
        mail.setTreatBodiesAsTemplate(true);
        mail.setSubject(template.Subject);
        mail.setWhatId(appt.Id);
        mail.setUseSignature(false);
        return mail;
    }

    public static void manualArrivalConfirm(List<Appointment__c> appts) {
        System.debug('AppointmentTriggerService.manualArrivalConfirm...');
        for (Appointment__c appt_i :appts) {
            appt_i.Appointment_Status__c = 'WaitingForAppointment';
            System.debug('TR Appointment__c manualArrivalConfirm ... executed');
        }
    }

    public static void updateSignedDoctor(List<Appointment__c> appts) {
        System.debug('AppointmentTriggerService.updateSignedDoctor...');
        for (Appointment__c appt_i :appts) {
            appt_i.SignedDoctor__c = appt_i.SignedBy__c;
            System.debug('TR Appointment__c updateSignedDoctor ... executed');
        }
    }

    public static void fillCreditDetails(List<Appointment__c> creditAppts, List<Appointment__c> appAppts) {
        System.debug('AppointmentTriggerService.fillCreditDetails...');
        if(creditAppts != null) {
            for (Appointment__c appt_i :creditAppts) {
                appt_i.Dateofcredit__c = datetime.now();
                System.debug('TR Appointment__c fillCreditDetails ... executed');
            }
        }

        if(appAppts != null) {
            for (Appointment__c appt_i :appAppts) {
                appt_i.Dateofarequestforcredit__c = datetime.now();
                System.debug('TR Appointment__c fillCreditDetails ... executed');
            }
        }
    }

    @future(callout=true)
    public static void updateRelatedCase(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c updateRelatedCase ... future');
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();

        List<Appointment__c> appointmentList = [
            SELECT Case__c
                 , Domain__c
                 , Appointment_Date_Time__c
                 , Site__r.Name
                 , Site__r.Address__c
                FROM Appointment__c
                WHERE Id IN :appointmentIdSet];
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);

        for (Appointment__c appt_i : appointmentList) {
            casesToUpdateMap.put(
                appt_i.Case__c,
                new Case(
                    Id = appt_i.Case__c,
                    Domain__c = appt_i.Domain__c,
                    date_of_appointment222__c = appt_i.Appointment_Date_Time__c,
                    site_of_appointment__c = appt_i.Site__r.Name,
                    Adress_for_app__c = appt_i.Site__r.Address__c
                )
            );
        }
        System.debug('casesToUpdateMap: size: ' + casesToUpdateMap.size() + ' value: ' + casesToUpdateMap);

        if (!casesToUpdateMap.isEmpty()) {
            update casesToUpdateMap.values();
            System.debug('TR Appointment__c updateRelatedCase ... executed');
        }
    }

    @future(callout=true)
    public static void updatePatientMailingApproval(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c updatePatientMailingApproval ... future');
        Map<Id, Account> patientsToUpdateMap = new Map<Id, Account>();

        List<Appointment__c> appointmentList = [
            SELECT Patient_Account__c
              FROM Appointment__c
             WHERE Id IN :appointmentIdSet
               AND Site__r.Site_Code__c != '33'
               AND Medical_Procedure__r.Confidentiality__c = false
               AND Medical_Procedure__r.Domain__r.ScheduleAppointmentMailingApproval__c = true
               AND Patient_Account__r.Mailing_approval__c != 'מאשר דיוור - הכל'
               AND Patient_Account__r.Mailing_approval__c != 'מאשר דיוור - שיווקי'
               AND (Patient_Account__r.ScheduleAppMailingApprovalDate__c = null
                 OR Patient_Account__r.ScheduleAppMailingApprovalDate__c < LAST_N_DAYS:730)];
        System.debug('appointmentList [' + appointmentList.size() + ']: ' + appointmentList);

        for (Appointment__c appointment_i : appointmentList) {
            patientsToUpdateMap.put(
                appointment_i.Patient_Account__c,
                new Account(
                    Id = appointment_i.Patient_Account__c,
                    Mailing_approval__c = 'מאשר דיוור - הכל',
                    Email_Approval_Date__c = Datetime.now(),
                    Opt_Out_Time_Stamp__pc = Datetime.now(),
                    ScheduleAppMailingApprovalDate__c = Datetime.now()
                )
            );
        }
        System.debug('patientsToUpdateMap [' + patientsToUpdateMap.size() + ']: ' + patientsToUpdateMap);

        if (!patientsToUpdateMap.isEmpty()) {
            update patientsToUpdateMap.values();
            System.debug('TR Appointment__c updatePatientMailingApproval ... executed');
        }
    }

    @future(callout=true)
    public static void sendCancelAppSMS(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c sendCancelAppSMS ... future');
        List<SMS__c> smsToInsertList = new List<SMS__c>();
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();

        for (Appointment__c appt_i :[SELECT Case__c
                                          , Site__c
                                          , Clinic__c
                                          , Site__r.Site_Code__c
                                          , Patient_Account__r.SMS_Phone_Number__c
                                       FROM Appointment__c
                                      WHERE Id IN :appointmentIdSet
                                        AND Patient_Account__r.SMS_Phone_Number__c != null
                                        AND Medical_Procedure__r.Confidentiality__c = false]) {
            appointmentToUpdateList.add(new Appointment__c(Id = appt_i.Id, cancel_via_reminder__c = true));
            smsToInsertList.add(prepareCancelSMS(appt_i));
        }
        System.debug('appointmentToUpdateList: size: ' + appointmentToUpdateList.size() + ' value: ' + appointmentToUpdateList);
        System.debug('smsToInsertList: size: ' + smsToInsertList.size() + ' value: ' + smsToInsertList);

        if (!appointmentToUpdateList.isEmpty()) {
            update appointmentToUpdateList;

            if (!smsToInsertList.isEmpty()) {
                insert smsToInsertList;
            }
            System.debug('TR Appointment__c sendCancelAppSMS ... executed');
        }
    }

    // should be in sms service in the future
    private static SMS__c prepareCancelSMS(Appointment__c appt) {
        return new SMS__c(
            Case__c = appt.Case__c,
            Appointment__c = appt.Id,
            Phone_Number__c = appt.Patient_Account__r.SMS_Phone_Number__c,
            ExpectedSendingDateTime__c = Datetime.now(),
            smsTemplate__c = appt.Clinic__c != null
                ? 'Cancel_Reminder_Experts'
                : appt.Site__r.Site_Code__c == '33'
                    ? 'Ashdod_Cancel_Reminder_Institutes'
                    : 'Cancel_Reminder_Institutes',
            Type__c = 'Outgoing'
        );
    }

    @future(callout=true)
    public static void updateSurveyTakerSmsSendingTime(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c updateSurveyTakerSmsSendingTime ... future');
        List<SurveyTaker__c> stToUpdateList = new List<SurveyTaker__c>();

        for (Appointment_To_Survey__c jct_i : [SELECT Appointment__r.Appointment_Date_Time__c
                                                    , Survey_patient__r.Survey__r.days_to_send_survey__c
                                                 FROM Appointment_To_Survey__c
                                                WHERE Appointment__c IN :appointmentIdSet
                                                  AND Survey_patient__c != null
                                                  AND SMS__c = false]) {
            stToUpdateList.add(
                new SurveyTaker__c(
                    Id = jct_i.Survey_patient__c,
                    sms_send_time__c = getSurveySendDate(
                        jct_i.Appointment__r.Appointment_Date_Time__c,
                        Integer.valueOf(jct_i.Survey_patient__r.Survey__r.days_to_send_survey__c), false)));
        }
        System.debug('stToUpdateList: size: ' + stToUpdateList.size() + ' values: ' + stToUpdateList);

        if (!stToUpdateList.isEmpty()) {
            update stToUpdateList;
            System.debug('TR Appointment__c updateSurveyTakerSmsSendingTime ... executed');
        }
    }

    public static void updateSendingbyWhatsApp(List<Appointment__c> appts, Set<Id> accountId, Set<Id> siteIds, Set<Id> procedureIds) {
        System.debug('TR Appointment__c updateSendingbyWhatsApp ...');
        Boolean sendingMessage = true;
        Boolean sendingWhatsApp = false;
        Id surgeriesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        Id institutesRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Institutes').getRecordTypeId();
        Id expertsRTId = AppointmentTriggerUtil.APPT_RT_MAP.get('Experts').getRecordTypeId();
        Map<Id, Medical_Procedure__c> procedureMap = new Map<Id, Medical_Procedure__c>();

        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Mailing_approval__c, Number_not_Kosher__c, SMS_Phone_Number__c
              FROM Account
             WHERE Id IN: accountId]);
        System.debug('accountMap: size: ' + accountMap.size() + ' value: ' + accountMap);

        Map<Id, Site__c> siteMap = new Map<Id, Site__c>([
            SELECT Id, sendingByWhatsApp__c
              FROM Site__c
             WHERE Id IN: siteIds
               AND sendingByWhatsApp__c = true]);
        System.debug('siteMap: size: ' + siteMap.size() + ' value: ' + siteMap);

        if (!procedureIds.isEmpty()) {
            procedureMap = new Map<Id, Medical_Procedure__c>([
                SELECT Id, Domain__r.sendingByWhatsApp__c, Confidentiality__c
                  FROM Medical_Procedure__c
                 WHERE Id IN: procedureIds]);
        }
        System.debug('procedureMap: size: ' + procedureMap.size() + ' value: ' + procedureMap);

        for (Appointment__c appt_i : appts) {
            for (String procedureLookup_i : AppointmentTriggerUtil.PROCEDURE_LOOKUPS) {
                if (appt_i.get(procedureLookup_i) != null && procedureMap.containskey(String.valueOf(appt_i.get(procedureLookup_i)))) {
                    if (procedureMap.get(String.valueOf(appt_i.get(procedureLookup_i))).Domain__r.sendingByWhatsApp__c) {
                        sendingWhatsApp = true;
                    }
                    if (procedureMap.get(String.valueOf(appt_i.get(procedureLookup_i))).Confidentiality__c) {
                        sendingMessage = false;
                    }
                } else {
                    break;
                }
            }
            if (siteMap.containskey(appt_i.Site__c)
                && accountMap.containskey(appt_i.Patient_Account__c)
                && accountMap.get(appt_i.Patient_Account__c).SMS_Phone_Number__c != null
                && accountMap.get(appt_i.Patient_Account__c).Number_not_Kosher__c == true
                && ((appt_i.RecordTypeId == surgeriesRTId && sendingWhatsApp)
                    ||((appt_i.RecordTypeId == institutesRTId || appt_i.RecordTypeId == expertsRTId) && procedureMap.get(appt_i.Medical_Procedure__c).Domain__r.sendingByWhatsApp__c)))
            {
                if (!appt_i.sendingByWhatsApp__c) {
                    appt_i.sendingByWhatsApp__c = true;
                    System.debug('TR Appointment__c update sendingByWhatsApp__c ... executed');
                }
            } else {
                appt_i.sendingByWhatsApp__c = false;
            }

            if (sendingMessage
                && accountMap.containskey(appt_i.Patient_Account__c)
                && accountMap.get(appt_i.Patient_Account__c).Mailing_approval__c != 'לא מאשר דיוור - הכל')
            {
                appt_i.SendingMessage__c = true;
                System.debug('TR Appointment__c update SendingMessage__c ... executed');
            }
        }
    }

    public static void updateGuidelines(List<Appointment__c> appointmentList, Set<Id> patientIdSet, Set<Id> procedureIdSet, Set<Id> pfIdSet) {
        Map<Id, List<GuidlinesWrapper.ScenarioWrp>> scenarioMap = new Map<Id, List<GuidlinesWrapper.ScenarioWrp>>();

        Id site33Id = [SELECT Id FROM Site__c WHERE Site_Code__c = '33']?.Id;

        Map<Id, Payer_Factor__c> pfMap = pfIdSet.isEmpty()
            ? new Map<Id, Payer_Factor__c>()
            : new Map<Id, Payer_Factor__c>([
                SELECT Code_Parent_for_Interface__c
                  FROM Payer_Factor__c
                 WHERE Id IN :pfIdSet]);
        System.debug('pfMap: size: ' + pfMap.size() + ' value: ' + pfMap);

        Map<Id, Account> patientMap = new Map<Id, Account>([
            SELECT PersonBirthdate
                 , Asthma__c
                 , Gender__c
                 , Diabetic__c
                 , Metals_in_body__c
                 , Blood_Dilution__c
                 , Iodine_sensitivity__c
              FROM Account
             WHERE Id IN :patientIdSet]);
        System.debug('patientMap: size: ' + patientMap.size() + ' value: ' + patientMap);

        for (Guidance_Scenario__c scenario_i : [SELECT Asthma__c
                                                     , Gender__c
                                                     , Protocol__c
                                                     , Diabetes__c
                                                     , Age_Range__c
                                                     , Payer_Factor__c
                                                     , MetalsInBody__c
                                                     , Blood_Dilution__c
                                                     , Iodine_Sensitive__c
                                                     , Medical_Procedure__c
                                                     , Site__r.Site_Code__c
                                                     , Guideline1__r.Guideline_Desc__c
                                                     , Guideline1__r.Guideline_Type__c
                                                     , Guideline2__r.Guideline_Desc__c
                                                     , Guideline2__r.Guideline_Type__c
                                                     , Guideline3__r.Guideline_Desc__c
                                                     , Guideline3__r.Guideline_Type__c
                                                     , Guideline4__r.Guideline_Desc__c
                                                     , Guideline4__r.Guideline_Type__c
                                                     , Guideline5__r.Guideline_Desc__c
                                                     , Guideline5__r.Guideline_Type__c
                                                     , Guideline6__r.Guideline_Desc__c
                                                     , Guideline6__r.Guideline_Type__c
                                                     , Guideline7__r.Guideline_Desc__c
                                                     , Guideline7__r.Guideline_Type__c
                                                     , Guideline8__r.Guideline_Desc__c
                                                     , Guideline8__r.Guideline_Type__c
                                                     , Guideline9__r.Guideline_Desc__c
                                                     , Guideline9__r.Guideline_Type__c
                                                     , Guideline10__r.Guideline_Desc__c
                                                     , Guideline10__r.Guideline_Type__c
                                                     , Guideline11__r.Guideline_Desc__c
                                                     , Guideline11__r.Guideline_Type__c
                                                     , Guideline12__r.Guideline_Desc__c
                                                     , Guideline12__r.Guideline_Type__c
                                                     , Guideline13__r.Guideline_Desc__c
                                                     , Guideline13__r.Guideline_Type__c
                                                     , Guideline14__r.Guideline_Desc__c
                                                     , Guideline14__r.Guideline_Type__c
                                                     , Guideline15__r.Guideline_Desc__c
                                                     , Guideline15__r.Guideline_Type__c
                                                     , Guideline16__r.Guideline_Desc__c
                                                     , Guideline16__r.Guideline_Type__c
                                                     , Guideline17__r.Guideline_Desc__c
                                                     , Guideline17__r.Guideline_Type__c
                                                     , Guideline18__r.Guideline_Desc__c
                                                     , Guideline18__r.Guideline_Type__c
                                                     , Guideline19__r.Guideline_Desc__c
                                                     , Guideline19__r.Guideline_Type__c
                                                     , Guideline20__r.Guideline_Desc__c
                                                     , Guideline20__r.Guideline_Type__c
                                                     , Guideline21__r.Guideline_Desc__c
                                                     , Guideline21__r.Guideline_Type__c
                                                     , Guideline22__r.Guideline_Desc__c
                                                     , Guideline22__r.Guideline_Type__c
                                                     , Guideline23__r.Guideline_Desc__c
                                                     , Guideline23__r.Guideline_Type__c
                                                     , Guideline1_Sort_Order__c
                                                     , Guideline2_Sort_Order__c
                                                     , Guideline3_Sort_Order__c
                                                     , Guideline4_Sort_Order__c
                                                     , Guideline5_Sort_Order__c
                                                     , Guideline6_Sort_Order__c
                                                     , Guideline7_Sort_Order__c
                                                     , Guideline8_Sort_Order__c
                                                     , Guideline9_Sort_Order__c
                                                     , Guideline10_Sort_Order__c
                                                     , Guideline11_Sort_Order__c
                                                     , Guideline12_Sort_Order__c
                                                     , Guideline13_Sort_Order__c
                                                     , Guideline14_Sort_Order__c
                                                     , Guideline15_Sort_Order__c
                                                     , Guideline16_Sort_Order__c
                                                     , Guideline17_Sort_Order__c
                                                     , Guideline18_Sort_Order__c
                                                     , Guideline19_Sort_Order__c
                                                     , Guideline20_Sort_Order__c
                                                     , Guideline21_Sort_Order__c
                                                     , Guideline22_Sort_Order__c
                                                     , Guideline23_Sort_Order__c
                                                  FROM Guidance_Scenario__c
                                                 WHERE Status__c = 'active'
                                                   AND Medical_Procedure__c IN :procedureIdSet
                                              ORDER BY Site__c NULLS LAST, Gender__c DESC]) {
            if (!scenarioMap.containsKey(scenario_i.Medical_Procedure__c)) {
                scenarioMap.put(scenario_i.Medical_Procedure__c, new List<GuidlinesWrapper.ScenarioWrp>());
            }
            scenarioMap.get(scenario_i.Medical_Procedure__c).add(new GuidlinesWrapper.ScenarioWrp(scenario_i));
        }
        System.debug('scenarioMap: size: ' + scenarioMap.size() + ' value: ' + scenarioMap);

        for (Appointment__c appt_i : appointmentList) {
            if (!scenarioMap.containsKey(appt_i.Medical_Procedure__c)) {
                continue;
            }
            Account patient_i = patientMap.get(appt_i.Patient_Account__c);
            Payer_Factor__c pf_i = pfMap.get(appt_i.PayerFactor__c);
            Integer patientAgeInMonths_i = 0;
            Decimal patientAge_i = 0;

            if (patient_i.PersonBirthdate != null) {
                patientAgeInMonths_i = patient_i.PersonBirthdate.monthsBetween(Date.today());
                patientAge_i = patientAgeInMonths_i < 12 ? patientAgeInMonths_i / 10 : patientAgeInMonths_i / 12;
            }

            for (GuidlinesWrapper.ScenarioWrp scenario_i : scenarioMap.get(appt_i.Medical_Procedure__c)) {
                if ((scenario_i.siteId == appt_i.Site__c || (scenario_i.siteId == null && appt_i.Site__c != site33Id))
                        && ((appt_i.PayerFactor__c != null && pf_i.Code_Parent_for_Interface__c == null) || scenario_i.pfList.contains(pf_i?.Code_Parent_for_Interface__c) || scenario_i.pfList.isEmpty())
                        && (scenario_i.gender == patient_i.Gender__c || scenario_i.gender == null)
                        && (scenario_i.protocol == appt_i.Protocol__c && (patient_i.PersonBirthdate == null || scenario_i.ageRange == null || (patientAge_i >= scenario_i.minAge && patientAge_i <= scenario_i.maxAge)))) {
                    appt_i.GuidanceKMS__c = scenario_i.getGuidelineMessage();
                    appt_i.Guidance_Scenario__c = scenario_i.id;

                    if ((isSick(patient_i.Iodine_sensitivity__c) || !scenario_i.isIodineSensitive)
                            && (isSick(patient_i.Metals_in_body__c) || !scenario_i.isBodyMetals)
                            && (isSick(patient_i.Blood_Dilution__c) || !scenario_i.isThinBlood)
                            && (isSick(patient_i.Diabetic__c) || !scenario_i.isDiabetes)
                            && (isSick(patient_i.Asthma__c) || !scenario_i.isAsthma)) {
                        break;
                    }
                }
            }
        }
    }

    private static Boolean isSick(String answer) {
        return answer != null && answer != 'לא' && answer != 'לא ידוע';
    }

    public static void createConFormAndSurvey(Set<Id> appointmentIds, Set<Id> siteIds, Set<Id> procedureIds) {
        System.debug('TR Appointment__c createConFormAndSurvey ...');        
        
        Map<Id, String> consentFormIdToName = new Map<Id, String>();                                
        Id surveyRT = AppointmentTriggerUtil.S_TAKER_RT_MAP.get('Digital_Forms').getRecordTypeId();  
        Map<String, Medical_Procedure_in_Sites__c> medProcInSiteToSurveyMap = new Map<String, Medical_Procedure_in_Sites__c>();    
            
        for (Medical_Procedure_in_Sites__c medProcInSite : [SELECT Id, DigitalSignConsentForm__c, DigitalSignConsentForm1__c, Medical_Procedure__c, Site__c,
                                                             DigitalSignConsentForm__r.Name, DigitalSignConsentForm1__r.Name, Digital_Survey1__c, Digital_Survey_2__c, 
                                                             Digital_Survey_3__c, Digital_Survey1__r.SurveyCode__c, Digital_Survey1__r.days_to_send_survey__c, Digital_Survey1__r.Min_Age__c, Digital_Survey1__r.Maximum_age__c, Digital_Survey1__r.Gender__c,
                                                             Digital_Survey1__r.Immediate_Send__c, Digital_Survey1__r.Survey_Version__c, Digital_Survey1__r.Maximum_submission__c, 
                                                             Digital_Survey_2__r.Immediate_Send__c, Digital_Survey_2__r.SurveyCode__c, Digital_Survey_2__r.Min_Age__c, Digital_Survey_2__r.days_to_send_survey__c, Digital_Survey_2__r.Maximum_age__c, Digital_Survey_2__r.Gender__c, 
                                                             Digital_Survey_2__r.Survey_Version__c, Digital_Survey_2__r.Maximum_submission__c, 
                                                             Digital_Survey_3__r.Immediate_Send__c, Digital_Survey_3__r.SurveyCode__c, Digital_Survey_3__r.Min_Age__c, Digital_Survey_3__r.days_to_send_survey__c, Digital_Survey_3__r.Maximum_age__c, Digital_Survey_3__r.Gender__c,   
                                                             Digital_Survey_3__r.Survey_Version__c, Digital_Survey_3__r.Maximum_submission__c  
                                                           FROM Medical_Procedure_in_Sites__c
                                                           WHERE (Medical_Procedure__c IN: procedureIds
                                                           AND Site__c IN: siteIds)]) {
            
            String key = makeKey(medProcInSite.Medical_Procedure__c, medProcInSite.Site__c);
            medProcInSiteToSurveyMap.put(key, medProcInSite);
            
            // Consent Form
            if (medProcInSite.DigitalSignConsentForm__c != null) {
                consentFormIdToName.put(medProcInSite.DigitalSignConsentForm__c, medProcInSite.DigitalSignConsentForm__r.Name);
            }
            if (medProcInSite.DigitalSignConsentForm1__c != null) {
                consentFormIdToName.put(medProcInSite.DigitalSignConsentForm1__c, medProcInSite.DigitalSignConsentForm1__r.Name);
            }   
        }                                             

        if (medProcInSiteToSurveyMap.isEmpty()) return;

        List<SurveyTaker__c> surveyTakenToInsert = new List<SurveyTaker__c>();
        List<Appointment__c> appointmentToUpdate = new List<Appointment__c>(); 
        List<ConsentFormTaken__c> consFormTakenToInsert = new List<ConsentFormTaken__c>();
        
        String key;
        Boolean isAppUpdate;
        for (Appointment__c appointment_i : [SELECT Id 
                                                    , Case__c
                                                    , Site__c
                                                    , Domain__c
                                                    , Patient_Account__c
                                                    , Medical_Procedure__c
                                                    , Appointment_Date_Time__c                                                   
                                                    , Patient_Account__r.Gender__c
                                                    , Patient_Account__r.Age_Number__c
                                                    , Medical_Procedure__r.Procedure_Code__c  
                                                    , Referral_from_doctor_website__r.Anesthesia_Type__c
                                            FROM Appointment__c
                                            WHERE Id IN: appointmentIds]) {
            isAppUpdate = false;                                    
            key = makeKey(appointment_i.Medical_Procedure__c, appointment_i.Site__c);
            Medical_Procedure_in_Sites__c procedureInSite = medProcInSiteToSurveyMap.containskey(key) ? medProcInSiteToSurveyMap.get(key) : null;
            if (procedureInSite != null) {               
                // check DigitalSignConsentForm, DigitalSignConsentForm1
                for (Id consentId : new List<Id>{procedureInSite.DigitalSignConsentForm__c,
                                                procedureInSite.DigitalSignConsentForm1__c}) {
                    if (consentId == null) continue;

                    if (isDigitalSignFormCreationNeeded(appointment_i, consentFormIdToName.get(consentId))) {
                        consFormTakenToInsert.add(createConsentFormTaken(appointment_i, consentId));
                        isAppUpdate = true;
                    }
                }
                // check DigitalSurvey1, DigitalSurvey2, DigitalSurvey3 
                List<SurveyWrp> digitalSurvey = new List<SurveyWrp>();
                if (procedureInSite.Digital_Survey1__c != null) 
                    digitalSurvey.add(new SurveyWrp(procedureInSite.Digital_Survey1__r));
                if (procedureInSite.Digital_Survey_2__c != null) 
                    digitalSurvey.add(new SurveyWrp(procedureInSite.Digital_Survey_2__r));
                if (procedureInSite.Digital_Survey_3__c != null) 
                    digitalSurvey.add(new SurveyWrp(procedureInSite.Digital_Survey_3__r));
                                
                for (SurveyWrp survey_i : digitalSurvey) {
                    if (survey_i == null) continue;
                    if (isSurveyCreationNeeded(appointment_i.Patient_Account__r , survey_i.minAge, survey_i.maxAge, survey_i.gender)) {
                        surveyTakenToInsert.add(createSurvey(appointment_i, survey_i, surveyRT));
                    }
                }
            }                                 
            if (isAppUpdate) {
                appointmentToUpdate.add(new Appointment__c(Id = appointment_i.Id, RelevantInformedConsent__c = true));
            }
        }

        if (!consFormTakenToInsert.isEmpty()) {
            insert consFormTakenToInsert;                
        }
        if (!surveyTakenToInsert.isEmpty()) {
            insert surveyTakenToInsert;           
        }
        if (!appointmentToUpdate.isEmpty()){
            update appointmentToUpdate;
        }
    }

    private static Boolean isDigitalSignFormCreationNeeded(Appointment__c appointment, String signFormName) {

    if (signFormName != 'BloodTransfusionAndAnesthesia') {
        return true;
    }

    return isAllowedAnesthesiaType(appointment);
}

private static Boolean isAllowedAnesthesiaType(Appointment__c appointment) {
    Set<String> anesthesiaTypes = new Set<String>{ '7', '8' };
    String type = appointment.Referral_from_doctor_website__r?.Anesthesia_Type__c;

    return appointment.Referral_from_doctor_website__c != null
        && type != null
        && !anesthesiaTypes.contains(type); 
}

    private static Boolean isSurveyCreationNeeded(Account account, Decimal surveyMinAge, Decimal surveyMaxAge, String surveyGender){        
        return ((surveyMinAge == null || account.Age_Number__c > surveyMinAge) &&
                (surveyMaxAge == null || account.Age_Number__c < surveyMaxAge) &&
                (surveyGender == null || account.Gender__c == surveyGender));
    }

    private static SurveyTaker__c createSurvey(Appointment__c appointment, SurveyWrp survey, Id surveyRT) {         
        return new SurveyTaker__c(
            Survey__c = survey.id,
            RecordTypeId = surveyRT,
            QuickReceiptFlow__c = true,
            Case__c = appointment.Case__c,
            Site__c = appointment.Site__c,
            Appointment__c = appointment.Id,
            Survey_Version__c = survey.version,            
            Account__c = appointment.Patient_Account__c,
            Taker_Maximum_submission__c = survey.maxSubmission,
            visit_date__c = appointment.Appointment_Date_Time__c,        
            activity_code__c = appointment.Medical_Procedure__r.Procedure_Code__c,
            IsGuardian__c = appointment.Patient_Account__r.Age_Number__c > 18,                      
            sms_send_time__c = getSurveySendDate(appointment.Appointment_Date_Time__c, survey.daysToSend, survey.immediateSend) 
        );
    }

    private static ConsentFormTaken__c createConsentFormTaken(Appointment__c appointment, Id consentFormId){
        return new ConsentFormTaken__c(
                Case__c = appointment.Case__c,
                Site__c = appointment.Site__c,
                Appointment__c = appointment.Id,
                Account__c = appointment.Patient_Account__c,
                Domain__c = appointment.Domain__c,
                Medical_Procedure__c = appointment.Medical_Procedure__c,
                ConsentForm__c = consentFormId
        );
    }

    private static DateTime getSurveySendDate(Datetime apptDate, Integer daysToSend, Boolean isImmediateSend) {
        if (isImmediateSend) {
            return System.now();
        }
        if (daysToSend == null) {
            return apptDate;
        } else {
            Datetime convertedDate = apptDate.addDays(-daysToSend);
            return daysToSend == 999 || convertedDate < System.now() ? System.now() : convertedDate;
        }
    }

    private static String makeKey(Id procedureId, Id siteId) {
        return String.valueOf(procedureId) + '_' + String.valueOf(siteId);
    }

    private class SurveyWrp {
        private String id {get;set;}
        private String code {get;set;}
        private Decimal minAge {get;set;}     
        private Decimal maxAge {get;set;} 
        private String gender {get;set;}
        private String version {get;set;}               
        private Integer daysToSend {get;set;}
        private Boolean immediateSend {get;set;}
        private Integer maxSubmission {get;set;}
      
        private SurveyWrp(Survey__c survey) {
            this.id = survey.Id;            
            this.gender = survey.Gender__c;            
            this.minAge = survey.Min_Age__c;   
            this.maxAge = survey.Maximum_age__c;
            this.code = survey.SurveyCode__c;  
            this.version = survey.Survey_Version__c;
            this.immediateSend = survey.Immediate_Send__c;                                  
            this.daysToSend = survey.days_to_send_survey__c != null ? Integer.valueOf(survey.days_to_send_survey__c): null;
            this.maxSubmission = survey.Maximum_submission__c != null? Integer.valueOf(survey.Maximum_submission__c): null;
        }
    }
}