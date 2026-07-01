public class WA_AshdodWrapper {
        
    @AuraEnabled public String accountId;
    @AuraEnabled public String siteName;
    @AuraEnabled public String firstName;
    @AuraEnabled public String sendingType;          
    @AuraEnabled public String dayDateHour; 
    @AuraEnabled public String phoneNumber; 
    @AuraEnabled public String appointmentId;   
    @AuraEnabled public String automationName;
    @AuraEnabled public String mProcedureName;             
    @AuraEnabled public String messageTemplate;
    @AuraEnabled public String messagingEndUserId; 
    @AuraEnabled public String formtitanArrivalLink;     
    @AuraEnabled public Decimal daysUntilAppointment; 
    @AuraEnabled public String colon1DayBeforeLink;
    @AuraEnabled public String colon2DayBeforeLink; 
    @AuraEnabled public String colon3DayBeforeLink;
    @AuraEnabled public String colon4DayBeforeLink;       
    @AuraEnabled public String colonKid2DaysBeforeLink;  
    @AuraEnabled public String colonKid3DaysBeforeLink;                
    @AuraEnabled public String colonParent2DaysBeforeLink;     
    @AuraEnabled public String colonParent3DaysBeforeLink;  
    
    public WA_AshdodWrapper(Appointment__c appointment, String messageTemplate, String automationName, String messagingEndUserId, String sendingType) {
        this.sendingType          = sendingType;        
        this.automationName       = automationName;     
        this.messageTemplate      = messageTemplate;
        this.messagingEndUserId   = messagingEndUserId;         

        this.appointmentId        = (String)appointment.get('Id');
        this.dayDateHour          = (String)appointment.get('day_date_hour__c');       
        this.formtitanArrivalLink = (String)appointment.get('formtitan_arrival_link__c');
        this.daysUntilAppointment = (Decimal)appointment.get('Days_Until_Appointment__c'); 
        
        // Site
        if (appointment.getSObject('Site__r') != null) {
            this.siteName = (String)appointment.getSObject('Site__r').get('Name');
        }  

        // Patient Account
        if (appointment.getSObject('Patient_Account__r') != null) {
            this.accountId   = (String)appointment.getSObject('Patient_Account__r').get('Id');
            this.firstName   = (String)appointment.getSObject('Patient_Account__r').get('FirstName');
            this.phoneNumber = (String)appointment.getSObject('Patient_Account__r').get('SMS_Phone_Number__c');        
        }

        // Medical Procedure
        if (automationName == 'WA_AshdodColonoscopySchedulableBatch' ) {
             if (appointment.getSObject('Medical_Procedure__r') != null) {
                SObject proc = appointment.getSObject('Medical_Procedure__r');
                this.mProcedureName             = (String)proc.get('Name');
                this.colon1DayBeforeLink        = (String)proc.get('Colonoscopy1DayBeforeLink__c');
                this.colon2DayBeforeLink        = (String)proc.get('Colonoscopy2DaysBeforeLink__c');
                this.colon3DayBeforeLink        = (String)proc.get('Colonoscopy3DaysBeforeLink__c');
                this.colon4DayBeforeLink        = (String)proc.get('Colonoscopy4DaysBeforeLink__c');
                this.colonKid2DaysBeforeLink    = (String)proc.get('ColonoscopyKid2DaysBeforeLink__c');
                this.colonKid3DaysBeforeLink    = (String)proc.get('ColonoscopyKid3DaysBeforeLink__c');
                this.colonParent2DaysBeforeLink = (String)proc.get('ColonoscopyParent2DaysBeforeLink__c'); 
                this.colonParent3DaysBeforeLink = (String)proc.get('ColonoscopyParent3DaysBeforeLink__c');   
            }
        }       
    }
}