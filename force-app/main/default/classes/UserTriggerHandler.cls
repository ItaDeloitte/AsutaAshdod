public class UserTriggerHandler {

    public static void handleTrigger(List<User> newList, Map<Id, User> oldMap, Map<Id, User> newMap, System.TriggerOperation triggerEvent) {
        System.debug('UserTriggerHandler.handleTrigger...');
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                UserTriggerDispatcher.markServiceCloudUser(newList, null);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                UserTriggerDispatcher.updateUserRoleByTitle(newList, oldMap);
                UserTriggerDispatcher.assignPermissionSet(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                UserTriggerDispatcher.markServiceCloudUser(newList, oldMap);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                UserTriggerDispatcher.updateRoleByTitleChange(newList, oldMap);
                UserTriggerDispatcher.assignPermissionSet(newList, oldMap);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}