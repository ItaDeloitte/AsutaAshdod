// Test: CaseServicesTest
public class CaseTriggerDispatcher {

    public static Map<String, RecordTypeInfo> caseRTMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    public static List<User> integrationUsers = [SELECT Id FROM User WHERE Id = :Label.Default_Integration_UserId OR ProfileId = :Label.Integration_ProfileId];

    /**
     * Copy information from the related Account record
     */
    public static void copyAccountInfo(List<Case> pNewList, Map<Id, Case> pOldMap) {
        System.debug('TR Case copyAccountInfo ... start');
        List<Case> caseList = new List<Case>();
        Set<Id> accountIdSet = new Set<Id>();

        Boolean isInsert = pOldMap == null;

        for (Case case_i : pNewList) {
            Case oldCase_i = pOldMap?.get(case_i.Id);

            if ((case_i.AccountId != null
                        && ((isInsert
                                && case_i.ContactId == null)
                            || (!isInsert
                                && oldCase_i.AccountId == null)
                            || (case_i.First_Call_Made_Female__c
                                && (isInsert
                                    || !oldCase_i.First_Call_Made_Female__c))
                            || (case_i.PayerFactor__c == null
                                && (case_i.RecordTypeId == caseRTMap.get('Assuta_360').getRecordTypeId()
                                    || case_i.RecordTypeId == caseRTMap.get('DOC_expert').getRecordTypeId())
                                && (isInsert
                                    || case_i.PayerFactor__c != oldCase_i.PayerFactor__c))))
                    || (case_i.Partner_Name__c != null
                        && ((case_i.First_Call_Made_Partner__c
                                && (isInsert
                                    || !oldCase_i.First_Call_Made_Partner__c))
                            || (case_i.Partner_Email__c == null
                                && (isInsert
                                    || case_i.Partner_Name__c != oldCase_i.Partner_Name__c))))
                    || (case_i.Recommended_doc__c != null
                        && case_i.Doctor_Arrangement__c == null
                        && (case_i.RecordTypeId == caseRTMap.get('Assuta_360').getRecordTypeId()
                            || case_i.RecordTypeId == caseRTMap.get('DOC_expert').getRecordTypeId()
                            || case_i.RecordTypeId == caseRTMap.get('CaseAfterSale').getRecordTypeId())
                        && (isInsert
                            || case_i.Recommended_doc__c != oldCase_i.Recommended_doc__c))) {
                accountIdSet.add(case_i.Recommended_doc__c);
                accountIdSet.add(case_i.Partner_Name__c);
                accountIdSet.add(case_i.AccountId);
                caseList.add(case_i);
            }
        }
        System.debug('TR Case caseList [' + caseList.size() + ']: ' + caseList);
        System.debug('TR Case accountIdSet [' + accountIdSet.size() + ']: ' + accountIdSet);

        if (!caseList.isEmpty()) {
            CaseServices.copyAccountInfo(caseList, pOldMap, accountIdSet);
        }
    }

    /**
     * Update information on the related Account 360 record
     */
    public static void updateAccount360Info(List<Case> pNewList, Map<Id, Case> pOldMap) {
        System.debug('TR Case updateAccount360Info ... start');
        List<Case> caseList = new List<Case>();
        Set<Id> accountIdSet = new Set<Id>();

        Boolean isInsert = pOldMap == null;

        for (Case case_i : pNewList) {
            Case oldCase_i = pOldMap?.get(case_i.Id);

            if (case_i.AccountId != null
                    && case_i.RecordTypeId == caseRTMap.get('Assuta_360').getRecordTypeId()
                    && ((case_i.Status == 'סגירת אירוע אוטומטית'
                            && (isInsert || case_i.Status != oldCase_i.Status))
                        || (case_i.First_user_to_own_the_case__c != null
                            && (isInsert || case_i.First_user_to_own_the_case__c != oldCase_i.First_user_to_own_the_case__c)))) {
                accountIdSet.add(case_i.AccountId);
                caseList.add(case_i);
            }
        }
        System.debug('TR Case caseList [' + caseList.size() + ']: ' + caseList);
        System.debug('TR Case accountIdSet [' + accountIdSet.size() + ']: ' + accountIdSet);

        if (!caseList.isEmpty()) {
            CaseServices.updateAccount360Info(caseList, pOldMap, accountIdSet);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Update Record Type based on pre filled Case_Recordtype_TMP__c in chat
     * 
     * Event            BEFORE_INSERT
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillRTFromChat(List<Case> newList) {
        System.debug('TR Case fillRTFromChat ... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.Case_Recordtype_TMP__c != null) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()){
            CaseServices.fillRTFromChat(cases);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Fill formtitan_id_2__c field by generated randomly key via CommonService.generateRandomKey(15)
     * 
     * Event            BEFORE_INSERT
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillFormtitanId(List<Case> newList) {
        System.debug('TR Case fillFormtitanId ... start');

        // no criteria
        System.debug('cases: size: ' + newList.size() + ' value: ' + newList);
        CaseServices.fillFormtitanId(newList);
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Validate Case's Recommended_doc__c by PayerFactor__c
     * 
     * Event            BEFORE_INSERT, BEFORE_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void validateRecDoctor(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case validateRecDoctor ... start');
        List<Case> cases = new List<Case>();
        Set<Id> pFactorIds = new Set<Id>();
        Set<Id> doctorIds = new Set<Id>();

        for (Case case_i : newList) {
            if (case_i.Recommended_doc__c != null &&
                    (oldMap == null ||
                    (case_i.Recommended_doc__c != oldMap.get(case_i.Id).Recommended_doc__c ||
                        case_i.PayerFactor__c != oldMap.get(case_i.Id).PayerFactor__c ||
                        case_i.Channel__c != oldMap.get(case_i.Id).Channel__c))) {
                doctorIds.add(case_i.Recommended_doc__c);
                pFactorIds.add(case_i.PayerFactor__c);
                cases.add(case_i);
            }
        }
        System.debug('pFactorIds: size: ' + pFactorIds.size() + ' value: ' + pFactorIds);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.validateRecDoctor(cases, doctorIds, pFactorIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Clear Doctor_Arrangement__c and Agreement__c fields on a Case when Recommended_doc__c is changed
     * 
     * Event            BEFORE_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void removeAgreementArrangement(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case removeAgreementArrangement ... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (oldMap.get(case_i.Id).Recommended_doc__c != case_i.Recommended_doc__c &&
                    oldMap.get(case_i.Id).Recommended_doc__c != null) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.removeAgreementArrangement(cases);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Run assignment rules for a Case created in the chat
     * 
     * Event            AFTER_INSERT
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void runAssignFromApex(List<Case> newList) {
        System.debug('TR Case runAssignFromApex ... start');
        Set<Id> caseIds = new Set<Id>();

        for (Case case_i : newList) {
            if (!case_i.Apex_Assigned__c && case_i.Origin == 'Chat') {
                caseIds.add(case_i.Id);
            }
        }
        System.debug('caseIds: size: ' + caseIds.size() + ' value: ' + caseIds);

        if (!caseIds.isEmpty()) {
            CaseServices.runAssignFromApex(caseIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Update Patient_has_open_case__c and DisableValidation__c on related Account if Case is closed
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void hasOpenCaseCheck(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case hasOpenCaseCheck ... start');
        Set<Id> acctIds = new Set<Id>();

        for (Case case_i : newList) {
            if (oldMap == null) {
                acctIds.add(case_i.AccountId);
            } else if (case_i.IsClosed != oldMap.get(case_i.Id).IsClosed || case_i.AccountId != oldMap.get(case_i.Id).AccountId) {
                acctIds.add(case_i.AccountId);
                acctIds.add(oldMap.get(case_i.Id).AccountId);
            }
        }
        System.debug('acctIds: size: ' + acctIds.size() + ' value: ' + acctIds);

        if (!acctIds.isEmpty()) {
            CaseServices.hasOpenCaseCheck(acctIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Fill First_user_to_own_the_case__c field with a user's id who owned this case first
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * User             * except Integration on insert
     * Profile          *
     * Record Type      * except CaseAfterSale and Assuta_360
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           
     * @created          
     * @modifiedBy       Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @modified         05-03-2021
     * @description      refactored
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void updateStatusByOwner(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case updateStatusByOwner ... start');
        Set<Id> caseIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        for (User user_i : integrationUsers) {
            userIds.add(user_i.Id);
        }

        for (Case case_i : newList) {
            if (User.getSObjectType() == case_i.OwnerId.getSObjectType() &&
               (case_i.RecordTypeId != null && !(Label.CaseRTIdToExcludeCaseTrigger.contains(case_i.RecordTypeId))) &&
                ((oldMap != null && Group.getSObjectType() == oldMap.get(case_i.Id).OwnerId.getSObjectType()) ||
                 (oldMap == null && !userIds.contains(case_i.CreatedById)))) {
                caseIds.add(case_i.Id);
            }
        }
        System.debug('caseIds: size: ' + caseIds.size() + ' value: ' + caseIds);

        if (!caseIds.isEmpty()) {
            CaseServices.updateStatusByOwner(caseIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Automatically complete all related Milestones if Case.Status = 'Closed' or if Shikum Bait case in phase 'בתהליך' with  
     * statuses 'First_Visit_Scheduled' or 'Appointments_Scheduled'.
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * User             *
     * Profile          *
     * Record Type      *
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Evgeniy Kravchuk            <evgeniy.kravchuk@synebo.io>
     * @created          25-12-2020
     * @modifiedBy       Sergey Duiev                <sergey.duiev@synebo.io>
     * @modified         26-04-2021
     * @description      added criteria from process builder for Shikum_Bait RT
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void completeMilestones(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case completeMilestones ... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if ((case_i.Status == 'Closed' && (oldMap == null || oldMap.get(case_i.Id).Status != case_i.Status)) 
                    || (case_i.Case_Phase__c == 'In_Process' 
                        && case_i.RecordTypeId == caseRTMap.get('Shikum_Bait').getRecordTypeId() 
                        //יציאה מSLA  התקבלה תשובה מרופא
                        //יציאה מSLA  מתמתין לתיאום תורים 24 שעות 
                        && (case_i.Case_Status_Shikum_Bait__c == 'First_Visit_Scheduled' || case_i.Case_Status_Shikum_Bait__c == 'Appointments_Scheduled')
                            && (oldMap == null || oldMap.get(case_i.Id).Case_Status_Shikum_Bait__c != case_i.Case_Status_Shikum_Bait__c))) {
                cases.add(case_i);
            } 
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.completeMilestones(cases);
        }
    }

    /**
     * Copy information from the Owner's Manager record
     */
    public static void copyManagerEmail(List<Case> pNewList, Map<Id, Case> pOldMap) {
        System.debug('TR Case copyManagerEmail ... start');
        List<Case> caseList = new List<Case>();
        Set<Id> ownerIdSet = new Set<Id>();

        for (Case case_i : pNewList) {
            if (case_i.OwnerId.getSObjectType() == User.getSObjectType()
                    && (pOldMap == null
                        || case_i.OwnerId != pOldMap.get(case_i.Id).OwnerId)) {
                caseList.add(case_i);
                ownerIdSet.add(case_i.OwnerId);
            }
        }
        System.debug('TR Case caseList [' + caseList.size() + ']: ' + caseList);
        System.debug('TR Case ownerIdSet [' + ownerIdSet.size() + ']: ' + ownerIdSet);

        if (!caseList.isEmpty()) {
            CaseServices.copyManagerEmail(caseList, ownerIdSet);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Case from doc? : Write Assuta SLA Entitlement Id to field EntitlementId
     * 
     * Event            BEFORE_INSERT
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          11-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillEntitlement(List<Case> newList) {
        System.debug('TR Case fillEntitlement ... start');

        // no criteria
        System.debug('cases: size: ' + newList.size() + ' value: ' + newList);
        CaseServices.fillEntitlement(newList);
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Send OPT sms/email if send_OTP__c has been set to true
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          18-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void sendOPT(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case sendOPT ... start');
        List<Case> cases = new List<Case>();
        Set<Id> contactIds = new Set<Id>();

        for (Case case_i : newList) {
            if (case_i.send_OTP__c
                    && (oldMap == null || case_i.send_OTP__c != oldMap.get(case_i.Id).send_OTP__c)
                    //OTP-SMS 
                    && (case_i.SMS_Phone_Number__c != null 
                    //OTP-Email 
                        || (case_i.SMS_Phone_Number__c == null && case_i.email_from_patient__c != null))
                    && case_i.ContactId != null
                    && case_i.AccountId != null) {
                cases.add(case_i);
                contactIds.add(case_i.ContactId);
            }
        }

        System.debug('cases: size: ' + cases.size() + ' values: ' + cases);
        System.debug('contactIds: size: ' + contactIds.size() + ' values: ' + contactIds);
        if (!cases.isEmpty()) {
            CaseServices.sendOPT(cases, contactIds);
        }
    }


    //קישור קייס המלצה לקייס ישן
    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Create Case_Recommended_Doctor__c for new Case and save related old case as last_recommended_case_id__c for Account 
     * and related_Case_rec__c for that new Case 
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          18-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void createRecommendedDoctor(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case createRecommendedDoctor ... start');
        Map<Id, Id> casesToAccsMap = new Map<Id, Id>();

        for (Case case_i : newList) {
            if (case_i.sub_case_subject__c == 'זימון תור לאחר המלצה'
                    && !case_i.call_flow_connect_rec_case_to__c
                    && (oldMap == null 
                        || case_i.call_flow_connect_rec_case_to__c != oldMap.get(case_i.Id).call_flow_connect_rec_case_to__c)
                    && case_i.AccountId != null 
                    && case_i.Status != 'Caneclled') {
                casesToAccsMap.put(case_i.Id, case_i.AccountId);
            }
        }

        System.debug('accsToCasesMap: size: ' + casesToAccsMap.size() + ' values: ' + casesToAccsMap);
        if (!casesToAccsMap.isEmpty()) {
            CaseServices.createRecommendedDoctor(casesToAccsMap);
        }
    }

    //הועבר לצד שלישי-פרסום בצ'אטר (Red mark in doc)
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * בדיקת הסדר שונה מפרטי במומחים : Set cases's doc_arrangment_not_private_hidden__c if Channel__c == 'פרטי' and 
     * Doctor_Arrangement__r.Arrangement__r.PayerFactor__r.Name = 'פרטי'
     * 
     * Event            BEFORE_INSERT, BEFORE_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          19-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void setDoctorArrangmentNotPrivateHidden(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case setDoctorArrangmentNotPrivateHidden ... start');
        List<Case> cases = new List<Case>();
        Set<Id> docArrangIds = new Set<Id>();

        for (Case case_i : newList) {
            if (case_i.Doctor_Arrangement__c != null
                    && case_i.doc_arrangment_not_private_hidden__c == null
                    && case_i.Channel__c == 'פרטי'
                    && case_i.PayerFactor__c != null
                    && case_i.Recommended_doc__c != null) {
                cases.add(case_i);
                docArrangIds.add(case_i.Doctor_Arrangement__c);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' values: ' + cases);
        System.debug('docArrangIds: size: ' + docArrangIds.size() + ' values: ' + docArrangIds);

        if (!cases.isEmpty()) {
            CaseServices.setDoctorArrangmentNotPrivateHidden(cases, docArrangIds);
        }
    }

    /**
     * Save the first User Owner into the custom field
     */
    public static void saveOwner(List<Case> newList, Map<Id, Case> pOldMap) {
        System.debug('TR Case saveOwner ... start');
        List<Case> caseList = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.OwnerId.getSObjectType() == User.getSObjectType()
                    && case_i.OwnerId != Label.User_Integration_User_Id
                    && case_i.OwnerId != Label.SSIS_User_Id
                    && case_i.First_user_to_own_the_case__c == null
                    && (pOldMap == null
                        || case_i.First_user_to_own_the_case__c != pOldMap.get(case_i.Id).First_user_to_own_the_case__c)) {
                caseList.add(case_i);
            }
        }
        System.debug('TR Case caseList [' + caseList.size() + ']: ' + caseList);

        if (!caseList.isEmpty()) {
            CaseServices.saveOwner(caseList);
        }
    }

    /**
     * Send custom notification to the new Owner
     */
    public static void notifyOwner(List<Case> pNewList, Map<Id, Case> pOldMap) {
        System.debug('TR Case notifyOwner ... start');
        List<Case> caseList = new List<Case>();

        for (Case case_i : pNewList) {
            if (case_i.OwnerId.getSObjectType() == User.getSObjectType()
                    && case_i.OwnerId != pOldMap.get(case_i.Id).OwnerId
                    && case_i.OwnerId != Label.User_Integration_User_Id
                    && case_i.OwnerId != Label.SSIS_User_Id
                    && (case_i.Origin != 'Chat'
                        || case_i.Origin == 'פייסבוק מסנג\'ר'
                        || case_i.Origin == 'WhatsApp'
                        || case_i.Origin == 'SMS')) {
                caseList.add(case_i);
            }
        }
        System.debug('TR Case caseList [' + caseList.size() + ']: ' + caseList);

        if (!caseList.isEmpty()) {
            CaseServices.notifyOwner(caseList);
        }
    }

    /**
     * Transfer ownership to the manager
     */
    public static void transferToManager(List<Case> pNewList, Map<Id, Case> pOldMap) {
        System.debug('TR Case transferToManager ... start');
        List<Case> caseList = new List<Case>();
        Set<Id> ownerIdSet = new Set<Id>();

        for (Case case_i : pNewList) {
            if (case_i.OwnerId.getSObjectType() == User.getSObjectType()
                    && case_i.OwnerId != Label.SSIS_User_Id
                    && case_i.First_user_to_own_the_case__c != null
                    && !case_i.help_transfer_to_manager__c
                    && case_i.Status == 'Escalated'
                    && (pOldMap == null
                        || case_i.Status != pOldMap.get(case_i.Id).Status)) {
                caseList.add(case_i);
                ownerIdSet.add(case_i.OwnerId);
            }
        }
        System.debug('TR Case caseList [' + caseList.size() + ']: ' + caseList);
        System.debug('TR Case ownerIdSet [' + ownerIdSet.size() + ']: ' + ownerIdSet);

        if (!caseList.isEmpty()) {
            CaseServices.transferToManager(caseList, ownerIdSet);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * For DOC_expert cases with Send_DocAdvisor__c = true send doctor recommendation by sms/email.
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * Record Type      DOC_expert, CaseAfterSale
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          11-05-2021
     * @modifiedBy       Sergey Duiev             <sergey.duiev@synebo.io>
     * @modified         18-05-2021
     * @description      added CaseAfterSale
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void sendDocAdvisor(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case sendDocAdvisor ... start');
        Id DOCexpertRTId = caseRTMap.get('DOC_expert').getRecordTypeId();
        Id CaseAfterSaleRTId = caseRTMap.get('CaseAfterSale').getRecordTypeId();
        List<Case> cases = new List<Case>();
        Set<Id> contactIds = new Set<Id>();

        for (Case case_i : newList) {
            if ((case_i.RecordTypeId == DOCexpertRTId || case_i.RecordTypeId == CaseAfterSaleRTId)
                    && case_i.Send_DocAdvisor__c == true 
                    && (oldMap == null || oldMap.get(case_i.Id).Send_DocAdvisor__c != case_i.Send_DocAdvisor__c)
                    //SMS rule
                    && (((case_i.preferd_chanal_case__c == 'SMS' 
                        || case_i.preferd_chanal_case__c == 'Whatsapp' 
                        || case_i.preferd_chanal_case__c == 'Phone') 
                        && case_i.SMS_Phone_Number__c != null) 
                    //Email rule
                    || (case_i.preferd_chanal_case__c == 'Email' 
                        && case_i.email_from_patient__c != null))  ) {
                cases.add(case_i);
                contactIds.add(case_i.ContactId);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('contactIds: size: ' + contactIds.size() + ' value: ' + contactIds);

        if (!cases.isEmpty()) {
            CaseServices.sendDocAdvisor(cases, contactIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * רופא כירורג דפולטי לקביעת פגישות : Set Contact_doctor__c if not set
     * 
     * Event            BEFORE_INSERT, BEFORE_UPDATE
     * RecordType       Assuta_360
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          19-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void setContactDoctor(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case setContactDoctor ... start');
        Id assuta360RTId = caseRTMap.get('Assuta_360').getRecordTypeId();
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.RecordTypeId == assuta360RTId
                    && case_i.surgeon_doctor__c != null 
                    && case_i.Contact_doctor__c == null) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' values: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.setContactDoctor(cases);
        }
    }

    //case not null
    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Set return_case_type__c = 'נפתחה עוד פנייה לפנייה זו' to exist cases with same patien id , same sub_case_subject__c and that
     * was created not earlier than three days ago
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          20-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void markCaseAsReturning(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case markCaseAsReturning ... start');
        List<Case> cases = new List<Case>();
        Set<Id> accIds = new Set<Id>();
        Set<String> subCaseSubjects = new Set<String>();
        Id transferToSecretariesRTId = caseRTMap.get('transfer_to_secretaries').getRecordTypeId();
        
        for (Case case_i : newList) {
            if (case_i.AccountId != null 
                    && (oldMap == null || case_i.sub_case_subject__c != oldMap.get(case_i.Id).sub_case_subject__c)
                    && case_i.sub_case_subject__c != null
                    && case_i.RecordTypeId != transferToSecretariesRTId) {
                cases.add(case_i);
                accIds.add(case_i.AccountId);
                subCaseSubjects.add(case_i.sub_case_subject__c);
            }
        }

        System.debug('cases: size: ' + cases.size() + ' values: ' + cases);
        System.debug('accIds: size: ' + accIds.size() + ' values: ' + accIds);
        System.debug('subCaseSubjects: size: ' + subCaseSubjects.size() + ' values: ' + subCaseSubjects);
        if (!cases.isEmpty()) {
            CaseServices.markCaseAsReturning(cases, accIds, subCaseSubjects);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * For cases with send_link_for_referral__c = true send referal by sms/email.
     * 
     * Event            AFTER_INSERT, AFTER_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          11-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void sendLinkForReferral(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case sendLinkForReferral ... start');
        List<Case> cases = new List<Case>();
        Set<Id> contactIds = new Set<Id>();

        for (Case case_i : newList) {
            if ((oldMap == null || case_i.send_link_for_referral__c != oldMap.get(case_i.Id).send_link_for_referral__c) 
                    && case_i.send_link_for_referral__c == true 
                    && case_i.ContactId != null 
                    //send sms
                    && ((case_i.preferd_chanal_case__c == 'SMS' && case_i.SMS_Phone_Number__c != null) 
                    //send email    
                        || (case_i.preferd_chanal_case__c == 'Email' && case_i.email_from_patient__c != null))) {
                cases.add(case_i);
                contactIds.add(case_i.ContactId);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('contactIds: size: ' + contactIds.size() + ' value: ' + contactIds);

        if (!cases.isEmpty()) {
           CaseServices.sendLinkForReferral(cases, contactIds);
        }
    }

    //create survey for surgery (removed due to email from yanan@assuta.co.il 20.03.22)
    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * For cases with record type ClosedInstitutes, ClosedExp, ClosedSurgeries and status = 'Closed' create Agent_survey__c, for 
     * other record types with status 'Closed' and not null opportunity - send sms if opportunity campaing has Survey__c and create 
     * Agent_survey__c if not
     * 
     * Event            AFTER_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          11-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static Boolean createAgentSurveyIsFirstRun = true;
    public static void createAgentSurvey(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case createAgentSurvey ... start');
        List<Case> cases = new List<Case>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> opptIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        for (Case case_i : newList) {                       
            if (createAgentSurveyIsFirstRun 
                    && case_i.Status == 'Closed' 
                    && case_i.RecordTypeId != oldMap.get(case_i.Id).RecordTypeId  
                    && case_i.AccountId != null 
                    && case_i.CreatedById != System.Label.SSIS_User_Id 
                    && case_i.CreatedById != System.Label.User_Integration_User_Id                     
                    && case_i.Dont_send_survey__c == false 
                    //create survey for expert\institute                   
                    && (case_i.RecordTypeId == caseRTMap.get('ClosedInstitutes').getRecordTypeId() 
                        || case_i.RecordTypeId == caseRTMap.get('ClosedExp').getRecordTypeId())) {                            
                cases.add(case_i);
                accIds.add(case_i.AccountId);
                opptIds.add(case_i.Opportunity__c);
                userIds.add(case_i.CreatedById);    
            //send survey for CaseAfterSale
            
            //create regular survey for caseAfterSale
            } else if (createAgentSurveyIsFirstRun 
                            && case_i.Opportunity__c != null
                            && case_i.Status == 'Closed' && case_i.Status != oldMap.get(case_i.Id).Status) {                                
                cases.add(case_i);
                opptIds.add(case_i.Opportunity__c);
                userIds.add(case_i.CreatedById);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('accIds: size: ' + accIds.size() + ' value: ' + accIds);
        System.debug('opptIds: size: ' + opptIds.size() + ' value: ' + opptIds); 
        System.debug('userIds: size: ' + userIds.size() + ' value: ' + userIds); 

        if (!cases.isEmpty()) {
            CaseServices.createAgentSurvey(cases, accIds, opptIds, userIds);
            createAgentSurveyIsFirstRun = false;
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Get Conact Comm Details : Fill case contact fields from Contact's Account if is person otherwise from contact.
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          11-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillContactDetails(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case fillContactDetails ... start');
        List<Case> cases = new List<Case>();
        Set<Id> contactIds = new Set<Id>();

        for (Case case_i : newList) {
            if (case_i.ContactId != null 
                    && case_i.AccountId != null 
                    && case_i.Get_contact_details__c == false
                    && (oldMap == null || case_i.Get_contact_details__c != oldMap.get(case_i.Id).Get_contact_details__c)) {
                cases.add(case_i);
                contactIds.add(case_i.ContactId);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('contactIds: size: ' + contactIds.size() + ' value: ' + contactIds);

        if (!cases.isEmpty()) {
            CaseServices.fillContactDetails(cases, contactIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * תוצאות ביופסיה : Change case status to 'התקבלו תוצאות ביופסיה' if biobsy result was picket
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE
     * Record Type       Assuta_360 
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          12-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void setBiopsyResults(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case setBiopsyResults ... start');
        Id assuta360RTId = caseRTMap.get('Assuta_360').getRecordTypeId();
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.RecordTypeId == assuta360RTId
                    && case_i.Status == 'ממתין לתוצאות ביופסיה'
                    && case_i.biopsy_result__c != null
                    && (oldMap == null || oldMap.get(case_i.Id).biopsy_result__c == null)) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.setBiopsyResults(cases);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * appointment_to_same_doc : Set case's appointment_to_doctor__c if Recommended_doc__c is chnaged and appointemnt with same
     * patient and doctor exists
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE 
     * RecordType        DOC_expert
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          20-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void setAppointmentToDoctor(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case setAppointmentToDoctor ... start');
        Id docExpertRTId = caseRTMap.get('DOC_expert').getRecordTypeId();
        List<Case> cases = new List<Case>();
        Set<Id> patientIds = new Set<Id>();
        Set<Id> docIds = new Set<Id>();

        for (Case case_i : newList) {
            if (case_i.RecordTypeId == docExpertRTId
                    && case_i.AccountId != null
                    && case_i.Recommended_doc__c != null
                    && (oldMap == null || case_i.Recommended_doc__c != oldMap.get(case_i.Id).Recommended_doc__c)) {
                cases.add(case_i);
                patientIds.add(case_i.AccountId);
                docIds.add(case_i.Recommended_doc__c);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('patientIds: size: ' + patientIds.size() + ' value: ' + patientIds);
        System.debug('docIds: size: ' + docIds.size() + ' value: ' + docIds);

        if (!cases.isEmpty()) {
            CaseServices.setAppointmentToDoctor(cases, patientIds, docIds);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * האם תורם? : Set Case_Route__c = 'Donation_Route' if Is_Donating__c was checked
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE        
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          13-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillDonating(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case fillDonating... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.Is_Donating__c
                    && (oldMap == null || !oldMap.get(case_i.Id).Is_Donating__c)) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.fillDonating(cases);
        }
    }
    
    //ChangeCaseOwnerPublicInquiry - (Not in doc)
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Set current user as owner if Status has been changed to 'In_Progress' for record types 'PublicInquiries'/'VF_Freezing_Eggs'
     * or if Case_Phase__c changed from 'New' for record type 'Shikum_Bait'
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE  
     * Record Type       PublicInquiries, IVF_Freezing_Eggs, Shikum_Bait      
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          13-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static Boolean setCurrentUserAsOwnerIsFirstRun = true;
    public static void setCurrentUserAsOwner(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case setCurrentUserAsOwner... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            //שינוי סטטוס הפניה ל"בטיפול"
            if (setCurrentUserAsOwnerIsFirstRun
                    && case_i.RecordTypeId == caseRTMap.get('IVF_Freezing_Eggs').getRecordTypeId()
                    && case_i.Status == 'In_Progress'
                    && (oldMap == null || case_i.Status != oldMap.get(case_i.Id).Status)) {
                cases.add(case_i);
            //פניית שיקום בית ושינוי סטטוס מ"חדש"
            } else if (setCurrentUserAsOwnerIsFirstRun
                            && case_i.RecordTypeId == caseRTMap.get('Shikum_Bait').getRecordTypeId()
                            && oldMap != null
                            && case_i.Case_Phase__c != oldMap.get(case_i.Id).Case_Phase__c
                            && oldMap.get(case_i.Id).Case_Phase__c == 'New') {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.setCurrentUserAsOwner(cases);
            setCurrentUserAsOwnerIsFirstRun = false;
        }
    }

    
   /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Creats Daily_Tasks_Log_IVF__c objects
     * 
     * Event             AFTER_INSERT, AFTER_UPDATE        
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          25-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static Boolean setCreateDailyTasksLogIVFIsFirstRun = true;
    public static void createDailyTasksLogIVF(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case createDailyTasksLogIVF... start');
        List<LogIVFWrapper> wrappers = new List<LogIVFWrapper>();
        Id IVFFreezingEggsRTId = caseRTMap.get('IVF_Freezing_Eggs').getRecordTypeId();

        for (Case case_i : newList) {
            if (setCreateDailyTasksLogIVFIsFirstRun) {
                //נשלח קיט ראשוני כלשהו
                if ((case_i.Send_Man_Kit__c
                            && (oldMap == null || case_i.Send_Man_Kit__c != oldMap.get(case_i.Id).Send_Man_Kit__c))
                        || (case_i.Send_First_Kit__c
                            && (oldMap == null || case_i.Send_First_Kit__c != oldMap.get(case_i.Id).Send_First_Kit__c))) {
                    wrappers.add(new LogIVFWrapper('לכמה נשלחו מסמכים', case_i));
                }
                //שלב פניה עבר להחלטה
                if ((case_i.Case_Stage__c == 'Decision'
                            && (oldMap == null || case_i.Case_Stage__c != oldMap.get(case_i.Id).Case_Stage__c))
                        || (case_i.Partner_Stage__c == 'Decision'
                            && (oldMap == null || case_i.Partner_Stage__c != oldMap.get(case_i.Id).Partner_Stage__c))
                        || (case_i.Female_Stage__c == 'Decision'
                            && (oldMap == null || case_i.Female_Stage__c != oldMap.get(case_i.Id).Female_Stage__c))) {
                    wrappers.add(new LogIVFWrapper('הושלם תהליך (התקבלה החלטה)', case_i));
                }
                //בוצע תשלום
                if (case_i.Payment_Done__c
                        && (oldMap == null || case_i.Payment_Done__c != oldMap.get(case_i.Id).Payment_Done__c)) {
                    wrappers.add(new LogIVFWrapper('בוצע תשלום', case_i));
                }
                //פניה נסגרה?
                if (case_i.RecordTypeId == IVFFreezingEggsRTId
                        && case_i.Status == 'Closed'
                        && (oldMap == null || case_i.Status != oldMap.get(case_i.Id).Status)) {
                    wrappers.add(new LogIVFWrapper('פניה נסגרה', case_i));
                }
                //פניה סומנה כרגישה?
                if (case_i.RecordTypeId == IVFFreezingEggsRTId
                        && case_i.Sensitive_Case__c
                        && (oldMap == null || case_i.Sensitive_Case__c != oldMap.get(case_i.Id).Sensitive_Case__c)) {
                    wrappers.add(new LogIVFWrapper('פניה סומנה כרגישה', case_i));
                }
            }
        }

        System.debug('wrappers: size: ' + wrappers.size() + ' values: ' + wrappers);
        if (!wrappers.isEmpty()) {
            CaseServices.createDailyTasksLogIVF(wrappers);
            setCreateDailyTasksLogIVFIsFirstRun = false;
        }
    }

    public class LogIVFWrapper {
        public Case cas {get;set;}
        public String changeReason {get;set;} 

        public LogIVFWrapper(String changeReason, Case cas) {
            this.changeReason = changeReason;
            this.cas = cas;
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * For case in stage 'Decision' fill Ministry_Of_Health_Transfer_Date__c, Research_Transfer_Date__c and Thawing_Date__c fields
     * depending on the Case_Status__c value
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          13-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillDecisionStageDate(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case fillDecisionStageDate... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.Case_Stage__c == 'Decision'
                    //העברה למחקר
                    && (case_i.Case_Status__c == 'Research_Donation' 
                       //הפשרה 
                        || case_i.Case_Status__c == 'UnControlled_Defrost' 
                        //העברה למשרד הבריאות
                        || case_i.Case_Status__c == 'No_Conception_HealthDepartment_Transfer')
                    && (oldMap == null
                        || (case_i.Case_Stage__c != oldMap.get(case_i.Id).Case_Stage__c
                            || case_i.Case_Status__c != oldMap.get(case_i.Id).Case_Status__c)
                            || case_i.Research_Transfer_Date__c != oldMap.get(case_i.Id).Research_Transfer_Date__c
                            || case_i.Thawing_Date__c != oldMap.get(case_i.Id).Thawing_Date__c
                            || case_i.Ministry_Of_Health_Transfer_Date__c != oldMap.get(case_i.Id).Ministry_Of_Health_Transfer_Date__c)) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.fillDecisionStageDate(cases);
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * For case with Case_Route__c == 'Seperate_Route' fill Payer__c and Recommendation__c fields depending on femail and partner
     * statuses.
     * 
     * Event             BEFORE_INSERT, BEFORE_UPDATE      
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          14-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void fillPayerRecommendation(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case fillPayerRecommendation... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.Case_Route__c == 'Seperate_Route'
                    && (oldMap == null
                        || (case_i.Female_Status__c != oldMap.get(case_i.Id).Female_Status__c
                            || case_i.Partner_Status__c != oldMap.get(case_i.Id).Partner_Status__c
                            || case_i.Case_Route__c != oldMap.get(case_i.Id).Case_Route__c
                            || case_i.Payer__c != oldMap.get(case_i.Id).Payer__c
                            || case_i.Recommendation__c != oldMap.get(case_i.Id).Recommendation__c))
                    //מסלול נפרד- הקפאה בתשלום לשניהם
                    && ((case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'Payed_Freezing')
                        //מסלול נפרד- הקפאה בתשלום+הפשרה /מחקר/אין מענה
                        || (case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'UnControlled_Defrost' )
                        || (case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'Research_Donation')
                        || (case_i.Female_Status__c == 'Payed_Freezing' && case_i.Partner_Status__c == 'No_Reply')
                        //מסלול נפרד- הפשרה והקפאה/מחקר והקפאה/אין מענה והקפאה
                        || (case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'Payed_Freezing')
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'Payed_Freezing')
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'Payed_Freezing')
                        //מסלול נפרד- הפשרה ומחקר/אין מענה
                        || (case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'Research_Donation')
                        || (case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'No_Reply')
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'UnControlled_Defrost')
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'No_Reply')
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'UnControlled_Defrost')
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'Research_Donation')
                        //מסלול בנפרד- הפשרה לשניהם
                        || (case_i.Female_Status__c == 'UnControlled_Defrost' && case_i.Partner_Status__c == 'UnControlled_Defrost')
                        //מסלול בנפרד- מחקר לשניהם
                        || (case_i.Female_Status__c == 'Research_Donation' && case_i.Partner_Status__c == 'Research_Donation')
                        //מסלול בנפרד- אין מענה לשניהם
                        || (case_i.Female_Status__c == 'No_Reply' && case_i.Partner_Status__c == 'No_Reply'))) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.fillPayerRecommendation(cases);
        }
    }

    //שליחת קיט ראשוני לגבר-רמת החייל
    //שליחת קיט ראשוני לגבר-ראשון לציון
     /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Send First_Call_Done_Male_RH or First_Call_Done_Male_RL if Send_Man_Kit__c has been set to true and Partner_Email__c
     * not null
     * 
     * Event             AFTER_INSERT, AFTER_UPDATE      
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          14-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static Boolean sendManKitEmailIsFirstRun = true;
    public static void sendManKitEmail(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case sendManKitEmail... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (sendManKitEmailIsFirstRun
                    && case_i.Send_Man_Kit__c
                    && (oldMap == null || case_i.Send_Man_Kit__c != oldMap.get(case_i.Id).Send_Man_Kit__c)
                    && (case_i.Case_site__c == 'Ramat_Hahayal' || case_i.Case_site__c == 'Rishon_Letzion')
                    && (case_i.Partner_Email__c != null
                        || case_i.Primary_Phone_Partner__c != null)) {
                cases.add(case_i);
            }
        }

        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        if (!cases.isEmpty()) {
            CaseServices.sendManKitEmail(cases);
            sendManKitEmailIsFirstRun = false;
        }
    }
    

    //שליחת קיט ראשוני מסלול בנפרד רמת החייל גבר
    //שליחת קיט ראשוני מסלול בנפרד ראשלצ גבר?
    //שליחת קיט ראשוני מסלול בנפרד ראשלצ מטופלת?
    //קיט ראשוני מסלול בנפרד רמת החייל מטופלת?
    //שליחת קיט ראשוני מסלול ביחד רמת החייל?
    //שליחת קיט ראשוני מסלול ביחד ראשון לציון?
    //שליחת קיט ראשוני מסלול תורם ראשון לציון?
    //שליחת קיט ראשוני מסלול תורם רמת החייל?
     /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Send Ramat_Hahayal or Rishon_Letzion 'First Call Done' email if Send_First_Kit__c = true and route on of  Seperate_Route, 
     * Double_Route or Donation_Route
     * 
     * Event             AFTER_INSERT, AFTER_UPDATE      
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          17-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void sendFirstKitEmail(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case sendFirstKitEmail ... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if ((case_i.Case_Route__c == 'Seperate_Route' 
                        || case_i.Case_Route__c == 'Double_Route' 
                        || case_i.Case_Route__c == 'Donation_Route') 
                    && (oldMap == null || case_i.Send_First_Kit__c != oldMap.get(case_i.Id).Send_First_Kit__c) 
                    && case_i.Send_First_Kit__c == true 
                    && (case_i.Case_site__c == 'Ramat_Hahayal' || case_i.Case_site__c == 'Rishon_Letzion') 
                    && (((case_i.Partner_Email__c != null 
                                || case_i.Primary_Phone_Partner__c != null)
                            && case_i.First_Call_Made_Partner__c == true) 
                        || ((case_i.email_from_patient__c != null 
                                || case_i.SMS_Phone_Number__c != null 
                                || case_i.phone__c != null)
                            && case_i.First_Call_Made_Female__c == true))) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if(!cases.isEmpty()) {
            CaseServices.sendFirstKitEmail(cases);
        }
    }

     /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Create task if Second_Reminder_Sent_Female_Couple__c or Second_Reminder_Sent_Partner__c was set to true
     * 
     * Event             AFTER_INSERT, AFTER_UPDATE      
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          17-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void createSecondReminderTask(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case createSecondReminderTask... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            //נשלחה תזכורת שניה למטופלת/זוג?
            if ((case_i.Second_Reminder_Sent_Female_Couple__c == true 
                        && (oldMap == null || case_i.Second_Reminder_Sent_Female_Couple__c != oldMap.get(case_i.Id).Second_Reminder_Sent_Female_Couple__c)) 
                    //נשלחה תזכורת שניה לבן הזוג?
                    || (case_i.Second_Reminder_Sent_Partner__c == true 
                        && (oldMap == null || case_i.Second_Reminder_Sent_Partner__c != oldMap.get(case_i.Id).Second_Reminder_Sent_Partner__c))) {
                cases.add(case_i);
            } 
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.createSecondReminderTask(cases);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Create task if femail/partner/case status is Documents_Holds and Last_file_attachment_date_Female__c or 
     * Last_file_attachment_date_Partner__c has been changed
     * 
     * Event             AFTER_INSERT, AFTER_UPDATE      
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          17-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void createDocumentsReceivedTask(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case createDocumentsReceivedTask... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            //התקבל מסמך IVF חדש- מטופלת
            if (((oldMap == null || case_i.Last_file_attachment_date_Female__c != oldMap.get(case_i.Id).Last_file_attachment_date_Female__c) 
                        && case_i.Case_Route__c == 'Seperate_Route' 
                        && case_i.Female_Status__c == 'Documents_Holds')         
                    //התקבל מסמך IVF חדש- בן זוג
                || ((oldMap == null || case_i.Last_file_attachment_date_Partner__c != oldMap.get(case_i.Id).Last_file_attachment_date_Partner__c) 
                    && case_i.Case_Route__c == 'Seperate_Route' 
                    && case_i.Partner_Status__c == 'Documents_Holds') 
                    //התקבל מסמך IVF חדש- זוג
                || ((oldMap == null || case_i.Last_file_attachment_date_Female__c != oldMap.get(case_i.Id).Last_file_attachment_date_Female__c) 
                    && (case_i.Case_Route__c == 'Donation_Route' || case_i.Case_Route__c == 'Double_Route') 
                    && case_i.Case_Status__c == 'Documents_Holds')) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.createDocumentsReceivedTask(cases);
        }
    }

    /*
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Send sms to doctor if Case_Status_Shikum_Bait__c == 'Pending_Doctor_Approval' and send email to owner 
     * if case_i.Case_Status_Shikum_Bait__c == 'Received_Doctor_Response'
     * 
     * Event             AFTER_INSERT, AFTER_UPDATE
     * Record Type       Shikum_Bait
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          17-05-2021
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void sendShikumBaitStatusChanged(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case sendShikumBaitStatusChanged... start');
        List<Case> cases = new List<Case>();
        Set<Id> docNameIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();

        for (Case case_i : newList) {
            //סטטוס טיפל שיקום בית הוא "ממתין לאישור רופא"?
            //האם התקבלה תשובה מהרופא?
            if (case_i.RecordTypeId == caseRTMap.get('Shikum_Bait').getRecordTypeId() 
                    && (oldMap == null || case_i.Case_Status_Shikum_Bait__c != oldMap.get(case_i.Id).Case_Status_Shikum_Bait__c) 
                    && (case_i.Case_Status_Shikum_Bait__c == 'Pending_Doctor_Approval' || case_i.Case_Status_Shikum_Bait__c == 'Received_Doctor_Response')) {
                cases.add(case_i);
                if (User.getSObjectType() == case_i.OwnerId.getSObjectType()) {
                    userIds.add(case_i.OwnerId);
                } else {
                    groupIds.add(case_i.OwnerId);
                }
                if (case_i.Approving_Doctor_Name__c != null) {
                    docNameIds.add(case_i.Approving_Doctor_Name__c);
                }
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);
        System.debug('docNameIds: size: ' + docNameIds.size() + ' value: ' + docNameIds);
        System.debug('userIds: size: ' + userIds.size() + ' value: ' + userIds);
        System.debug('groupIds: size: ' + groupIds.size() + ' value: ' + groupIds);

        if (!cases.isEmpty()) {
            CaseServices.sendShikumBaitStatusChanged(cases, docNameIds, userIds, groupIds);
        }
    }

    //תאריך שחרור עודכן עבור שיקום בית? (removed due to email from yanan@assuta.co.il 20.03.22) 
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
     * Change Shikum_Bait cases Case_Phase__c and Case_Status_Shikum_Bait__c fields
     * 
     * Event             BEFORE_UPDATE
     * Record Type       Shikum_Bait
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     * @author           Sergey Duiev             <sergey.duiev@synebo.io>
     * @created          17-05-2021 
     * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static void updateShikumBaitStatus(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case updateShikumBaitStatus... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.RecordTypeId == caseRTMap.get('Shikum_Bait').getRecordTypeId() &&
                    //קיים אישור רופא לשיקום בית?
                    //אין קיים אישור רופא לשיקום בית?
                    (((oldMap == null || oldMap.get(case_i.Id).Shikum_Bait_Approval__c != case_i.Shikum_Bait_Approval__c) &&
                        (case_i.Shikum_Bait_Approval__c == 'Approves_Shikum' || case_i.Shikum_Bait_Approval__c == 'Not_Approved_Shikum')) ||
                    //אישור רופא לשיקום בית ריק? 
                    (oldMap == null && case_i.Surgery_Name__c != null && case_i.Shikum_Bait_Approval__c == null))) {
                cases.add(case_i);
            }
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.updateShikumBaitStatus(cases);
        }
    }

    public static void deleteAvayaDuplicates(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case deleteAvayaDuplicates ... start');
        Set<String> ucids = new Set<String>();

        for (Case case_i : newList) {
            if (case_i.UCID__c != null
                    && case_i.Case_subject__c != null
                    && oldMap.get(case_i.Id).Case_subject__c == null) {
                ucids.add(case_i.UCID__c);
            }
        }
        System.debug('ucids: size: ' + ucids.size() + ' value: ' + ucids);

        if (!ucids.isEmpty()) {
            CaseServices.deleteAvayaDuplicates(newList, ucids);
        }
    }

    public static void fillAccountId(List<Case> newList) {
        System.debug('TR Case fillAccountId ... start');
        List<Case> cases = new List<Case>();
        Set<Id> opptIds = new Set<Id>();

        for (Case case_i : newList) {
            if (case_i.Opportunity__c != null && case_i.AccountId == null) {
                opptIds.add(case_i.Opportunity__c);
                cases.add(case_i);
            }
        }
        System.debug('opptIds: size: ' + opptIds.size() + ' value: ' + opptIds);
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.fillAccountId(cases, opptIds);
        }
    }
    
    public static void fillReferralAgencyLabel(List<Case> newList, Map<Id, Case> oldMap) {
        System.debug('TR Case fillReferralAgencyLabel ... start');
        List<Case> cases = new List<Case>();

        for (Case case_i : newList) {
            if (case_i.referralAgency__c != null 
                    && (oldMap == null ||
                        case_i.referralAgency__c != oldMap.get(case_i.Id).referralAgency__c)) {
                cases.add(case_i);
            }
        }
        System.debug('cases: [' + cases.size() + '] values: ' + cases);

        if (!cases.isEmpty()) {
            CaseServices.fillReferralAgencyLabel(cases);
        }
    }
}