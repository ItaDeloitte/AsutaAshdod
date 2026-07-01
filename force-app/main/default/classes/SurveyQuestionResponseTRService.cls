/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Survey Question Response Apex Trigger Service class
 *
 * Test                 SurveyQuestionResponseTRTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             18-04-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class SurveyQuestionResponseTRService {

    @future(callout=true)
    public static void mirrorPercentage(Set<Id> takerIdSet) {
        System.debug('TR SurveyQuestionResponse__c mirrorPercentage ... future');
        List<Appointment__c> appointmentToUpdateList = new List<Appointment__c>();

        List<SurveyTaker__c> takerList = [
            SELECT Appointment__c
                 , Fill_Percentage__c
              FROM SurveyTaker__c
             WHERE Id IN :takerIdSet
               AND Appointment__c != null
               AND SurveyCode__c = 'PreSurgery'];
        System.debug('takerList: size: ' + takerList.size() + ' value: ' + takerList);

        for (SurveyTaker__c taker_i : takerList) {
            appointmentToUpdateList.add(
                new Appointment__c(
                    Id = taker_i.Appointment__c,
                    PercentageOfCompletion__c = taker_i.Fill_Percentage__c.toPlainString()));
        }
        System.debug('appointmentToUpdateList: size: ' + appointmentToUpdateList.size() + ' value: ' + appointmentToUpdateList);

        if (!appointmentToUpdateList.isEmpty()) {
            update appointmentToUpdateList;
            System.debug('TR SurveyQuestionResponse__c mirrorPercentage ... executed');
        }
    }

    public static void resetSendingRIS(Set<Id> takerIdSet){
        System.debug('TR SurveyQuestionResponse__c resetSendingRIS');
        List<SurveyTaker__c> surveyToUpdateList = new List<SurveyTaker__c>();

        List<SurveyTaker__c> takerList = [
            SELECT SendTime__c, IsSent__c
            FROM SurveyTaker__c
            WHERE Id IN :takerIdSet
            AND Appointment__c != null];
        System.debug('takerList: size: ' + takerList.size() + ' value: ' + takerList);

        for (SurveyTaker__c taker_i : takerList) {
            taker_i.SendTime__c = null;
            taker_i.IsSent__c = false;
            surveyToUpdateList.add(taker_i);
        }
        System.debug('surveyToUpdateList: size: ' + surveyToUpdateList.size() + ' value: ' + surveyToUpdateList);

        if (!surveyToUpdateList.isEmpty()) {
            update surveyToUpdateList;
            System.debug('TR SurveyQuestionResponse__c resetSendingRIS ... executed');
        }
    }
}