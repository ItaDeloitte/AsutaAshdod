trigger Implants_mp_aptTrigger on Implants_mp_apt__c (before insert, after insert, before update, after update) {

    Implants_mp_aptTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);

}