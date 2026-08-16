public with sharing class InstitutesTRHandler {

    public static void handleTrigger(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                System.debug('TR Appointment__c BEFORE_INSERT');
                AppointmentTriggerDispatcher.disableAutomation(newList, null);
                AppointmentTriggerDispatcher.fillAppointmentDateAndHour(newList, null);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.fillProcedureAndCalendarLookups(newList, null);
                    AppointmentTriggerDispatcher.fillSiteLookup(newList, null);
                    AppointmentTriggerDispatcher.fillPayerFactorLookup(newList);
                }
                InstitutesTRDispatcher.checkExistingAppointments(newList, oldMap);
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, null);
                AppointmentTriggerDispatcher.updateReminderDate(newList, null);
                AppointmentTriggerDispatcher.updateReminderType(newList, null);
                AppointmentTriggerDispatcher.fillFormtitanId(newList);
                InstitutesTRDispatcher.syncWithSiteDomain(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, null);
                AppointmentTriggerDispatcher.setPaymentStatus(newList);
                AppointmentTriggerDispatcher.updateGuidelines(newList, oldMap);
                InstitutesTRDispatcher.setBarcodeIdentifyTime(newList, null);                
            }
            when AFTER_INSERT {
                System.debug('TR Appointment__c AFTER_INSERT');
                AppointmentTriggerDispatcher.schedulePaymentStatusCheck(newList);  
                AppointmentTriggerDispatcher.createConFormAndSurvey(newList);                
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.linkProcedurePlan(newList);
                }
                if (!System.isFuture()) { 
                    //AppointmentTriggerDispatcher.createSurvey(newList, null); // FUTURE
                }  
                InstitutesTRDispatcher.linkAppointments(newList);              
                InstitutesTRDispatcher.retAmbulatoryReferralsAndCommitments(newList);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, null); // FUTURE
                    InstitutesTRDispatcher.relatedPreSurgeryToSurgery(newList); // FUTURE
                    AppointmentTriggerDispatcher.updateRelatedCase(newList); // FUTURE
                    InstitutesTRDispatcher.SendingWhatsApp(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.updatePatientMailingApproval(newList, null); // FUTURE
                }
            }
            when BEFORE_UPDATE {
                System.debug('TR Appointment__c BEFORE_UPDATE');
                AppointmentTriggerDispatcher.updatePaymentStatus(newList, oldMap);
                AppointmentTriggerDispatcher.unmarkSMSReminderProcess(newList, null);
                AppointmentTriggerDispatcher.disableAutomation(newList, oldMap);
                AppointmentTriggerDispatcher.fillAppointmentDateAndHour(newList, oldMap);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.fillProcedureAndCalendarLookups(newList, oldMap);
                    AppointmentTriggerDispatcher.fillSiteLookup(newList, oldMap);
                    AppointmentTriggerDispatcher.sourceSystemCanceledReason(oldMap, newList);
                }
                InstitutesTRDispatcher.checkExistingAppointments(newList, oldMap);
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderDate(newList, oldMap);
                AppointmentTriggerDispatcher.waitingForReschedule(newList, oldMap);
                AppointmentTriggerDispatcher.resetReminders(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderType(newList, oldMap);
                InstitutesTRDispatcher.syncWithSiteDomain(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, oldMap);
                AppointmentTriggerDispatcher.manualArrivalConfirm(newList, oldMap);
                AppointmentTriggerDispatcher.updateSignedDoctor(newList, oldMap);
                AppointmentTriggerDispatcher.FillCreditDetails(newList, oldMap);
                AppointmentTriggerDispatcher.updateGuidelines(newList, oldMap);
                InstitutesTRDispatcher.setBarcodeIdentifyTime(newList, oldMap);
            }
            when AFTER_UPDATE {
                System.debug('TR Appointment__c AFTER_UPDATE');
                if (!System.isFuture()) {
                    //AppointmentTriggerDispatcher.createSurvey(newList, oldMap); // FUTURE
                }
                AppointmentTriggerDispatcher.cancelAppointment(newList, oldMap);
                if (!System.isFuture() && !System.isBatch()) {
                    AppointmentTriggerDispatcher.resetMedicalAids(newList, oldMap); // FUTURE
                    InstitutesTRDispatcher.cancelPreSurgery(newList, oldMap); // FUTURE
                }
                AppointmentTriggerDispatcher.updateRemindersInSourceSystem(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderRecordToInActive(newList, oldMap);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, oldMap); // FUTURE                    
                    InstitutesTRDispatcher.updateForwardToRIS(newList, oldMap); // FUTURE
                    //AppointmentTriggerDispatcher.sendCancelAppSMS(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.updateSurveyTakerSmsSendingTime(newList, oldMap); // FUTURE
                    InstitutesTRDispatcher.SendingWhatsApp(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.updatePatientMailingApproval(newList, oldMap); // FUTURE
                    InstitutesTRDispatcher.checkUrgentAppointments(newList, oldMap);// FUTURE
                    InstitutesTRDispatcher.changeUrgentStatus(newList, oldMap);// FUTURE 
                    InstitutesTRDispatcher.createCpapSurvey(newList, oldMap); 
                }               
            }
        }
    }
}