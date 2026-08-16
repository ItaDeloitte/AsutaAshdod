// Test: RecommendExamServicesTest
public class RecommendExamServices {

    public static void convertRecommendation(List<Recommendations_after_exam__c> recommendWithType, Set<Id> recommendTypeIds) {
        System.debug('RecommendExamServices.convertRecommendation...');
        Map<Id, RecommendationsTypeAfterExam__c> recommendTypeMap = new Map<Id, RecommendationsTypeAfterExam__c>([SELECT Id, action_type__c FROM RecommendationsTypeAfterExam__c WHERE Id IN: recommendTypeIds]);
        Set<Id> recommendationsIds = new Set<Id>();

        System.debug('recommendTypeMap: size: ' + recommendTypeMap.size() + ' value: ' + recommendTypeMap);
        for (Recommendations_after_exam__c recommendation_i : recommendWithType) {
            if (recommendTypeMap.containsKey(recommendation_i.RecommendationsType__c) && recommendTypeMap.get(recommendation_i.RecommendationsType__c).action_type__c == 'אוטומציה פתיחת קייס') {
                recommendationsIds.add(recommendation_i.Id);
            }
        }

        System.debug('recommendationsIds: size: ' + recommendationsIds.size() + ' value: ' + recommendationsIds);
        if (!recommendationsIds.isEmpty()) {
            LC_Case360Controller controller = new LC_Case360Controller();
            controller.convertRecommendation([SELECT Id,
                                                     Status_recommendation__c,
                                                     Case360__c,
                                                     Patient__c,
                                                     who_treat__c,
                                                     Related_Appointment__c,
                                                     Related_Appointment__r.Patient_Account__c,
                                                     Related_Appointment__r.after_appointment__c,
                                                     Related_Appointment__r.Medical_Procedure__r.Procedure_Code__c,
                                                     Referral_Doctor__c,
                                                     Referral_Doctor__r.Expertise_1__c,
                                                     Referral_Doctor__r.Expertise_2__c,
                                                     Referral_Doctor__r.Expertise_1__r.Expertise_Code__c,
                                                     Referral_Doctor__r.Expertise_2__r.Expertise_Code__c,
                                                     RecordType.Name
                                              FROM Recommendations_after_exam__c
                                              WHERE Id IN: recommendationsIds
                                              AND who_treat__c = 'מוקד'], true);
        }
    }
}