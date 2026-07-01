//ws_TizkuritTest
public class ReminderTriggerDispatcher {

    public static void updateReminderStatus(List<Reminder__c> newList, Map<Id, Reminder__c> oldMap) {
        System.debug('ReminderTriggerDispatcher.updateReminderStatus...');
        Id integrationProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Integration Profile' LIMIT 1].Id;
        System.debug('User.ProfileId: ' + UserInfo.getProfileId());

        if (UserInfo.getProfileId() != integrationProfileId) {
            Set<Id> reminderIds = new Set<Id>();

            for (Reminder__c reminder_i : newList) {
                if (reminder_i.Reminder_Status__c != null && oldMap.get(reminder_i.Id).Reminder_Status__c != reminder_i.Reminder_Status__c) {
                    reminderIds.add(reminder_i.Id);
                }
            }
            System.debug('reminderIds: size: ' + reminderIds.size() + ' value: ' + reminderIds);

            if (!reminderIds.isEmpty()) {
                ReminderServices.sendUpdateRemindStatus(reminderIds);
            }
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
    public static void receiveAnswer(List<Reminder__c> newList, Map<Id, Reminder__c> oldMap) {
        System.debug('ReminderTriggerDispatcher.receiveAnswer...');
        Set<String> statuses = new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
        List<Reminder__c> reminders = new List<Reminder__c>();
        Set<Id> apptIds = new Set<Id>();

        for (Reminder__c reminder_i : newList) {
            if (
                reminder_i.Appointment__c != null &&
                statuses.contains(reminder_i.Reminder_Status__c) &&
                (
                    oldMap == null ||
                    oldMap.get(reminder_i.Id).Appointment__c != reminder_i.Appointment__c ||
                    oldMap.get(reminder_i.Id).Reminder_Status__c != reminder_i.Reminder_Status__c
                )
            ) {
                apptIds.add(reminder_i.Appointment__c);
                reminders.add(reminder_i);
            }
        }
        System.debug('apptIds: size: ' + apptIds.size() + ' value: ' + apptIds);
        System.debug('reminders: size: ' + reminders.size() + ' value: ' + reminders);

        if (!reminders.isEmpty()) {
            ReminderServices.receiveAnswer(reminders, apptIds);
        }
    }
}