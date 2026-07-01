// Test: LC_DisabilityControllerTest
public with sharing class LC_DisabilityController implements ILCController {

    public static Map<String, PicklistUtil.PicklistValue> typesMap = PicklistUtil.buildPicklistMapping('Disabilities__c', 'Type_of_disability__c');
    public static Map<String, PicklistUtil.PicklistValue> assistsMap = PicklistUtil.buildPicklistMapping('Disabilities__c', 'Type_of_Assist__c');

    public class LC_DisabilityControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'getDisabilities' {
                return this.getDisabilities(
                    this.getCaseId((String) params.get('caseId')),
                    this.getAppointmentIds((String) params.get('appointmentIds'), true)
                );
            }
            when 'setDisabilities' {
                return this.setDisabilities(
                    this.getCaseId((String) params.get('caseId')),
                    (String) params.get('jsonedParams'),
                    this.getAppointmentIds((String) params.get('appointmentIds'), true)
                );
            }
            when else {
                throw new LC_DisabilityControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private String getCaseId(String recordId) {
        System.debug('LC_DisabilityController.getCaseId...\nrecordId: ' + recordId);

        if (Id.valueOf(recordId).getSobjectType() == Appointment__c.getSObjectType()) {
            recordId = [SELECT Id, Case__c FROM Appointment__c WHERE Id =: recordId].Case__c;
        }

        return recordId;
    }

    // send isSingle true if you need to create medical aid only for the first appointment of sequence
    private List<String> getAppointmentIds(String jsonedList, Boolean isSingle) {
        System.debug('LC_DisabilityController.getAppointmentIds...\nisSingle: ' + isSingle);

        List<String> tempList = (List<String>) JSON.deserialize(jsonedList, List<String>.class);
        List<String> appointmentIds = isSingle && !tempList.isEmpty() ? new List<String>{tempList.get(0)} : tempList;

        return appointmentIds;
    }

    public Response getDisabilities(String caseId, List<String> appointmentIds) {
        System.debug('LC_DisabilityController.getDisabilities...\ncaseId: ' + caseId + '\nappointmentIds: ' + appointmentIds);
        Map<String, Set<String>> assistsSelectedMap = new Map<String, Set<String>>();
        Map<String, List<String>> aidIdsMap = new Map<String, List<String>>();
        List<MedicalAid> wrapper = new List<MedicalAid>();

        Case cas = [SELECT Id, AccountId FROM Case WHERE Id =: caseId];
        List<Disabilities__c> disabilities = [SELECT Id, Patient_Account__c, Type_of_disability__c, Type_of_Assist__c FROM Disabilities__c
                                              WHERE Patient_Account__c =: cas.AccountId AND Type_of_Assist__c != null];

        if (!appointmentIds.isEmpty()) {
            Map<String, Map<String, String>> orderMap = new Map<String, Map<String, String>>();

            for (Medical_Aid_Appointment__c aid_i : [SELECT Id, Disabilities__c, Appointment__c, Type_of_Assist__c FROM Medical_Aid_Appointment__c
                                                     WHERE Patient__c =: cas.AccountId AND Appointment__c IN: appointmentIds AND Status__c != 'בוטל']) {
                // populating orderMap with aid ids to save appoitnment order
                if (!orderMap.containsKey(aid_i.Appointment__c)) {
                    orderMap.put(aid_i.Appointment__c, new Map<String, String>());
                }
                orderMap.get(aid_i.Appointment__c).put(aid_i.Disabilities__c, aid_i.Id);

                // populating assistsSelectedMap to mark assists as selected and upsert them on setDisabilities method
                if (!assistsSelectedMap.containsKey(aid_i.Disabilities__c)) {
                    assistsSelectedMap.put(aid_i.Disabilities__c, new Set<String>());
                }
                assistsSelectedMap.get(aid_i.Disabilities__c).addAll(aid_i.Type_of_Assist__c != null ? aid_i.Type_of_Assist__c.split(';') : new List<String>());
            }

            // populating aidIdsMap in right order for sequence
            for (String appointmentId_i : appointmentIds) {
                if (orderMap.containsKey(appointmentId_i)) {
                    for (String disability_i : orderMap.get(appointmentId_i).keySet()) {
                        if (!aidIdsMap.containsKey(disability_i)) {
                            aidIdsMap.put(disability_i, new List<String>());
                        }
                        aidIdsMap.get(disability_i).add(orderMap.get(appointmentId_i).get(disability_i));
                    }
                }
            }
        }

        // wrap MedicalAids for frontend
        for (Disabilities__c disability_i : disabilities) {
            if (aidIdsMap.containsKey(disability_i.Id)) {
                wrapper.add(new MedicalAid(aidIdsMap.get(disability_i.Id), disability_i, assistsSelectedMap.get(disability_i.Id)));
            } else {
                wrapper.add(new MedicalAid(disability_i, new Set<String>()));
            }
        }
        System.debug('wrapper: size: ' + wrapper.size() + ' value: ' + wrapper);
        return new Response(wrapper);
    }

    public Response setDisabilities(String caseId, String jsonedParams, List<String> appointmentIds) {
        System.debug('LC_DisabilityController.setDisabilities...\ncaseId: ' + caseId + '\njsonedParams: ' + jsonedParams + '\nappointmentIds: ' + appointmentIds);
        List<MedicalAid> data = (List<MedicalAid>) JSON.deserialize(jsonedParams, List<MedicalAid>.class);
        System.debug('data [' + data.size() + ']: ' + data);

        List<Medical_Aid_Appointment__c> aidsToSendEmail = new List<Medical_Aid_Appointment__c>();
        List<Medical_Aid_Appointment__c> aidsToUpsert = new List<Medical_Aid_Appointment__c>();
        List<Medical_Aid_Appointment__c> aidsToDelete = new List<Medical_Aid_Appointment__c>();
        Map<String, Integer> workingDaysByDate = new Map<String, Integer>();
        Map<Id, Appointment__c> apptMap = new Map<Id, Appointment__c>();
        Map<String, Id> queueByDevName = new Map<String, Id>();
        List<MedicalAid> dataExtended = new List<MedicalAid>();
        Map<Id, Id> queueByApptId = new Map<Id, Id>();
        List<Option> assists = new List<Option>();
        Set<Id> medicalAidIds = new Set<Id>();
        Date maxScheduleDate = Date.today();

        // throw error if there are no appointments' ids
        if (appointmentIds.isEmpty()) {
            throw new LC_DisabilityControllerException('List of appointments\' ids is empty');
        }

        // separate assist 80 and add it as a separate aid
        for (MedicalAid aid_i : data) {
            for (Option assist_j : aid_i.assists) {
                if (assist_j.value == '80' && assist_j.isSelected) {
                    dataExtended.add(new MedicalAid(aid_i, new Option(assist_j.label, assist_j.value, true)));
                    assist_j.isSelected = false;
                    break;
                }
            }
        }
        System.debug('dataExtended [' + dataExtended.size() + ']: ' + dataExtended);

        data.addAll(dataExtended);

        // prepare map with all necessary queues
        for (QueueSobject qSobject_i : [SELECT QueueId, Queue.DeveloperName FROM QueueSobject WHERE SobjectType = 'Medical_Aid_Appointment__c' ORDER BY Queue.DeveloperName DESC]) {
            if (qSobject_i.Queue.DeveloperName == 'Q_Medical_Aid_No_Owner') {
                queueByDevName.put(qSobject_i.Queue.DeveloperName, qSobject_i.QueueId);
            } else {
                List<String> temp = new List<String>();
                for (String part_i : qSobject_i.Queue.DeveloperName.split('_')) {
                    temp.add(part_i);
                    if (temp.size() == 3) {
                        break;
                    }
                }
                queueByDevName.put(String.join(temp, '_'), qSobject_i.QueueId);
            }
        }
        System.debug('queueByDevName: size: ' + queueByDevName.size() + ' value: ' + queueByDevName);

        for (Appointment__c appt_i : [SELECT Id, RecordType.DeveloperName, Appointment_Date_time__c, Site__r.Site_Code__c, Medical_Procedure__r.Domain__r.DomainCode__c
                                      FROM Appointment__c WHERE Id IN: appointmentIds]) {
            // prepare appointments map
            apptMap.put(appt_i.Id, appt_i);
            // get max schedule date
            if (maxScheduleDate < appt_i.Appointment_Date_Time__c) {
                maxScheduleDate = Date.valueOf(appt_i.Appointment_Date_Time__c);
            }
            // prepare map with queues by appointment id
            if (queueByDevName.containsKey('Q_' + appt_i.Site__r.Site_Code__c + '_' + appt_i.Medical_Procedure__r.Domain__r.DomainCode__c)) {
                queueByApptId.put(appt_i.Id, queueByDevName.get('Q_' + appt_i.Site__r.Site_Code__c + '_' + appt_i.Medical_Procedure__r.Domain__r.DomainCode__c));
            } else {
                queueByApptId.put(appt_i.Id, queueByDevName.get('Q_Medical_Aid_No_Owner'));
            }
        }
        System.debug('maxScheduleDate: ' + maxScheduleDate);
        System.debug('apptMap: size: ' + apptMap.size() + ' value: ' + apptMap);
        System.debug('queueByApptId: size: ' + queueByApptId.size() + ' value: ' + queueByApptId);

        // prepare map with working days by date
        Integer daysCounter = 0;
        for (Calendar1__c calendar_i : [SELECT Id, business_day__c, Gregorian_Date__c FROM Calendar1__c WHERE Gregorian_Date__c >= TODAY AND Gregorian_Date__c <=: maxScheduleDate ORDER BY Gregorian_Date__c]) {
            String dateKey = '' + calendar_i.Gregorian_Date__c.year() + calendar_i.Gregorian_Date__c.month() + calendar_i.Gregorian_Date__c.day();
            if (calendar_i.business_day__c) {
                daysCounter++;
            }
            workingDaysByDate.put(dateKey, daysCounter);
        }
        System.debug('workingDaysByDate: size: ' + workingDaysByDate.size() + ' value: ' + workingDaysByDate);

        // get first apointment date key to check number of working days
        Appointment__c firstAppt = apptMap.get(appointmentIds.get(0));
        String dateKey = '' + firstAppt.Appointment_Date_Time__c.year() + firstAppt.Appointment_Date_Time__c.month() + firstAppt.Appointment_Date_Time__c.day();

        // collect existing medical aids' ids
        for (MedicalAid aid_i : data) {
            if (aid_i.ids != null) {
                for (String id_i : aid_i.ids) {
                    medicalAidIds.add(id_i);
                }
            }
        }
        System.debug('medicalAidIds: size: ' + medicalAidIds.size() + ' value: ' + medicalAidIds);

        // get existing medical aid records
        Map<Id, Medical_Aid_Appointment__c> medicalAidsMap = new Map<Id, Medical_Aid_Appointment__c>([SELECT Id, Patient__r.PersonContactId, Email_MedicalAidManager__c, Type_of_Assist__c FROM Medical_Aid_Appointment__c WHERE Id IN: medicalAidIds]);
        System.debug('medicalAidsMap: size: ' + medicalAidsMap.size() + ' value: ' + medicalAidsMap);

        System.debug('process: start');
        for (MedicalAid aid_i : data) {
            // collect all assists in single list
            assists.addAll(aid_i.assists);

            for (Integer i = 0; i < appointmentIds.size(); i++) {
                // populate record with base data
                Medical_Aid_Appointment__c obj_i = new Medical_Aid_Appointment__c(
                    Id = aid_i.ids != null ? aid_i.ids.get(i) : null,
                    Patient__c = aid_i.patientId,
                    Disabilities__c = aid_i.disabilityId,
                    Appointment__c = appointmentIds.get(i),
                    Type_of_Disability__c = aid_i.type.value,
                    OwnerId = queueByApptId.get(appointmentIds.get(i)),
                    Type_of_Assist__c = this.getValuesString(aid_i.assists)
                );

                // if more than 7 working days update records, else cancel old records and create new ones
                if (workingDaysByDate.get(dateKey) < 7) {
                    System.debug('process: working days < 7:');
                    // cancel if record exist or insert if record is new
                    if (obj_i.Id == null && obj_i.Type_of_Assist__c != null) {
                        System.debug('process: insert');
                        aidsToUpsert.add(obj_i);
                    } else if (obj_i.Id != null) {
                        // throw an error if the record has been deleted in sf or cancel an error and send an email if assist 80 was canceled
                        if (!medicalAidsMap.containsKey(obj_i.Id)) {
                            throw new LC_DisabilityControllerException(System.Label.Reload_medical_aids);
                        } else if (medicalAidsMap.get(obj_i.Id).Type_of_Assist__c != obj_i.Type_of_Assist__c) {
                            System.debug('process: cancel (' + obj_i.Id + ')');
                            aidsToUpsert.add(new Medical_Aid_Appointment__c(Id = obj_i.Id, Status__c = 'בוטל'));
                            if (this.with80Assist(medicalAidsMap.get(obj_i.Id).Type_of_Assist__c) && !this.with80Assist(obj_i.Type_of_Assist__c) && medicalAidsMap.get(obj_i.Id).Email_MedicalAidManager__c != null) {
                                System.debug('process: send email (' + obj_i.Id + ')');
                                aidsToSendEmail.add(medicalAidsMap.get(obj_i.Id));
                            }
                            // if a record is canceled but assists exist, insert a new one with these assists
                            if (obj_i.Type_of_Assist__c != null) {
                                System.debug('process: insert');
                                obj_i.Id = null;
                                aidsToUpsert.add(obj_i);
                            }
                        }
                    }
                } else {
                    System.debug('working days >= 7:');
                    // upsert if assists not null or delete if it's null and record is exist
                    if (obj_i.Type_of_Assist__c != null) {
                        System.debug('process: upsert (' + obj_i.Id + ')');
                        aidsToUpsert.add(obj_i);
                        // check a record in sf if id is not null
                        if (obj_i.Id != null) {
                            // throw an error if the record has been deleted in sf or send an email if assist 80 was canceled
                            if (!medicalAidsMap.containsKey(obj_i.Id)) {
                                throw new LC_DisabilityControllerException(System.Label.Reload_medical_aids);
                            } else if (this.with80Assist(medicalAidsMap.get(obj_i.Id).Type_of_Assist__c) && !this.with80Assist(obj_i.Type_of_Assist__c) && medicalAidsMap.get(obj_i.Id).Email_MedicalAidManager__c != null) {
                                System.debug('process: send email (' + obj_i.Id + ')');
                                aidsToSendEmail.add(medicalAidsMap.get(obj_i.Id));
                            }
                        }
                    } else if (obj_i.Id != null) {
                        System.debug('process: delete (' + obj_i.Id + ')');
                        aidsToDelete.add(obj_i);
                        // throw an error if the record has been deleted in sf or send an email if assist 80 was canceled
                        if (!medicalAidsMap.containsKey(obj_i.Id)) {
                            throw new LC_DisabilityControllerException(System.Label.Reload_medical_aids);
                        } else if (this.with80Assist(medicalAidsMap.get(obj_i.Id).Type_of_Assist__c) && medicalAidsMap.get(obj_i.Id).Email_MedicalAidManager__c != null) {
                            System.debug('process: send email (' + obj_i.Id + ')');
                            aidsToSendEmail.add(medicalAidsMap.get(obj_i.Id));
                        }
                    }
                }
            }
        }
        System.debug('process: end');

        // check 7 working days for specified assist (80)
        this.check7WorkingDaysForAssist(caseId, firstAppt, assists);
        
        // send emails if specified assist was canceled/deleted
        LC_BackendUtils.sendEmailAlert(aidsToSendEmail);

        // do dml
        System.debug('aidsToUpsert: size: ' + aidsToUpsert.size() + ' value: ' + aidsToUpsert);
        if (!aidsToUpsert.isEmpty()) {
            upsert aidsToUpsert;
        }
        System.debug('aidsToDelete: size: ' + aidsToDelete.size() + ' value: ' + aidsToDelete);
        if (!aidsToDelete.isEmpty()) {
            delete aidsToDelete;
        }

        return new Response('success');
    }

    // INNER METHODS
    private String getValuesString(List<Option> entries) {
        List<String> values = new List<String>();

        for (Option entry_i : entries) {
            if (entry_i.isSelected) {
                values.add(entry_i.value);
            }
        }

        System.debug('values: size: ' + values.size() + ' value: ' + values);
        if (!values.isEmpty()) {
            return String.join(values, ';');
        } else {
            return null;
        }
    }

    private Boolean with80Assist(String assists) {
        Boolean result = false;
        if (assists != null && assists.split(';').contains('80')) {
            result = true;
        }
        return result;
    }

    private void check7WorkingDaysForAssist(String caseId, Appointment__c appt, List<Option> entries) {
        System.debug('LC_DisabilityController.check7WorkingDaysForAssist...\ncaseId: ' + caseId + '\nappt: ' + appt + '\nentries: ' + entries);
        List<String> assists = this.getValuesString(entries) != null ? this.getValuesString(entries).split(';') : new List<String>();
        Case cas = [SELECT Id, Account.Status__c FROM Case WHERE Id =: caseId];
        Date scheduleDate = Date.valueOf(appt.Appointment_Date_time__c);

        if (
            [SELECT COUNT() FROM Calendar1__c WHERE Gregorian_Date__c >= TODAY AND Gregorian_Date__c <=: scheduleDate AND business_day__c = true] < 7 &&
            appt.RecordType.DeveloperName == 'Institutes' &&
            cas.Account.Status__c == 'פ' &&
            assists.contains('80')
        ) {
            throw new LC_DisabilityControllerException(System.Label.Translator_patient_7_business_days);
        }
    }

    // WRAPPERS
    public class MedicalAid {
        @AuraEnabled
        public List<String> ids {get;set;}
        @AuraEnabled
        public String patientId {get;set;}
        @AuraEnabled
        public String disabilityId {get;set;}
        @AuraEnabled
        public PicklistUtil.PicklistValue type {get;set;}
        @AuraEnabled
        public List<Option> assists {get;set;}

        public MedicalAid(MedicalAid pThat, Option pAssist) {
            this.ids = pThat.ids;
            this.patientId = pThat.patientId;
            this.disabilityId = pThat.disabilityId;
            this.type = pThat.type;
            this.assists = new List<Option>{pAssist};
        }

        public MedicalAid(List<String> ids, Disabilities__c disability, Set<String> assistsSelected) {
            this(disability, assistsSelected);
            this.ids = ids;
        }

        public MedicalAid(Disabilities__c disability, Set<String> assistsSelected) {
            this.disabilityId = disability.Id;
            this.patientId = disability.Patient_Account__c;
            this.type = typesMap.get(disability.Type_of_disability__c);

            this.assists = new List<Option>();
            for (String assist_i : disability.Type_of_Assist__c.split(';')) {
                if (assistsSelected.contains(assist_i)) {
                    this.assists.add(new Option(assistsMap.get(assist_i), true));
                } else {
                    this.assists.add(new Option(assistsMap.get(assist_i), false));
                }
            }
        }
    }

    public class Option {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public Boolean isSelected {get;set;}

        public Option(String pLabel, String pValue, Boolean pIsSelected) {
            this.label = pLabel;
            this.value = pValue;
            this.isSelected = pIsSelected;
        }

        public Option(PicklistUtil.PicklistValue pEntry, Boolean pIsSelected) {
            this(pEntry.label, pEntry.value, pIsSelected);
        }
    }
}