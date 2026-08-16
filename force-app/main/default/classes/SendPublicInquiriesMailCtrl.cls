/*
    * @author           Israel Chayon        <israelch@assuta.co.il>
    * @Test             SendPublicInquiriesMailCtrlTest
    * @modifiedBy       Israel Chayon        <israelch@assuta.co.il>
    * @created          
    * @modified         25-07-2021
    * @description      The apex controller of "SendPublicInquiriesMail" lightning component
    * @modified         31-08-2022     Ortal kazum        <ortalk@assuta.co.il>         
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class SendPublicInquiriesMailCtrl {

    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Fetch children cases and wraps them for the lightning component "SendPublicInquiriesMail"
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param        caseId        Id of the current case on screen
    * @return       ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static List<CaseWrapper> getChildCases(Id caseId) {
        Set<Id> caseIds = new Set<Id>();
        Set<Id> fileIds = new Set<Id>();
        caseIds.add(caseId);
        Map<Id, List<File__c>> caseIdToFiles = new Map<Id, List<File__c>>();
        List<CaseWrapper> caseWrapperList = new List<CaseWrapper>();            
        for (Case record : [SELECT Id, ParentId, Owner_Queue_wf__c, AccountId, CaseNumber, Responsible_Employee_Notes__c, 
                                   Treating_Employee_Notes__c, Created_date_no_time_text__c, Case_subject__c, sub_case_subject__c,
                                   ToLabel(Status), Treating_Employee__c, Responsible_Employee__c, Treating_Employee__r.First_Name__c,
                                   Responsible_Employee__r.First_Name__c, Treating_Employee__r.Last_Name__c, Responsible_Employee__r.Last_Name__c, 
                                   Treating_Employee__r.Email__c, Responsible_Employee__r.Email__c, anonymous_case__c, Site_Public_Inquiry__r.Site_Code__c
                            FROM Case 
                            WHERE ParentId =: caseId
                            AND Status != 'Not_Active']) {
            caseIds.add(record.Id);
            caseWrapperList.add(new CaseWrapper(record));
        }
        if (!caseIds.isEmpty()){
            for (File__c file : [SELECT Id, Name, Case__c FROM File__c WHERE Case__c IN: caseIds ORDER BY createdDate DESC]) {                
                fileIds.add(file.Id);
                if(!caseIdToFiles.containsKey(file.Case__c)) {
                    caseIdToFiles.put(file.Case__c, new List<File__c>());
                }
                caseIdToFiles.get(file.Case__c).add(file);
            }

            System.debug('fileIds: size: ' + fileIds.size() + ' value: ' + fileIds);
            System.debug('caseIdToFiles: size: ' + caseIdToFiles.size() + ' value: ' + caseIdToFiles);  
            if (!caseIdToFiles.isEmpty()) {
                Map<Id, String> conDocTofileId = new Map<Id, String>();                                     
                for (ContentDocumentLink cdl_i : [SELECT LinkedEntityId                                 
                                                ,ContentDocumentId                                                
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId IN :fileIds 
                                                ORDER BY SystemModstamp  DESC]) {                                                 
                    conDocTofileId.put(cdl_i.ContentDocumentId, cdl_i.LinkedEntityId); 
                }
                System.debug('conDocTofileId ' + conDocTofileId.size() + 'value' + conDocTofileId);
               
                List<String> filesLst = conDocTofileId.values();
                for (CaseWrapper cw : caseWrapperList) {                       
                    List<File__c> files = new List<File__c>();                                             
                    if (caseIdToFiles.containsKey(cw.caseId)) {                                          
                        for (File__c file_i :caseIdToFiles.get(cw.caseId)) {
                            if (filesLst.contains(file_i.Id)) {
                                files.add(file_i);
                            }
                        }
                    }     
                    if (caseIdToFiles.containsKey(cw.parentId)) {                        
                        for (File__c file_i :caseIdToFiles.get(cw.parentId)) {
                            if (filesLst.contains(file_i.Id)) {
                                files.add(file_i);
                            }
                        }
                    }                                   
                    cw.files = files;                             
                }                              
            }
        }
        System.debug('caseWrapperList: ' + caseWrapperList);
        return caseWrapperList;
    }

    /*
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Send the relevant emails for the lightning component "SendPublicInquiriesMail"
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param        caseWrapperListJsonStr        all the data needed by "SendPublicInquiriesMail"
    *               parentCaseId                  The Id of the current case on screen
    * @return       ---
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static Boolean sendEmail(String caseWrapperListJsonStr, Id parentCaseId) {
        Savepoint sp = Database.setSavepoint();
        try {  
            List<EmailMessage> emailMessages = new List<EmailMessage>();
            Map<String, Id> emailTempIds = getEmailTemplate();
            List<Case> caseListToUpdate = new List<Case>();            
            caseListToUpdate.add(new Case(Id = parentCaseId, Status = 'ThirdParty'));                     
            List<CaseWrapper> caseWrapperList = (List<CaseWrapper>)JSON.deserialize(caseWrapperListJsonStr, List<CaseWrapper>.class);
            Map<Id, List<Id>> caseIdToFilesIds = new Map<Id, List<Id>>();
            Set<Id> fileIds = new Set<Id>();            
            
            for (CaseWrapper cw : caseWrapperList) {
                if (cw.isCaseChecked) {                                                                      
                    emailMessages.addAll(createEmailMessages(cw, emailTempIds, parentCaseId));
                    caseListToUpdate.add(getCaseToUpdate(cw));                                       
                    if (!cw.fileIds.isEmpty()) {
                        caseIdToFilesIds.put(cw.caseId, cw.fileIds);
                        fileIds.addAll(cw.fileIds);
                    }                                       
                }
            }
            System.debug('caseListToUpdate: size: ' + caseListToUpdate.size() + ' value: ' + caseListToUpdate);   
            if (!caseListToUpdate.isEmpty()) {
                update caseListToUpdate;
            }
            System.debug('emailMessages: size: ' + emailMessages.size() + ' value: ' + emailMessages);  
            System.debug('caseIdToFilesIds: size: ' + caseIdToFilesIds.size() + ' value: ' + caseIdToFilesIds);  
            if (!emailMessages.isEmpty()) {
                createEmailAndDocument(emailMessages, caseIdToFilesIds, fileIds); 
            }                            
            return true;
        }
        catch (dmlexception x) {
            Database.rollback(sp);
            Log__c log = new Log__c();
            log.Class__c = 'SendPublicInquiriesMailCtrl';
            log.Method__c = 'sendEmail';
            String debugString = '###### APEX EXCEPTION OCCURED ###### : '+x.getMessage()+'\n'+'###### EXCEPTION OCCURED CAUSE ###### : '+x.getCause()+'\n'+'###### EXCEPTION OCCURED ON ###### : '+x.getLineNumber();
            system.debug(debugString);
            log.Message__c = debugString;
            log.UserId__c = UserInfo.getUserId();
            insert log;
            return false;
        }
    }

    static Map<String, Id> getEmailTemplate() {
        Map<String, Id> emailTempIds = new Map<String, Id> ();            
        List<String> emailTempName = new List<String> {'AssutaPublicInquiriesResponsible','AssutaPublicInquiriesResponsibleAshdod',
                                                        'AssutaPublicInquiriesResponsible_Anonymous','AssutaPublicInquiriesResponsible_AnonymousAshdod',
                                                        'AssutaPublicInquiriesTreating','AssutaPublicInquiriesTreatingAshdod',
                                                        'AssutaPublicInquiriesTreating_Anonymous','AssutaPublicInquiriesTreating_AnonymousAshdod'};
                                                        
        for (EmailTemplate emailTemp :[SELECT Id, DeveloperName
                                        FROM EmailTemplate                                            
                                        WHERE DeveloperName IN :emailTempName]) {
            emailTempIds.put(emailTemp.DeveloperName, emailTemp.Id);                    
        }
        System.debug('emailTempIds: size: ' + emailTempIds.size() + ' value: ' + emailTempIds); 
        return emailTempIds;
    } 
    
    static Case getCaseToUpdate(CaseWrapper cw) {
        Case c = new Case(Id = cw.caseId);
        if (cw.isResponsibleChecked || cw.isTakingCareChecked) {
            if(cw.isResponsibleNotesChecked && cw.responsibleNotes != null) {
                c.Responsible_Employee_Notes__c = cw.responsibleNotes;
            }            
            if(cw.isTakingCareNotesChecked && cw.takingCareNotes != null) {
                c.Treating_Employee_Notes__c = cw.takingCareNotes;                
            }            
            c.Status = 'Awaits_Response';
            c.Time_The_Mail_Was_Sent__c = Date.today();
            return c;
        }

        return null;
    }
    
    static List<EmailMessage> createEmailMessages(CaseWrapper cw, Map<String, Id> emailTempIds, Id parentCaseId) {         
        List<EmailMessage> emails = new List<EmailMessage>(); 
        String emailTemplate;
        String fromAdress = cw.siteCode == '33' ? 'pniotash@assuta.co.il' :'pniot@assuta.co.il';
        if (cw.isResponsibleChecked && cw.responsibleMail != null) {   
            EmailMessage em = new EmailMessage();         
            emailTemplate = cw.anonymousCase ? 'AssutaPublicInquiriesResponsible_Anonymous' : 'AssutaPublicInquiriesResponsible';           
            emailTemplate = cw.siteCode == '33' ? emailTemplate + 'Ashdod': emailTemplate; 
            em.AccountId__c = cw.accId;
            em.ExpectedSendingDateTime__c = Datetime.now();
            em.EmailTemplateId = emailTempIds.get(emailTemplate);            
            em.EmailTemplateDeveloperName__c = emailTemplate;            
            em.FromAddress = fromAdress;
            em.ParentId = cw.caseId;
            em.ToAddress = cw.responsibleMail;
            em.Automation_name__c = 'PublicInquiriesSendAlerts';
            System.debug('em: ' + em);
            emails.add(em);
        }
        if (cw.isTakingCareChecked && cw.takingCareMail != null) {
            EmailMessage em2 = new EmailMessage();   
            emailTemplate = cw.anonymousCase ? 'AssutaPublicInquiriesTreating_Anonymous' : 'AssutaPublicInquiriesTreating';            
            emailTemplate = cw.siteCode == '33' ? emailTemplate + 'Ashdod': emailTemplate;            
            em2.AccountId__c = cw.accId;
            em2.ExpectedSendingDateTime__c = Datetime.now();           
            em2.EmailTemplateId = emailTempIds.get(emailTemplate);             
            em2.EmailTemplateDeveloperName__c = emailTemplate;            
            em2.FromAddress = fromAdress;
            em2.ParentId = cw.caseId;
            em2.ToAddress = cw.takingCareMail; 
            em2.Automation_name__c = 'PublicInquiriesSendAlerts';
            System.debug('em2: ' + em2);
            emails.add(em2);
        }              
        return emails;
    }

    static void createEmailAndDocument (List<EmailMessage> emailMessages,  Map<Id, List<Id>> caseIdToFilesIds, Set<Id> fileIds) {        
        Set<Id> emIds = new Set<Id>();
        List<Database.SaveResult> emList = Database.insert(emailMessages, false);            
        for (Database.SaveResult em : emList) {
            if (em.isSuccess()) {
                emIds.add(em.getId());
            }
        }  
        System.debug('emIds: size: ' + emIds.size() + ' value: ' + emIds);    
        if (!emIds.isEmpty() && !caseIdToFilesIds.isEmpty()) {
            Map<Id, List<Id>> caseIdToEmails = new Map<Id, List<Id>>();
            for (EmailMessage em_i :[SELECT Id, ParentId FROM EmailMessage WHERE Id IN :emIds]) {
                if(!caseIdToEmails.containsKey(em_i.ParentId)) {
                    caseIdToEmails.put(em_i.ParentId, new List<String>());
                }
                caseIdToEmails.get(em_i.ParentId).add(em_i.Id);                    
            }
            Map<Id, String> fileIdToConDocIds = getContentDocument(fileIds);
            System.debug('caseIdToEmails: size: ' + caseIdToEmails.size() + ' value: ' + caseIdToEmails); 
            System.debug('fileIdToConDocIds: size: ' + fileIdToConDocIds.size() + ' value: ' + fileIdToConDocIds);

            if (!caseIdToEmails.isEmpty() && !fileIdToConDocIds.isEmpty()) {
                List<ContentDocumentLink> cDocLinkToInsert = new List<ContentDocumentLink>();
                for (Id caseId : caseIdToFilesIds.keySet()) {
                    if (caseIdToEmails.containsKey(caseId)) {
                        for (Id emailId : caseIdToEmails.get(caseId)) {
                            for (Id fileId :caseIdToFilesIds.get(caseId)) {
                                if (fileIdToConDocIds.containsKey(fileId)) {
                                    cDocLinkToInsert.add(createContentDocumentLink(
                                                        emailId, 
                                                        fileIdToConDocIds.get(fileId))
                                    );
                                }                                
                            }
                        }
                    }  
                }
                System.debug('cDocLinkToInsert: size: ' + cDocLinkToInsert.size() + ' value: ' + cDocLinkToInsert);
                if(!cDocLinkToInsert.isEmpty()){
                    insert cDocLinkToInsert;     
                }                                                                   
            }  
        }
    }  

    static Map<Id, String> getContentDocument(Set<Id> filesIds) {      
        Map<Id, String> fileIdToConDocIds = new Map<Id, String>();                                     
        for (ContentDocumentLink cdl_i : [SELECT LinkedEntityId
                                                //, ContentDocument.LatestPublishedVersionId   
                                                ,ContentDocumentId                                                
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId IN :filesIds]) {
            fileIdToConDocIds.put(cdl_i.LinkedEntityId, cdl_i.ContentDocumentId);                    
        }
        System.debug('fileIdToConDocIds: size: ' + fileIdToConDocIds.size() + ' value: ' + fileIdToConDocIds);
        return fileIdToConDocIds;
    }

    static ContentDocumentLink createContentDocumentLink (Id emailMessageId, Id conDocumentId) {
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocumentId;
        cDocLink.LinkedEntityId = emailMessageId;                
        //cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        return cDocLink;
    }    
   
    public class CaseWrapper {
        @AuraEnabled public Boolean isCaseChecked = true;
        @AuraEnabled public Boolean isResponsibleChecked;
        @AuraEnabled public Boolean isTakingCareChecked = true;
        @AuraEnabled public Boolean isResponsibleNotesChecked = false;
        @AuraEnabled public Boolean isTakingCareNotesChecked = false;        
        @AuraEnabled public Boolean isFilesChecked = false; 
        @AuraEnabled public String takingCareNotes;
        @AuraEnabled public String responsibleNotes;
        @AuraEnabled public String takingCareId;
        @AuraEnabled public String takingCareMail;
        @AuraEnabled public String responsibleId;
        @AuraEnabled public String responsibleMail;
        @AuraEnabled public String takingCareFullName;
        @AuraEnabled public String responsibleFullName;
        @AuraEnabled public String caseNum;
        @AuraEnabled public String subject;
        @AuraEnabled public String subSubject;
        @AuraEnabled public String status;
        @AuraEnabled public String createdDate;
        @AuraEnabled public String caseId;
        @AuraEnabled public String parentId;
        @AuraEnabled public String accId;
        @AuraEnabled public Boolean isAshdod;
        @AuraEnabled public Boolean anonymousCase;
        @AuraEnabled public String siteCode;
        @AuraEnabled public List<File__c> files;
        @AuraEnabled public List<Id> fileIds;

        public CaseWrapper(Case record) {
            this.caseId = record.Id;
            this.parentId = record.ParentId;
            this.accId = record.AccountId;
            this.caseNum = record.CaseNumber;
            this.subject = record.Case_subject__c;
            this.subSubject = record.sub_case_subject__c;
            this.status = record.Status;
            this.createdDate = record.Created_date_no_time_text__c;
            this.takingCareFullName = record.Treating_Employee__c != null ? record.Treating_Employee__r.First_Name__c + ' ' + record.Treating_Employee__r.Last_Name__c : '';
            this.responsibleFullName = record.Responsible_Employee__c != null ? record.Responsible_Employee__r.First_Name__c + ' ' + record.Responsible_Employee__r.Last_Name__c : '';
            this.takingCareMail = record.Treating_Employee__c != null ? record.Treating_Employee__r.Email__c : '';
            this.responsibleMail = record.Responsible_Employee__c != null ? record.Responsible_Employee__r.Email__c : '';
            this.takingCareId = record.Treating_Employee__c;
            this.responsibleId = record.Responsible_Employee__c;
            this.isAshdod = record.Owner_Queue_wf__c != null && record.Owner_Queue_wf__c.contains('אשדוד') ? true : false;
            this.isResponsibleChecked = this.isAshdod ? false : true;
            this.anonymousCase = record.anonymous_case__c;
            this.siteCode = record.Site_Public_Inquiry__r.Site_Code__c;
            this.files = new List<File__c>();
            this.fileIds = new List<Id>();
        }
    }
}