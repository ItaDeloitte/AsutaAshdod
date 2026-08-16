public class UserTriggerDispatcher {

    /*
     * ─────────────────────────────────────────────────────────────────────────────────────────────┐
     * Assign Permission Set depends on User's profile and based on metadata setting
     * ─────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @created          19-02-2021
     * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void assignPermissionSet(List<User> newList, Map<Id, User> oldMap) {
        System.debug('LOG User assignPermissionSet ... start');
        List<User> users = new List<User>();

        for (User user_i : newList) {
            if (oldMap == null || oldMap.get(user_i.Id).ProfileId != user_i.ProfileId) {
                users.add(user_i);
            }
        }
        System.debug('users: size: ' + users.size() + ' users: ' + users);

        if (!users.isEmpty()) {
            UserTriggerService.assignPermissionSet(users, oldMap);
        }
    }

    /*
     * ─────────────────────────────────────────────────────────────────────────────────────────────┐
     * Mark Service Cloud User checkbox depends on User's profile and based on metadata setting
     * ─────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @created          01-03-2021
     * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void markServiceCloudUser(List<User> newList, Map<Id, User> oldMap) {
        System.debug('LOG User markServiceCloudUser ... start');
        List<User> users = new List<User>();

        for (User user_i : newList) {
            if (oldMap == null || oldMap.get(user_i.Id).ProfileId != user_i.ProfileId) {
                users.add(user_i);
            }
        }
        System.debug('users: size: ' + users.size() + ' users: ' + users);

        if (!users.isEmpty()) {
            UserTriggerService.markServiceCloudUser(users);
        }
    }

    /*
     * @author         Avraham Dasa <adasa@deloitte.co.il>
     * @Class Name     UserTriggerDispatcher
     * @Test Class     UserTriggerDispatcherTest
     * @modifiedBy     
     * @version        1.0
     * @created        09-01-2020
     * @modified       28-01-2020
     * @description    When created a new User updated user Role according to the Title & set callcenter=MainCallCenter & PermissionSetId=Cases_Permission_Set & UserPermissionsSupportUser=true
     *                 if the title is null or empty created user with callcenter and PermissionSetId and UserPermissionsSupportUser without user role and send email alert by process buillder name Send email
     */
    public static void updateUserRoleByTitle(List<User> newList, Map<Id, User> oldMap) {
        System.debug('UserTriggerDispatcher.updateUserRole...');
        List<PermissionSetAssignment> updateUserPermissionSet = new List<PermissionSetAssignment>();
        Map<Id, User> userToUpdateMap = new Map<Id, User>();
        List<User> updateUserRole = new List<User>();
        Set<String> userTitle = new Set<String>();
        Set<String> adNameSet = new Set<String>();
        Set<Id> userId = new Set<Id>();
        String userAD = '';

        List<PermissionSetAssignment> psa = [SELECT PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Cases_Permission_Set'];
        List<CallCenter> callCenter = [SELECT Id, Name FROM CallCenter WHERE Name =: Label.callCenterName];
        List<UserRole__mdt> uRoleMdt = [SELECT Id, SFUserRoleName__c, Label FROM UserRole__mdt];

        for (UserRole__mdt urMdt : uRoleMdt) {
            adNameSet.add(urMdt.Label);
        }

        for (User newUser : newList) {
            userAD = newUser.Username.SubStringBefore('@');
            if (newUser.Title != null && adNameSet.contains(newUser.Title) && (newUser.UserRoleId == null || newUser.UserRoleId == '')) {
                userTitle.add(newUser.Title);
                userToUpdateMap.put(newUser.Id, newUser);
            } else {
                User u = new User();
                u.Id = newUser.Id;
                //u.User_AD__c = userAD;
                u.UserPermissionsSupportUser = true;
                if (callCenter.size() > 0) {
                    u.CallCenterId = callCenter[0].Id;
                }
                updateUserRole.add(u);
                userId.add(newUser.Id);
            }
        }

        if (userTitle.size() > 0 ) {
            List<UserRole> roleList = [SELECT Id, Name FROM UserRole WHERE Name IN : userTitle];
            Map<String, Id> roleToIdMap = new Map<String, Id>();

            if (!roleList.isEmpty()) {
                for (UserRole uRole : roleList) {
                    roleToIdMap.put(uRole.Name, uRole.Id);
                }
                for (Id currentUserId : userToUpdateMap.keySet()) {
                    System.debug('### Current userId ' + currentUserId);
                    User user = new User();
                    user.Id = currentUserId;
                    user.UserRoleId = roleToIdMap.get(userToUpdateMap.get(currentUserId).Title);
                    user.Title = userToUpdateMap.get(currentUserId).Title;
                    //user.User_AD__c = userAD;
                    System.debug('### NEW TITLE : ' + userToUpdateMap.get(currentUserId).Title);
                    user.UserPermissionsSupportUser = true;
                    if (callCenter.size() > 0) {
                          user.CallCenterId = callCenter[0].Id;
                    }
                    updateUserRole.add(user);
                    userId.add(currentUserId);
                }
            }
        }

        if (updateUserRole.size() > 0) {
            try {
                System.debug('### created User ' +JSON.serializePretty(updateUserRole));
                update updateUserRole;
            } catch (DMLException e) {
                System.debug(e.getMessage());
            }
        }

        if (!userId.isEmpty() && psa.size() > 0) {
            List<PermissionSetAssignment> psaUser = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :userId];
            if (psaUser[0].PermissionSetId != null) {
                for (User cUser:updateUserRole) {
                    System.debug('### Create PermissionSet ');
                    PermissionSetAssignment psaUpdate = new PermissionSetAssignment();
                    psaUpdate.PermissionSetId = psa[0].PermissionSetId;
                    psaUpdate.AssigneeId = cUser.Id;
                    updateUserPermissionSet.add(psaUpdate);
                }
            }
        }

        if (updateUserPermissionSet.size() > 0) {
            try {
                System.debug('### Insert permission set to new User ' + JSON.serializePretty(updateUserPermissionSet));
                insert updateUserPermissionSet;
            } catch (DMLException e) {
                System.debug(e.getMessage());
            }
        }
    }

    /*
     * @author         Avraham Dasa <adasa@deloitte.co.il>
     * @Class Name     UserTriggerDispatcher
     * @Test Class     UserTriggerDispatcherTest
     * @modifiedBy
     * @version        1.0
     * @created        10-03-2020
     * @modified
     * @description    When changed title update role by role maping
     */
    public static void updateRoleByTitleChange(List<User> newList, Map<Id, User> oldMap) {
        System.debug('UserTriggerDispatcher.updateRoleByTitleChange...');
        Map<Id, User> userToUpdateMap = new Map<Id, User>();
        Set<String> userTitle = new Set<String>();
        Set<Id> userId = new Set<Id>();

        for (User user : newList) {
            if (user.Title != oldMap.get(user.Id).Title) {
                System.debug('current title ' + user.Title);
                userTitle.add(user.Title);
                userToUpdateMap.put(user.Id, user);
            }
        }

        List<User> updateUser = new List<User>();
        Set<String> adNameSet = new Set<String>();
        List<UserRole__mdt> uRoleMdt = [SELECT Id, SFUserRoleName__c, Label FROM UserRole__mdt];
        Boolean isTitle = true;

        for (UserRole__mdt urMdt : uRoleMdt) {
            adNameSet.add(urMdt.Label);
        }
        System.debug('userTitle size ' + userTitle.size());
        if (userTitle.size() > 0 ) {
            List<UserRole> roleList = [SELECT Id, Name FROM UserRole WHERE Name IN : userTitle];
            Map<String, Id> roleToIdMap = new Map<String, Id>();
            if (!roleList.isEmpty()) {
                for (UserRole uRole : roleList) {
                    roleToIdMap.put(uRole.Name, uRole.Id);
                }

                for (Id currentUserId : userToUpdateMap.keySet()) {
                    User user = new User();
                    user.Id = currentUserId;
                    user.UserRoleId = roleToIdMap.get(userToUpdateMap.get(currentUserId).Title);
                    updateUser.add(user);
                }
            } else {
                isTitle = false;
            }
        } else {
            isTitle = false;
        }

        if (isTitle == false) {
            for (Id currentUserId : userToUpdateMap.keySet()) {
                 User user = new User();
                 user.Id = currentUserId;
                 user.UserRoleId = null;
                 updateUser.add(user);
            }
        }

        if (updateUser.size() > 0) {
            try {
                System.debug('### created User ' +JSON.serializePretty(updateUser));
                update updateUser;
            } catch (DMLException e) {
                System.debug(e.getMessage());
            }
        }
    }
}