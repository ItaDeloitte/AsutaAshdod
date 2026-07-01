public with sharing class ExpertsTRService {

    public static void markDontSendReminder(List<Appointment__c> appts, Set<Id> doctorIds, Set<Id> clinicIds) {
        Boolean logicExecuted = false;
        Map<String, Boolean> jctMap = new Map<String, Boolean>();

        for (Doctor_in_Clinic__c jct_i : [SELECT Clinic__c
                                               , Doctors__c
                                               , Dont_send_reminder__c
                                            FROM Doctor_in_Clinic__c
                                           WHERE Doctors__c IN :doctorIds
                                             AND Clinic__c IN :clinicIds]) {
            if (!jctMap.containsKey(jct_i.Doctors__c + '' + jct_i.Clinic__c)) {
                jctMap.put(jct_i.Doctors__c + '' + jct_i.Clinic__c, jct_i.Dont_send_reminder__c);
            }
        }
        System.debug('jctMap: size: ' + jctMap.size() + ' value: ' + jctMap);

        for (Appointment__c appt_i : appts) {
            String key_i = appt_i.Doctor_Account__c + '' + appt_i.Clinic__c;
            if (jctMap.containsKey(key_i) && jctMap.get(key_i)) {
                appt_i.Dont_send_reminder__c = jctMap.get(key_i);
                logicExecuted = true;
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c markDontSendReminder ... executed');
        }
    }

    public static void fillClinicLookup(List<Appointment__c> appts, Set<Id> calendarIds, Set<Id> siteIds) {
        Map<Id, Map<Id, Id>> doctorIdToSiteIdToClinicIdMap = new Map<Id, Map<Id, Id>>();
        Map<Id, Calendar__c> calendarMap = new Map<Id, Calendar__c>();
        Set<Id> doctorIds = new Set<Id>();
        Boolean logicExecuted = false;

        for (Calendar__c calendar_i : [SELECT Doctor__c
                                            , CalenderInClinic__r.Clinic__c
                                         FROM Calendar__c
                                        WHERE Id IN :calendarIds
                                          AND Doctor__c != null]) {
            calendarMap.put(calendar_i.Id, calendar_i);
            doctorIds.add(calendar_i.Doctor__c);
        }
        System.debug('calendarMap: size: ' + calendarMap.size() + ' value: ' + calendarMap);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);

        for (Doctor_in_Clinic__c jct_i : [SELECT Doctors__c
                                               , Clinic__r.Site__c
                                            FROM Doctor_in_Clinic__c
                                           WHERE Doctors__c IN :doctorIds
                                             AND Clinic__r.Site__c IN :siteIds]) {
            if (!doctorIdToSiteIdToClinicIdMap.containsKey(jct_i.Doctors__c)) {
                doctorIdToSiteIdToClinicIdMap.put(jct_i.Doctors__c, new Map<Id, Id>());
            }
            doctorIdToSiteIdToClinicIdMap.get(jct_i.Doctors__c).put(jct_i.Clinic__r.Site__c, jct_i.Clinic__c);
        }
        System.debug('doctorIdToSiteIdToClinicIdMap: size: ' + doctorIdToSiteIdToClinicIdMap.size() + ' value: ' + doctorIdToSiteIdToClinicIdMap);

        for (Appointment__c appt_i : appts) {
            if (!calendarMap.containsKey(appt_i.Calendar__c)) {
                continue;
            }

            Calendar__c calendar_i = calendarMap.get(appt_i.Calendar__c);

            if (calendar_i.CalenderInClinic__r.Clinic__c != null) {
                appt_i.Clinic__c = calendar_i.CalenderInClinic__r.Clinic__c;
                logicExecuted = true;
            } else if (doctorIdToSiteIdToClinicIdMap.get(calendar_i.Doctor__c)?.get(appt_i.Site__c) != null) {
                appt_i.Clinic__c = doctorIdToSiteIdToClinicIdMap.get(calendar_i.Doctor__c).get(appt_i.Site__c);
                logicExecuted = true;
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);

        if (logicExecuted) {
            System.debug('TR Appointment__c fillClinicLookup ... executed');
        }
    }

    public static void validateExpertProcedures(List<Appointment__c> appts, Set<Id> procedureIds) {
        Boolean logicExecuted = false;
        List<String> expertProcedures = ExpertProcedureService.getInstance().getAll();
        Map<Id, String> procedureMap = new Map<Id, String>();
        
        for (Medical_Procedure__c procedure_i : [SELECT Procedure_Code__c
                                                   FROM Medical_Procedure__c
                                                  WHERE Id IN :procedureIds]) {
            procedureMap.put(procedure_i.Id, procedure_i.Procedure_Code__c);
        }
        System.debug('procedureMap: size: ' + procedureMap.size() + ' value: ' + procedureMap);

        for (Appointment__c appt_i : appts) {
            if (procedureMap.containsKey(appt_i.Medical_Procedure__c)
                    && !expertProcedures.contains(procedureMap.get(appt_i.Medical_Procedure__c))) {
                appt_i.addError(Label.The_procedure_code_does_not_match_the_experts);
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c validateExpertProcedures ... executed');
        }
    }

    public static void fillDoctorExperts(List<Appointment__c> appts, Set<Id> calendarIds) {
        Boolean logicExecuted = false;
        Map<Id, Calendar__c> calendarMap = new Map<Id, Calendar__c>([
            SELECT Doctor__c
              FROM Calendar__c
             WHERE Id IN :calendarIds
               AND Doctor__c != null]);
        System.debug('calendarMap: size: ' + calendarMap.size() + ' value: ' + calendarMap);

        for (Appointment__c app_i :appts) {
            if (calendarMap.containsKey(app_i.Calendar__c)) {
                app_i.Doctor_Account__c = calendarMap.get(app_i.Calendar__c).Doctor__c;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c fillDoctorExperts ... executed');
        }
    }

    @future(callout=true)
    public static void updateExpertsCase(Set<Id> appointmentIdSet) {
        System.debug('TR Appointment__c updateExpertsCase ... future');
        Map<Id, Case> caseToUpdateMap = new Map<Id, Case>();

        List<Appointment__c> appointmentList = [
            SELECT Case__c
                 , Clinic__c
                 , Appointment_Date_Time__c
                 , Clinic__r.Address__c
                 , Clinic__r.street_address__c
              FROM Appointment__c
             WHERE Id IN :appointmentIdSet
               AND Case__r.Channel__c = 'פרטי'
               AND Case__r.Doctor_Arrangement__r.Arrangement__r.Name LIKE '%מומחים%'
               AND Clinic__r.street_address__c != null];
        System.debug('appointmentList: size: ' + appointmentList.size() + ' value: ' + appointmentList);

        for (Appointment__c appt_i : appointmentList) {
            caseToUpdateMap.put(
                appt_i.Case__c,
                new Case(
                    Id = appt_i.Case__c,
                    site_of_appointment__c = appt_i.Clinic__r.Address__c,
                    Adress_for_app__c = appt_i.Clinic__r.street_address__c,
                    date_of_appointment222__c = appt_i.Appointment_Date_Time__c));
        }
        System.debug('caseToUpdateMap: size: ' + caseToUpdateMap.size() + ' value: ' + caseToUpdateMap);

        if (!caseToUpdateMap.isEmpty()) {
            update caseToUpdateMap.values();
            System.debug('TR Appointment__c updateExpertsCase ... executed');
        }
    }

    public static void sendClinicMail(List<Appointment__c> scheduleAppts, List<Appointment__c> updateAppts, List<Appointment__c> cancelAppts) {
        System.debug('AppointmentTriggerService.sendClinicMail...');
        List<EmailMessage> emails = new List<EmailMessage>(); 
        Map<String, EmailTemplate> templates = new Map<String, EmailTemplate> ();

        for (EmailTemplate template_i : [SELECT DeveloperName
                                           FROM EmailTemplate
                                          WHERE DeveloperName IN :AppointmentTriggerUtil.CLINIC_EMAIL_TEMPLATES]) {
            templates.put(template_i.DeveloperName, template_i);
        }
        System.debug('templates: size: ' + templates.size() + ' value: ' + templates);

        if (!scheduleAppts.isEmpty()) {
            for (Appointment__c appt_i : scheduleAppts) {
                appt_i.Clinic_email_sent_status__c = 'זימון';
                emails.add(prepareEmailMessage(appt_i, templates.get('Assuta_Kit_Experts_4_clinic')));
            }
        }
        if (!updateAppts.isEmpty()) {
            for (Appointment__c appt_i : updateAppts) {
                appt_i.Clinic_email_sent_status__c = 'עדכון';
                emails.add(prepareEmailMessage(appt_i, templates.get('Assuta_Kit_Experts_4_clinic_upd')));
            }
        }
        if (!cancelAppts.isEmpty()) {
            for (Appointment__c appt_i : cancelAppts) {
                appt_i.Clinic_email_sent_status__c = 'ביטול';
                emails.add(prepareEmailMessage(appt_i, templates.get('Assuta_Kit_Experts_4_clinic_cncl')));
            }
        }
        System.debug('emails: size: ' + emails.size() + ' value: ' + emails);

        if (!emails.isEmpty()) {
            insert emails;
        }
    }

    private static EmailMessage prepareEmailMessage(Appointment__c appt, EmailTemplate template) {
        return new EmailMessage(
            AppointmentId__c = appt.Id,
            EmailTemplateId = template.Id,
            ToAddress = appt.clinic_Email__c,
            FromAddress = 'nonreply@assuta.co.il',
            AccountId__c = appt.Patient_Account__c,
            TemplateMergeField__c = 'AppointmentId__c',
            ExpectedSendingDateTime__c = Datetime.now(),
            EmailTemplateDeveloperName__c = template.DeveloperName,
            Automation_name__c = 'sendClinicMailAppTrigger');
    }
    
    public static void fillApptTypeAndLocation(List<Appointment__c> appts, Set<Id> calendarIds, Set<Id> domainIds) {
        Boolean logicExecuted = false;
        Set<Id> siteIds = new Set<Id>();        
        Map<Id, Calendar__c> expertCalendarMap = new Map<Id, Calendar__c>();
        Map<Id, Calendar__c> excellentCalendarMap = new Map<Id, Calendar__c>();
        Map<String, Site_Domain__c> keyToJctMap = new Map<String, Site_Domain__c>();
        
        for (Calendar__c calendar_i :[SELECT BranchName__c
                                            , Excellent_Clinics__c                 
                                            , CalenderInClinic__r.Full_address_doc_clinic__c            
                                        FROM Calendar__c
                                        WHERE Id IN :calendarIds]) {
            if (calendar_i.Excellent_Clinics__c == true) {
                excellentCalendarMap.put(calendar_i.Id, calendar_i);
                siteIds.add(calendar_i.BranchName__c); 
            } else {
                expertCalendarMap.put(calendar_i.Id, calendar_i); 
            }              
        }
        System.debug('expertCalendarMap: size: ' + expertCalendarMap.size() + ' value: ' + expertCalendarMap);
        System.debug('excellentCalendarMap: size: ' + excellentCalendarMap.size() + ' value: ' + excellentCalendarMap);
        
        if (!siteIds.isEmpty()) {
            // === Query Site–Domain === //
            for (Site_Domain__c jct_i : [SELECT Site__c, Domain__c, accurate_site__c, Exact_Location_In_Domain__c
                                        FROM Site_Domain__c
                                        WHERE Site__c IN :siteIds
                                            AND Domain__c IN :domainIds]) {
                keyToJctMap.put(jct_i.Site__c + '_' + jct_i.Domain__c, jct_i);
            }
            System.debug('keyToJctMap: size: ' + keyToJctMap.size() + ' value: ' + keyToJctMap);
        }
        
        for (Appointment__c app_i :appts) {
            if (excellentCalendarMap.containsKey(app_i.Calendar__c)) {                
                String key = excellentCalendarMap.get(app_i.Calendar__c).BranchName__c + '_' + app_i.Domain__c;
                Site_Domain__c jct = keyToJctMap.get(key);     

                app_i.Exact_Location_In_Domain__c = jct != null ? jct.Exact_Location_In_Domain__c : null;
                app_i.Appointment_Type__c = 'Excellent'; 
                logicExecuted = true;
            } else if (expertCalendarMap.containsKey(app_i.Calendar__c)) {
                    app_i.Exact_Location_In_Domain__c = expertCalendarMap.get(app_i.Calendar__c).CalenderInClinic__r.Full_address_doc_clinic__c;
                    app_i.Appointment_Type__c = 'Experts';
                    logicExecuted = true;
            }            
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c fillApptTypeAndLocation ... executed');
        }
    }


    public static void updateDoctorReminderDate(List<Appointment__c> appts) {
        Boolean logicExecuted = false;        
        Set<Date> dateSet = new Set<Date>{};
        
        for (Appointment__c appointment_i :appts) {
            dateSet.add(appointment_i.Appointment_Date_Time__c.date().addDays(-1));                     
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

        for (Appointment__c appointment_i : appts) {           
            appointment_i.ExpertsDoctorReminderDate__c = getReminderDate(appointment_i.Appointment_Date_Time__c.date(), startDate, 1, dateToCalendarMap);
            logicExecuted = true;
        }

        if (logicExecuted) {
            System.debug('TR Appointment__c updateDoctorReminderDate ... executed');
        }
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

    public static Date getReminderDate(Date startDate, Date minDate, Integer numOfDays, Map<Date, Calendar1__c> calendarMap) { 
        Integer counter = 0;
        Integer day = 1;
        Date endDay;
        
        System.debug('numOfDays ' + numOfDays);       
        do {            
            endDay = startDate.addDays(-day); 
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
}