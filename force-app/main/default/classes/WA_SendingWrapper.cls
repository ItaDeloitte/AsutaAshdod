public class WA_SendingWrapper {
    
    @AuraEnabled  
    public String WhatsAppId {get;set;} 
    @AuraEnabled  
    public String MessagingTemplate {get;set;}               
    @AuraEnabled
    public String messagingEndUserId {get;set;}
    @AuraEnabled
    public String Values4ScheduledWA {get;set;} 
    @AuraEnabled
    public String AutomationName {get;set;} 
    


    public WA_SendingWrapper(String WhatsAppId, String MessagingTemplate, String messagingEndUserId, String Values4ScheduledWA, String AutomationName) { 
        this.WhatsAppId = WhatsAppId;
        this.MessagingTemplate = MessagingTemplate;
        this.messagingEndUserId = messagingEndUserId;
        this.Values4ScheduledWA = Values4ScheduledWA; 
        this.AutomationName = AutomationName;
    }
}