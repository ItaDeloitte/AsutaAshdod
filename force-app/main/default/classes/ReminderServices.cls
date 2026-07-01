//ws_TizkuritTest
public class ReminderServices {

    public static void sendUpdateRemindStatus(Set<Id> reminderIds) {
        System.debug('ReminderServices.sendUpdateRemindStatus...');
        List<Reminder__c> reminders = [SELECT Id, Accession_Number__c, Reminder_Status__c FROM Reminder__c WHERE Id IN: reminderIds];
        List<String> messBodiestLst = new List<String>();

        for (Integer i = 0; i < reminders.size(); i++) {
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeStringField('accessionNumber', reminders[i].Accession_Number__c);
            jsGen.writeStringField('followUpTypeCode', reminders[i].Reminder_Status__c);
            jsGen.writeEndObject();

            messBodiestLst.add(jsGen.getAsString());
            if (Math.mod(i + 1, 100) == 0) {
                checkLimit(messBodiestLst);
                messBodiestLst.clear();
            } else if (i + 1 == reminders.size()) {
                checkLimit(messBodiestLst);
            }
        }
    }

    public static void checkLimit(List<String> messLst) {
        //check to ensure a callout can be performed using the Limits class. 
        //This is 100 callouts per execution as of Spring 16 release
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
            System.debug('Maximum number of callouts has been reached.');
        } else {
            Id jobID = System.enqueueJob(new ws_UpdateRemindStatus(messLst));
        }
    }

/*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Replacement of the 'קבלת תשובה מתזכורית' process builder
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
    * @created          27-07-2020
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void receiveAnswer(List<Reminder__c> reminders, Set<Id> apptIds) {
        System.debug('ReminderServices.receiveAnswer...');
        Map<Id, Appointment__c> apptsMap = new Map<Id, Appointment__c>([SELECT Id, Appointment_Status__c, Remainder_status__c, Remainder_type__c, Date_for_human_reminder__c
                                                                        FROM Appointment__c WHERE Id IN: apptIds AND Remainder_status__c != 'השיב להודעה בשלילה' AND Remainder_status__c != 'השיב להודעה בחיוב']);
        List<Appointment__c> appts = new List<Appointment__c>();
        Set<Id> apptIdsToCancel = new Set<Id>();
        Set<Id> apptIdsForCheck = new Set<Id>();
        System.debug('apptsMap: size: ' + apptsMap.size() + ' value: ' + apptsMap);

        for (Reminder__c reminder_i : reminders) {
            if (!apptsMap.containsKey(reminder_i.Appointment__c) || apptIdsForCheck.contains(reminder_i.Appointment__c)) {
                continue;
            }
            Appointment__c appt_i = apptsMap.get(reminder_i.Appointment__c);

            switch on reminder_i.Reminder_Status__c {
                // answered in the affirmative
                when '1' {
                    appt_i.Appointment_Status__c = 'WaitingForAppointment';
                    appt_i.Remainder_status__c = 'השיב להודעה בחיוב';
                    appt_i.Remainder_type__c = 'תזכורית';
                    apptIdsForCheck.add(appt_i.Id);
                    appts.add(appt_i);
                }
                // answered in the negative
                when '2' {
                    appt_i.Remainder_status__c = 'השיב להודעה בשלילה';
                    appt_i.Remainder_type__c = 'תזכורית';
                    apptIdsToCancel.add(appt_i.Id);
                    apptIdsForCheck.add(appt_i.Id);
                    appts.add(appt_i);
                }
                // did not answer
                /*when '3', '4', '5', '6', '7', '8', '9' {
                    if (appt_i.Date_for_human_reminder__c != null) {
                        appt_i.Remainder_status__c = 'אין מענה';
                        appt_i.Remainder_type__c = 'אנושי';
                        apptIdsForCheck.add(appt_i.Id);
                        appts.add(appt_i);
                    }
                }*/
                // transferred to the hotline
                /*when '10' {
                    appt_i.Remainder_status__c = 'אין מענה';
                    apptIdsForCheck.add(appt_i.Id);
                    appts.add(appt_i);
                }*/
            }
        }
        System.debug('appts: size: ' + appts.size() + ' value: ' + appts);
        System.debug('apptIdsForCheck: size: ' + apptIdsForCheck.size() + ' value: ' + apptIdsForCheck);
        System.debug('apptIdsToCancel: size: ' + apptIdsToCancel.size() + ' value: ' + apptIdsToCancel);

        if (!appts.isEmpty()) {
            update appts;
        }
        if (!apptIdsToCancel.isEmpty()) {
            CancelApptInFuture.execute(apptIdsToCancel, '5', 'ביטול המטופל');
        }
    }
}