global class RunOutWAFirstReminderFlow implements Schedulable {
    global void execute(SchedulableContext SC) {
        new Flow.Interview.Outbound_WA_for_MRI_first_reminder(new Map<String, Object>()).start();
    }
}