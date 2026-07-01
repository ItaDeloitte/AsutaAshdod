/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────┐
 * Updates PermissionSetAssignment and UserPermissionsSupportUser for active secritary users 
 * ─────────────────────────────────────────────────────────────────────────────────────────────
 * @created         06-04-2021           <sergey.duiev@synebo.io>
 * ─────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class AssignPermissionSetBatch implements Database.Batchable<sObject> { 

    private String query = 'SELECT Id' 
                                + ', ProfileId' 
                                + ', UserPermissionsSupportUser' 
                                + ' FROM User' 
                                + ' WHERE (Profile.Name = \'Secretary\' OR Profile.Name = \'Secretary - IVF\')' 
                                    + ' AND IsActive = true';

    public AssignPermissionSetBatch() {}

    public AssignPermissionSetBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<User> scope) {
        UserTriggerService.markServiceCloudUser(scope);
        update scope;
        UserTriggerService.assignPermissionSet(scope, null);
    }

    public void finish(Database.BatchableContext BC) {}
}