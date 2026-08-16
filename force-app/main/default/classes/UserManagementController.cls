public with sharing class UserManagementController {

    private static Id permissionsLiveMessageId = [SELECT Id FROM PermissionSet WHERE Name = 'Live_Message_Setup_Flow'].Id;
    private static Id permissionsMessagingUserId = [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'LiveMessageUserPsl'].Id;

    @AuraEnabled(cacheable=true) 
    public static  List<User>  getUserPermissionsLiveAgent() {
        System.debug('UserManagementController.getUserPermissionsLiveAgent.....');
        set<Id> userId =  getPermissionSetAssignment();
        return [SELECT Id, Name FROM User WHERE Id IN :userId ORDER BY Name];
    }

    @AuraEnabled(cacheable=true) 
    public static  List<User>  getAgentName() {
        System.debug('UserManagementController.getAgentName.....');
        set<Id> removeUserId =  getPermissionSetAssignment();
        Id agentProfileId = [SELECT Id FROM Profile WHERE Name = 'Agent'].Id;
        return [SELECT Id, Name FROM User WHERE profileId = :agentProfileId AND IsActive = true AND Id NOT IN :removeUserId ORDER BY Name];
    }

    @AuraEnabled(cacheable=true) 
    public static  Boolean  getMaxLicenses() {
        System.debug('UserManagementController.getMaxLicenses.....');
        PermissionSetLicense psLicense =  [SELECT Id, TotalLicenses, UsedLicenses FROM PermissionSetLicense WHERE Id = :permissionsMessagingUserId ];
        if(psLicense.TotalLicenses == psLicense.UsedLicenses){
            return true;
        }
        return false;
    }
    @AuraEnabled(cacheable=false) 
    public static void deleteUserPermissionsLiveAgent(Id userId) {
        System.debug('UserManagementController.deleteUserPermissionsLiveAgent.....');
        PermissionSetAssignment psAssignmentDelete = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionsLiveMessageId AND AssigneeId = :userId];
        PermissionSetLicenseAssign psLicenseAssignDelete = [SELECT Id, PermissionSetLicenseId, AssigneeId FROM PermissionSetLicenseAssign WHERE PermissionSetLicenseId = :permissionsMessagingUserId AND AssigneeId = :userId];
        deleteSObject(psAssignmentDelete, 'PermissionSetLicenseAssign');
        deleteSObject(psLicenseAssignDelete, 'PermissionSetAssignment');
    }

    @AuraEnabled(cacheable=false) 
    public static Id insertUserPermissionsLiveAgent(String userName) {
        System.debug('UserManagementController.insertUserPermissionsLiveAgent.....');
        Id userId = [SELECT Id FROM user WHERE Name = :userName LIMIT 1].Id;
        PermissionSetLicenseAssign psLicenseAssignInsert = new PermissionSetLicenseAssign(PermissionSetLicenseId = permissionsMessagingUserId, AssigneeId  = userId);
        PermissionSetAssignment psAssignmentInsert = new PermissionSetAssignment (PermissionSetId = permissionsLiveMessageId, AssigneeId = userId);
        insertSObject(psLicenseAssignInsert, 'PermissionSetLicenseAssign');
        insertSObject(psAssignmentInsert, 'PermissionSetAssignment');

        System.debug('userId......' + userId);
        return userId;
    }

    public static Set<Id> getPermissionSetAssignment (){ 
        Set<Id> userSetId = new Set<Id> ();
        List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionsLiveMessageId];
        for (PermissionSetAssignment pset_i : permissionSetAssignmentList) {
            userSetId.add(pset_i.AssigneeId);
        }
        if(userSetId.Size() > 0){
            return userSetId;
        }
        return null;   
    }

    public static void insertSObject(SObject SObjectPermissionSet, String psName) {
        try{
            Database.SaveResult saveResult = Database.insert(SObjectPermissionSet, false);
            if(saveResult.isSuccess()){
                System.debug('Successfully inserted '+ psName +' . permissionSet ID is : ' + saveResult.getId());
            }else {
                for(Database.Error err : saveResult.getErrors()) {
                    System.debug('The following error has occurred.');                  
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(psName + ' oject field which are affected by the error:'+ err.getFields());
                }
            }                     
        } catch(Exception ex){
            System.debug('exception for assigning Permission Set To User: ' + ex);                  
        }    
    }

    public static void deleteSObject(SObject SObjectPermissionSet, String psName) {
        try{
            Database.DeleteResult deleteResult = Database.delete(SObjectPermissionSet, false);
            if(deleteResult.isSuccess()){ 
                System.debug('Successfully deleted '+ psName +' with ID: ' + deleteResult.getId());
            }else {
                for(Database.Error err : deleteResult.getErrors()) {
                    System.debug('The following error has occurred.');                  
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(psName + ' oject field which are affected by the error:'+ err.getFields());
                }
            }      
        }catch(exception ex){
            system.debug('exception for delete Permission Set To User' + ex);
        }
    }
}