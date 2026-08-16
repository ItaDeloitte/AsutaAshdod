//Test AppointmentTriggerServiceTest
public class AppointmentTriggerHandler {

    public static void handleTrigger(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
        System.debug('AppointmentTriggerHandler.handleTrigger...');
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                System.debug('TR Appointment__c BEFORE_INSERT');
                AppointmentTriggerDispatcher.fillAppointmentDateAndHour(newList, null);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.fillProcedureAndCalendarLookups(newList, null);
                    AppointmentTriggerDispatcher.fillSiteLookup(newList, null);
                    AppointmentTriggerDispatcher.fillPayerFactorLookup(newList);
                }
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, null);
                AppointmentTriggerDispatcher.updateReminderDate(newList, null);
                AppointmentTriggerDispatcher.updateReminderType(newList, null);
                AppointmentTriggerDispatcher.fillFormtitanId(newList);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, null);                
            }
            when AFTER_INSERT {
                System.debug('TR Appointment__c AFTER_INSERT');
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.linkProcedurePlan(newList);
                }
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.updateRelatedCase(newList); // FUTURE
                }
            }
            when BEFORE_UPDATE {
                System.debug('TR Appointment__c BEFORE_UPDATE');
                AppointmentTriggerDispatcher.unmarkSMSReminderProcess(newList, null);
                AppointmentTriggerDispatcher.fillAppointmentDateAndHour(newList, oldMap);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.fillProcedureAndCalendarLookups(newList, oldMap);
                    AppointmentTriggerDispatcher.fillSiteLookup(newList, oldMap);
                    AppointmentTriggerDispatcher.sourceSystemCanceledReason(oldMap, newList);
                }
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderDate(newList, oldMap);
                AppointmentTriggerDispatcher.waitingForReschedule(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderType(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, oldMap);
                AppointmentTriggerDispatcher.manualArrivalConfirm(newList, oldMap);
                AppointmentTriggerDispatcher.updateSignedDoctor(newList, oldMap);
                AppointmentTriggerDispatcher.FillCreditDetails(newList, oldMap);                
            }
            when AFTER_UPDATE {
                System.debug('TR Appointment__c AFTER_UPDATE');
                AppointmentTriggerDispatcher.cancelAppointment(newList, oldMap);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.resetMedicalAids(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.updateSurveyTakerSmsSendingTime(newList, oldMap); // FUTURE
                }
            }
        }
    }
}