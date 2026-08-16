// Test: LC_CaseQueueTest
// Created: Evgeniy Kravchuk
// Date: 12.02.2020
public class LC_CaseQueue implements ILCController {

    public class LC_CaseQueueException extends Exception {}

    private static final Id TRANSFER_RT_ID = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('transfer_to_secretaries').getRecordTypeId();
    private static final Set<String> PROFILE_NAME_SET = new Set<String>{
        'Agent', 'Agent 360', 'Manager', 'Marketing', 'Marketing (NEW)', 'Senior Agent', 'Survey-Agent', 'TelleAll Agent'};

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainQueues' {
                return this.obtainQueues(
                    (String) params.get('recordId'),
                    (String) params.get('keyword')
                );
            }
            when 'transferCase'{
                return this.transferCase(
                    (String) params.get('recordId'),
                    (String) params.get('queueId')
                );
            }
            when else {
                throw new LC_CaseQueueException('UNKNOWN ACTION');
            }
        }
    }

    /** ENTRY METHODS */
    private Response obtainQueues(Id pRecordId, String pKeyword) {
        System.debug('LC_CaseQueue.obtainQueues ...');
        pKeyword = '%' + pKeyword + '%';

        User user = this.getUser();
        Map<String, Set<String>> hiddenQueuesMap = this.obtainHiddenQueuesMap();

        String query = 'SELECT Name'
                      + ' FROM Group'
                     + ' WHERE Type = \'Queue\''
                       + ' AND Name LIKE :pKeyword';

        if (pRecordId.getSobjectType() == Case.getSObjectType()) {
            query += ' AND DeveloperName LIKE \'Q_%\'';

            if (user.Ashdod_employee__c) {
                query += ' AND DeveloperName LIKE \'Q_33%\'';
            }

            if (PROFILE_NAME_SET.contains(user.Profile.Name) && !user.Ashdod_employee__c) {
                query += ' AND (NOT DeveloperName LIKE \'Q_33%\')'
                       + ' AND (NOT Name LIKE \'%ציבורי%\')';
            }

            if (hiddenQueuesMap.containsKey(user.Profile.Name)) {
                for (String hiddenQueue_i : hiddenQueuesMap.get(user.Profile.Name)) {
                    query += ' AND (NOT DeveloperName = \'' + hiddenQueue_i + '\')';
                }
            }
        }
        System.debug('query: ' + query);

        List<Group> queueList = Database.query(query);
        System.debug('queueList [' + queueList.size() + ']: ' + queueList);

        return new Response(queueList);
    }

    private Response transferCase(Id pRecordId, String pQueueId) {
        System.debug('LC_CaseQueue.transferCase ...');
        String message;

        if (pRecordId.getSobjectType() == Case.getSObjectType()) {
            Case cas = this.getCase(pRecordId);
            Group queue = this.getQueue(pQueueId);

            if (cas.RecordType.DeveloperName == 'Appointments' && cas.description_history__c == null) {
                throw new LC_CaseQueueException(Label.ERR_Missing_Description_History);
            }

            if (cas.RecordType.DeveloperName != 'Medical_Info_Management'
                    || !queue.Name.startsWith('ניהול ורישום מידע רפואי')) {
                cas.RecordTypeId = TRANSFER_RT_ID;
                cas.Status = 'Third Party';
            }

            cas.OwnerId = pQueueId;

            update cas;
            System.debug('cas: ' + cas);

            message = Label.Successfully_transferred;
        } else if (pRecordId.getSobjectType() == Opportunity.getSObjectType()) {
            Opportunity oppt = this.getOpportunity(pRecordId);

            Case cas = new Case(
                Status = 'New',
                Origin = 'sales',
                OwnerId = pQueueId,
                AccountId = oppt.AccountId,
                Opportunity__c = pRecordId,
                RecordTypeId = TRANSFER_RT_ID);
            insert cas;
            System.debug('cas: ' + cas);

            oppt.StageName = 'Closed Won';
            oppt.StageStatus__c = 'transferToDepartment';
            update oppt;
            System.debug('oppt: ' + oppt);

            message = Label.Opportunity_successfully_transferred;
        }

        return new Response(message);
    }

    /** INNER METHODS */
    private User getUser() {
        return [SELECT Profile.Name, Ashdod_employee__c FROM User WHERE Id = :UserInfo.getUserId()];
    }

    private Case getCase(Id pRecordId) {
        return [SELECT Status, Owner.Name, RecordType.DeveloperName, description_history__c FROM Case WHERE Id = :pRecordId];
    }

    private Opportunity getOpportunity(Id pRecordId) {
        return [SELECT AccountId, StageName, StageStatus__c FROM Opportunity WHERE Id = :pRecordId];
    }

    private Group getQueue(Id pRecordId) {
        return [SELECT Name FROM Group WHERE Id = :pRecordId];
    }

    private Map<String, Set<String>> obtainHiddenQueuesMap() {
        Map<String, Set<String>> hiddenQueuesMap = new Map<String, Set<String>> ();

        for (Hidden_Queue__mdt hiddenQueue_i : Hidden_Queue__mdt.getAll().values()) {
            if (!hiddenQueuesMap.containsKey(hiddenQueue_i.Profile__c)) {
                hiddenQueuesMap.put(hiddenQueue_i.Profile__c, new Set<String>());
            }
            hiddenQueuesMap.get(hiddenQueue_i.Profile__c).add(hiddenQueue_i.Queue_DeveloperName__c);
        }
        System.debug('hiddenQueuesMap [' + hiddenQueuesMap.size() + ']: ' + hiddenQueuesMap);

        return hiddenQueuesMap;
    }
}