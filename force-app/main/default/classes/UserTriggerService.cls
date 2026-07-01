public class UserTriggerService {

    public static void assignPermissionSet(List<User> users, Map<Id, User> oldMap) {
        Boolean logicExecuted = false;
        List<PermissionSetAssignment> psasToCreate = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psasToRemove = new List<PermissionSetAssignment>();

        // licenseIds and userIds to unassignLicense
        Set<Id> licenseIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        Map<String, List<PermissionSetAssignment>> assignmentsMap = getAssignmentsMap(users);
        Map<String, Set<String>> assignmentIdsMap = getAssignmentIdsMap(assignmentsMap);

        Map<String, Set<String>> allPSMapping = PermissionSetMappingService.getInstance().getAllPSMapping();
        Map<String, Set<String>> removablePSMapping = PermissionSetMappingService.getInstance().getRemovablePSMapping();

        for (User user_i : users) {
            for (String permissionSetId_i : allPSMapping.get(user_i.ProfileId)) {
                // check if such permission set is already assigned to the user and assign if not
                if (!assignmentIdsMap.get(user_i.Id).contains(permissionSetId_i)) {
                    psasToCreate.add(
                        new PermissionSetAssignment(
                            PermissionSetId = permissionSetId_i,
                            AssigneeId = user_i.Id
                        )
                    );
                }
            }
            // assignments deletion available only on the update event
            if (oldMap != null) {
                for (PermissionSetAssignment psa_i : assignmentsMap.get(user_i.Id)) {
                    // check if such permission set assignment should be deleted based on metadata settings
                    if (!allPSMapping.get(user_i.ProfileId).contains(psa_i.PermissionSetId) && removablePSMapping.get(oldMap.get(user_i.Id).ProfileId).contains(psa_i.PermissionSetId)) {
                        psasToRemove.add(psa_i);
                        // collect license Ids and user Ids potential to removing
                        licenseIds.add(psa_i.PermissionSet.LicenseId);
                        userIds.add(user_i.Id);
                    }
                }
            }
        }

        System.debug('psasToCreate: size: ' + psasToCreate.size() + ' users: ' + psasToCreate);
        if (!psasToCreate.isEmpty()) {
            logicExecuted = true;
            insert psasToCreate;
        }

        System.debug('psasToRemove: size: ' + psasToRemove.size() + ' users: ' + psasToRemove);
        if (!psasToRemove.isEmpty()) {
            logicExecuted = true;
            delete psasToRemove;
        }

        if (logicExecuted) {
            System.debug('LOG User assignPermissionSet ... logic has been executed');
        }

        if (!licenseIds.isEmpty() && !userIds.isEmpty()) {
            unassignLicense(licenseIds, userIds);
        }
    }

    private static Map<String, List<PermissionSetAssignment>> getAssignmentsMap(List<User> users) {
        Map<String, List<PermissionSetAssignment>> assignmentsMap = new Map<String, List<PermissionSetAssignment>>();

        for (User user_i : users) {
            if (!assignmentsMap.containsKey(user_i.Id)) {
                assignmentsMap.put(user_i.Id, new List<PermissionSetAssignment>());
            }
        }

        for (PermissionSetAssignment psa_i : [SELECT Id, AssigneeId, PermissionSetId, PermissionSet.LicenseId FROM PermissionSetAssignment WHERE AssigneeId IN: users]) {
            assignmentsMap.get(psa_i.AssigneeId).add(psa_i);
        }
        System.debug('assignmentsMap: size: ' + assignmentsMap.size() + ' users: ' + assignmentsMap);

        return assignmentsMap;
    }

    private static Map<String, Set<String>> getAssignmentIdsMap(Map<String, List<PermissionSetAssignment>> assignmentsMap) {
        Map<String, Set<String>> assignmentIdsMap = new Map<String, Set<String>>();

        for (String userId_i : assignmentsMap.keySet()) {
            assignmentIdsMap.put(userId_i, new Set<String>());
            for (PermissionSetAssignment pas_i : assignmentsMap.get(userId_i)) {
                assignmentIdsMap.get(userId_i).add(pas_i.PermissionSetId);
            }
        }
        System.debug('assignmentIdsMap: size: ' + assignmentIdsMap.size() + ' users: ' + assignmentIdsMap);

        return assignmentIdsMap;
    }

    private static void unassignLicense(Set<Id> licenseIds, Set<Id> userIds) {
        System.debug('LOG User unassignLicense ... start');
        System.debug('licenseIds: size: ' + licenseIds.size() + ' value: ' + licenseIds);
        System.debug('userIds: size: ' + userIds.size() + ' value: ' + userIds);

        List<PermissionSetLicenseAssign> psalsToRemove = new List<PermissionSetLicenseAssign>();
        Map<Id, Set<Id>> licenseIdsByUserIdMap = new Map<Id, Set<Id>>();

        // get licenses that should remain in the system per user
        for (PermissionSetAssignment psa_i : [SELECT AssigneeId, PermissionSet.LicenseId FROM PermissionSetAssignment WHERE AssigneeId IN: userIds]) {
            if (!licenseIdsByUserIdMap.containsKey(psa_i.AssigneeId)) {
                licenseIdsByUserIdMap.put(psa_i.AssigneeId, new Set<Id>());
            }
            licenseIdsByUserIdMap.get(psa_i.AssigneeId).add(psa_i.PermissionSet.LicenseId);
        }
        System.debug('licenseIdsByUserIdMap: size: ' + licenseIdsByUserIdMap.size() + ' value: ' + licenseIdsByUserIdMap);

        // check if existing licenses assignments should remain in the system and delete is if not
        for (PermissionSetLicenseAssign psal_i : [SELECT Id, PermissionSetLicenseId, AssigneeId FROM PermissionSetLicenseAssign WHERE PermissionSetLicenseId IN: licenseIds AND AssigneeId IN: userIds]) {
            if (!licenseIdsByUserIdMap.containsKey(psal_i.AssigneeId) || !licenseIdsByUserIdMap.get(psal_i.AssigneeId).contains(psal_i.PermissionSetLicenseId)) {
                psalsToRemove.add(psal_i);
            }
        }
        System.debug('psalsToRemove: size: ' + psalsToRemove.size() + ' value: ' + psalsToRemove);

        if (!psalsToRemove.isEmpty()) {
            delete psalsToRemove;
            System.debug('LOG User unassignLicense ... logic has been executed');
        }
    }

    public static void markServiceCloudUser(List<User> users) {
        Map<String, Boolean> serviceCloudMapping = PermissionSetMappingService.getInstance().getServiceCloudMapping();

        for (User user_i : users) {
            user_i.UserPermissionsSupportUser = serviceCloudMapping.get(user_i.ProfileId);
        }
        System.debug('LOG User markServiceCloudUser ... logic has been executed');
    }
}