/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Survey Question Response Apex Trigger Handler class
 *
 * Test                 SurveyQuestionResponseTRTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             18-04-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class SurveyQuestionResponseTRHandler {

    public static void handleTrigger(List<SurveyQuestionResponse__c> newList, Map<Id, SurveyQuestionResponse__c> oldMap) {
        switch on Trigger.operationType {
            when AFTER_INSERT {
                SurveyQuestionResponseTRDispatcher.resetSendingRIS(newList, oldMap);
                System.debug('TR SurveyQuestionResponse__c AFTER_INSERT');
            }
            when AFTER_UPDATE {
                System.debug('TR SurveyQuestionResponse__c AFTER_UPDATE');
                SurveyQuestionResponseTRDispatcher.resetSendingRIS(newList, oldMap);
                if (!System.isFuture() && !System.isBatch()) {
                    SurveyQuestionResponseTRDispatcher.mirrorPercentage(newList, oldMap);
                }
            }
        }
    }
}