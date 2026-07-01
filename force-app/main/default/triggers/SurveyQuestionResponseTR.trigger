/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Test                 SurveyQuestionResponseTRTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             18-04-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
trigger SurveyQuestionResponseTR on SurveyQuestionResponse__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SurveyQuestionResponseTRHandler.handleTrigger(Trigger.new, Trigger.oldMap);
}