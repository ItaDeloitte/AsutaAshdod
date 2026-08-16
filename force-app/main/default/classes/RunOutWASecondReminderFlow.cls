global class RunOutWASecondReminderFlow implements Schedulable {
    global void execute(SchedulableContext SC) {
        new Flow.Interview.Outbound_WA_for_MRI_second_reminder(new Map<String, Object>()).start();
    }
}