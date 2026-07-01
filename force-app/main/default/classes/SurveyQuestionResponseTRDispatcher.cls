/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Survey Question Response Apex Trigger Dispatcher class
 *
 * Test                 SurveyQuestionResponseTRTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             18-04-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class SurveyQuestionResponseTRDispatcher {

    /**
     * Mirroring the Taker's Fill Percentage into the related Appointment record
     */
    public static void mirrorPercentage(List<SurveyQuestionResponse__c> newList, Map<Id, SurveyQuestionResponse__c> oldMap) {
        System.debug('TR SurveyQuestionResponse__c mirrorPercentage ... start');
        Set<Id> takerIdSet = new Set<Id>();

        for (SurveyQuestionResponse__c res_i : newList) {
            if (res_i.SurveyTaker__c != null
                    && (res_i.UnShow__c != oldMap.get(res_i.Id).UnShow__c
                        || res_i.IsAnswered__c != oldMap.get(res_i.Id).IsAnswered__c
                        || res_i.IsGroupHeadline__c != oldMap.get(res_i.Id).IsGroupHeadline__c)) {
                takerIdSet.add(res_i.SurveyTaker__c);
            }
        }
        System.debug('takerIdSet: size: ' + takerIdSet.size() + ' value: ' + takerIdSet);

        if (!takerIdSet.isEmpty()) {
            SurveyQuestionResponseTRService.mirrorPercentage(takerIdSet);
            System.debug('TR SurveyQuestionResponse__c mirrorPercentage ... future');
        }
    }

    public static void resetSendingRIS(List<SurveyQuestionResponse__c> newList, Map<Id, SurveyQuestionResponse__c> oldMap){
        System.debug('TR SurveyQuestionResponse__c mirrorPercentage ... start');
        Set<Id> takerIdSet = new Set<Id>();

        for (SurveyQuestionResponse__c res_i : newList) {
            if (res_i.SurveyTaker__c != null) {
                takerIdSet.add(res_i.SurveyTaker__c);
            }
        }
        System.debug('takerIdSet: size: ' + takerIdSet.size() + ' value: ' + takerIdSet);

        if (!takerIdSet.isEmpty()) {
            SurveyQuestionResponseTRService.resetSendingRIS(takerIdSet);
            System.debug('TR SurveyQuestionResponse__c resetSendingRIS');
        }
    }
}