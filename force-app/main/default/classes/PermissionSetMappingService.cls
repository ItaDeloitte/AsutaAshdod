// Test: PermissionSetMappingServiceTest
public inherited sharing class PermissionSetMappingService {

    private static PermissionSetMappingService instance;

    private List<Permission_Set_Mapping__mdt> mappings;

    private Map<String, String> permissionSetsMap = new Map<String, String>();
    private Map<String, String> profilesMap = new Map<String, String>();

    private PermissionSetMappingService() {
        System.debug('PermissionSetMappingService ...');
        this.obtainProfiles();
        this.obtainRecords();
        this.obtainPermissionSets();

    }

    public static PermissionSetMappingService getInstance() {
        if (instance == null) {
            instance = new PermissionSetMappingService();
        }
        return instance;
    }

    private void obtainProfiles() {
        for (Profile profile_i : [SELECT Id, Name FROM Profile]) {
            this.profilesMap.put(profile_i.Name, profile_i.Id);
        }
        System.debug('profilesMap: size: ' + this.profilesMap.size() + ' users: ' + this.profilesMap);
    }

    private void obtainRecords() {
        this.mappings = [
            SELECT ProfileName__c
                 , PermissionSetName__c
                 , IsServiceCloudUser__c
                 , RemoveOnChange__c
              FROM Permission_Set_Mapping__mdt
             WHERE IsActive__c = true
               AND (ProfileName__c IN: this.getProfileNames() OR ProfileName__c = null)];
        System.debug('mappings: size: ' + this.mappings.size() + ' users: ' + this.mappings);
    }

    private void obtainPermissionSets() {
        for (PermissionSet permissionSet_i : [SELECT Id, Name FROM PermissionSet WHERE Name IN: this.getPermissionSetNames()]) {
            this.permissionSetsMap.put(permissionSet_i.Name, permissionSet_i.Id);
        }
        System.debug('permissionSetsMap: size: ' + this.permissionSetsMap.size() + ' users: ' + this.permissionSetsMap);
    }

    private Set<String> getProfileNames() {
        Set<String> profileNames = new Set<String>();

        for (String profileName_i : this.profilesMap.keySet()) {
            profileNames.add(profileName_i);
        }

        return profileNames;
    }

    private Set<String> getPermissionSetNames() {
        Set<String> permissionSetNames = new Set<String>();

        for (Permission_Set_Mapping__mdt mapping_i : this.mappings) {
            permissionSetNames.add(mapping_i.PermissionSetName__c);
        }

        return permissionSetNames;
    }

    public Map<String, Boolean> getServiceCloudMapping() {
        Map<String, Boolean> serviceCloudMapping = new Map<String, Boolean>();

        for (Permission_Set_Mapping__mdt mapping_i : this.mappings) {
            String profileId_i = this.profilesMap.get(mapping_i.ProfileName__c);
            serviceCloudMapping.put(profileId_i, mapping_i.IsServiceCloudUser__c);
        }

        for (String profileId_i : this.profilesMap.values()) {
            Boolean isServiceCloudUser = false;

            if (serviceCloudMapping.containsKey(profileId_i)) {
                isServiceCloudUser = serviceCloudMapping.get(profileId_i);
            } else if (serviceCloudMapping.containsKey(null)) {
                isServiceCloudUser = serviceCloudMapping.get(null);
            }

            serviceCloudMapping.put(profileId_i, isServiceCloudUser);
        }
        serviceCloudMapping.remove(null);
        System.debug('serviceCloudMapping: size: ' + serviceCloudMapping.size() + ' users: ' + serviceCloudMapping);

        return serviceCloudMapping;
    }

    public Map<String, Set<String>> getAllPSMapping() {
        Map<String, Set<String>> allPSMapping = this.getPSMapping(false);
        System.debug('allPSMapping: size: ' + allPSMapping.size() + ' users: ' + allPSMapping);

        return allPSMapping;
    }

    public Map<String, Set<String>> getRemovablePSMapping() {
        Map<String, Set<String>> removablePSMapping = this.getPSMapping(true);
        System.debug('removablePSMapping: size: ' + removablePSMapping.size() + ' users: ' + removablePSMapping);

        return removablePSMapping;
    }

    private Map<String, Set<String>> getPSMapping(Boolean removableOnly) {
        Map<String, Set<String>> psMapping = new Map<String, Set<String>>();

        for (Permission_Set_Mapping__mdt mapping_i : this.mappings) {
            String profileId_i = this.profilesMap.get(mapping_i.ProfileName__c);
            String permissionSetId_i = this.permissionSetsMap.get(mapping_i.PermissionSetName__c);

            if (!psMapping.containsKey(profileId_i)) {
                psMapping.put(profileId_i, new Set<String>());
            }
            if (permissionSetId_i != null && (!removableOnly || (removableOnly && mapping_i.RemoveOnChange__c))) {
                psMapping.get(profileId_i).add(permissionSetId_i);
            }
        }

        this.addDefault(psMapping);

        return psMapping;
    }

    private void addDefault(Map<String, Set<String>> psMapping) {
        for (String profileId_i : this.profilesMap.values()) {
            Set<String> permissionSetIds_i = new Set<String>();

            if (psMapping.containsKey(profileId_i)) {
                permissionSetIds_i = psMapping.get(profileId_i);
            } else if (psMapping.containsKey(null)) {
                permissionSetIds_i = psMapping.get(null);
            }

            psMapping.put(profileId_i, permissionSetIds_i);
        }
        psMapping.remove(null);
    }
}