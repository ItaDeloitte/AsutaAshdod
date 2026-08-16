// Created: Evgeniy Kravchuk
// Date: 16.01.2020
// Description: custom wrappers for sobjects for better work with front
public class SObjectCustomWrapper {

    // Medical_Procedure__c wrapper
    public class Procedure {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String marketingName {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> protocols {get;set;}
        @AuraEnabled
        public Boolean waitingList {get;set;}
        @AuraEnabled
        public Id domainId {get;set;}
        @AuraEnabled
        public String domainName {get;set;}

        public Procedure(Medical_Procedure__c procedure, List<PicklistUtil.PicklistValue> protocolValues) {
            this.id = procedure.Id;
            this.name = procedure.Name;
            this.marketingName = procedure.Marketing_Procedure_Name__c;
            this.code = procedure.Procedure_Code__c;
            this.protocols = new List<PicklistUtil.PicklistValue>();
            for (PicklistUtil.PicklistValue protocol_i : protocolValues) {
                if (procedure.Protocols__c != null && procedure.Protocols__c.split(';').contains(protocol_i.value)) {
                    this.protocols.add(protocol_i);
                }
            }
            this.waitingList = procedure.Waiting_List__c;
            this.domainId = procedure.Domain__c;
            this.domainName = procedure.Domain__r.Name;
        }
    }

    // File__c wrapper
    public class File {
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String link {get;set;}

        public File(File__c file, Id versionId) {
            this.Id = file.Id;
            this.Name = file.Name + ' ' + parseDate(file.ReferralDate__c);
            this.link = versionId == null ? null : System.Url.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + versionId;
        }

        private String parseDate(Date fDate) {
            return addZero(fDate.day()) + '/' + addZero(fDate.month()) + '/' + fDate.year();
        }

        private String addZero(Integer num) {
            return num < 10 ? '0' + String.valueOf(num) : String.valueOf(num);
        }
    }

    // Technician wrapper
    public class Technician {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String siteCode {get;set;}
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String calendarCode {get;set;}
        @AuraEnabled
        public Boolean withProcedures {get;set;}

        public Technician(String label) {
            this.label = label;
            this.id = label == System.Label.Without_a_technician ? 'null' : 'all';
            this.siteCode = label == System.Label.Without_a_technician ? null : '84';
            this.withProcedures = label == System.Label.Without_a_technician ? false : true;
        }

        public Technician(String id, String label, String siteCode, String accountId, String calendarCode) {
            this.id = accountId + siteCode;
            this.label = label;
            this.siteCode = siteCode;
            this.accountId = accountId;
            this.calendarCode = calendarCode;
            this.withProcedures = false;
        }
    }

    public class TechnicianProcedure {
        @AuraEnabled
        public Boolean isLeading {get;set;}
        @AuraEnabled
        public Medical_Procedure__c procedure {get;set;}

        public TechnicianProcedure(Boolean isLeading, Medical_Procedure__c procedure) {
            this.isLeading = isLeading;
            this.procedure = procedure;
        }
    }

    // Ensemble error
    public class EnsembleError {
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String description {get;set;}

        public EnsembleError(String message, String description) {
            this.message = message;
            this.description = description;
        }
    }
}