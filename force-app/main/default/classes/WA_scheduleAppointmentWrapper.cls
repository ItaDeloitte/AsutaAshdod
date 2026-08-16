public with sharing class WA_scheduleAppointmentWrapper {
    @AuraEnabled  
    public Id caseId;           
    @AuraEnabled      
    public Id appointmentId; 
    @AuraEnabled
    public Id patientAccount;
    @AuraEnabled
    public String dateText;
    @AuraEnabled
    public String domainCode;              
    @AuraEnabled        
    public String SMSAddress;    
    @AuraEnabled
    public String kitForInst;
    @AuraEnabled
    public Boolean isSequence;    
    @AuraEnabled
    public String phoneNumber;  
    @AuraEnabled
    public String remainderType;
    @AuraEnabled
    public String procedureCode; 
    @AuraEnabled
    public String patientName;         
    @AuraEnabled
    public String appointmentTime;
    @AuraEnabled
    public Boolean isPrivateService; 
    @AuraEnabled
    public String calendarDirection;      
    @AuraEnabled
    public String accurateSiteAddress;      
    @AuraEnabled
    public String exactLocationInDomain;
    @AuraEnabled
    public Boolean converPrivateZone;  
    @AuraEnabled
    public String messagingChannelId;   
    @AuraEnabled
    public String messagingChannelName;   
    @AuraEnabled
    public Boolean isAssutaOneProcedure; 
    @AuraEnabled
    public String fTPreSurgeryUploadFiles; 
    @AuraEnabled
    public Boolean isDocRequired;
    @AuraEnabled
    public Boolean isVirtualAppointment;    
    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String payerFactorCode;
    @AuraEnabled
    public String receiptNum;
    @AuraEnabled
    public String automationName; 
    
    public WA_scheduleAppointmentWrapper(Id caseId, String dateText, String domainCode, String SMSAddress, String phoneNumber, 
                                         String kitForInst, Boolean isSequence, String remainderType, Id appointmentId, 
                                         Id patientAccount, String appointmentTime, Boolean isPrivateService, 
                                         String calendarDirection, String accurateSiteAddress, String exactLocationInDomain,
                                         Boolean converPrivateZone, String procedureCode, String messagingChannelName,
                                         String messagingChannelId, Boolean isAssutaOneProcedure, String fTpreSurgeryUploadFiles, 
                                         Boolean isDocRequired, Boolean isVirtualAppointment, String patientName,
                                         String payerFactorCode, String firstName, String receiptNum, String automationName) {        
        this.caseId = caseId;
        this.dateText = dateText;                
        this.firstName = firstName;
        this.receiptNum = receiptNum;
        this.domainCode = domainCode;
        this.SMSAddress = SMSAddress;
        this.phoneNumber = phoneNumber;
        this.kitForInst = kitForInst;
        this.isSequence = isSequence; 
        this.patientName = patientName;    
        this.isDocRequired = isDocRequired; 
        this.procedureCode = procedureCode;
        this.remainderType = remainderType; 
        this.appointmentId = appointmentId;
        this.patientAccount = patientAccount;
        this.automationName = automationName; 
        this.payerFactorCode = payerFactorCode;      
        this.appointmentTime = appointmentTime; 
        this.isPrivateService = isPrivateService; 
        this.calendarDirection = calendarDirection;  
        this.converPrivateZone = converPrivateZone;  
        this.messagingChannelId = messagingChannelId;
        this.messagingChannelName = messagingChannelName;          
        this.accurateSiteAddress = accurateSiteAddress; 
        this.isAssutaOneProcedure = isAssutaOneProcedure;              
        this.exactLocationInDomain = exactLocationInDomain;        
        this.fTpreSurgeryUploadFiles = fTpreSurgeryUploadFiles;
        this.isVirtualAppointment = isVirtualAppointment;        
    }
}