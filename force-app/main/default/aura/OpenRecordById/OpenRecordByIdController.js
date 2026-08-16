({
    // Sets an empApi error handler on component initialization
    onInit : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');
        //The path of the event to which we listen
        const channel = '/event/Pop_Record__e';
        // Replay option to get new events From top
        const replayId = -1;
        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event: ' + JSON.stringify(eventReceived));
            console.log('RecordId: ' + typeof recordId);
            console.log('UserId: ' + typeof userId);
            
            var recordId = eventReceived['data']['payload']['Record_ID__c'];
            var userId = eventReceived['data']['payload']['User_ID__c'];
            var closeTab = eventReceived['data']['payload']['Is_Clos_Tab__c'];
            if(userId == $A.get("$SObjectType.CurrentUser.Id")){
                var redirect = $A.get("e.force:navigateToSObject");
                // Pass the record ID to the event
                redirect.setParams({
                "recordId": recordId
                });
                var TimeOut = new Date();
                console.log('Get TimeOut before' + new Date());
                console.log('Get TimeOut before' + TimeOut);
                // Open the record
                setTimeout($A.getCallback(function() {redirect.fire();}), 500);
                console.log('Get TimeOut After' + new Date()); 
                if(closeTab){
                    var workspaceAPI = component.find("workspace");
                    console.log('workspaceAPI: ' + workspaceAPI);
                    workspaceAPI.getAllTabInfo().then(function(response) {
                        console.log('Response: ' + response);
                        if(response.length>0){
                            var focusedTabIds = response;
                            focusedTabIds.forEach(i => {
                                console.log('tabId: ' + i.tabId);
                                workspaceAPI.closeTab({tabId: i.tabId});                                             
                            });
                        }
                    })
                    .catch(function(error) {
                        console.log('Error:' + error);
                    });
                }
            }   
        }))

        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            //debugger
            console.error('EMP API error: ', JSON.stringify(error));
        }));  
    } 
})