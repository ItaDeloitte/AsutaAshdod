// Test: LC_RecommendExamCaseTest
public class LC_RecommendExamCase implements ILCController {

    public class LC_RecommendExamCaseException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainCases' {
                return this.obtainCases((String) params.get('recordId'), (String) params.get('keyWord'));
            }
            when 'setCase'{
                return this.setCase((String) params.get('recordId'), (String) params.get('caseId'));
            }
            when 'getCase'{
                return this.getCase((String) params.get('recordId'));
            }
            when else {
                throw new LC_RecommendExamCaseException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainCases(String recordId, String keyWord) {
        System.debug('LC_RecommendExamCase.obtainCases...\nrecordId: ' + recordId + ' keyWord: ' + keyWord);
        Recommendations_after_exam__c recommendation = [SELECT Id, Patient__c FROM Recommendations_after_exam__c WHERE Id =: recordId];
        keyWord = '%' + keyWord + '%';

        List<Case> cases = [SELECT Id, CaseNumber FROM Case WHERE RecordType.DeveloperName = 'Assuta_360' AND AccountId =: recommendation.Patient__c AND CaseNumber LIKE :keyWord ORDER BY CaseNumber DESC];
        System.debug('success\ncases' + cases);
        return new Response(cases);
    }

    private Response setCase(String recordId, String caseId) {
        System.debug('LC_RecommendExamCase.setCase...\nrecordId: ' + recordId + ' caseId: ' + caseId);
        Recommendations_after_exam__c recommendation = new Recommendations_after_exam__c(Id = recordId);
        if (String.isBlank(caseId)) {
            recommendation.Case360__c = null;
            recommendation.Status_recommendation__c = 'חדש';
        } else {
            recommendation.Case360__c = caseId;
            recommendation.Status_recommendation__c = 'הומר לאירוע קיים';
        }
        update recommendation;
        System.debug('success\nrecommendation ' + recommendation);
        return new Response('success');
    }

    private Response getCase(String recordId) {
        System.debug('LC_RecommendExamCase.getCase...\nrecordId: ' + recordId);
        Recommendations_after_exam__c recommendation = [SELECT Id, Case360__c FROM Recommendations_after_exam__c WHERE Id =: recordId];
        Case cas = new Case();
        if (String.isNotBlank(recommendation.Case360__c)) {
            cas = [SELECT Id, CaseNumber FROM Case WHERE Id =: recommendation.Case360__c];
        }
        System.debug('success\ncas ' + cas);
        return new Response(cas);
    }
}