global without sharing class LiveAgentChatQueueable implements Queueable, Database.AllowsCallouts{
    
    public static final Integer LONGPULLING_MINUTES = 10;

    public Integer orderNumber;
    public Integer postCount;
    public Integer sequenceNumber;
    public LiveAgentChatUtil.SessionWrapper session; 
    public SMS_Parent_Session__c messageSession;
    public Datetime lastActivityDateTime;
    public LiveAgentChatUtil.IncommingMessageWrapper firstAgentResponse;// welcome message, will be skipped  

    public LiveAgentChatQueueable(SMS_Parent_Session__c messageSession) {
        this.orderNumber = -1;
        this.sequenceNumber = -1;
        this.postCount = 1;
        this.session = null;
        this.messageSession = messageSession; 
        this.lastActivityDateTime = System.now();// time when job was first time queued
    }
    
    private void updateLastActivityDateTime(){
        this.lastActivityDateTime = System.now();

        this.messageSession.Last_Session_Activity__c = System.now();
        update this.messageSession;
    }

    private void updateSessionEnd(){
        this.messageSession.Session_ended__c = true;
    }

    

    public void execute(QueueableContext context) {
        // skip if this job was waited X minutes
        if (System.now() >= this.lastActivityDateTime.addMinutes(LONGPULLING_MINUTES)){
            this.updateSessionEnd();
            System.abortJob(context.getJobId());
            return;
        }


        LiveAgentChatUtil.IncommingMessagesWrapper response;
        // firs run
        if (this.session == null){
            this.session = LiveAgentChatUtil.createSession();
            LiveAgentChatUtil.startSession(session, this.messageSession.Phone__c);
            // incriment for next job
            this.postCount = this.postCount + 1;
            this.orderNumber =  this.orderNumber + 1;
            if (!Test.isRunningTest()) {
            	System.enqueueJob(this);
            }
        } else {
            // all next run longpulling 
            System.debug('this.orderNumber '+this.orderNumber);

            Boolean chatWasInited = false;
            Boolean chatEnded = false;

            response = LiveAgentChatUtil.checkChanel(session, this.sequenceNumber, this.orderNumber); 
            List <SMS__c> outgoingSMSList = new List <SMS__c> ();


            if (response != null){
                this.sequenceNumber = response.sequence;
                for (LiveAgentChatUtil.IncommingMessageWrapper resp_i : response.messages){
                    if (firstAgentResponse != null && resp_i.type == 'ChatMessage'){
                        SMS__c newSms = new SMS__c(
                            Content__c = resp_i.message.text,
                            Phone_Number__c = this.messageSession.Phone__c,
                            Type__c = 'Outgoing',
                            SMS_Parent_Session__c = this.messageSession.id, 
                            Sent_to_chat__c = true
                        );
                        outgoingSMSList.add(newSms);
                    }
                    if (resp_i.type == 'ChatMessage' && firstAgentResponse == null){
                        chatWasInited = true;
                        firstAgentResponse = resp_i;
                    }
                    if (resp_i.type == 'ChatEnded' || resp_i.type == 'ChatRequestFail'){
                        chatEnded = true;
                    }
                    
                }
            }
            
            // send message after you've recived initial response
            if (response != null && !response.messages.isEmpty() &&  firstAgentResponse != null){
                List <SMS__c> sentToChatSmsList = new List <SMS__c> ();
                for (SMS__c sms_i : [SELECT ID, Content__c, Sent_to_chat__c, Patient_Answer__c FROM SMS__c WHERE SMS_Parent_Session__c =: this.messageSession.id AND Sent_to_chat__c = false ORDER BY CreatedDate LIMIT 50]){

                    if (String.isNotBlank(sms_i.Content__c) || String.isNotBlank(sms_i.Patient_Answer__c)){
                        LiveAgentChatUtil.sendNewMessageToAgent(session, String.isNotBlank(sms_i.Content__c) == true ? sms_i.Content__c : sms_i.Patient_Answer__c, this.postCount);
                        this.postCount = this.postCount + 1;   
                    } 
                    sms_i.Sent_to_chat__c = true;
                    sentToChatSmsList.add(sms_i);
                }

                System.debug('sentToChatSmsList.size '+sentToChatSmsList.size());
                if (!sentToChatSmsList.isEmpty()){
                    this.updateLastActivityDateTime();
                    update sentToChatSmsList;
                }  
                
            }
            this.orderNumber =  this.orderNumber + 1;
            System.debug('outgoingSMSList.size '+outgoingSMSList.size());
            if (!outgoingSMSList.isEmpty()){
                insert outgoingSMSList;
                this.updateLastActivityDateTime();
            }

            if (!chatEnded) {
                if (!Test.isRunningTest()) {
                	System.enqueueJob(this);
                }
            } else {
                this.updateSessionEnd();
            }
        }
       
    }




}