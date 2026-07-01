// Test: ChatTranscriptServiceTest
trigger ChatTranscriptTrigger on LiveChatTranscript (before insert, before update, after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('LiveChatTranscript')){
        ChatTranscriptTriggerHandller.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}