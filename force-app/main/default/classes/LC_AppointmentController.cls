// author : anatoly voronov
// controller for appointment lightning component
public without sharing class LC_AppointmentController implements ILCController {

    public static Map<String, Schema.RecordTypeInfo> APPT_RT_MAP = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName();
    public static final TimeZone ISRAEL_TIMEZONE = TimeZone.getTimeZone('Asia/Tel_Aviv');

    public class LC_AppointmentControllerException extends Exception {}

    public Response executeAction (Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        Response resp;
        switch on actionName {
            when 'appointmentSearchById',
                 'getSequenceAppointments',
                 'isAppointmentAvailable',
                 'getPreferredChannels',
                 'updatePreferredChannel',
                 'getFormData',
                 'domainSearch',
                 'procedureSearch',
                 'siteSequenceSearch',
                 'technicianSearch',
                 'technicianProcedureSearch',
                 'clinicSearch',
                 'calendarSearch',
                 'procedureSearchByCalendar',
                 'siteForcedSearch',
                 'calendarSearchForced',
                 'calendarSearchAshdod',
                 'isFileMandatory',
                 'procedureCheck',
                 'retrieveReferralsFromAccount',
                 'getFilePrepopulatedData',
                 'fileLookupSearch',
                 'getSlotsArray',
                 'searchForcedSlots',
                 'getSlotsByClinic',
                 'lockSlotArray',
                 'unlockSlotArray',
                 'refreshLockSlotArray',
                 'unlockAndRefreshSlotArray',
                 'createAppointmentArray',
                 'setAppointmentArray',
                 'checkAccessionNumber',
                 'rescheduleAppointmentArray',
                 'transferToDepartment',
                 'getProcedureForCalendar',
                 'getCancelFormData',
                 'getUpdateFormData',
                 'checkWorkingDays',
                 'checkAppointmentWorkingDaysOnCreate',
                 'approveAppointmentForMoreThan14Days',
                 'cancelAppointmentForMoreThan14Days',
                 'updateScreen',
                 'checkSchedulerParameters',
                 'isRelatedDocExists',
                 'getUrgentAppointmentFormData',
                 'appointmentSearch',
                 'cancelAppointment',
                 'isSaveSlot' {
                resp = new LC_AppointmentScreenController().executeAction(params);
            }
            when else {
                throw new LC_AppointmentControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
        return resp;
    }
}