// Test: CaseServicesTest
// Created: Evgeniy Kravchuk
trigger CaseTrigger on Case (before insert, after insert, before update, after update, after delete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('Case') && !(UserInfo.getProfileId() == System.Label.CaseTriggerDeactivateProfiles) || Test.isRunningTest()) {
        //CaseTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
        new CaseTriggerHandler().run();
    }
}