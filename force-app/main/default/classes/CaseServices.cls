// Test: CaseServicesTest
// Created: Evgeniy Kravchuk
// Updated date: 29.05.2019
public class CaseServices {

    public static Map<String, RecordTypeInfo> caseRTMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    public static Map<String, String> CASE_SITE_TO_EMAIL_MAP = new Map<String, String>{
        'Ramat_Hahayal' => 'ramat.info@assuta.co.il',
        'Rishon_Letzion' => 'rishon.info@assuta.co.il'
    };

    public static void copyAccountInfo(List<Case> pNewList, Map<Id, Case> pOldMap, Set<Id> pAccountIdSet) {
        Boolean logicExecuted = false;
        Boolean isInsert = pOldMap == null;

        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Phone
                 , FirstName
                 , PersonEmail
                 , PersonBirthdate
                 , PersonContactId
                 , RecordType.DeveloperName
                 , ID_Number__c
                 , Experts_center__c
                 , payer_factor_ID__c
                 , (SELECT Id
                      FROM doc_arrangement__r
                     WHERE Arrangment_Name__c LIKE '%מומחים%'
                     LIMIT 1)
              FROM Account
             WHERE Id IN :pAccountIdSet]);
        System.debug('TR Case accountMap [' + accountMap.size() + ']: ' + accountMap);

        for (Case case_i : pNewList) {
            Case oldCase_i = pOldMap?.get(case_i.Id);

            if (((isInsert
                            && case_i.ContactId == null)
                        || (!isInsert
                            && oldCase_i.AccountId == null))
                    && accountMap.containsKey(case_i.AccountId)
                    && accountMap.get(case_i.AccountId).RecordType.DeveloperName == 'PersonAccount') {
                case_i.ContactId = accountMap.get(case_i.AccountId).PersonContactId;
                logicExecuted = true;
            }

            if (case_i.PayerFactor__c == null
                    && (case_i.RecordTypeId == caseRTMap.get('Assuta_360').getRecordTypeId()
                        || case_i.RecordTypeId == caseRTMap.get('DOC_expert').getRecordTypeId())
                    && (isInsert
                        || case_i.PayerFactor__c != oldCase_i.PayerFactor__c)
                    && accountMap.containsKey(case_i.AccountId)
                    && accountMap.get(case_i.AccountId).payer_factor_ID__c != null) {
                case_i.PayerFactor__c = accountMap.get(case_i.AccountId).payer_factor_ID__c;
                logicExecuted = true;
            }

            if (case_i.Doctor_Arrangement__c == null
                    && (case_i.RecordTypeId == caseRTMap.get('Assuta_360').getRecordTypeId()
                        || case_i.RecordTypeId == caseRTMap.get('DOC_expert').getRecordTypeId()
                        || case_i.RecordTypeId == caseRTMap.get('CaseAfterSale').getRecordTypeId())
                    && (isInsert
                        || case_i.Recommended_doc__c != oldCase_i.Recommended_doc__c)
                    && accountMap.containsKey(case_i.Recommended_doc__c)
                    && accountMap.get(case_i.Recommended_doc__c).Experts_center__c
                    && !accountMap.get(case_i.Recommended_doc__c).doc_arrangement__r.isEmpty()) {
                case_i.Doctor_Arrangement__c = accountMap.get(case_i.Recommended_doc__c).doc_arrangement__r.get(0).Id;
                logicExecuted = true;
            }

            if (case_i.Partner_Email__c == null
                    && (isInsert
                        || case_i.Partner_Name__c != oldCase_i.Partner_Name__c)
                    && accountMap.containsKey(case_i.Partner_Name__c)) {
                case_i.Birthdate_Partner__c = accountMap.get(case_i.Partner_Name__c).PersonBirthdate;
                case_i.Primary_Phone_Partner__c = accountMap.get(case_i.Partner_Name__c).Phone;
                case_i.Partner_Email__c = accountMap.get(case_i.Partner_Name__c).PersonEmail;
                case_i.Partner_ID__c = accountMap.get(case_i.Partner_Name__c).ID_Number__c;
                logicExecuted = true;
            }

            if (case_i.First_Call_Made_Female__c
                    && (isInsert
                        || !oldCase_i.First_Call_Made_Female__c)
                    && accountMap.containsKey(case_i.AccountId)) {
                case_i.Female_First_Name__c = accountMap.get(case_i.AccountId).FirstName;
                logicExecuted = true;
            }

            if (case_i.First_Call_Made_Partner__c
                    && (isInsert
                        || !oldCase_i.First_Call_Made_Partner__c)
                    && accountMap.containsKey(case_i.Partner_Name__c)) {
                case_i.Male_First_Name__c = accountMap.get(case_i.Partner_Name__c).FirstName;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case copyAccountInfo ... executed');
        }
    }

    public static void updateAccount360Info(List<Case> pNewList, Map<Id, Case> pOldMap, Set<Id> pAccountIdSet) {
        List<Account> accountToUpdateList = new List<Account>();
        Boolean isInsert = pOldMap == null;

        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Case_360__c
                 , X360_Coordinator__c
                 , X360_patient_checkbox__c
              FROM Account
             WHERE Id IN :pAccountIdSet
               AND Case_360__c IN :pNewList]);
        System.debug('TR Case accountMap [' + accountMap.size() + ']: ' + accountMap);

        for (Case case_i : pNewList) {
            if (!accountMap.containsKey(case_i.AccountId)) {
                continue;
            }

            Account account_i = accountMap.get(case_i.AccountId);
            Case oldCase_i = pOldMap?.get(case_i.Id);
            Boolean isUpdated_i = false;

            if (case_i.Status == 'סגירת אירוע אוטומטית'
                    && (isInsert
                        || case_i.Status != oldCase_i.Status)
                    && account_i.X360_patient_checkbox__c
                    && account_i.Case_360__c == case_i.Id) {
                account_i.Case_360__c = null;
                account_i.X360_Coordinator__c = null;
                account_i.X360_patient_checkbox__c = false;
                isUpdated_i = true;
            }

            if (case_i.First_user_to_own_the_case__c != null
                    && (isInsert
                        || case_i.First_user_to_own_the_case__c != oldCase_i.First_user_to_own_the_case__c)
                    && account_i.X360_Coordinator__c == null
                    && account_i.Case_360__c == case_i.Id) {
                account_i.X360_Coordinator__c = case_i.First_user_to_own_the_case__c;
                isUpdated_i = true;
            }

            if (isUpdated_i) {
                accountToUpdateList.add(account_i);
            }
        }
        System.debug('TR Case accountToUpdateList [' + accountToUpdateList.size() + ']: ' + accountToUpdateList);

        if (!accountToUpdateList.isEmpty()) {
            update accountToUpdateList;
            System.debug('TR Case updateAccountInfo ... executed');
        }
    }

    public static void fillRTFromChat(List<Case> cases) {
        Set<Id> caseRTIds = Schema.SObjectType.Case.getRecordTypeInfosById().keySet();
        Boolean logicExecuted = false;

        for (Case case_i : cases) {
            if (caseRTIds.contains(case_i.Case_Recordtype_TMP__c) && case_i.Case_Recordtype_TMP__c != case_i.RecordTypeId) {
                case_i.RecordTypeId = case_i.Case_Recordtype_TMP__c;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case fillRTFromChat ... executed');
        }
    }

    public static void fillFormtitanId(List<Case> cases) {
        for (Case case_i : cases) {
            case_i.formtitan_id_2__c = CommonService.generateRandomKey(15);
        }
        System.debug('TR Case fillFormtitanId ... executed');
    }

    public static void validateRecDoctor(List<Case> cases, Set<Id> doctorIds, Set<Id> pFactorIds) {
        Map<Id, List<Agreement__c>> agreementMap = new Map<Id, List<Agreement__c>>();
        Map<Id, String> pFactorsMap = new Map<Id, String>();
        Map<Id, Id> parentPFactorsMap = new Map<Id, Id>();
        Set<Id> docArrangementIds = new Set<Id>();
        Set<Id> caseWithPF = new Set<Id>();
        Boolean logicExecuted = false;

        // COLLECTING PARENT RAYER FACTOR'S IDS
        for (Payer_Factor__c pFactor_i : [SELECT Id, Name_of_parent__c, InsuranceCode__c FROM Payer_Factor__c WHERE Id IN: pFactorIds]) {
            pFactorsMap.put(pFactor_i.Id, pFactor_i.InsuranceCode__c);
            parentPFactorsMap.put(pFactor_i.Id, pFactor_i.Name_of_parent__c);
        }
        System.debug('pFactorsMap: size: ' + pFactorsMap.size() + ' value: ' + pFactorsMap);
        System.debug('parentPFactorsMap: size: ' + parentPFactorsMap.size() + ' value: ' + parentPFactorsMap);

        // COLLECTING DOCTOR ARRANGEMENTS
        for (Doctor_Arrangement__c docArrangement_i : [SELECT Id, Doctor__c FROM Doctor_Arrangement__c WHERE Doctor__c IN: doctorIds]) {
            docArrangementIds.add(docArrangement_i.Doctor__c);
        }
        System.debug('docArrangementIds: size: ' + docArrangementIds.size() + ' value: ' + docArrangementIds);

        // COLLECTING AGREEMENT
        for (Agreement__c agreement_i : [SELECT Id, Doctor_Account__c, PayerFactor__c, PayerFactor__r.InsuranceCode__c, PayerFactor__r.Name_of_parent__c FROM Agreement__c WHERE Doctor_Account__c IN: doctorIds]) {
            if (!agreementMap.containsKey(agreement_i.Doctor_Account__c)) {
                agreementMap.put(agreement_i.Doctor_Account__c, new List<Agreement__c>());
            }
            agreementMap.get(agreement_i.Doctor_Account__c).add(agreement_i);
        }
        System.debug('agreementMap: size: ' + agreementMap.size() + ' value: ' + agreementMap);

        for (Case case_i : cases) {
            if (pFactorsMap.get(case_i.PayerFactor__c) == '0' || pFactorsMap.get(case_i.PayerFactor__c) == '1111') {
                caseWithPF.add(case_i.Id);
                continue;
            }
            if (agreementMap.containsKey(case_i.Recommended_doc__c)) {
                for (Agreement__c agreement_i : agreementMap.get(case_i.Recommended_doc__c)) {
                    if (
                            agreement_i.PayerFactor__c == case_i.PayerFactor__c ||
                            agreement_i.PayerFactor__r.InsuranceCode__c == '0' ||
                            agreement_i.PayerFactor__r.InsuranceCode__c == '1111' ||
                            agreement_i.PayerFactor__r.Name_of_parent__c == case_i.PayerFactor__c ||
                            (parentPFactorsMap.containsKey(case_i.PayerFactor__c) && agreement_i.PayerFactor__c == parentPFactorsMap.get(case_i.PayerFactor__c)) ||
                            (parentPFactorsMap.containsKey(case_i.PayerFactor__c) && agreement_i.PayerFactor__r.Name_of_parent__c == parentPFactorsMap.get(case_i.PayerFactor__c))
                    ) {
                        caseWithPF.add(case_i.Id);
                    }
                }
            }
        }
        System.debug('caseWithPF: size: ' + caseWithPF.size() + ' value: ' + caseWithPF);

        for (Case case_i : cases) {
            if (case_i.Channel__c == 'פרטי' && !docArrangementIds.contains(case_i.Recommended_doc__c)) {
                case_i.addError(Label.There_are_no_Doctor_Arrangements);
                logicExecuted = true;
            } else if (case_i.Channel__c == 'קופה' && (!agreementMap.containsKey(case_i.Recommended_doc__c) || !caseWithPF.contains(case_i.Id))) {
                case_i.addError(Label.There_are_no_Agreements);
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case validateRecDoctor ... executed');
        }
    }

    public static void removeAgreementArrangement(List<Case> cases) {
        for (Case case_i : cases) {
            case_i.Doctor_Arrangement__c = null;
            case_i.Agreement__c = null;
        }
        System.debug('TR Case removeAgreementArrangement ... executed');
    }

    public static void runAssignFromApex(Set<Id> caseIds) {
        System.debug('CaseServices.runAssignFromApex...');
        List<Case> casesToUpdate = new List<Case>();

        List<AssignmentRule> rules = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
        System.debug('rules: size: ' + rules.size() + ' value: ' + rules);

        if (!rules.isEmpty()) {
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.AssignmentRuleHeader.AssignmentRuleId = rules.get(0).Id;

            for (Id caseId_i : caseIds) {
                Case case_i = new Case(Id = caseId_i, Apex_Assigned__c = true);
                case_i.setOptions(dmlOptions);
                casesToUpdate.add(case_i);
            }
            System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);

            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
                System.debug('TR Case runAssignFromApex ... executed');
            }
        }
    }

    public static void hasOpenCaseCheck(Set<Id> acctIds) {
        List<Account> acctsToUpdate = new List<Account>();

        List<Account> accounts = [
            SELECT Id
                 , DisableValidation__c
                 , Patient_has_open_case__c
                 , (SELECT Id, IsClosed FROM Cases WHERE IsClosed = false LIMIT 1)
              FROM Account
             WHERE Id IN: acctIds];

        for (Account acct_i : accounts) {
            if (!acct_i.Cases.isEmpty() && !acct_i.Patient_has_open_case__c) {
                acct_i.DisableValidation__c = !acct_i.DisableValidation__c;
                acct_i.Patient_has_open_case__c = true;
                acctsToUpdate.add(acct_i);
            } else if (acct_i.Cases.isEmpty() && acct_i.Patient_has_open_case__c) {
                acct_i.DisableValidation__c = !acct_i.DisableValidation__c;
                acct_i.Patient_has_open_case__c = false;
                acctsToUpdate.add(acct_i);
            }
        }
        System.debug('acctsToUpdate: size: ' + acctsToUpdate.size() + ' value: ' + acctsToUpdate);

        if (!acctsToUpdate.isEmpty()) {
            update acctsToUpdate;
            System.debug('TR Case hasOpenCaseCheck ... executed');
        }
    }

    public static void updateStatusByOwner(Set<Id> caseIds) {
        List<Case> cases = [SELECT Id, Status, OwnerId, First_user_to_own_the_case__c FROM Case WHERE Id IN: caseIds];
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        for (Case case_i : cases) {
            case_i.Status = 'In_Progress';
            if (String.isBlank(case_i.First_user_to_own_the_case__c)) {
                case_i.First_user_to_own_the_case__c = case_i.OwnerId;
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            update cases;
            System.debug('TR Case updateStatusByOwner ... executed');
        }
    }

    public static void completeMilestones(List<Case> cases) {
        List<CaseMilestone> milestones = new List<CaseMilestone>();
        Map<Id, List<CaseMilestone>> caseToCaseMilestonesMap = new  Map<Id, List<CaseMilestone>>();
       
        for (CaseMilestone milestone_i : [SELECT Id, CompletionDate, CaseId, IsCompleted FROM CaseMilestone WHERE CaseId IN: cases]) {
            if (!caseToCaseMilestonesMap.containsKey(milestone_i.CaseId)) {
                caseToCaseMilestonesMap.put(milestone_i.CaseId, new List<CaseMilestone>());
            }
            caseToCaseMilestonesMap.get(milestone_i.CaseId).add(milestone_i);
            
        }
        System.debug('caseToCaseMilestonesMap: size: ' + caseToCaseMilestonesMap.size() + ' value: ' + caseToCaseMilestonesMap);

        for (Case case_i : cases) {
            if (caseToCaseMilestonesMap.containsKey(case_i.Id)) {                
                for (CaseMilestone milestone_i : caseToCaseMilestonesMap.get(case_i.Id)) {
                    if (case_i.Status == 'Closed' && !milestone_i.IsCompleted) {
                        milestone_i.CompletionDate = System.now();
                        milestones.add(milestone_i);
                    } else if (case_i.Case_Phase__c == 'In_Process' && case_i.RecordTypeId == caseRTMap.get('Shikum_Bait').getRecordTypeId()) {
                        milestone_i.CompletionDate = System.now();
                        milestones.add(milestone_i);
                    }
                }
            }
        }
        System.debug('milestones: size: ' + milestones.size() + ' value: ' + milestones);

        if (!milestones.isEmpty()) {
            update milestones;
            System.debug('TR Case completeMilestones ... executed');
        }
    }

    public static void copyManagerEmail(List<Case> pCaseList, Set<Id> pOwnerIdSet) {
        Boolean logicExecuted = false;

        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Manager.Email FROM User WHERE Id IN :pOwnerIdSet AND Manager.Email != null]);
        System.debug('TR Case userMap [' + userMap.size() + ']: ' + userMap);

        for (Case case_i : pCaseList) {
            if (userMap.containsKey(case_i.OwnerId)) {
                case_i.manager_mail__c = userMap.get(case_i.OwnerId).Manager.Email;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case copyManagerEmail ... executed');
        }
    }

    public static void fillEntitlement(List<Case> cases) {
        for (Case case_i : cases) {
            case_i.EntitlementId = (case_i.Owner_Queue_wf__c != null && case_i.Owner_Queue_wf__c.contains('ציבורי')) ? Label.Assuta_SLA_Entitlement_Id_Ashdod : Label.Assuta_SLA_Entitlement_Id;
        }
        System.debug('TR Case fillEntitlement ... executed');
    }

    public static void sendOPT(List<Case> cases, Set<Id> contactIds) {
        Boolean logicExecuted = false;
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id 
                                                            FROM Contact 
                                                            WHERE Id IN :contactIds 
                                                                AND (Account.Mailing_approval__c = 'מאשר דיוור - הכל' 
                                                                    OR Account.Mailing_approval__c = 'מאשר דיוור - שירותי')]);
        
        OrgWideEmailAddress owea = [SELECT Id
                                        , Address 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address = 'nonreply@assuta.co.il' 
                                    LIMIT 1];
        EmailTemplate template = [SELECT Subject
                                        , HtmlValue
                                        , Body 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName = 'Assuta_OTP'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<SMS__c> smssToInsert = new List<SMS__c>();
        List<Account> accsToUpdate = new List<Account>();
        List<Case> casesToUpdate = new List<Case>();

        for (Case case_i : cases) {
            if (contactsMap.containsKey(case_i.ContactId)) {
                casesToUpdate.add(
                    new Case(
                        Id = case_i.Id,
                        OTP_Succeeded__c = false,
                        send_OTP__c = false
                    )
                );
                
                if (case_i.SMS_Phone_Number__c != null) {
                    smssToInsert.add(prepareOPTSMS(case_i));
                    accsToUpdate.add(
                        new Account(
                            Id = case_i.AccountId,
                            otp_phone_hidden__c = case_i.SMS_Phone_Number__c,
                            otp_sent__c = false
                        )
                    );
                } else if (case_i.SMS_Phone_Number__c == null && case_i.email_from_patient__c != null) {
                    mails.add(prepareMail(case_i, case_i.email_from_patient__c, template, owea.Id));
                    accsToUpdate.add(
                        new Account(
                            Id = case_i.AccountId,
                            OTP_EMAIL_HIDDEN__c = case_i.email_from_patient__c,
                            otp_sent__c = false
                        )
                    );
                }
                
            }   
        }

        System.debug('smssToInsert: size: ' + smssToInsert.size() + ' values: ' + smssToInsert);
        if (!smssToInsert.isEmpty()) {
            insert smssToInsert;
            logicExecuted = true;
        }

        System.debug('mails: size: ' + mails.size() + ' values: ' + mails);
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
            logicExecuted = true;
        }
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' values: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            TriggerHandler.bypass('CaseTriggerHandler'); //Added YL 09112025
            update casesToUpdate;
            TriggerHandler.clearBypass('CaseTriggerHandler'); //Added YL 09112025
            logicExecuted = true;
        }

        System.debug('accsToUpdate: size: ' + accsToUpdate.size() + ' values: ' + accsToUpdate);
        if (!accsToUpdate.isEmpty()) {
            update accsToUpdate;
            logicExecuted = true;
        }
        if (logicExecuted) {
            System.debug('TR Case sendOPT ... executed');
        }
    }

    private static SMS__c prepareOPTSMS(Case cas) {
        return new SMS__c(
            Case__c = cas.Id,
            Template_Text__c = getSMSTemplate(new String[]{cas.first_name_patient__c, cas.formtitan_otp_link__c} ,'OTP'),
            Phone_Number__c = cas.SMS_Phone_Number__c,
            status__c = '1',           
            Type__c = 'Outgoing'
        );
    }

    public static void createRecommendedDoctor(Map<Id, Id> casesToAccsMap) {
        Boolean logicExecuted = false;
        Map<Id, Id> accsToOldCaseMap = new Map<Id, Id>();
        Map<Id, Set<Id>> oldCaseToNewCasesMap = new Map<Id, Set<Id>>();
        List<Account> accsToUpdate = new List<Account>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        List<Case_Recommended_Doctor__c> docsToInsert = new List<Case_Recommended_Doctor__c>();

        for (Account acc_i : [SELECT Id
                                    , (SELECT Id 
                                        FROM Cases 
                                        WHERE Id NOT IN :casesToAccsMap.keySet() 
                                            AND Status != 'Caneclled'
                                            AND num_of_apts__c = 0
                                            AND sub_case_subject__c = 'המלצה על רופא מומחה'
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1) 
                                FROM Account
                                WHERE Id IN :casesToAccsMap.values()]) {
            if (!acc_i.Cases.isEmpty()) {
                accsToOldCaseMap.put(acc_i.Id, acc_i.Cases.get(0).Id);
            }
        }

        System.debug('accsToOldCaseMap: size: ' + accsToOldCaseMap.size() + ' values: ' + accsToOldCaseMap);
        for (Id caseId_i : casesToAccsMap.keySet()) {
            Id accId_i = casesToAccsMap.get(caseId_i);
            Id oldCaseId_i = accsToOldCaseMap.get(accId_i);

            if (accsToOldCaseMap.containsKey(accId_i)) {
                Set<Id> newCases_i = oldCaseToNewCasesMap.containsKey(oldCaseId_i) ? oldCaseToNewCasesMap.get(oldCaseId_i) : new Set<Id>();
                
                newCases_i.add(caseId_i);
                oldCaseToNewCasesMap.put(oldCaseId_i, newCases_i);
            }
        }
        for (Id accId_i : accsToOldCaseMap.keySet()) {
            accsToUpdate.add(
                new Account(
                    Id = accId_i,
                    last_recommended_case_id__c = accsToOldCaseMap.get(accId_i)
                )
            );
        }
        System.debug('oldCaseToNewCasesMap: size: ' + oldCaseToNewCasesMap.size() + ' values: ' + oldCaseToNewCasesMap);
        for (Id oldCaseId_i : oldCaseToNewCasesMap.keySet()) {
            for (Id newCaseId_i : oldCaseToNewCasesMap.get(oldCaseId_i)) {
                casesToUpdate.put(
                    newCaseId_i,
                    new Case(
                        Id = newCaseId_i,
                        related_Case_rec__c = oldCaseId_i
                    )
                );
            }
        }

        for (Case_Recommended_Doctor__c	 doc_i : [SELECT Id
                                                        , Case__c 
                                                        , Doctor__c
                                                    FROM Case_Recommended_Doctor__c	
                                                    WHERE Case__c IN :oldCaseToNewCasesMap.keySet()]) {
            for (Id newCaseId_i : oldCaseToNewCasesMap.get(doc_i.Case__c)) {
                docsToInsert.add(
                    new Case_Recommended_Doctor__c(
                        Case__c = newCaseId_i,
                        Doctor__c = doc_i.Doctor__c
                    )
                );   
            }
        }

        for (Id caseId_i : casesToAccsMap.keySet()) {
            if (!casesToUpdate.containsKey(caseId_i)) {
                casesToUpdate.put(
                    caseId_i,
                    new Case(
                        Id = caseId_i
                    ));
            }
            casesToUpdate.get(caseId_i).call_flow_connect_rec_case_to__c = true;
        }

        System.debug('accsToUpdate: size: ' + accsToUpdate.size() + ' values: ' + accsToUpdate);
        if (!accsToUpdate.isEmpty()) {
            update accsToUpdate;
            logicExecuted = true;
        }

        System.debug('docsToInsert: size: ' + docsToInsert.size() + ' values: ' + docsToInsert);
        if (!docsToInsert.isEmpty()) {
            insert docsToInsert;
            logicExecuted = true;
        }

        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' values: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
            logicExecuted = true;
        }
        if (logicExecuted) {
            System.debug('TR Case createRecommendedDoctor ... executed');
        }
    }

    public static void setDoctorArrangmentNotPrivateHidden(List<Case> cases, Set<Id> docArrangIds) {
        Boolean logicExecutedd = false;
        Set<Id> pFactorIds = new Set<Id>();
        Set<Id> docIds = new Set<Id>();
        Map<Id, Id> docToArrangMap = new Map<Id, Id>();
        List<Case> casesToUpdate = new List<Case>();
        Map<Id, Doctor_Arrangement__c> docArrangMap = new Map<Id, Doctor_Arrangement__c>([
            SELECT Id
              FROM Doctor_Arrangement__c
             WHERE Id IN :docArrangIds
               AND Arrangement__r.PayerFactor__r.Name LIKE '%פרטי%']);
        System.debug('docArrangMap: size: ' + docArrangMap.size() + ' values: ' + docArrangMap);

        for (Case case_i : cases) {
            if (docArrangMap.containsKey(case_i.Doctor_Arrangement__c)) {
                casesToUpdate.add(case_i);
                pFactorIds.add(case_i.PayerFactor__c);
                docIds.add(case_i.Recommended_doc__c);
            }
        }
        System.debug('pFactorIds: size: ' + pFactorIds.size() + ' values: ' + pFactorIds);
        System.debug('docIds: size: ' + docIds.size() + ' values: ' + docIds);

        for (Account doc_i : [SELECT Id
                                   , (SELECT Id 
                                        FROM doc_arrangement__r
                                       WHERE Arrangement__r.PayerFactor__c IN :pFactorIds
                                       LIMIT 1) 
                                FROM Account
                               WHERE Id IN :docIds]) {
            if (!doc_i.doc_arrangement__r.isEmpty()) {
                docToArrangMap.put(doc_i.Id, doc_i.doc_arrangement__r.get(0).Id);
            }
        }
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' values: ' + casesToUpdate);
        System.debug('docToArrangMap: size: ' + docToArrangMap.size() + ' values: ' + docToArrangMap);

        for (Case case_i : casesToUpdate) {
            if (docToArrangMap.containsKey(case_i.Recommended_doc__c)) {
                case_i.doc_arrangment_not_private_hidden__c = docToArrangMap.get(case_i.Recommended_doc__c);
                logicExecutedd = true;
            }
        }

        if (logicExecutedd) {
            System.debug('TR Case setDoctorArrangmentNotPrivateHidden ... executed');
        }
    }

    public static void saveOwner(List<Case> pCaseList) {
        for (Case case_i : pCaseList) {
            case_i.First_user_to_own_the_case__c = case_i.OwnerId;
        }
        System.debug('TR Case saveOwner ... executed');
    }

    public static void notifyOwner(List<Case> pCaseList) {
        CustomNotificationType notificationType = [
            SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'new_case_transfer_for_you'];

        for (Case case_i : pCaseList) {
            new Messaging.CustomNotification(
                notificationType.Id,
                null,
                'פנייה ' + case_i.CaseNumber + ' הועברה לטיפולך',
                'יש לטפל בפנייה',
                case_i.Id,
                null).send(new Set<String>{case_i.OwnerId});
        }
        System.debug('TR Case notifyOwner ... executed');
    }

    public static void transferToManager(List<Case> pCaseList, Set<Id> pOwnerIdSet) {
        Boolean logicExecuted = false;

        Map<Id, User> userMap = new Map<Id, User>([
            SELECT ManagerId FROM User WHERE Id IN :pOwnerIdSet AND ManagerId != null]);
        System.debug('TR Case userMap [' + userMap.size() + ']: ' + userMap);

        for (Case case_i : pCaseList) {
            if (userMap.containsKey(case_i.OwnerId)) {
                case_i.OwnerId = userMap.get(case_i.OwnerId).ManagerId;
                case_i.help_transfer_to_manager__c = true;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case transferToManager ... executed');
        }
    }

    public static void sendDocAdvisor(List<Case> cases, Set<Id> contactIds) {
        Boolean logicExecuted = false;
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id 
                                                            FROM Contact 
                                                            WHERE Id IN :contactIds 
                                                                AND (Account.Mailing_approval__c = 'מאשר דיוור - הכל' 
                                                                    OR Account.Mailing_approval__c = 'מאשר דיוור - שירותי')]);
        List<SMS__c> smssToInsert = new List<SMS__c>();
        OrgWideEmailAddress owea = [SELECT Id
                                            , Address 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address = 'nonreply@assuta.co.il' 
                                    LIMIT 1];
        EmailTemplate template = [SELECT Subject
                                        , HtmlValue
                                        , Body 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName = 'Assuta_Doc_Recommendation'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Case> casesToUpdate = new List<Case>();

        for (Case case_i : cases) {
            if (contactsMap.containsKey(case_i.ContactId)) {
                if (case_i.preferd_chanal_case__c == 'SMS' 
                        || case_i.preferd_chanal_case__c == 'Whatsapp' 
                        || case_i.preferd_chanal_case__c == 'Phone') {
                    casesToUpdate.add(new Case(
                                        Id = case_i.Id, 
                                        Send_DocAdvisor__c = false));
                    smssToInsert.add(prepareDocAdvisorSMS(case_i));
                } else if (case_i.preferd_chanal_case__c == 'Email') {
                    casesToUpdate.add(new Case(
                                        Id = case_i.Id, 
                                        Send_DocAdvisor__c = false));
                    mails.add(prepareMail(case_i, case_i.email_from_patient__c, template, owea.Id));
                }
            }
        }

        System.debug('smssToInsert: size: ' + smssToInsert.size() + ' value: ' + smssToInsert);
        if (!smssToInsert.isEmpty()) {
            insert smssToInsert;
            logicExecuted = true;
        }
        System.debug('mails: size: ' + mails.size() + ' value: ' + mails);
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
            logicExecuted = true;
        }
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            TriggerHandler.bypass('CaseTriggerHandler'); //Added YL 09112025
            update casesToUpdate;
            TriggerHandler.clearBypass('CaseTriggerHandler'); //Added YL 09112025
            logicExecuted = true;
        }
        if (logicExecuted) {
            System.debug('TR Case sendDocAdvisor ... executed');
        }
    }

    private static SMS__c prepareDocAdvisorSMS(Case cas) {
        return new SMS__c(
            Case__c = cas.Id,
            Template_Text__c = getSMSTemplate(new String[]{cas.first_name_patient__c, cas.formtitan_recommandation_link__c}, 'Doc_Advisor_Recommandation_Link'),
            Phone_Number__c = cas.SMS_Phone_Number__c, 
            status__c = '1',           
            Type__c = 'Outgoing'
        );
    }

    private static Messaging.SingleEmailMessage prepareMail(Case cas, String toAddress, EmailTemplate template, Id oweaId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>{toAddress});
        mail.setOrgWideEmailAddressId(oweaId);
        mail.setTemplateId(template.Id);
        mail.setTargetObjectId(cas.ContactId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setWhatId(cas.Id);
        mail.setSaveAsActivity(false);
        return mail;
    }

    public static void setContactDoctor(List<Case> cases) {
        for (Case case_i : cases) {
            case_i.Contact_doctor__c = case_i.surgeon_doctor__c;
        }
        System.debug('TR Case setContactDoctor ... executed');
    }

    public static void markCaseAsReturning(List<Case> cases, Set<Id> acctIds, Set<String> subSubjects) {
        Boolean logicExecuted = false;
        List<Case> casesToUpdate = new List<Case>();
        List<Account> accsToUpdate = new List<Account>();
        Map<String, List<Case>> uniqueKeyToExistCasesMap = new Map<String, List<Case>>();
        List<Case> existCases = [SELECT Id
                                    , sub_case_subject__c
                                    , return_case_type__c
                                    , AccountId
                                 FROM Case
                                WHERE Id NOT IN :cases
                                  AND sub_case_subject__c IN :subSubjects
                                  AND Created_Date_no_time__c = LAST_N_DAYS:2
                                  AND AccountId IN :acctIds
                                  AND Account.ID_Number__c != :System.Label.Fictitious_Account_ID_Number];
        System.debug('cases: size: ' + cases.size() + ' values: ' + cases);

        for (Case existCase_i : existCases) {
            String uniqueKey = existCase_i.AccountId + '-' + existCase_i.sub_case_subject__c;

            if (!uniqueKeyToExistCasesMap.containsKey(uniqueKey)) {
                uniqueKeyToExistCasesMap.put(uniqueKey, new List<Case>());
            }
            uniqueKeyToExistCasesMap.get(uniqueKey).add(existCase_i);
        }

        Set<String> updatedCases = new Set<String>();
        for (Case case_i : cases) {

            if (uniqueKeyToExistCasesMap.containsKey(case_i.AccountId + '-' + case_i.sub_case_subject__c)) {
                casesToUpdate.add(
                    new Case(
                        Id = case_i.Id,
                        cut_points__c = true,
                        return_case_type__c = 'אחרון'
                    )
                );
                for (Case oldCase_i : uniqueKeyToExistCasesMap.get(case_i.AccountId + '-' + case_i.sub_case_subject__c)) {
                    if (oldCase_i.return_case_type__c != 'נפתחה עוד פנייה לפנייה זו' && !updatedCases.contains(oldCase_i.Id)) {
                        updatedCases.add(oldCase_i.Id);
                        casesToUpdate.add(
                            new Case(
                                Id = oldCase_i.Id,
                                return_case_type__c = 'נפתחה עוד פנייה לפנייה זו'
                            )
                        );
                    }   
                }
            } else {
                acctIds.remove(case_i.AccountId);
            }
        }
        accsToUpdate = [SELECT Id, satisfaction__c FROM Account WHERE Id IN :acctIds];

        for (Account acc_i : accsToUpdate) {
            acc_i.satisfaction__c = acc_i.satisfaction__c > 10 ? acc_i.satisfaction__c - 10 : 0;
        }

        System.debug('accsToUpdate: size: ' + accsToUpdate.size() + ' values: ' + accsToUpdate);
        if (!accsToUpdate.isEmpty()) {
            update accsToUpdate;
            logicExecuted = true;
        }

        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' values: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            TriggerHandler.bypass('CaseTriggerHandler'); //Added YL 09112025
            update casesToUpdate;
            TriggerHandler.clearBypass('CaseTriggerHandler'); //Added YL 09112025
            logicExecuted = true;
        }
        if (logicExecuted) {
            System.debug('TR Case markCaseAsReturning ... executed');
        }
    }

    public static void sendLinkForReferral(List<Case> cases, Set<Id> contactIds) {
        Boolean logicExecuted = false;
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id 
                                                            FROM Contact 
                                                            WHERE Id IN :contactIds 
                                                                AND (Account.Mailing_approval__c = 'מאשר דיוור - הכל' 
                                                                    OR Account.Mailing_approval__c = 'מאשר דיוור - שירותי') 
                                                                AND AccountId != null]);
        List<SMS__c> smssToInsert = new List<SMS__c>();
        OrgWideEmailAddress owea = [SELECT Id
                                            , Address 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address = 'nonreply@assuta.co.il' 
                                    LIMIT 1];
        EmailTemplate template = [SELECT Subject
                                        , HtmlValue
                                        , Body 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName = 'Upload_referral'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Case> casesToUpdate = new List<Case>();

        for (Case case_i : cases) {
            if (contactsMap.containsKey(case_i.ContactId)) {
                if (case_i.preferd_chanal_case__c == 'SMS') {
                    casesToUpdate.add(new Case(
                                        Id = case_i.Id,
                                        send_link_for_referral__c = false));
                    smssToInsert.add(prepareSendLinkSMS(case_i));
                } else if (case_i.preferd_chanal_case__c == 'Email') {
                    casesToUpdate.add(new Case(
                                        Id = case_i.Id,
                                        send_link_for_referral__c = false));
                    mails.add(prepareMail(case_i, case_i.email_from_patient__c, template, owea.Id));
                }
            }
        }
        System.debug('smssToInsert: size: ' + smssToInsert.size() + ' smssToInsert: ' + smssToInsert);
        if (!smssToInsert.isEmpty()) {
            insert smssToInsert;
            logicExecuted = true;
        }
        System.debug('mails: size: ' + mails.size() + ' value: ' + mails);
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
            logicExecuted = true;
        }
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
            logicExecuted = true;
        }
        if (logicExecuted) {
            System.debug('TR Case sendLinkForReferral ... executed');
        }
    }

    private static SMS__c prepareSendLinkSMS(Case cas) {
        return new SMS__c(
            Template_Text__c = getSMSTemplate(new String[]{cas.link_upload_files__c }, 'File_Upload_Link'),
            Phone_Number__c = cas.SMS_Phone_Number__c, 
            status__c = '1',           
            Type__c = 'Outgoing'//,
            // Case__c = cas.Id,
            // Account__c = cas.AccountId
        );
    }

    public static void createAgentSurvey(List<Case> cases, Set<Id> accIds, Set<Id> opptIds, Set<Id> userIds) {
        Boolean logicExecuted = false;
        Map<Id, Account> accsMap = new Map<Id, Account>();
        Map<Id, Opportunity> opptsMap = new Map<Id, Opportunity>([SELECT Id
                                                                        , Campaign.Survey__c 
                                                                    FROM Opportunity 
                                                                    WHERE Id IN :opptIds 
                                                                        AND Campaign.SensitiveCampaign__c = false 
                                                                        AND Campaign.AgentSurvey__c = true]);
        Map<Id, User> usersMap = new Map<Id, User>();
        List<Agent_survey__c> surveiesToInsert = new List<Agent_survey__c>();
        List<SMS__c> smssToInsert = new List<SMS__c>();

        if (!accIds.isEmpty()) {
            accsMap = new Map<Id, Account>([SELECT Id 
                                            FROM Account 
                                            WHERE Id IN :accIds 
                                                AND (Answering_Survey_Date__c = null 
                                                    OR Answering_Survey_Date__c < :System.today().addDays(-90))]);
        }
        if (!userIds.isEmpty()) {
            usersMap = new Map<Id, User>([SELECT Id
                                                    , ManagerId 
                                                FROM User 
                                                WHERE Id IN :userIds]);
        }

        for (Case case_i : cases) {
            if (((case_i.Opportunity__c == null || opptsMap.containsKey(case_i.Opportunity__c))
                    && accsMap.containsKey(case_i.AccountId) 
                    && (case_i.Origin != 'WhatsApp' || case_i.Origin != 'Web_Site')
                    && (case_i.RecordTypeId == caseRTMap.get('ClosedInstitutes').getRecordTypeId() 
                        || case_i.RecordTypeId == caseRTMap.get('ClosedExp').getRecordTypeId())) 
               || ((case_i.Origin == 'WhatsApp' || case_i.Origin == 'Web_Site')
                   && case_i.Waiting_for_agent__c == true
                   && case_i.Ashdod_Case__c == true
                   && case_i.Ashdod_Employee__c == true)) {
                surveiesToInsert.add(prepareAgentSurvey(case_i, System.Label.Institutes_Experts_Survey_Assuta_Id, case_i.CreatedById, usersMap.get(case_i.CreatedById).ManagerId));
            } else if ((case_i.Opportunity__c != null && opptsMap.containsKey(case_i.Opportunity__c)) 
                            && opptsMap.get(case_i.Opportunity__c).Campaign.Survey__c != null 
                            && case_i.SMS_Phone_Number__c != null) {
                smssToInsert.add(prepareSurveySMS(case_i));
            } else if ((case_i.Opportunity__c != null && opptsMap.containsKey(case_i.Opportunity__c)) 
                            && opptsMap.get(case_i.Opportunity__c).Campaign.Survey__c == null) {
                Id managerId = User.getSObjectType() == case_i.OwnerId.getSObjectType() ? usersMap.get(case_i.CreatedById).ManagerId : null;

                surveiesToInsert.add(prepareAgentSurvey(case_i, System.Label.Analysis_Survey_Assuta_Id, case_i.CreatedById, managerId));
            }
        }
        System.debug('surveiesToInsert: size: ' + surveiesToInsert.size() + ' value: ' + surveiesToInsert);
        if (!surveiesToInsert.isEmpty()) {
            insert surveiesToInsert;
            logicExecuted = true;
        }
        System.debug('smssToInsert: size: ' + smssToInsert.size() + ' value: ' + smssToInsert);
        if (!smssToInsert.isEmpty()) {
            insert smssToInsert; 
            logicExecuted = true; 
        }
        if (logicExecuted) {
            System.debug('TR Case createAgentSurvey ... executed');
        }
    }

    private static SMS__c prepareSurveySMS(Case cas) {
        return new SMS__c(
            Account__c = cas.AccountId,
            Case__c = cas.Id,
            Template_Text__c = getSMSTemplate(new String[]{cas.campaignLink__c}, 'Survey_Campaign_Link'),
            Phone_Number__c = cas.SMS_Phone_Number__c, 
            status__c = '1',           
            Type__c = 'Outgoing'
        );
    }

    private static Agent_survey__c prepareAgentSurvey(Case cas, String surgery, Id agentId, Id managerId) {
        return new Agent_survey__c(
            Account_Survived__c = cas.AccountId,
            Case__c = cas.Id,
            Survey__c = surgery,
            agent__c = agentId,
            agents_manager__c = managerId,
            status__c = 'create'
        );
    }

    public static void fillContactDetails(List<Case> cases, Set<Id> contactIds) {
        Boolean logicExecuted = false;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Email
                 , Phone
                 , OtherPhone
                 , SMS_Phone__c
                 , Preferred_Channel__c
                 , Account.Phone
                 , Account.PersonEmail
                 , Account.IsPersonAccount
                 , Account.PersonOtherPhone
                 , Account.SMS_Phone_Number__c
                 , Account.Preferred_Channel__c
              FROM Contact
             WHERE Id IN :contactIds 
               AND AccountId != null]);
        System.debug('contactMap: size: ' + contactMap.size() + ' value: ' + contactMap);

        for (Case case_i : cases) {
            if (case_i.AccountId != null 
                    && contactMap.containsKey(case_i.ContactId) 
                    && case_i.AccountId != contactMap.get(case_i.ContactId).AccountId) {
                Contact cont = contactMap.get(case_i.ContactId);

                case_i.Get_contact_details__c = true;
                case_i.phone__c = cont.Account.IsPersonAccount ? cont.Account.Phone : cont.Phone;
                case_i.email_from_patient__c = cont.Account.IsPersonAccount ? cont.Account.PersonEmail : cont.Email;
                case_i.Person_Other_Phone__c = cont.Account.IsPersonAccount ? cont.Account.PersonOtherPhone : cont.OtherPhone;
                case_i.SMS_Phone_Number__c = cont.Account.IsPersonAccount ? cont.Account.SMS_Phone_Number__c : cont.SMS_Phone__c;
                case_i.preferd_chanal_case__c = cont.Account.IsPersonAccount ? cont.Account.Preferred_Channel__c : cont.Preferred_Channel__c;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case fillContactDetails ... executed');
        }   
    }

    public static void setBiopsyResults(List<Case> cases) {
        for (Case case_i : cases) {
            case_i.Status = 'התקבלו תוצאות ביופסיה';
        }
        System.debug('TR Case setBiopsyResults ... executed');
    }

    public static void setAppointmentToDoctor(List<Case> cases, Set<Id> patientIds, Set<Id> docIds) {
        Boolean logicExecuted = false;
        Map<String, Appointment__c> uniqueKeyToApptMap = new Map<String, Appointment__c>();

        for (Appointment__c appt_i : [SELECT Doctor_Account__c
                                           , Patient_Account__c
                                        FROM Appointment__c 
                                       WHERE Doctor_Account__c IN :docIds
                                         AND Patient_Account__c IN :patientIds
                                         AND (Appointment_Status__c = 'וידוא הגעה לפגישה'
                                              OR Appointment_Status__c = 'בטיפול אדמיניסטרטיבי'
                                              OR Appointment_Status__c = 'WaitingForAppointment')
                                         AND RT_HEBREW_NAME__c = 'מומחים'
                                         AND Appointment_Date_Time__c > :System.now()]) {
            uniqueKeyToApptMap.put(appt_i.Patient_Account__c + '-' + appt_i.Doctor_Account__c, appt_i);
        }
        System.debug('uniqueKeyToApptMap: size: ' + uniqueKeyToApptMap.size() + ' values: ' + uniqueKeyToApptMap);

        for (Case case_i : cases) {
            if (uniqueKeyToApptMap.containsKey(case_i.AccountId + '-' + case_i.Recommended_doc__c)) {
                case_i.appointment_to_doctor__c = uniqueKeyToApptMap.get(case_i.AccountId + '-' + case_i.Recommended_doc__c).Id;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case setAppointmentToDoctor ... executed');
        }
    }

    public static void fillDonating(List<Case> cases) {
        for(Case case_i : cases) {
            case_i.Case_Route__c = 'Donation_Route';
            case_i.Is_Donating__c = false;
        }
        System.debug('TR Case fillDonating... executed');
    }

    public static void setCurrentUserAsOwner(List<Case> cases) {
        for (Case case_i : cases) {
            case_i.OwnerId = UserInfo.getUserId();
        }
        System.debug('TR Case setCurrentUserAsOwner... executed');
    }

    public static void createDailyTasksLogIVF(List<CaseTriggerDispatcher.LogIVFWrapper> wrappers) {
        List<Daily_Tasks_Log_IVF__c> dailyTastskLogsToInsert = new List<Daily_Tasks_Log_IVF__c>();

        for (CaseTriggerDispatcher.LogIVFWrapper wrapper_i : wrappers) {
            dailyTastskLogsToInsert.add(
                new Daily_Tasks_Log_IVF__c(
                    Change_Reason__c = wrapper_i.changeReason,
                    Parent_Account__c = wrapper_i.cas.AccountId,
                    Source_Case__c = wrapper_i.cas.Id,
                    User__c = UserInfo.getUserId()
                )
            );
        }
        
        if (!dailyTastskLogsToInsert.isEmpty()) {
            insert dailyTastskLogsToInsert;
            System.debug('TR Case createDailyTasksLogIVF... executed');
        }
    }

    public static void fillDecisionStageDate(List<Case> cases) {
        Boolean logicExecuted = false;

        for (Case case_i : cases) {
            case_i.Ministry_Of_Health_Transfer_Date__c = case_i.Case_Status__c == 'No_Conception_HealthDepartment_Transfer' ? System.today() : null;
            case_i.Research_Transfer_Date__c = case_i.Case_Status__c == 'Research_Donation' ? System.today() : null;
            case_i.Thawing_Date__c = case_i.Case_Status__c == 'UnControlled_Defrost' ? System.today() : null;
            logicExecuted = true;
        }

        if (logicExecuted) {
            System.debug('TR Case fillDecisionStageDate... executed');
        }
    }
 
    public static void fillPayerRecommendation(List<Case> cases) {
        Boolean logicExecuted = false;

        for (Case case_i : cases) {
            if (case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'Payed_Freezing') {
                case_i.Payer__c = 'יש לבדוק';
                case_i.Recommendation__c = 'Payment_Freezing';
                logicExecuted = true;
            } else if ((case_i.Female_Status__c  == 'Payed_Freezing' && case_i.Partner_Status__c == 'UnControlled_Defrost' ) 
                    || (case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'Research_Donation') 
                    || (case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'No_Reply')) {
                case_i.Payer__c = 'Woman';
                case_i.Recommendation__c = 'Payment_Freezing';
                logicExecuted = true;
            } else if ((case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'Payed_Freezing') 
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'Payed_Freezing') 
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'Payed_Freezing')) {
                case_i.Payer__c = 'Man';
                case_i.Recommendation__c = 'Payment_Freezing';
                logicExecuted = true;
            } else if ((case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'Research_Donation') 
                        || (case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'No_Reply') 
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'UnControlled_Defrost') 
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'No_Reply') 
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'UnControlled_Defrost') 
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'Research_Donation')) {
                case_i.Payer__c = 'לא רלוונטי';
                case_i.Recommendation__c = 'HealthDepartment _Reference_defrost_Approval_Request';
                logicExecuted = true;
            } else if (case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'UnControlled_Defrost') {
                case_i.Payer__c = 'לא רלוונטי';
                case_i.Recommendation__c = 'Defrost';
                logicExecuted = true;
            } else if (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'Research_Donation') {
                case_i.Payer__c = 'לא רלוונטי';
                case_i.Recommendation__c = 'Research_Transfer';
                logicExecuted = true;
            } else if (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'No_Reply') {
                case_i.Payer__c	 = 'לא רלוונטי';
                case_i.Recommendation__c = 'Repeating_Trials';
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case fillPayerRecommendation... executed');
        }
    }

    public static void sendManKitEmail(List<Case> cases) {
        Boolean logicExecuted = false;
        List<Case> casesToUpdate = new List<Case>();
        Map<String, EmailTemplate> emailDevNameToTemplatelMap = new Map<String, EmailTemplate>();
        Map<String, OrgWideEmailAddress> emailToOrgWideEmailMap = new Map<String, OrgWideEmailAddress>();

        for(EmailTemplate template_i : [SELECT Subject
                                                , HtmlValue
                                                , Body
                                                , DeveloperName 
                                            FROM EmailTemplate 
                                            WHERE DeveloperName IN :new List<String> {'First_Call_Done_Male_RH'
                                                                                        , 'First_Call_Done_Male_RL'}]) {
            emailDevNameToTemplatelMap.put(template_i.DeveloperName, template_i);
        }
        for (OrgWideEmailAddress orgWideEmail_i : [SELECT Id
                                                        , Address 
                                                    FROM OrgWideEmailAddress 
                                                    WHERE Address IN :CASE_SITE_TO_EMAIL_MAP.values()]) {
            emailToOrgWideEmailMap.put(orgWideEmail_i.Address, orgWideEmail_i);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        for (Case case_i : cases) {
            
            casesToUpdate.add(
                new Case(
                    Id = case_i.Id,
                    Kit_Sent_Partner__c = true,
                    Send_Man_Kit__c = false,
                    Kit_Sending_Date_Partner_IVF__c = System.now()
                )
            );
            OrgWideEmailAddress owe = emailToOrgWideEmailMap.get(CASE_SITE_TO_EMAIL_MAP.get(case_i.Case_site__c));
            if (case_i.Case_site__c == 'Ramat_Hahayal') { 
                if (case_i.Partner_Email__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.Partner_Email__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Male_RH'), 
                            owe.Id)
                    );
                }
            } else if (case_i.Case_site__c == 'Rishon_Letzion') {
                if (case_i.Partner_Email__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.Partner_Email__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Male_RL'), 
                            owe.Id)
                    );
                }
            }
        }

        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' values: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
            logicExecuted = true;
        }

        System.debug('mails: size: ' + mails.size() + ' values: ' + mails);
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
            logicExecuted = true;
        }

        if (logicExecuted) {
            System.debug('TR Case sendManKitEmail... executed');
        }
    }

    public static void sendFirstKitEmail(List<Case> cases) {
        Boolean logicExecuted = false;
        Map<String, EmailTemplate> emailDevNameToTemplatelMap = new Map<String, EmailTemplate>();
        Map<String, OrgWideEmailAddress> emailToOrgWideEmailMap = new Map<String, OrgWideEmailAddress>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();

        for (EmailTemplate template_i : [SELECT Subject
                                                , HtmlValue
                                                , Body
                                                , DeveloperName 
                                            FROM EmailTemplate 
                                            WHERE DeveloperName IN :new List<String> {'First_Call_Done_Male_RH'
                                                                                        , 'First_Call_Done_Male_RL'
                                                                                        , 'First_Call_Done_Female_RL'
                                                                                        , 'First_Call_Done_Female_RH'
                                                                                        , 'First_Call_Done_Couple_RH'
                                                                                        , 'First_Call_Done_Couple_RL'}]) {
            emailDevNameToTemplatelMap.put(template_i.DeveloperName, template_i);
        }
        for (OrgWideEmailAddress orgWideEmail_i : [SELECT Id
                                                        , Address 
                                                    FROM OrgWideEmailAddress 
                                                    WHERE Address IN :CASE_SITE_TO_EMAIL_MAP.values()]) {
            emailToOrgWideEmailMap.put(orgWideEmail_i.Address, orgWideEmail_i);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Case case_i : cases) {
            OrgWideEmailAddress owe = emailToOrgWideEmailMap.get(CASE_SITE_TO_EMAIL_MAP.get(case_i.Case_site__c));

            if (case_i.Case_Route__c == 'Seperate_Route' 
                    && case_i.Case_site__c == 'Ramat_Hahayal' 
                    && case_i.First_Call_Made_Partner__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Partner_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Partner__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.Partner_Email__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.Partner_Email__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Male_RH'),
                            owe.Id)
                    );
                }
            }
            if (case_i.Case_Route__c == 'Seperate_Route' 
                        && case_i.Case_site__c == 'Rishon_Letzion' 
                        && case_i.First_Call_Made_Partner__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Partner_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Partner__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.Partner_Email__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.Partner_Email__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Male_RL'), 
                            owe.Id)
                    );
                }
            }
            if (case_i.Case_Route__c == 'Seperate_Route' 
                        && case_i.Case_site__c == 'Rishon_Letzion' 
                        && case_i.First_Call_Made_Female__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);
                   
                caseToUpdate.Kit_Sending_Date_Female_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Female__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.email_from_patient__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.email_from_patient__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Female_RL'), 
                            owe.Id)
                    );
                }
            }
            if (case_i.Case_Route__c == 'Seperate_Route' 
                        && case_i.Case_site__c == 'Ramat_Hahayal' 
                        && case_i.First_Call_Made_Female__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Female_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Female__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.email_from_patient__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.email_from_patient__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Female_RH'), 
                            owe.Id)
                    );
                }
            }
            if (case_i.Case_Route__c == 'Double_Route' 
                            && case_i.Case_site__c == 'Ramat_Hahayal' 
                            && case_i.First_Call_Made_Female__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Female_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Couple__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.email_from_patient__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.email_from_patient__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Couple_RH'), 
                            owe.Id)
                    );
                }
            }
            if (case_i.Case_Route__c == 'Double_Route' 
                        && case_i.Case_site__c == 'Rishon_Letzion' 
                        && case_i.First_Call_Made_Female__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Female_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Couple__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.email_from_patient__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.email_from_patient__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Couple_RL'), 
                            owe.Id));
                }
            }
            if (case_i.Case_Route__c == 'Donation_Route' 
                        && case_i.Case_site__c == 'Rishon_Letzion' 
                        && case_i.First_Call_Made_Female__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Female_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Couple__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.email_from_patient__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.email_from_patient__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Female_RL'), 
                            owe.Id)
                    );
                }
            } 
            if (case_i.Case_Route__c == 'Donation_Route' 
                        && case_i.Case_site__c == 'Ramat_Hahayal' 
                        && case_i.First_Call_Made_Female__c == true) {
                if (!casesToUpdate.containsKey(case_i.Id)) {
                    casesToUpdate.put(case_i.Id, new Case(Id = case_i.Id));
                }
                Case caseToUpdate = casesToUpdate.get(case_i.Id);

                caseToUpdate.Kit_Sending_Date_Female_IVF__c = System.now();
                caseToUpdate.Kit_Sent_Couple__c = true;
                caseToUpdate.Send_First_Kit__c = false;
                if (case_i.email_from_patient__c != null) {
                    mails.add(
                        prepareMail(
                            case_i, 
                            case_i.email_from_patient__c, 
                            emailDevNameToTemplatelMap.get('First_Call_Done_Female_RH'), 
                            owe.Id)
                    );
                }
            }
        }
        
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
            logicExecuted = true;
        }

        System.debug('mails: size: ' + mails.size() + ' value: ' + mails);
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
            logicExecuted = true;
        }

        if (logicExecuted) {
            System.debug('TR Case sendFirstKitEmail ... executed');
        }
    }
   
    public static void createSecondReminderTask(List<Case> cases) {
        List<Task> tasksToInsert = new List<Task>();

        for (Case case_i : cases) {
            if (case_i.Second_Reminder_Sent_Female_Couple__c == true) {
                tasksToInsert.add(new Task(
                    OwnerId = case_i.OwnerId, 
                    Status = 'Not Started', 
                    Subject = 'תזכור המטופלת בנוגע לשליחת המסמכים', 
                    WhatId = case_i.AccountId));
            } 
            if (case_i.Second_Reminder_Sent_Partner__c == true) {
                tasksToInsert.add(new Task(
                    OwnerId = case_i.OwnerId, 
                    Status = 'Not Started', 
                    Subject = 'תזכור בן הזוג בנוגע לשליחת המסמכים', 
                    WhatId = case_i.Partner_Name__c));
            }
        }

        System.debug('tasksToInsert: size: ' + tasksToInsert.size() + ' value: ' + tasksToInsert);
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
            System.debug('TR Case createSecondReminderTask... executed');
        } 
    }

    public static void createDocumentsReceivedTask(List<Case> cases) {
        Boolean logicExecuted = false;
        List<Case> casesToUpdate = new List<Case>();
        List<Task> tasksToInsert = new List<Task>();

        for (Case case_i : cases) {
            if (case_i.Case_Route__c == 'Seperate_Route' && case_i.Female_Status__c == 'Documents_Holds') {
                casesToUpdate.add(
                    new Case(
                        Id = case_i.Id,
                        Female_Status__c = 'Documents_Received'
                    )
                );
                tasksToInsert.add(
                    new Task(
                        OwnerId = case_i.OwnerId,
                        Status = 'Not Started', 
                        Subject = 'נוספו מסמכים חדשים לפנייה מהמטופלת להתייחסותך', 
                        WhatId = case_i.Id, 
                        Related_Account__c = case_i.AccountId
                    )
                );
            } else if (case_i.Case_Route__c == 'Seperate_Route' && case_i.Partner_Status__c == 'Documents_Holds') {
                casesToUpdate.add(
                    new Case(
                        Id = case_i.Id,
                        Partner_Status__c = 'Documents_Received'
                    )
                );
                tasksToInsert.add(
                    new Task(
                        OwnerId = case_i.OwnerId,
                        Status = 'Not Started', 
                        Subject = 'נוספו מסמכים חדשים לפנייה מבן הזוג להתייחסותך',
                        WhatId = case_i.Id, 
                        Related_Account__c = case_i.Partner_Name__c
                    )
                );
            } else if ((case_i.Case_Route__c == 'Donation_Route' || case_i.Case_Route__c == 'Double_Route') && case_i.Case_Status__c == 'Documents_Holds') {
                casesToUpdate.add(
                    new Case(
                        Id = case_i.Id,
                        Case_Status__c = 'Documents_Received'
                    )
                );
                tasksToInsert.add(
                    new Task(
                        OwnerId = case_i.OwnerId,
                        Status = 'Not Started', 
                        Subject = 'נוספו מסמכים חדשים לפנייה מהזוג להתייחסותך',
                        WhatId = case_i.Id, 
                        Related_Account__c = case_i.AccountId
                    )
                );
            } 
        } 

        System.debug('tasksToInsert: size: ' + tasksToInsert.size() + ' value: ' + tasksToInsert);
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
            logicExecuted = true;
        } 
        System.debug('casesToUpdate: size: ' + casesToUpdate.size() + ' value: ' + casesToUpdate);
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
            logicExecuted = true;
        } 
        if (logicExecuted) {
            System.debug('TR Case createDocumentsReceivedTask... executed');
        }
    }
    
    public static void sendShikumBaitStatusChanged(List<Case> cases, Set<Id> docNameIds, Set<Id> userIds, Set<Id> groupIds) {
        Boolean logicExecuted = false;
        Map<Id, Account> docNamesMap = new Map<Id, Account>();
        Map<Id, User> usersMap = new Map<Id, User>();
        Map<Id, Group> groupsMap = new Map<Id, Group>();
        List<SMS__c> smssToInsert = new List<SMS__c>();
        EmailTemplate template = [SELECT Subject
                                        , HtmlValue
                                        , Body 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName = 'Shikum_Bait_Response_Update'];
        OrgWideEmailAddress owea = [SELECT Id
                                            , Address 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address = 'nonreply@assuta.co.il' 
                                    LIMIT 1];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        if (!docNameIds.isEmpty()) {
            docNamesMap = new Map<Id, Account>([SELECT Id
                                                        , Name
                                                        , Doctor_personal_phone__c 
                                                FROM Account 
                                                WHERE Id IN :docNameIds 
                                                    AND  Doctor_personal_phone__c != null]);
        }
        if (!userIds.isEmpty()) {
            usersMap = new Map<Id, User>([SELECT Id
                                                , Email 
                                            FROM User 
                                            WHERE Id IN :userIds 
                                                AND Email != null]);
        }
        if (!groupIds.isEmpty()) {
            groupsMap = new Map<Id, Group>([SELECT Id
                                                    , Email 
                                            FROM Group 
                                            WHERE Id IN :groupIds 
                                                AND Email != null]);
        }

        System.debug('docNamesMap: size: ' + docNamesMap.size() + ' value: ' + docNamesMap);
        System.debug('usersMap: size: ' + usersMap.size() + ' value: ' + usersMap);
        System.debug('groupsMap: size: ' + groupsMap.size() + ' value: ' + groupsMap);
        for (Case case_i : cases) {
            if (case_i.Case_Status_Shikum_Bait__c == 'Pending_Doctor_Approval' && docNamesMap.containsKey(case_i.Approving_Doctor_Name__c)) {
                smssToInsert.add(prepareApprovingDoctorSMS(case_i, docNamesMap.get(case_i.Approving_Doctor_Name__c)));
            } else if (case_i.Case_Status_Shikum_Bait__c == 'Received_Doctor_Response' 
                            && (usersMap.containsKey(case_i.OwnerId) || groupsMap.containsKey(case_i.OwnerId))) {
                String email = User.getSObjectType() == case_i.OwnerId.getSObjectType() ? usersMap.get(case_i.OwnerId).Email : groupsMap.get(case_i.OwnerId).Email;

                mails.add(prepareMail(case_i, email, template, owea.Id));
            }
        }

        System.debug('smssToInsert: size: ' + smssToInsert.size() + ' value: ' + smssToInsert);
        if (!smssToInsert.isEmpty()) {
            insert smssToInsert;
            logicExecuted = true;
        }
        System.debug('mails: size: ' + mails.size() + ' value: ' + mails);
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
            logicExecuted = true;
        }
        if (logicExecuted) {
            System.debug('TR Case sendShikumBaitStatusChanged... executed');
        }
    }

    private static SMS__c prepareApprovingDoctorSMS(Case cas, Account docName) {
        return new SMS__c(
            Case__c = cas.Id,
            Template_Text__c = getSMSTemplate(new String[]{docName.Name}, 'Approving_Doctor'),
            Phone_Number__c = docName.Doctor_personal_phone__c, 
            status__c = '1',           
            Type__c = 'Outgoing'
        );
    }

    public static void updateShikumBaitStatus(List<Case> cases) {
        for (Case case_i : cases) {
            if (case_i.Shikum_Bait_Approval__c == 'Approves_Shikum') {
                case_i.Case_Phase__c = 'Service_Adaption';
                case_i.Case_Status_Shikum_Bait__c = 'Received_Doctor_Response';
            } else if (case_i.Shikum_Bait_Approval__c == 'Not_Approved_Shikum') {
                case_i.Case_Phase__c = 'Closing';
                case_i.Case_Status_Shikum_Bait__c = 'Service_Unqualified';
            } else if (case_i.Surgery_Name__c != null && case_i.Shikum_Bait_Approval__c == null) {
                case_i.Case_Phase__c = 'New';
                case_i.Case_Status_Shikum_Bait__c = 'New';
            }
        }
        System.debug('TR Case updateShikumBaitStatus... executed');
    }

    private static String getSMSTemplate(String smsName) {
        return getSMSTemplate(null, smsName);
    }

    private static String getSMSTemplate(String[] values, String smsName) {
        List<String> valuesList = new List<String>{smsName};

        if (values != null && !values.isEmpty()) {
            valuesList.addAll(values);
        }
        return String.join(valuesList, ',');
    }

    public static void deleteAvayaDuplicates(List<Case> newList, Set<String> ucids) {
        List<Case> caseListToDelete = [
            SELECT Id
              FROM Case
             WHERE Id NOT IN :newList
               AND UCID__c IN :ucids
               AND Case_subject__c = null];
        System.debug('caseListToDelete: size: ' + caseListToDelete.size() + ' value: ' + caseListToDelete);

        if (!caseListToDelete.isEmpty()) {
            System.debug('TR Case deleteAvayaDuplicates ... executed');
            delete caseListToDelete;
        }
    }
    
    public static void fillAccountId(List<Case> cases, Set<Id> opptIds) {
        Boolean logicExecuted = false;

        Map<Id, Opportunity> opptsMap = new Map<Id, Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN: opptIds AND AccountId != null]);
        System.debug('opptsMap: size: ' + opptsMap.size() + ' value: ' + opptsMap);

        for (Case case_i : cases) {
            if (opptsMap.containsKey(case_i.Opportunity__c)) {
                case_i.AccountId = opptsMap.get(case_i.Opportunity__c).AccountId;
                logicExecuted = true;
            }
        }

        if (logicExecuted) {
            System.debug('TR Case fillAccountId ... executed');
        }
    }
    
    public static void fillReferralAgencyLabel(List<Case> cases) {
        Boolean logicExecuted = false;
        Map<String, PicklistUtil.PicklistValue> picklistMap = PicklistUtil.buildPicklistMapping('Case', 'referralAgency__c');

        for (Case case_i : cases) {
            case_i.ReferralAgencyLabel__c = picklistMap.get(case_i.referralAgency__c)?.label;
            logicExecuted = true;
        }

        if (logicExecuted) {
            System.debug('TR Case fillReferralAgencyLabel ... executed');
        }
    }    
}