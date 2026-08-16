// Test: LC_OmniChanelControllerTest
public class LC_OmniChanelController implements ILCController {

    public class LC_OmniChanelControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getInitData' {
                return this.getInitData();
            }
            when 'checkStatusPossibility' {
                return this.checkStatusPossibility((String) params.get('statusId'));
            }
            when 'assignOwner' {
                return this.assignOwner((String) params.get('itemId'));
            }
            when else {
                throw new LC_OmniChanelControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response getInitData() {
        System.debug('LC_OmniChanelController.getInitData...');
        StatusListWrapper listWrapper = new StatusListWrapper();

        List<String> statusesToExclude = new List<String>();

        for (Service_Presence_Status_to_exclude__mdt metadata_i : [SELECT Id, MasterLabel, DeveloperName FROM Service_Presence_Status_to_exclude__mdt]) {
            statusesToExclude.add(metadata_i.DeveloperName);
        }

        for (ServicePresenceStatus status_i : [SELECT Id, DeveloperName, MasterLabel FROM ServicePresenceStatus]) {
            if (!statusesToExclude.contains(status_i.DeveloperName)) {
                listWrapper.avaliableStatusList.add(new ServiceStatusWrapper(status_i));
            } else {
                listWrapper.depricatedStatusList.add(new ServiceStatusWrapper(status_i));
            }
        }
        
        
        return new Response(listWrapper);
    }

    private Response checkStatusPossibility(String statusId){
        List <UserServicePresence> userServiceList = [SELECT Id, 
                                                             UserId, 
                                                             ServicePresenceStatus.MasterLabel,
                                                             ServicePresenceStatusId, 
                                                             StatusDuration, 
                                                             ConfiguredCapacity, 
                                                             LastModifiedBy.Name, 
                                                             LastModifiedById,
                                                             LastModifiedBy.Profile.Name,
                                                             LastModifiedBy.ProfileId
                                                        FROM UserServicePresence 
                                                       WHERE IsCurrentState = true 
                                                         AND UserId =: UserInfo.getUserId()
                                                         AND ServicePresenceStatusId =: statusId];

        //משתמש סטנדרטי - חדש - agent
        Boolean isAvaliable = true;
        System.debug('userServiceList.size '+userServiceList.size());
        System.debug('userServiceList '+userServiceList);
        if (!userServiceList.isEmpty()){
            for (UserServicePresence sercive : userServiceList){
                if (sercive.LastModifiedBy.Profile.Name == 'משתמש סטנדרטי - חדש' && sercive.LastModifiedById ==  sercive.UserId){
                    isAvaliable = false;
                }
            }
        }
        
        return new Response(isAvaliable);
    }

    private Response assignOwner(String caseId) {
        System.debug('LC_OmniChanelController.assignOwner...');
        Case cas = [SELECT Id, Status, OwnerId, First_user_to_own_the_case__c FROM Case WHERE Id =: caseId];
        Boolean result = false;

        if (String.isNotBlank(cas.First_user_to_own_the_case__c)) {
            return new Response(result);
        }

        for (CaseHistory history_i : [SELECT Id, OldValue, NewValue FROM CaseHistory WHERE CaseId =: caseId AND Field = 'Owner' ORDER BY CreatedDate, Id]) {
            String oldValue = String.valueOf(history_i.OldValue);
            String newValue = String.valueOf(history_i.NewValue);
            if (oldValue.startsWith('00G') && newValue.startsWith('005')) {
                cas.First_user_to_own_the_case__c = newValue;
                cas.Status = 'In_Progress';
                result = true;
                update cas;
                break;
            }
        }

        return new Response(result);
    }

    public class StatusListWrapper {
        @AuraEnabled
        public List <ServiceStatusWrapper> avaliableStatusList {get;set;}
        @AuraEnabled
        public List <ServiceStatusWrapper> depricatedStatusList {get;set;}

        public StatusListWrapper(){
            this.avaliableStatusList = new LIst <ServiceStatusWrapper> ();
            this.depricatedStatusList = new LIst <ServiceStatusWrapper> ();
        }
    }

    public class ServiceStatusWrapper {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String developerName {get;set;}
        @AuraEnabled
        public String masterLabel {get;set;}

        public ServiceStatusWrapper(ServicePresenceStatus status) {
            this.id = String.valueOf(status.Id).substring(0, 15);
            this.developerName = status.DeveloperName;
            this.masterLabel = status.MasterLabel;
        }
    }
}