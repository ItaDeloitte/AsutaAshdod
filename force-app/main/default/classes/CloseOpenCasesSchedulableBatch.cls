public class CloseOpenCasesSchedulableBatch implements Database.Batchable<sObject>, Schedulable{

    //Id appointmentsRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
    Id docExpertRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DOC_expert').getRecordTypeId();

    Boolean runCreateAgentSurvey = true;

    String query = 'SELECT Id'
                      + ', Status'
                  + ' FROM Case'
                 + ' WHERE RecordTypeId =:docExpertRT'
                   + ' AND Case_subject__c = \'זימון רופא מומחה\''
                   + ' AND sub_case_subject__c = \'זימון תור לאחר המלצה\''
                   + ' AND Status IN (\'In_Progress\', \'New\')';

    //   + ' WHERE RecordTypeId = :appointmentsRT'
    //   + ' AND Case_subject__c = \'זימון תור חדש\''
    //   + ' AND sub_case_subject__c = \'זימון תור חדש\''
    public CloseOpenCasesSchedulableBatch() {
        this(true);
    }

    public CloseOpenCasesSchedulableBatch(String query) {
        this.query = query;
    }

    public CloseOpenCasesSchedulableBatch(Boolean runCreateAgentSurvey) {
        this.runCreateAgentSurvey = runCreateAgentSurvey;
        this.query += this.runCreateAgentSurvey ? ' AND CreatedDate = TODAY' : ' AND CreatedDate != TODAY';
        this.query += ' ORDER BY CreatedDate DESC LIMIT 10000';
    }

    public CloseOpenCasesSchedulableBatch(Boolean runCreateAgentSurvey, String query) {
        this.runCreateAgentSurvey = runCreateAgentSurvey;
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CloseOpenCasesSchedulableBatch.start ...');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('CloseOpenCasesSchedulableBatch.execute ...');
        CaseTriggerDispatcher.createAgentSurveyIsFirstRun = this.runCreateAgentSurvey;

        for (Case case_i : scope) {
            case_i.Status = 'Closed';
        }

        AsyncUtil.doUpdate(scope);
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('CloseOpenCasesSchedulableBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CloseOpenCasesSchedulableBatch(this.runCreateAgentSurvey), 25);
    }
}