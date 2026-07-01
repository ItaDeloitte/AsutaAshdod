//Test: AppointmentTriggerServiceTest
trigger AppointmentTrigger on Appointment__c (before insert, before update, after insert, after update) {

    public static Map<String, Set<Id>> methodToApptIdsMap = new Map<String, Set<Id>>();

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('Appointment__c')) {
        Map<String, List<Appointment__c>> rtIdToApptsMap = sortAppointments();

        if (!rtIdToApptsMap.get(AppointmentTriggerUtil.INSTITUTES_RT_ID).isEmpty()) {
            System.debug('TR Appointment__c INSTITUTES');
            InstitutesTRHandler.handleTrigger(rtIdToApptsMap.get(AppointmentTriggerUtil.INSTITUTES_RT_ID), Trigger.oldMap);
        }

        if (!rtIdToApptsMap.get(AppointmentTriggerUtil.SURGERIES_RT_ID).isEmpty()) {
            System.debug('TR Appointment__c SURGERIES');
            SurgeriesTRHandler.handleTrigger(rtIdToApptsMap.get(AppointmentTriggerUtil.SURGERIES_RT_ID), Trigger.oldMap);
        }

        if (!rtIdToApptsMap.get(AppointmentTriggerUtil.EXPERTS_RT_ID).isEmpty()) {
            System.debug('TR Appointment__c EXPERTS');
            ExpertsTRHandler.handleTrigger(rtIdToApptsMap.get(AppointmentTriggerUtil.EXPERTS_RT_ID), Trigger.oldMap);
        }

        if (!rtIdToApptsMap.get(null).isEmpty()) {
            System.debug('TR Appointment__c ANY');
            AppointmentTriggerHandler.handleTrigger(rtIdToApptsMap.get(null), Trigger.oldMap);
        }
    }

    private static Map<String, List<Appointment__c>> sortAppointments() {
        Map<String, List<Appointment__c>> rtIdToApptsMap = new Map<String, List<Appointment__c>>{
            AppointmentTriggerUtil.INSTITUTES_RT_ID => new List<Appointment__c>(),
            AppointmentTriggerUtil.SURGERIES_RT_ID => new List<Appointment__c>(),
            AppointmentTriggerUtil.EXPERTS_RT_ID => new List<Appointment__c>(),
            null => new List<Appointment__c>()
        };

        for (Appointment__c appt_i : Trigger.new) {
            if (rtIdToApptsMap.containsKey(appt_i.RecordTypeId)) {
                rtIdToApptsMap.get(appt_i.RecordTypeId).add(appt_i);
            } else {
                rtIdToApptsMap.get(null).add(appt_i);
            }
        }

        return rtIdToApptsMap;
    }
}