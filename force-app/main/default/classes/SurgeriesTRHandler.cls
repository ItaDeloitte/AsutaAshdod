public with sharing class SurgeriesTRHandler {

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
                SurgeriesTRDispatcher.agreementCheckBoxPopulation(newList, oldMap);
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, null);
                AppointmentTriggerDispatcher.updateReminderDate(newList, null);
                AppointmentTriggerDispatcher.fillFormtitanId(newList);
                SurgeriesTRDispatcher.calculateFinalPrices(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, null);
                //AppointmentTriggerDispatcher.setPaymentStatus(newList);
                SurgeriesTRDispatcher.markMissMatchMP(newList, oldMap);
                SurgeriesTRDispatcher.fillPatientEmail(newList);
                if (!AppointmentTriggerUtil.IS_ENSEMBLE) {
                    SurgeriesTRDispatcher.fillSurgeryDomain(newList);
                }
                SurgeriesTRDispatcher.updateMaccabiGuid(newList);
                SurgeriesTRDispatcher.relatedSurgeryToPreSurgery(newList);
                SurgeriesTRDispatcher.fillReferringDoctor(newList);
                SurgeriesTRDispatcher.markFollowingTelemedicineSession(newList);                
            }
            when AFTER_INSERT {
                System.debug('TR Appointment__c AFTER_INSERT');
                //AppointmentTriggerDispatcher.schedulePaymentStatusCheck(newList);  
                SurgeriesTRDispatcher.getPricesJob(newList);
                AppointmentTriggerDispatcher.createJunction(newList, null);
                AppointmentTriggerDispatcher.createConFormAndSurvey(newList);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.linkProcedurePlan(newList);
                }
                SurgeriesTRDispatcher.createImplats(newList);
                if (!System.isFuture()) {
                    //AppointmentTriggerDispatcher.createSurvey(newList, null); // FUTURE
                }
                if (!AppointmentTriggerUtil.IS_ENSEMBLE) {
                    SurgeriesTRDispatcher.updateSurgeryCase(newList);
                }
                SurgeriesTRDispatcher.createKITFile(newList, oldMap);
                //SurgeriesTRDispatcher.createConFormTaken(newList);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.updateRelatedCase(newList); // FUTURE
                    SurgeriesTRDispatcher.createPreMedicalProcedure(newList, null);//FUTURE
                }
            }
            when BEFORE_UPDATE {
                System.debug('TR Appointment__c BEFORE_UPDATE');
                //AppointmentTriggerDispatcher.updatePaymentStatus(newList, oldMap);
                AppointmentTriggerDispatcher.unmarkSMSReminderProcess(newList, null);
                AppointmentTriggerDispatcher.disableAutomation(newList, oldMap);
                AppointmentTriggerDispatcher.fillAppointmentDateAndHour(newList, oldMap);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.fillProcedureAndCalendarLookups(newList, oldMap);
                    AppointmentTriggerDispatcher.fillSiteLookup(newList, oldMap);
                }
                SurgeriesTRDispatcher.agreementCheckBoxPopulation(newList, oldMap);
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderDate(newList, oldMap);
                AppointmentTriggerDispatcher.waitingForReschedule(newList, oldMap);
                SurgeriesTRDispatcher.calculateFinalPrices(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, oldMap);
                SurgeriesTRDispatcher.markMissMatchMP(newList, oldMap);
                AppointmentTriggerDispatcher.manualArrivalConfirm(newList, oldMap);
                AppointmentTriggerDispatcher.updateSignedDoctor(newList, oldMap);
                AppointmentTriggerDispatcher.FillCreditDetails(newList, oldMap);
            }
            when AFTER_UPDATE {
                System.debug('TR Appointment__c AFTER_UPDATE');
                AppointmentTriggerDispatcher.createJunction(newList, oldMap);
                if (!System.isFuture()) {
                    //AppointmentTriggerDispatcher.createSurvey(newList, oldMap); // FUTURE
                }
                AppointmentTriggerDispatcher.cancelAppointment(newList, oldMap);
                SurgeriesTRDispatcher.createKITFile(newList, oldMap);
                SurgeriesTRDispatcher.retServiceReferrals(newList, oldMap);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.resetMedicalAids(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, oldMap); // FUTURE
                }
                SurgeriesTRDispatcher.updateImplantsPrices(newList, oldMap);
                SurgeriesTRDispatcher.updateShikumBaitCases(newList, oldMap);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.updateSurveyTakerSmsSendingTime(newList, oldMap); // FUTURE
                    SurgeriesTRDispatcher.createPreMedicalProcedure(newList, oldMap);//FUTURE
                }
                SurgeriesTRDispatcher.isRetAnsFromTR(newList, oldMap);
            }
        }
    }
}