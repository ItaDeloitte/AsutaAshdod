/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Ris Status event Apex Trigger Dispatcher class
 *
 * Test                 ws_RisStatusesTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             12-05-22          <ortalk@assuta.co.il>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */

public with sharing class RisStatusTriggerDispatcher {

    public static void updateStatus(List<RisStatus__e> statuses) {
        System.debug('RisStatusTriggerDispatcher.updateStatus....');
        Map<String, RisStatus__e> accNumToEvents = new Map<String, RisStatus__e>();    
        Map<String, Id> recTypeToRecommend = new Map<String, Id>();
        Map<String, List<Recommendations_after_exam__c>> recExamToRecommend = new Map<String, List<Recommendations_after_exam__c>>();
        List<Recommendations_after_exam__c> recoAfterExamToIns = new List<Recommendations_after_exam__c>();
        List<Recommendations_after_exam__c> recoAfterExamToUpt = new List<Recommendations_after_exam__c>();        
        Set<String> recoCodes = new Set<String>();        
        Integer counter = 0;
        
        for (RisStatus__e status : statuses) {
            counter++;
            if(status.AnswerStatus__c != null && status.RecommendationCode__c != null && status.AnswerStatus__c == '6' ) {               
                recoCodes.add(status.RecommendationCode__c);                
            }
            accNumToEvents.put(status.AccessionNumber__c, status);
            
            if (counter > 200) {
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(status.ReplayId);
                break;
            }            
        }
		
        System.debug('recoCodes.size: ' + recoCodes.size() + 'value' + recoCodes);
        System.debug('accNumToEvents.size: ' + accNumToEvents.size() + 'value' + accNumToEvents);
        for (RecommendationsTypeAfterExam__c recType :[SELECT Id, RecommendationType__c 
                                                      FROM RecommendationsTypeAfterExam__c 
                                                      WHERE RecommendationType__c IN :recoCodes]) {
            if(!recTypeToRecommend.containsKey(recType.RecommendationType__c)){
                recTypeToRecommend.put(recType.RecommendationType__c, recType.Id);
            }            
        }
        
        for(Recommendations_after_exam__c recExam :[SELECT Id, RecommendationsType__c, Related_Appointment__c, Related_Appointment__r.Accession_Number__c  
                                                    FROM Recommendations_after_exam__c 
                                                    WHERE Related_Appointment__r.Accession_Number__c IN :accNumToEvents.keySet() Order By CreatedDate desc]) {
            if (!recExamToRecommend.containsKey(recExam.Related_Appointment__r.Accession_Number__c)) {
                recExamToRecommend.put(recExam.Related_Appointment__r.Accession_Number__c, new List<Recommendations_after_exam__c>());
            }
            recExamToRecommend.get(recExam.Related_Appointment__r.Accession_Number__c).add(recExam);
        }
        System.debug('recExamToRecommend.size: ' + recExamToRecommend.size() + 'value' + recExamToRecommend);
        List<Appointment__c> appts = [SELECT Id, Accession_Number__c FROM Appointment__c WHERE Accession_Number__c IN :accNumToEvents.keySet()];      
        Boolean isUpdate;
        Id recAfterExamId;
        
        System.debug('Got Here!!!');
        for (Appointment__c app : appts) {            
            RisStatus__e status =  accNumToEvents.get(app.Accession_Number__c);            
            if (status.AnswerStatus__c != null && status.AnswerStatus__c == '6' && (status.HasFinding__c != null || status.Birad__c != null)) {
                //check if exists record of Recommendations_after_exam__c that related to appointment
                if (recExamToRecommend.containsKey(status.AccessionNumber__c)) { 
                    //check if Recommendation Code in Recommendations_after_exam__c equal to RecommendationCode in new status
                    isUpdate = false;
                    recAfterExamId = null;
                    for (Recommendations_after_exam__c recAfterExam :recExamToRecommend.get(status.AccessionNumber__c)) {
                        if (recTypeToRecommend.containsKey(status.RecommendationCode__c) && recAfterExam.RecommendationsType__c == recTypeToRecommend.get(status.RecommendationCode__c)) {
                            isUpdate = true;
                            recAfterExamId = recAfterExam.Id;
                        }
                    }
                    if (isUpdate && recAfterExamId != null) {
                        recoAfterExamToUpt.add(new Recommendations_after_exam__c(
                                                Id = recAfterExamId,
                                                BIRAD__c=  status.Birad__c,                                               
                                                pathologic_found__c = status.HasFinding__c,
                                                Recommend_Desc__c = status.RecommendationDescription__c 
                                                ));
                    } else { // Recommendation Code in Recommendations_after_exam__c not equal to RecommendationCode in new status
                        recoAfterExamToIns.add(createRecommAfterExam(app.Id, status, recTypeToRecommend));
                    }
                // not exists record of Recommendations_after_exam__c that related to appointment
                } else if(recTypeToRecommend.containsKey(status.RecommendationCode__c)) {                     
                        recoAfterExamToIns.add(createRecommAfterExam(app.Id, status, recTypeToRecommend));                       
                }                                   
            }                                
        }
        System.debug('recoAfterExamToIns.size: ' +recoAfterExamToIns.size() + 'value' + recoAfterExamToIns);
        System.debug('recoAfterExamToUpt.size: ' +recoAfterExamToUpt.size() + 'value' + recoAfterExamToUpt);               
        if (!recoAfterExamToIns.isEmpty()) {
            insert recoAfterExamToIns;
        }
        if (!recoAfterExamToUpt.isEmpty()) {
            update recoAfterExamToUpt;
        }        
    }   
    
    private static Recommendations_after_exam__c createRecommAfterExam (Id appId, RisStatus__e status, Map<String, Id> recTypeToRecommend) {
        return new Recommendations_after_exam__c (
            RecordTypeId = Schema.SObjectType.Recommendations_after_exam__c.getRecordTypeInfosByDeveloperName().get('Memo').getRecordTypeId(),
            Related_Appointment__c = appId,
            RecommendationNumber__c = status.RecommendationCode__c,
            RecommendationsType__c = recTypeToRecommend.get(status.RecommendationCode__c),
            BIRAD__c=  status.Birad__c,
            Type_of_recommendation__c = 'Breast',
            pathologic_found__c = status.HasFinding__c,
            Recommend_Desc__c = status.RecommendationDescription__c 
            );
    }
}