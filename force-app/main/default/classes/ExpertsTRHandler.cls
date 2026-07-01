public without sharing class ExpertsTRHandler {

    public static void handleTrigger(List<Appointment__c> newList, Map<Id, Appointment__c> oldMap) {
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
                ExpertsTRDispatcher.markDontSendReminder(newList, null);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, null);
                ExpertsTRDispatcher.fillClinicLookup(newList);
                AppointmentTriggerDispatcher.setPaymentStatus(newList);
                if (!AppointmentTriggerUtil.IS_INTEGRATION) {
                    ExpertsTRDispatcher.validateExpertProcedures(newList, null);
                }
                ExpertsTRDispatcher.fillDoctorExperts(newList, null);
                ExpertsTRDispatcher.fillApptTypeAndLocation(newList, null);                
                ExpertsTRDispatcher.updateDoctorReminderDate(newList, null);
                AppointmentTriggerDispatcher.updateGuidelines(newList, null);                
            }
            when AFTER_INSERT {
                System.debug('TR Appointment__c AFTER_INSERT');
                AppointmentTriggerDispatcher.schedulePaymentStatusCheck(newList);
                AppointmentTriggerDispatcher.createJunction(newList, null);
                if (AppointmentTriggerUtil.IS_INTEGRATION || Test.isRunningTest()) {
                    AppointmentTriggerDispatcher.linkProcedurePlan(newList);
                }
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, null); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, null); // FUTURE
                    ExpertsTRDispatcher.updateExpertsCase(newList); // FUTURE
                    AppointmentTriggerDispatcher.updatePatientMailingApproval(newList, null); // FUTURE
                }
            }
            when BEFORE_UPDATE {
                System.debug('TR Appointment__c BEFORE_UPDATE');
                AppointmentTriggerDispatcher.updatePaymentStatus(newList, oldMap);
                AppointmentTriggerDispatcher.unmarkSMSReminderProcess(newList, null);
                AppointmentTriggerDispatcher.fillAppointmentDateAndHour(newList, oldMap);
                AppointmentTriggerDispatcher.fillProcedureAndCalendarLookups(newList, oldMap);
                AppointmentTriggerDispatcher.fillSiteLookup(newList, oldMap);
                AppointmentTriggerDispatcher.sourceSystemCanceledReason(oldMap, newList);
                AppointmentTriggerDispatcher.updateSendingbyWhatsApp(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderDate(newList, oldMap);
                AppointmentTriggerDispatcher.waitingForReschedule(newList, oldMap);
                AppointmentTriggerDispatcher.resetReminders(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderType(newList, oldMap);
                ExpertsTRDispatcher.markDontSendReminder(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderStatus(newList, oldMap);
                if (!AppointmentTriggerUtil.IS_INTEGRATION) {
                    ExpertsTRDispatcher.validateExpertProcedures(newList, oldMap);
                }
                ExpertsTRDispatcher.fillDoctorExperts(newList, oldMap);
                AppointmentTriggerDispatcher.manualArrivalConfirm(newList, oldMap);
                AppointmentTriggerDispatcher.updateSignedDoctor(newList, oldMap);
                AppointmentTriggerDispatcher.FillCreditDetails(newList, oldMap);
                ExpertsTRDispatcher.sendClinicMail(newList, oldMap);
                ExpertsTRDispatcher.fillApptTypeAndLocation(newList, oldMap);          
                ExpertsTRDispatcher.updateDoctorReminderDate(newList, oldMap); 
                AppointmentTriggerDispatcher.updateGuidelines(newList, oldMap);               

            }
            when AFTER_UPDATE {
                System.debug('TR Appointment__c AFTER_UPDATE');
                AppointmentTriggerDispatcher.createJunction(newList, oldMap);
                AppointmentTriggerDispatcher.cancelAppointment(newList, oldMap);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.resetMedicalAids(newList, oldMap); // FUTURE
                }
                AppointmentTriggerDispatcher.updateRemindersInSourceSystem(newList, oldMap);
                AppointmentTriggerDispatcher.updateReminderRecordToInActive(newList, oldMap);
                if (!System.isFuture()) {
                    AppointmentTriggerDispatcher.findLatestSalesApp(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.fillRelatedDocument(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.sendCancelAppSMS(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.updateSurveyTakerSmsSendingTime(newList, oldMap); // FUTURE
                    AppointmentTriggerDispatcher.updatePatientMailingApproval(newList, oldMap); // FUTURE
                }
            }
        }
    }
}