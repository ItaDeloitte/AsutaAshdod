// Test: LC_CaseExpertiseTest
public class LC_CaseExpertise implements ILCController {

    public class LC_CaseExpertiseException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getExpertises' {
                return this.getExpertises((String) params.get('expertiseName'));
            }
            when 'getSubExpertises'{
                return this.getSubExpertises((String) params.get('expertiseId'), (String) params.get('subExpertiseName'));
            }
            when 'getProcedures'{
                return this.getProcedures((String) params.get('subExpertiseId'), (String) params.get('procedureName'));
            }
            when 'setExpertises'{
                return this.setExpertises((String) params.get('caseId'), (String) params.get('expertiseId'), (String) params.get('subExpertiseId'), (String) params.get('procedureId'));
            }
            when else {
                throw new LC_CaseExpertiseException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response getExpertises(String expertiseName) {
        System.debug('LC_CaseExpertise.getExpertises...\nexpertiseName: ' + expertiseName);
        expertiseName = '%' + expertiseName + '%';

        List<Expertise__c> expertises = [SELECT Id, Name FROM Expertise__c WHERE Name LIKE :expertiseName LIMIT 10];
        System.debug('success\nexpertises' + expertises);
        return new Response(expertises);
    }

    private Response getSubExpertises(String expertiseId, String subExpertiseName) {
        System.debug('LC_CaseExpertise.getSubExpertises...\nexpertiseId: ' + expertiseId + ' subExpertiseName: ' + subExpertiseName);
        subExpertiseName = '%' + subExpertiseName + '%';

        List<Sub_Expertise__c> subExpertises = [SELECT Id, Name FROM Sub_Expertise__c WHERE Expertise__c = :expertiseId AND Name LIKE :subExpertiseName LIMIT 10];
        System.debug('success\nsubExpertises' + subExpertises);
        return new Response(subExpertises);
    }

    private Response getProcedures(String subExpertiseId, String procedureName) {
        System.debug('LC_CaseExpertise.getProcedures...\nsubExpertiseId: ' + subExpertiseId + ' procedureName: ' + procedureName);
        procedureName = '%' + procedureName + '%';

        List<Medical_Procedure__c> procedures = [SELECT Id, Name FROM Medical_Procedure__c WHERE Sub_Expertise__c = :subExpertiseId AND Name LIKE :procedureName LIMIT 10];
        System.debug('success\nprocedures' + procedures);
        return new Response(procedures);
    }

    private Response setExpertises(String caseId, String expertiseId, String subExpertiseId, String procedureId) {
        System.debug('LC_CaseExpertise.setExpertises...\ncaseId: ' + caseId + ' expertiseId: ' + expertiseId + ' subExpertiseId: ' + subExpertiseId + ' procedureId: ' + procedureId);

        Case cas = [SELECT Id, Expertise__c, Sub_Expertise__c, Medical_Procedure__c FROM Case WHERE Id = :caseId];
        cas.Expertise__c = String.isBlank(expertiseId) ? null : expertiseId;
        cas.Sub_Expertise__c = String.isBlank(subExpertiseId) ? null : subExpertiseId;
        cas.Medical_Procedure__c = String.isBlank(procedureId) ? null : procedureId;
        update cas;
        System.debug('success\ncas' + cas);
        return new Response(cas);
    }
}