// Test: CaseServicesTest
// Created: Evgeniy Kravchuk
// Updated date: 29.05.2019
public class CaseTriggerHandler extends TriggerHandler {

    private List<Case>    newList;
    private List<Case>    oldList;
    private Map<Id, Case> newMap;
    private Map<Id, Case> oldMap;

    public CaseTriggerHandler() {
        newList = (List<Case>) Trigger.new;
        oldList = (List<Case>) Trigger.old;
        newMap  = (Map<Id, Case>) Trigger.newMap;
        oldMap  = (Map<Id, Case>) Trigger.oldMap;
    }

    protected override void beforeInsert() {
        System.debug('TR Case BEFORE_INSERT');
        CaseTriggerDispatcher.fillAccountId(newList);
        CaseTriggerDispatcher.fillRTFromChat(newList);
        CaseTriggerDispatcher.fillFormtitanId(newList);
        CaseTriggerDispatcher.validateRecDoctor(newList, null);
        CaseTriggerDispatcher.completeMilestones(newList, null);

        CaseTriggerDispatcher.copyAccountInfo(newList, oldMap);
        CaseTriggerDispatcher.copyManagerEmail(newList, oldMap);
        CaseTriggerDispatcher.fillEntitlement(newList); //from PB
        CaseTriggerDispatcher.setDoctorArrangmentNotPrivateHidden(newList, null);//from PB
        CaseTriggerDispatcher.saveOwner(newList, oldMap);
        CaseTriggerDispatcher.transferToManager(newList, oldMap);
        CaseTriggerDispatcher.setContactDoctor(newList, null);//from PB
        CaseTriggerDispatcher.fillContactDetails(newList, null);//from PB
        CaseTriggerDispatcher.setBiopsyResults(newList, null);//from PB
        CaseTriggerDispatcher.setAppointmentToDoctor(newList, null);//from PB
        CaseTriggerDispatcher.fillDonating(newList, null);//from PB
        CaseTriggerDispatcher.setCurrentUserAsOwner(newList, null);//from PB
        CaseTriggerDispatcher.fillDecisionStageDate(newList, null);//from PB
        CaseTriggerDispatcher.fillPayerRecommendation(newList, null);//from PB
        CaseTriggerDispatcher.updateShikumBaitStatus(newList, null); //from PB
        CaseTriggerDispatcher.fillReferralAgencyLabel(newList, null);  
    }

    protected override void beforeUpdate() {
        System.debug('TR Case BEFORE_UPDATE');
        CaseTriggerDispatcher.validateRecDoctor(newList, oldMap);
        CaseTriggerDispatcher.removeAgreementArrangement(newList, oldMap);
        CaseTriggerDispatcher.completeMilestones(newList, oldMap);
        CaseTriggerDispatcher.fillEntitlement(newList);
        CaseTriggerDispatcher.copyAccountInfo(newList, oldMap);
        CaseTriggerDispatcher.copyManagerEmail(newList, oldMap);
        CaseTriggerDispatcher.setDoctorArrangmentNotPrivateHidden(newList, oldMap);//from PB
        CaseTriggerDispatcher.saveOwner(newList, oldMap);
        CaseTriggerDispatcher.transferToManager(newList, oldMap);
        CaseTriggerDispatcher.setContactDoctor(newList, oldMap);//from PB
        CaseTriggerDispatcher.fillContactDetails(newList, oldMap);//from PB
        CaseTriggerDispatcher.setBiopsyResults(newList, oldMap);//from PB
        CaseTriggerDispatcher.setAppointmentToDoctor(newList, oldMap);//from PB
        CaseTriggerDispatcher.fillDonating(newList, oldMap);//from PB
        CaseTriggerDispatcher.setCurrentUserAsOwner(newList, oldMap);//from PB
        CaseTriggerDispatcher.fillDecisionStageDate(newList, oldMap);//from PB
        CaseTriggerDispatcher.fillPayerRecommendation(newList, oldMap);//from PB
        CaseTriggerDispatcher.updateShikumBaitStatus(newList, oldMap); //from PB
        CaseTriggerDispatcher.fillReferralAgencyLabel(newList, oldMap);  
    }

    protected override void afterUpdate() {
        System.debug('TR Case AFTER_UPDATE');
        CaseTriggerDispatcher.hasOpenCaseCheck(newList, oldMap);
        CaseTriggerDispatcher.updateStatusByOwner(newList, oldMap);
        CaseTriggerDispatcher.deleteAvayaDuplicates(newList, oldMap);
        //CaseTriggerDispatcher.completeMilestones(newList, oldMap);

        CaseTriggerDispatcher.sendOPT(newList, oldMap);//from PB
        CaseTriggerDispatcher.createRecommendedDoctor(newList, oldMap);//from PB
        CaseTriggerDispatcher.notifyOwner(newList, oldMap);
        CaseTriggerDispatcher.sendDocAdvisor(newList, oldMap);//from PB
        CaseTriggerDispatcher.updateAccount360Info(newList, oldMap);
        CaseTriggerDispatcher.markCaseAsReturning(newList, oldMap);//from PB
        CaseTriggerDispatcher.sendLinkForReferral(newList, oldMap); //from PB
        CaseTriggerDispatcher.createAgentSurvey(newList, oldMap);//from PB
        CaseTriggerDispatcher.createDailyTasksLogIVF(newList, oldMap);//from PB
        CaseTriggerDispatcher.sendManKitEmail(newList, oldMap);//from PB
        CaseTriggerDispatcher.sendFirstKitEmail(newList, oldMap);//from PB
        CaseTriggerDispatcher.createSecondReminderTask(newList, oldMap);//from PB
        CaseTriggerDispatcher.createDocumentsReceivedTask(newList, oldMap);//from PB
        CaseTriggerDispatcher.sendShikumBaitStatusChanged(newList, oldMap);//from PB
    }

    protected override void afterInsert() {
        System.debug('TR Case AFTER_INSERT');
        CaseTriggerDispatcher.runAssignFromApex(newList);
        CaseTriggerDispatcher.hasOpenCaseCheck(newList, null);
        CaseTriggerDispatcher.updateStatusByOwner(newList, null);
        //CaseTriggerDispatcher.completeMilestones(newList, null);

        CaseTriggerDispatcher.sendOPT(newList, null);//from PB
        CaseTriggerDispatcher.createRecommendedDoctor(newList, null);//from PB
        CaseTriggerDispatcher.sendDocAdvisor(newList, null);//from PB
        CaseTriggerDispatcher.updateAccount360Info(newList, oldMap);
        CaseTriggerDispatcher.markCaseAsReturning(newList, null);//from PB
        CaseTriggerDispatcher.sendLinkForReferral(newList, null); //from PB
        CaseTriggerDispatcher.createDailyTasksLogIVF(newList, null);//from PB
        CaseTriggerDispatcher.sendManKitEmail(newList, null);//from PB
        CaseTriggerDispatcher.sendFirstKitEmail(newList, null);//from PB
        CaseTriggerDispatcher.createSecondReminderTask(newList, null);//from PB
        CaseTriggerDispatcher.createDocumentsReceivedTask(newList, null);//from PB
        CaseTriggerDispatcher.sendShikumBaitStatusChanged(newList, null);//from PB
    }

    protected override void afterDelete() {
        System.debug('TR Case AFTER_DELETE');
        CaseTriggerDispatcher.hasOpenCaseCheck(oldMap.values(), null);
    }

    // public static void handleTrigger(List<Case> newList, Map<Id, Case> oldMap, System.TriggerOperation triggerEvent) {
    //     System.debug('CaseTriggerHandler.handleTrigger...');

    //     switch on triggerEvent {
    //         when BEFORE_INSERT {
    //             System.debug('TR Case BEFORE_INSERT');
    //             CaseTriggerDispatcher.fillAccountId(newList);
    //             CaseTriggerDispatcher.fillRTFromChat(newList);
    //             CaseTriggerDispatcher.fillFormtitanId(newList);
    //             CaseTriggerDispatcher.validateRecDoctor(newList, null);
    //             CaseTriggerDispatcher.completeMilestones(newList, null);

    //             CaseTriggerDispatcher.copyAccountInfo(newList, oldMap);
    //             CaseTriggerDispatcher.copyManagerEmail(newList, oldMap);
    //             CaseTriggerDispatcher.fillEntitlement(newList); //from PB
    //             CaseTriggerDispatcher.setDoctorArrangmentNotPrivateHidden(newList, null);//from PB
    //             CaseTriggerDispatcher.saveOwner(newList, oldMap);
    //             CaseTriggerDispatcher.transferToManager(newList, oldMap);
    //             CaseTriggerDispatcher.setContactDoctor(newList, null);//from PB
    //             CaseTriggerDispatcher.fillContactDetails(newList, null);//from PB
    //             CaseTriggerDispatcher.setBiopsyResults(newList, null);//from PB
    //             CaseTriggerDispatcher.setAppointmentToDoctor(newList, null);//from PB
    //             CaseTriggerDispatcher.fillDonating(newList, null);//from PB
    //             CaseTriggerDispatcher.setCurrentUserAsOwner(newList, null);//from PB
    //             CaseTriggerDispatcher.fillDecisionStageDate(newList, null);//from PB
    //             CaseTriggerDispatcher.fillPayerRecommendation(newList, null);//from PB
    //             CaseTriggerDispatcher.updateShikumBaitStatus(newList, null); //from PB
    //             CaseTriggerDispatcher.fillReferralAgencyLabel(newList, null);  
    //         }
    //         when AFTER_INSERT {
    //             System.debug('TR Case AFTER_INSERT');
    //             CaseTriggerDispatcher.runAssignFromApex(newList);
    //             CaseTriggerDispatcher.hasOpenCaseCheck(newList, null);
    //             CaseTriggerDispatcher.updateStatusByOwner(newList, null);
    //             //CaseTriggerDispatcher.completeMilestones(newList, null);

    //             CaseTriggerDispatcher.sendOPT(newList, null);//from PB
    //             CaseTriggerDispatcher.createRecommendedDoctor(newList, null);//from PB
    //             CaseTriggerDispatcher.sendDocAdvisor(newList, null);//from PB
    //             CaseTriggerDispatcher.updateAccount360Info(newList, oldMap);
    //             CaseTriggerDispatcher.markCaseAsReturning(newList, null);//from PB
    //             CaseTriggerDispatcher.sendLinkForReferral(newList, null); //from PB
    //             CaseTriggerDispatcher.createDailyTasksLogIVF(newList, null);//from PB
    //             CaseTriggerDispatcher.sendManKitEmail(newList, null);//from PB
    //             CaseTriggerDispatcher.sendFirstKitEmail(newList, null);//from PB
    //             CaseTriggerDispatcher.createSecondReminderTask(newList, null);//from PB
    //             CaseTriggerDispatcher.createDocumentsReceivedTask(newList, null);//from PB
    //             CaseTriggerDispatcher.sendShikumBaitStatusChanged(newList, null);//from PB
    //         }
    //         when BEFORE_UPDATE {
    //             System.debug('TR Case BEFORE_UPDATE');
    //             CaseTriggerDispatcher.validateRecDoctor(newList, oldMap);
    //             CaseTriggerDispatcher.removeAgreementArrangement(newList, oldMap);
    //             CaseTriggerDispatcher.completeMilestones(newList, oldMap);

    //             CaseTriggerDispatcher.copyAccountInfo(newList, oldMap);
    //             CaseTriggerDispatcher.copyManagerEmail(newList, oldMap);
    //             CaseTriggerDispatcher.setDoctorArrangmentNotPrivateHidden(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.saveOwner(newList, oldMap);
    //             CaseTriggerDispatcher.transferToManager(newList, oldMap);
    //             CaseTriggerDispatcher.setContactDoctor(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.fillContactDetails(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.setBiopsyResults(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.setAppointmentToDoctor(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.fillDonating(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.setCurrentUserAsOwner(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.fillDecisionStageDate(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.fillPayerRecommendation(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.updateShikumBaitStatus(newList, oldMap); //from PB
    //             CaseTriggerDispatcher.fillReferralAgencyLabel(newList, oldMap);  
    //         }
    //         when AFTER_UPDATE {
    //             System.debug('TR Case AFTER_UPDATE');
    //             CaseTriggerDispatcher.hasOpenCaseCheck(newList, oldMap);
    //             CaseTriggerDispatcher.updateStatusByOwner(newList, oldMap);
    //             CaseTriggerDispatcher.deleteAvayaDuplicates(newList, oldMap);
    //             //CaseTriggerDispatcher.completeMilestones(newList, oldMap);

    //             CaseTriggerDispatcher.sendOPT(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.createRecommendedDoctor(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.notifyOwner(newList, oldMap);
    //             CaseTriggerDispatcher.sendDocAdvisor(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.updateAccount360Info(newList, oldMap);
    //             CaseTriggerDispatcher.markCaseAsReturning(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.sendLinkForReferral(newList, oldMap); //from PB
    //             CaseTriggerDispatcher.createAgentSurvey(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.createDailyTasksLogIVF(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.sendManKitEmail(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.sendFirstKitEmail(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.createSecondReminderTask(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.createDocumentsReceivedTask(newList, oldMap);//from PB
    //             CaseTriggerDispatcher.sendShikumBaitStatusChanged(newList, oldMap);//from PB
    //         }
    //         when AFTER_DELETE {
    //             System.debug('TR Case AFTER_DELETE');
    //             CaseTriggerDispatcher.hasOpenCaseCheck(oldMap.values(), null);
    //         }
    //     }
    // }
}