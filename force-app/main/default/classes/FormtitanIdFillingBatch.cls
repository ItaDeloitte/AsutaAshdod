/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Batch job to data fix Formtitan Id values
 * 
 * Test                 FormtitanIdFillingBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-12-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class FormtitanIdFillingBatch implements Database.Batchable<SObject> {

    private String query;
    private String sobjName;
    private String fieldName;

    global FormtitanIdFillingBatch(SObjectType sobj, SObjectField field) {
        this.sobjName = sobj.getDescribe().getName();
        this.fieldName = field.getDescribe().getName();
        this.query = 'SELECT ' + this.fieldName + ' FROM ' + this.sobjName + ' WHERE ' + this.fieldName + ' = null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('FormtitanIdFillingBatch... start');
        System.debug('query: ' + this.query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('FormtitanIdFillingBatch... execute');
        for (SObject record_i : scope) {
            record_i.put(this.fieldName, CommonService.generateRandomKey(15));
        }
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);

        update scope;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('FormtitanIdFillingBatch... finish');
    }
}