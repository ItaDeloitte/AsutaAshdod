public with sharing class AppointmentReminderDateBatch implements Database.Batchable<sObject> {

    private String query;

    public AppointmentReminderDateBatch() {}

    public AppointmentReminderDateBatch(String pQuery) {
        this.query = pQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('AppointmentReminderDateBatch.start ... ');
        if (this.query != null) {
            return Database.getQueryLocator(query);
        }

        return Database.getQueryLocator([
            SELECT Medical_Procedure__c
                 , Appointment_Date_Time__c
                 , sendingByWhatsApp__c
                 , Site_Code__c
                 , Remainder_type__c
                 , Remainder_time__c
                 , Date_for_human_reminder__c
                 , Date_for_tizkorit_reminder__c
                 , dateRemainder1WA__c
                 , dateRemainder2WA__c
              FROM Appointment__c
             WHERE Remainder_time__c >= TODAY
               AND Remainder_type__c = 'WhatsApp'
               AND Appointment_Status__c = 'וידוא הגעה לפגישה'
          ORDER BY Appointment_Date_Time__c]);
    }

    public void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('AppointmentReminderDateBatch.execute ... ');
        System.debug('DATAFIX appointmentList [' + scope.size() + ']: ' + scope);
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();
        Map<Id, Map<String, Map<String, Date>>> debugMap = new Map<Id, Map<String, Map<String, Date>>>();

        for (Appointment__c appointment_i : scope) {
            if (!debugMap.containsKey(appointment_i.Id)) {
                debugMap.put(appointment_i.Id, new Map<String, Map<String, Date>>{
                    'Remainder_time__c' => new Map<String, Date>{'old' => appointment_i.Remainder_time__c},
                    'Date_for_tizkorit_reminder__c' => new Map<String, Date>{'old' => appointment_i.Date_for_tizkorit_reminder__c},
                    'Date_for_human_reminder__c' => new Map<String, Date>{'old' => appointment_i.Date_for_human_reminder__c},
                    'dateRemainder1WA__c' => new Map<String, Date>{'old' => appointment_i.dateRemainder1WA__c},
                    'dateRemainder2WA__c' => new Map<String, Date>{'old' => appointment_i.dateRemainder2WA__c}});
            }
            appointment_i.dateRemainder1WA__c = null;
            appointment_i.dateRemainder2WA__c = null;
            appointment_i.Remainder_time__c = null;
            appointment_i.Date_for_human_reminder__c = null;
            appointment_i.Date_for_tizkorit_reminder__c = null;
        }

        // run the trigger method to execute the same logic
        AppointmentTriggerDispatcher.updateReminderDate(scope, null);

        for (Appointment__c appointment_i : scope) {
            if (appointment_i.dateRemainder1WA__c != null || appointment_i.dateRemainder2WA__c != null) {
                appointmentToUpdateList.add(appointment_i);

                debugMap.get(appointment_i.Id).get('Remainder_time__c').put('new', appointment_i.Remainder_time__c);
                debugMap.get(appointment_i.Id).get('Date_for_tizkorit_reminder__c').put('new', appointment_i.Date_for_tizkorit_reminder__c);
                debugMap.get(appointment_i.Id).get('Date_for_human_reminder__c').put('new', appointment_i.Date_for_human_reminder__c);
                debugMap.get(appointment_i.Id).get('dateRemainder1WA__c').put('new', appointment_i.dateRemainder1WA__c);
                debugMap.get(appointment_i.Id).get('dateRemainder2WA__c').put('new', appointment_i.dateRemainder2WA__c);
            } else {
                debugMap.remove(appointment_i.Id);
            }
        }
        System.debug('DATAFIX appointmentToUpdateList [' + appointmentToUpdateList.size() + ']: ' + appointmentToUpdateList);

        // update records with allOrNothing false
        AsyncUtil.doUpdate(appointmentToUpdateList);

        for (Id id_i : debugMap.keySet()) {
            for (String field_j : debugMap.get(id_i).keySet()) {
                System.debug('DATAFIX ' + id_i + ' ' + field_j + ' '
                    + debugMap.get(id_i).get(field_j).get('old') + ' => ' + debugMap.get(id_i).get(field_j).get('new'));
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('AppointmentReminderDateBatch.finish ... ');
    }
}