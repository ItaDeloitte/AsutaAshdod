//WA_ReminderBatchableTest
public with sharing class WA_ReminderWrapper {
    
    @AuraEnabled  
    public String caseId; 
    @AuraEnabled  
    public String accountId;    
    @AuraEnabled  
    public String siteName;  
    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String domainCode;
    @AuraEnabled
    public String SMSAddress; 
    @AuraEnabled        
    public String dayDateHour;
    @AuraEnabled  
    public String phoneNumber; 
    @AuraEnabled
    public String reminderType;   
    @AuraEnabled
    public String appointmentId;                  
    @AuraEnabled
    public String messagingEndUserId; 
    @AuraEnabled
    public String formtitanArrivalLink;
    @AuraEnabled
    public String exactLocationInDomain;
    @AuraEnabled
    public Boolean isVirtual;
    @AuraEnabled
    public String automationName;
    @AuraEnabled
    public String medicalProcedureMarketingName;   
    
    public WA_ReminderWrapper(String caseId, String accountId, String siteName, String firstName, 
                              String domainCode, String SMSAddress, String dayDateHour, 
                              String phoneNumber, String appointmentId, String messagingEndUserId, 
                              String formtitanArrivalLink, String exactLocationInDomain, String medicalProcedureMarketingName, 
                              String reminderType, Boolean isVirtual, String automationName) {
        this.caseId = caseId;        
        this.siteName = siteName;
        this.firstName = firstName;
        this.isVirtual = isVirtual;
        this.accountId = accountId;
        this.domainCode = domainCode;
        this.SMSAddress = SMSAddress;
        this.dayDateHour = dayDateHour;
        this.phoneNumber = phoneNumber;        
        this.reminderType = reminderType;        
        this.appointmentId = appointmentId;
        this.automationName = automationName;
        this.messagingEndUserId = messagingEndUserId;
        this.formtitanArrivalLink = formtitanArrivalLink; 
        this.exactLocationInDomain = exactLocationInDomain;   
        this.medicalProcedureMarketingName = medicalProcedureMarketingName;        
    }
}