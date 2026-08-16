public with sharing class ExpertsTRDispatcher {

    /**
     * Mark Dont_send_reminder__c checkbox with a value from a Doctor_in_Clinic__c object linked
     * via Doctor_Account__c and PayerFactor__c lookup fields
     */
    public static void markDontSendReminder(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c markDontSendReminder ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> clinicIds = new Set<Id>();
        Set<Id> doctorIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Doctor_Account__c != null
                    && appt_i.Clinic__c != null
                    && !appt_i.Dont_send_reminder__c
                    && (oldMap == null
                        || oldMap.get(appt_i.Id).Dont_send_reminder__c != appt_i.Dont_send_reminder__c
                        || oldMap.get(appt_i.Id).Doctor_Account__c != appt_i.Doctor_Account__c
                        || oldMap.get(appt_i.Id).Clinic__c != appt_i.Clinic__c)) {
                doctorIds.add(appt_i.Doctor_Account__c);
                clinicIds.add(appt_i.Clinic__c);
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);
        System.debug('clinicIds: size: ' + clinicIds.size() + ' value: ' + clinicIds);

        if (!appts.isEmpty()) {
            ExpertsTRService.markDontSendReminder(appts, doctorIds, clinicIds);
        }
    }

    /**
     * Fill the Clinic__c field on Experts Appointments
     */
    public static void fillClinicLookup(List<Appointment__c> newList) {
        System.debug('TR Appointment__c fillClinicLookup ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> calendarIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Calendar__c != null
                    && appt_i.Site__c != null
                    && appt_i.Clinic__c == null) {
                calendarIds.add(appt_i.Calendar__c);
                siteIds.add(appt_i.Site__c);
                appts.add(appt_i);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('siteIds: size: ' + siteIds.size() + ' value: ' + siteIds);
        System.debug('calendarIds: size: ' + calendarIds.size() + ' value: ' + calendarIds);

        if (!appts.isEmpty()) {
            ExpertsTRService.fillClinicLookup(appts, calendarIds, siteIds);
        }
    }

    /*
     * Check if Experts appointment contains a procedure code that didn't conform to the expert code
     * according to Metadata of expertProcedures
     */
    public static void validateExpertProcedures(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c validateExpertProcedures ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> procedureIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Medical_Procedure__c != null
                    && (oldMap == null
                        || oldMap.get(appt_i.Id).Medical_Procedure__c != appt_i.Medical_Procedure__c)) {
                appts.add(appt_i);
                procedureIds.add(appt_i.Medical_Procedure__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('procedureIds: size: ' + procedureIds.size() + ' value: ' + procedureIds);

        if (!appts.isEmpty()) {
            ExpertsTRService.validateExpertProcedures(appts, procedureIds);
        }
    }

    /**
     * Fill Doctor_Account__c lookup on an Appointment from based on Doctor__c field in Calendar__c object
     */
    public static void fillDoctorExperts(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c fillDoctorExperts ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> calendarIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Doctor_Account__c == null
                    && appt_i.Calendar__c != null
                    && (oldMap == null
                        || appt_i.Calendar__c != oldMap.get(appt_i.Id).Calendar__c)) {
                appts.add(appt_i);
                calendarIds.add(appt_i.Calendar__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts); 
        System.debug('calendarIds: size: ' + calendarIds.size() + ' value: ' + calendarIds);

        if (!appts.isEmpty()) {
            ExpertsTRService.fillDoctorExperts(appts, calendarIds);
        }
    }

    /**
     * Update the related Experts Case's date_of_appointment222__c, site_of_appointment__c
     * and Adress_for_app__c fields with values from the Clinic__r.street_address__c,
     * Clinic__r.Address__c and Appointment_Date_Time__C fields on an Appointment
     */
    public static void updateExpertsCase(List<Appointment__c> newList) {
        System.debug('TR Appointment__c updateExpertsCase ... start');
        Set<Id> appointmentIdSet = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (!AppointmentTriggerUtil.isMethodRun('updateExpertsCase', appt_i.Id)
                    && appt_i.Case__c != null
                    && appt_i.Clinic__c != null) {
                appointmentIdSet.add(appt_i.Id);
                AppointmentTriggerUtil.addExecutedRecordId('updateExpertsCase', appt_i.Id);
            }
        }
        System.debug('appointmentIdSet: size: ' + appointmentIdSet.size() + ' value: ' + appointmentIdSet);

        if (!appointmentIdSet.isEmpty()) {
            ExpertsTRService.updateExpertsCase(appointmentIdSet);
            System.debug('TR Appointment__c updateExpertsCase ... future');
        }
    }

    /**
     * Send an email to the clinic to schedule, update and cancel an appointment
     */
    public static void sendClinicMail(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c sendClinicUpdateMail... start');
        List<Appointment__c> updateAppts = new List<Appointment__c>();
        List<Appointment__c> cancelAppts = new List<Appointment__c>();
        List<Appointment__c> scheduleAppts = new List<Appointment__c>();
               
        for (Appointment__c appt_i : newList) {
            if (appt_i.clinic_Email__c != null && !AppointmentTriggerUtil.isMethodRun('sendClinicMail', appt_i.Id)) {
                if ((appt_i.Appointment_Status__c == 'וידוא הגעה לפגישה'
                            || appt_i.Appointment_Status__c == 'WaitingForAppointment')
                        && appt_i.Appointment_Date_Time__c != null
                        && appt_i.Clinic_email_sent_status__c == null
                        && appt_i.Appointment_Type__c != 'Excellent' //2086687876 להוציא את תורים של מצויינות מתהליך שליחת וואצר 
                        && appt_i.Appointment_Date_Time__c.date() >= Date.today()) {
                    scheduleAppts.add(appt_i);
                    AppointmentTriggerUtil.addExecutedRecordId('sendClinicMail', appt_i.Id);
                } else if (appt_i.Appointment_Date_Time__c != null
                        && appt_i.Clinic_email_sent_status__c == 'זימון'
                        && appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c) {
                    updateAppts.add(appt_i);
                    AppointmentTriggerUtil.addExecutedRecordId('sendClinicMail', appt_i.Id);
                } else if (appt_i.Appointment_Status__c != null
                        && appt_i.Appointment_Status__c != oldMap.get(appt_i.Id).Appointment_Status__c
                        && (appt_i.Appointment_Status__c == 'Canceled'
                            || appt_i.Appointment_Status__c == 'RescheduleByClient'
                            || appt_i.Appointment_Status__c == 'RescheduleByAssuta'
                            || appt_i.Appointment_Status__c == 'WaitingForCanceled'
                            || appt_i.Appointment_Status__c == 'CanceledFailed')
                        && (appt_i.Clinic_email_sent_status__c == 'זימון'
                            || appt_i.Clinic_email_sent_status__c == 'עדכון' )) {
                    cancelAppts.add(appt_i);
                    AppointmentTriggerUtil.addExecutedRecordId('sendClinicMail', appt_i.Id);
                }
            }
        }
        System.debug('scheduleAppts: size: ' + scheduleAppts.size() + ' value: ' + scheduleAppts);
        System.debug('updateAppts: size: ' + updateAppts.size() + ' value: ' + updateAppts);
        System.debug('cancelAppts: size: ' + cancelAppts.size() + ' value: ' + cancelAppts);

        if (!scheduleAppts.isEmpty() || !updateAppts.isEmpty() || !cancelAppts.isEmpty() ) {
            ExpertsTRService.sendClinicMail(scheduleAppts, updateAppts, cancelAppts);
        }
    }
            
    /**
    * This method determines each appointment’s type and fills its location based on related calendar and site data.
    */
    public static void fillApptTypeAndLocation(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c fillApptTypeAndLocation ... start');
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> calendarIds = new Set<Id>();
        Set<Id> domainIds = new Set<Id>();

        for (Appointment__c appt_i : newList) {
            if (appt_i.Calendar__c != null 
                    && appt_i.Domain__c != null
                    && (oldMap == null
                        || appt_i.Calendar__c != oldMap.get(appt_i.Id).Calendar__c)){
                appts.add(appt_i);
                domainIds.add(appt_i.Domain__c);
                calendarIds.add(appt_i.Calendar__c);
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts); 
        System.debug('domainIds: size: ' + domainIds.size() + ' value: ' + domainIds);
        System.debug('calendarIds: size: ' + calendarIds.size() + ' value: ' + calendarIds);

        if (!appts.isEmpty()) {
            ExpertsTRService.fillApptTypeAndLocation(appts, calendarIds, domainIds);
        }
    }

    public static void updateDoctorReminderDate(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('TR Appointment__c updateDoctorReminderDate... start');        
        List<Appointment__c> appts = new List<Appointment__c>();  
        Map<Id, Account> doctorMap = new Map<Id, Account>();
        Set<Id> doctorIds = new Set<Id>();   
        
        for (Appointment__c appt_i : newList) {
            if (appt_i.Doctor_Account__c != null) {
                doctorIds.add(appt_i.Doctor_Account__c);                
            }
        }
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);                
         
        if (!doctorIds.isEmpty()) {        
            doctorMap = new Map<Id, Account>([
                SELECT Id
                  FROM Account
                 WHERE Id IN :doctorIds
                 AND Experts_center__c = true]);
        }       

        for (Appointment__c appt_i : newList) {
            if (doctorMap.containsKey(appt_i.Doctor_Account__c)
                    && appt_i.Appointment_Type__c == 'Experts'
                    && appt_i.Appointment_Date_Time__c != null
                    && appt_i.Appointment_Date_Time__c.date() >= Date.today()
                    && (oldMap == null
                        || appt_i.Appointment_Date_Time__c != oldMap.get(appt_i.Id).Appointment_Date_Time__c)){
                appts.add(appt_i);
                doctorIds.add(appt_i.Doctor_Account__c);                
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);         

        if (!appts.isEmpty()) {
            ExpertsTRService.updateDoctorReminderDate(appts);
        }  
    } 
}