// Test: CreateSMSByMetadataBatchTest
global class CreateSMSByMetadataBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                      + ', doc_from_try__c'
                      + ', link_memo_text__c'
                      + ', AppointmentTime__c'
                      + ', Appointment_Date_Time__c'
                      + ', formtitan_arrival_link__c'
                      + ', Formula_for_weekday_kit__c'
                      + ', RecordType.DeveloperName'
                      + ', Site__c'
                      + ', Site__r.Name'
                      + ', Clinic__r.Name'
                      + ', Case__c'
                      + ', Case__r.SMS_Phone_Number__c'
                      + ', Patient_Account__r.FirstName'
                      + ', Patient_Account__r.SMS_Phone_number__c'
                      + ', Medical_Procedure__r.Procedure_Code__c'
                      + ', Medical_Procedure__r.Domain__c'
                      + ', Medical_Procedure__r.Domain__r.DomainCode__c'
                      + ', Domain__c'
                      + ', Domain__r.DomainCode__c'
                  + ' FROM Appointment__c'
                 + ' WHERE Appointment_Date_Time__c >= TODAY'
                   + ' AND (Appointment_Status__c = \'וידוא הגעה לפגישה\' OR Appointment_Status__c = \'WaitingForAppointment\')'
                   + ' AND Medical_Procedure__c != null'
                   + ' AND Medical_Procedure__r.Confidentiality__c = false'
                   + ' AND Patient_Account__c != null'
                   + ' AND (Patient_Account__r.Mailing_approval__c = \'מאשר דיוור - הכל\' OR Patient_Account__r.Mailing_approval__c = \'מאשר דיוור - שירותי\')'
                   + ' AND (Case__r.SMS_Phone_Number__c != null OR Patient_Account__r.SMS_Phone_number__c != null)'
                   + ' AND (Site__c != null OR Clinic__c != null)'
              + ' ORDER BY Appointment_Date_Time__c';

    global CreateSMSByMetadataBatch() {}

    global CreateSMSByMetadataBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('Appointment__c '));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        List<SMS__c> newSMSList = new List<SMS__c>();
        Map<String, Map<String, SMS__c>> newSMSMap = new Map<String, Map<String, SMS__c>>();
        Set<Database.Error> errors = new Set<Database.Error>();
        Set<String> smsIds = new Set<String>();

        Map<Integer, Map<String, String>> contentsMap = this.getContentsMap();
        Map<String, Map<String, SMS__c>> reSMSMap = this.getReSMSMap(scope);
        Map<Date, Integer> businessDaysMap = this.getBusinessDaysMap();

        for (Appointment__c appt_i : scope) {
            Date date_i = appt_i.Appointment_Date_Time__c.date();
            String procedureCode_i = appt_i.Medical_Procedure__r.Procedure_Code__c;
            String domainCode_i = this.getDomainCode(appt_i);

            if (
                businessDaysMap.containsKey(date_i) &&
                contentsMap.containsKey(businessDaysMap.get(date_i)) &&
                (
                    contentsMap.get(businessDaysMap.get(date_i)).containsKey(procedureCode_i) ||
                    contentsMap.get(businessDaysMap.get(date_i)).containsKey(domainCode_i)
                )
            ) {
                String content_i = contentsMap.get(businessDaysMap.get(date_i)).containsKey(procedureCode_i)
                                 ? contentsMap.get(businessDaysMap.get(date_i)).get(procedureCode_i)
                                 : contentsMap.get(businessDaysMap.get(date_i)).get(domainCode_i);

                if (!newSMSMap.containsKey(appt_i.Id)) {
                    newSMSMap.put(appt_i.Id, new Map<String, SMS__c>());
                }
                SMS__c newSMS_i = this.prepareSMS(appt_i, content_i);
                newSMSMap.get(appt_i.Id).put(newSMS_i.Content__c, newSMS_i);
            }
        }
        System.debug('newSMSMap: size: ' + newSMSMap.size() + ' value: ' + newSMSMap);

        for (String apptId_i : reSMSMap.keySet()) {
            if (!newSMSMap.containsKey(apptId_i)) {
                newSMSMap.put(apptId_i, new Map<String, SMS__c>());
            }
            for (SMS__c sms_i : reSMSMap.get(apptId_i).values()) {
                if (!newSMSMap.get(apptId_i).containsKey(sms_i.Content__c)) {
                    newSMSMap.get(apptId_i).put(sms_i.Content__c, sms_i);
                }
            }
        }
        System.debug('newSMSMap: size: ' + newSMSMap.size() + ' value: ' + newSMSMap);

        for (String apptId_i : newSMSMap.keySet()) {
            for (SMS__c sms_i : newSMSMap.get(apptId_i).values()) {
                newSMSList.add(sms_i);
            }
        }
        System.debug('newSMSList: size: ' + newSMSList.size() + ' value: ' + newSMSList);

        for (Database.SaveResult result_i : Database.insert(newSMSList, false)) {
            if (result_i.isSuccess()) {
                smsIds.add(result_i.getId());
            } else {
                errors.addAll(result_i.getErrors());
            }
        }
        System.debug('smsIds: size: ' + smsIds.size() + ' value: ' + smsIds);
        System.debug('errors: ' + JSON.serialize(errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CreateSMSByMetadataBatch(), 25);
    }

    private Map<Integer, Map<String, String>> getContentsMap() {
        Map<Integer, Map<String, String>> contentsMap = new Map<Integer, Map<String, String>>();

        List<SMS_Setting__mdt> settings = [
            SELECT Number_of_days__c, Procedure_Codes__c, Domain_Codes__c, SMS_Message__r.SMS_Content__c
              FROM SMS_Setting__mdt
             WHERE Is_Active__c = true];

        for (SMS_Setting__mdt setting_i : settings) {
            Integer numberOfDays_i = Integer.valueOf(setting_i.Number_of_days__c);
            if (!contentsMap.containsKey(numberOfDays_i)) {
                contentsMap.put(numberOfDays_i, new Map<String, String>());
            }
            String codes = setting_i.Procedure_Codes__c == null ? setting_i.Domain_Codes__c : setting_i.Procedure_Codes__c;
            for (String code_i : codes.deleteWhitespace().split('[,;]')) {
                contentsMap.get(numberOfDays_i).put(code_i, setting_i.SMS_Message__r.SMS_Content__c);
            }
        }
        System.debug('contentsMap: size: ' + contentsMap.size() + ' value: ' + contentsMap);

        return contentsMap;
    }

    private Map<Date, Integer> getBusinessDaysMap() {
        Map<Date, Integer> businessDaysMap = new Map<Date, Integer>();

        List<Calendar1__c> calendar = [
            SELECT Gregorian_Date__c, business_day__c
              FROM Calendar1__c
             WHERE Gregorian_Date__c >= TODAY
          ORDER BY Gregorian_Date__c];

        Integer counter = 0;
        for (Calendar1__c day_i : calendar) {
            businessDaysMap.put(day_i.Gregorian_Date__c, counter);
            if (day_i.business_day__c) {
                counter++;
            }
        }
        System.debug('businessDaysMap: size: ' + businessDaysMap.size() + ' value: ' + businessDaysMap);

        return businessDaysMap;
    }

    private Map<String, Map<String, SMS__c>> getReSMSMap(List<Appointment__c> scope) {
        List<SMS__c> smss = [
            SELECT Appointment__c, Phone_Number__c, Content__c, Success__c
              FROM SMS__c
             WHERE Appointment__c IN: scope
               AND Sent_with_SMS_Settings__c = true
          ORDER BY Appointment__c, CreatedDate, Success__c];

        Map<String, Map<String, SMS__c>> allSMSMap = new Map<String, Map<String, SMS__c>>();
        for (SMS__c sms_i : smss) {
            allSMSMap.put(sms_i.Appointment__c, new Map<String, SMS__c>{sms_i.Content__c => sms_i});
        }

        Map<String, Map<String, SMS__c>> reSMSMap = new Map<String, Map<String, SMS__c>>();
        for (String apptId_i : allSMSMap.keySet()) {
            for (SMS__c sms_i : allSMSMap.get(apptId_i).values()) {
                if (!sms_i.Success__c) {
                    reSMSMap.put(
                        sms_i.Appointment__c,
                        new Map<String, SMS__c>{
                            sms_i.Content__c => this.prepareSMS(sms_i.Content__c, sms_i.Phone_Number__c, sms_i.Appointment__c)
                        }
                    );
                }
            }
        }
        System.debug('reSMSMap: size: ' + reSMSMap.size() + ' value: ' + reSMSMap);

        return reSMSMap;
    }

    private SMS__c prepareSMS(Appointment__c appt, String content) {
        return this.prepareSMS(this.getContent(appt, content), this.getPhoneNumber(appt), appt.Id);
    }

    private SMS__c prepareSMS(String content, String phoneNumber, String apptId) {
        return new SMS__c(
            status__c = '1',
            Type__c = 'Outgoing',
            Content__c = content,
            Appointment__c = apptId,
            Phone_Number__c = phoneNumber,
            Sent_with_SMS_Settings__c = true
        );
    }

    private String getDomainCode(Appointment__c appt) {
        String code;
        if (appt.Medical_Procedure__r.Domain__c != null && appt.Medical_Procedure__r.Domain__r.DomainCode__c != null) {
            code = String.valueOf(Integer.valueOf(appt.Medical_Procedure__r.Domain__r.DomainCode__c));
        } else if (appt.Domain__c != null && appt.Domain__r.DomainCode__c != null) {
            code = String.valueOf(Integer.valueOf(appt.Domain__r.DomainCode__c));
        }
        return code;
    }

    private String getPhoneNumber(Appointment__c appt) {
        String phone = appt.Case__c != null && appt.Case__r.SMS_Phone_Number__c != null
            ? appt.Case__r.SMS_Phone_Number__c
            : appt.Patient_Account__r.SMS_Phone_number__c;
        return phone;
    }

    private String getContent(Appointment__c appt, String Content) {
        content = content.replace('{0}', appt.Patient_Account__r.FirstName);
        content = content.replace('{1}', appt.RecordType.DeveloperName == 'Experts' ? ' ' + appt.doc_from_try__c : ' ');
        content = content.replace('{2}', appt.Site__c == null ? appt.Clinic__r.Name : appt.Site__r.Name);
        content = content.replace('{3}', appt.Formula_for_weekday_kit__c);
        content = content.replace('{4}', appt.AppointmentTime__c);
        content = content.replace('{5}', appt.formtitan_arrival_link__c);
        content = content.replace('{6}', appt.link_memo_text__c != null ? appt.link_memo_text__c + '. ' : '');
        return content;
    }
}