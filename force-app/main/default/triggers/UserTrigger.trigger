//Test: UserTriggerDispatcherTest
trigger UserTrigger on User (before insert, after insert, before update, after update) {

     TriggerSetting triggerObj = TriggerSetting.getInstance();
     if(TriggerSetting.isTriggerActive('User')){
          UserTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.newMap, Trigger.operationType);
     }
}