/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * DML Util for Async Apex with allOrNone FALSE
 *
 * Test                 AsyncUtilTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-02-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class AsyncUtil {

    /** INSERT */
    public static Set<Id> doInsert(List<SObject> records) {
        System.debug('AsyncUtil.doInsert ...');
        return main('insert', records);
    }

    /** UPDATE */
    public static Set<Id> doUpdate(List<SObject> records) {
        System.debug('AsyncUtil.doUpdate ...');
        return main('update', records);
    }

    /** DELETE */
    public static Set<Id> doDelete(List<SObject> records) {
        System.debug('AsyncUtil.doDelete ...');
        return main('delete', records);
    }

    public static Set<Id> doDelete(List<Id> ids) {
        return doDelete(obtainRecords(ids));
    }

    public static Set<Id> doDelete(Set<Id> ids) {
        return doDelete(new List<Id>(ids));
    }

    /** UNDELETE */
    public static Set<Id> doUndelete(List<SObject> records) {
        System.debug('AsyncUtil.doUndelete ...');
        return main('undelete', records);
    }

    public static Set<Id> doUndelete(List<Id> ids) {
        return doUndelete(obtainRecords(ids));
    }

    public static Set<Id> doUndelete(Set<Id> ids) {
        return doUndelete(new List<Id>(ids));
    }

    /** INNER LOGIC */
    private static Set<Id> main(String operation, List<SObject> records) {
        Set<Id> recordIds = new Set<Id>();

        switch on operation {
            when 'insert' {
                recordIds = handleSaveResults(Database.insert(records, false), obtainSObjTypes(records));
            }
            when 'update' {
                recordIds = handleSaveResults(Database.update(records, false), obtainSObjTypes(records));
            }
            when 'delete' {
                recordIds = handleDeleteResults(Database.delete(records, false), obtainSObjTypes(records));
            }
            when 'undelete' {
                recordIds = handleUndeleteResults(Database.undelete(records, false), obtainSObjTypes(records));
            }
        }
        System.debug('AsyncUtil: recordIds: size: ' + recordIds.size() + ' value: ' + recordIds);

        return recordIds;
    }

    private static List<SObject> obtainRecords(List<Id> ids) {
        List<SObject> records = new List<SObject>();

        for (Id id_i : ids) {
            records.add(id_i.getSobjectType().newSObject(id_i));
        }

        return records;
    }

    private static List<String> obtainSObjTypes(List<SObject> sobjs) {
        List<String> sobjTypes = new List<String>();

        for (SObject sobj_i : sobjs) {
            sobjTypes.add(String.valueOf(sobj_i.getSObjectType()));
        }

        return sobjTypes;
    }

    /** RESULT HANDLERS */
    private static Set<Id> handleSaveResults(List<Database.SaveResult> results, List<String> sobjTypes) {
        Set<Id> insertedIds = new Set<Id>();

        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult result_i = results.get(i);
            if (result_i.isSuccess()) {
                insertedIds.add(result_i.getId());
            } else {
                handleError(result_i.getId() == null ? 'insert' : 'update', sobjTypes.get(i), result_i.getId(), result_i.getErrors());
            }
        }

        return insertedIds;
    }

    private static Set<Id> handleDeleteResults(List<Database.DeleteResult> results, List<String> sobjTypes) {
        Set<Id> deletedIds = new Set<Id>();

        for (Integer i = 0; i < results.size(); i++) {
            Database.DeleteResult result_i = results.get(i);
            if (result_i.isSuccess()) {
                deletedIds.add(result_i.getId());
            } else {
                handleError('delete', sobjTypes.get(i), result_i.getId(), result_i.getErrors());
            }
        }

        return deletedIds;
    }

    private static Set<Id> handleUndeleteResults(List<Database.UndeleteResult> results, List<String> sobjTypes) {
        Set<Id> undeletedIds = new Set<Id>();

        for (Integer i = 0; i < results.size(); i++) {
            Database.UndeleteResult result_i = results.get(i);
            if (result_i.isSuccess()) {
                undeletedIds.add(result_i.getId());
            } else {
                handleError('undelete', sobjTypes.get(i), result_i.getId(), result_i.getErrors());
            }
        }

        return undeletedIds;
    }

    private static void handleError(String operation, String sobjType, Id recordId, List<Database.Error> errors) {
        String msg = 'AsyncUtil: The following errors have occurred while trying to ' + operation + ' ' + sobjType;

        switch on operation {
            when 'insert' {
                System.debug(msg + ':');
            }
            when 'update', 'delete', 'undelete' {
                System.debug(msg + ' (' + recordId + '):');
            }
        }

        for (Database.Error err_i : errors) {
            System.debug('AsyncUtil: - ' + err_i.getStatusCode() + ': ' + err_i.getMessage());
        }
    }
}