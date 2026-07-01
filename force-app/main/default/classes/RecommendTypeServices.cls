// Test: RecommendTypeServicesTest
public class RecommendTypeServices {

    public static void convertRecommendation(Set<Id> recommendTypeIds) {
        System.debug('RecommendTypeServices.convertRecommendation...');
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
                                        WHERE RecommendationsType__c IN: recommendTypeIds
                                        AND Related_Appointment__c != null
                                        AND Related_Appointment__r.Already_received_recom__c = false
                                        AND who_treat__c = 'מוקד'], true);
    }
}