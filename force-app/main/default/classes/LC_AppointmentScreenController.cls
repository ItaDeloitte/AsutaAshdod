/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment Scheduling Screen Apex Controller class to keep main logical entries
 *
 * Test                 LC_AppointmentScreenTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             28-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_AppointmentScreenController implements ILCController {

    public class LC_AppointmentScreenException extends Exception {}

    public Map<String, String> BACKWARD_COMPATIBILITY_MAP = new Map<String, String>{
        'appointmentSearchById' => 'getAppointment',
        'getSequenceAppointments' => 'getSequenceOfAppointments',
        'isAppointmentAvailable' => 'isAvailable',
        'getFormData' => 'init',
        'domainSearch' => 'searchDomains',
        'procedureSearch' => 'searchProcedures',
        'siteSequenceSearch' => 'searchSites',
        'technicianSearch' => 'searchTechnicians',
        'technicianProcedureSearch' => 'searchTechnicianProcedures',
        'clinicSearch' => 'searchExpertClinics',
        'calendarSearch' => 'searchExpertCalendars',
        'getProcedureForCalendar' => 'getCalendarProcedure',
        'procedureSearchByCalendar' => 'searchExpertProcedures',
        'siteForcedSearch' => 'searchSitesForced',
        'calendarSearchForced' => 'searchCalendarsForced',
        'calendarSearchAshdod' => 'searchQFlowCalendars',
        'procedureCheck' => 'checkProcedure',
        'retrieveReferralsFromAccount' => 'retrieveReferrals',
        'getFilePrepopulatedData' => 'obtainDraftFile',
        'fileLookupSearch' => 'searchFiles',
        'isRelatedDocExists' => 'isDocumentExists',
        'checkSchedulerParameters' => 'obtainSchedulerParams',
        'getSlotsArray' => 'obtainSlots',
        'getUrgentAppointmentFormData' => 'obtainUrgentForm',
        'searchForcedSlots' => 'obtainSlotsForced',
        'getSlotsByClinic' => 'obtainExpertSlots',
        'lockSlotArray' => 'lockSlots',
        'unlockSlotArray' => 'unlockSlots',
        'refreshLockSlotArray' => 'relockSlots',
        'unlockAndRefreshSlotArray' => 'unlockRelockSlots',
        'createAppointmentArray' => 'createAppointments',
        'setAppointmentArray' => 'setAppointments',
        'checkAccessionNumber' => 'validateAppointments',
        'updateScreen' => 'updateScreen',
        'rescheduleAppointmentArray' => 'rescheduleAppointments',
        'getUpdateFormData' => 'obtainUpdateForm',
        'getCancelFormData' => 'obtainCancelForm',
        'appointmentSearch' => 'searchAppointments',
        'cancelAppointment' => 'cancelAppointment',
        'transferToDepartment' => 'transferToDepartment',
        'checkWorkingDays' => 'checkWorkingDays',
        'checkAppointmentWorkingDaysOnCreate' => 'checkAppointmentWorkingDays',
        'approveAppointmentForMoreThan14Days' => 'approveTwoWeeksAppointment',
        'cancelAppointmentForMoreThan14Days' => 'cancelTwoWeeksAppointment'
    };

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        actionName = BACKWARD_COMPATIBILITY_MAP.containsKey(actionName)
            ? BACKWARD_COMPATIBILITY_MAP.get(actionName)
            : actionName;

        switch on actionName {
            when 'getAppointment' {
                return this.getAppointment(
                    (String) params.get('appointmentId')
                );
            }
            when 'getSequenceOfAppointments' {
                return this.getSequenceOfAppointments(
                    (String) params.get('appointmentId'),
                    (String) params.get('operationType')
                );
            }

            when 'isAvailable' {
                return this.isAvailable(
                    (String) params.get('recordId')
                );
            }
            when 'getPreferredChannels' {
                return this.getPreferredChannels(
                    (String) params.get('recordId')
                );
            }
            when 'updatePreferredChannel' {
                return this.updatePreferredChannel(
                    (String) params.get('recordId'),
                    (String) params.get('preferredChannel'),
                    (String) params.get('additionalInput'));
            }
            when 'init' {
                return this.init(
                    (String) params.get('recordId'),
                    (String) params.get('clinicId'),
                    (String) params.get('doctorId'),
                    (String) params.get('procedureId'), // URL Param
                    (String) params.get('payerFactorId') // URL Param
                );
            }

            when 'searchDomains' {
                return this.searchDomains(
                    (String) params.get('recordId'), // null
                    (String) params.get('screenMode'),
                    (String) params.get('keyWord')
                );
            }
            when 'searchProcedures' {
                return this.searchProcedures(
                    (String) params.get('recordId'), // null
                    (String) params.get('domainId'),
                    (String) params.get('screenMode'),
                    (String) params.get('procedureCodes'),
                    (String) params.get('keyWord')
                );
            }
            when 'searchSites' {
                return this.searchSites(
                    (String) params.get('recordId'), // null
                    (String) params.get('procedureCodes'),
                    (String) params.get('keyWord')
                );
            }

            when 'searchTechnicians' {
                return this.searchTechnicians(
                    (String) params.get('recordId'), // null
                    (String) params.get('procedureCode'),
                    (String) params.get('keyWord')
                );
            }
            when 'searchTechnicianProcedures' {
                return this.searchTechnicianProcedures(
                    (String) params.get('recordId'), // null
                    (String) params.get('accountId'),
                    (String) params.get('siteCode'),
                    (String) params.get('procedureCode'),
                    (String) params.get('keyWord')
                );
            }

            when 'searchExpertClinics' {
                return this.searchExpertClinics(
                    (String) params.get('caseId'),
                    (String) params.get('doctorId'),
                    (String) params.get('keyWord')
                );
            }
            when 'searchExpertCalendars' {
                return this.searchExpertCalendars(
                    (String) params.get('caseId'),
                    (String) params.get('doctorId'),
                    (String) params.get('siteCode'),
                    (String) params.get('keyWord')
                );
            }
            when 'searchExpertProcedures' {
                return this.searchExpertProcedures(
                    (String) params.get('recordId'),
                    (String) params.get('calendarCode'),
                    (String) params.get('procedureCodes'),
                    (String) params.get('keyWord')
                );
            }

            when 'searchSitesForced' {
                return this.searchSitesForced(
                    (String) params.get('recordId'), // null
                    (String) params.get('procedureCode'),
                    (String) params.get('keyWord')
                );
            }
            when 'searchCalendarsForced' {
                return this.searchCalendarsForced(
                    (String) params.get('recordId'), // null
                    (String) params.get('siteCode'),
                    (String) params.get('procedureCode'),
                    (String) params.get('keyWord')
                );
            }

            when 'searchQFlowCalendars' {
                return this.searchQFlowCalendars(
                    (String) params.get('recordId'), // null
                    (String) params.get('siteCode'),
                    (String) params.get('procedureCode')
                );
            }

            when 'checkProcedure' {
                return this.checkProcedure(
                    (String) params.get('recordId'), // null
                    (String) params.get('procedureCodes')
                );
            }

            when 'retrieveReferrals' {
                return this.retrieveReferrals(
                    (String) params.get('recordId'),
                    (String) params.get('domainCode'),
                    (String) params.get('procedureCode')
                );
            }
            when 'isFileMandatory' {
                return this.isFileMandatory(
                    (String) params.get('recordId'),
                    (String) params.get('domainId'),
                    (String) params.get('insurerFactor')
                );
            }
            when 'obtainDraftFile' {
                return this.obtainDraftFile(
                    (String) params.get('caseId'),
                    (String) params.get('procedureCode')
                );
            }
            when 'searchFiles' {
                return this.searchFiles(
                    (String) params.get('recordId'),
                    (String) params.get('domainId'),
                    (String) params.get('keyWord')
                );
            }

            when 'obtainSlots' {
                return this.obtainSlots(
                    (String) params.get('recordId'), // null
                    (String) params.get('patientId'),
                    (String) params.get('idType'),
                    (String) params.get('insurenceCode'),
                    (String) params.get('procedureCodes'),
                    (String) params.get('startDate'),
                    (String) params.get('endDate'),
                    (String) params.get('fromHour'),
                    (String) params.get('toHour'),
                    (String) params.get('calendar'),
                    (String) params.get('siteCode'),
                    (String) params.get('protocols'),
                    (String) params.get('domainId'),
                    (String) params.get('technician'),
                    (String) params.get('technicianProcedureCode'),
                    (Boolean) params.get('technicianProcedureLeading')
                );
            }
            when 'obtainSlotsForced' {
                return this.obtainSlotsForced(
                    (String) params.get('recordId'), // null
                    (String) params.get('siteCode'),
                    (String) params.get('calendarCode'),
                    (String) params.get('procedureCode'),
                    (String) params.get('startDate'),
                    (Boolean) params.get('restrictionsOnly'),
                    (String) params.get('doctorId')
                );
            }
            when 'obtainExpertSlots' {
                return this.obtainExpertSlots(
                    (String) params.get('recordId'),
                    (String) params.get('siteCode'),
                    (String) params.get('calendarCode'),
                    (String) params.get('procedureCode'),
                    (String) params.get('startDate'),
                    (String) params.get('doctorId')
                );
            }

            when 'lockSlots' {
                return this.lockSlots(
                    (String) params.get('recordId'), // null
                    (String) params.get('jsonedSlots'),
                    (String) params.get('slotLockIds'),
                    (String) params.get('doctorId')
                );
            }
            when 'unlockSlots' {
                return this.unlockSlots(
                    (String) params.get('recordId'), // null
                    (String) params.get('jsonedSlots'),
                    (String) params.get('slotLockIds'),
                    (String) params.get('doctorId')
                );
            }
            when 'relockSlots' {
                return this.relockSlots(
                    (String) params.get('recordId'), // null
                    (String) params.get('jsonedSlots'),
                    (String) params.get('slotLockIds'),
                    (String) params.get('doctorId')
                );
            }
            when 'unlockRelockSlots' {
                return this.unlockRelockSlots(
                    (String) params.get('recordId'), // null
                    (String) params.get('jsonedSlotsForUnlock'),
                    (String) params.get('slotLockIdsForUnlock'),
                    (String) params.get('jsonedSlotsForRefresh'),
                    (String) params.get('slotLockIdsForRefresh'),
                    (String) params.get('doctorId')
                );
            }

            when 'createAppointments' {
                return this.createAppointments(
                    (String) params.get('recordId'),
                    (String) params.get('clinicId'),
                    (String) params.get('patientId'),
                    (String) params.get('idType'),
                    (String) params.get('assists'),
                    (String) params.get('protocols'),
                    (String) params.get('urgentReason'),
                    (String) params.get('insurenceCode'),
                    (String) params.get('procedureCodes'),
                    (String) params.get('jsonedSlots'),
                    (String) params.get('technician'),
                    (String) params.get('technicianProcedureCode'),
                    (Boolean) params.get('technicianProcedureLeading'),
                    (String) params.get('doctorId')
                );
            }
            when 'setAppointments' {
                return this.setAppointments(
                    (String) params.get('recordId'), // null
                    (String) params.get('jsonedSlots'),
                    (String) params.get('patientId'),
                    (String) params.get('idType'),
                    (String) params.get('recordIds'),
                    (String) params.get('fileIds'),
                    (String) params.get('forcedCode')
                );
            }
            when 'validateAppointments' {
                return this.validateAppointments(
                    (String) params.get('recordId'), // null
                    (String) params.get('recordIds')
                );
            }
            when 'rescheduleAppointments' {
                return this.rescheduleAppointments(
                    (String) params.get('recordId'),
                    (String) params.get('clinicId'),
                    (String) params.get('patientId'),
                    (String) params.get('idType'),
                    (String) params.get('assists'),
                    (String) params.get('insurenceCode'),
                    (String) params.get('appointmentIds'),
                    (String) params.get('jsonedSlots')
                );
            }
            when 'transferToDepartment' {
                return this.transferToDepartment(
                    (String) params.get('caseId'),
                    (String) params.get('siteCode'),
                    (String) params.get('procedureCode'),
                    (String) params.get('insurenceCode'),
                    (String) params.get('domainId'),
                    (String) params.get('queueId')
                );
            }
            when 'getCalendarProcedure' {
                return this.getCalendarProcedure(
                    (String) params.get('recordId'), // null
                    (String) params.get('calendarCode')
                );
            }
            when 'obtainCancelForm' {
                return this.obtainUpdateCancelForm(
                    (String) params.get('recordId')
                );
            }
            when 'obtainUpdateForm' {
                return this.obtainUpdateCancelForm(
                    (String) params.get('caseId')
                );
            }
            when 'checkWorkingDays' {
                return this.checkWorkingDays(
                    (String) params.get('recordId'), //null
                    (String) params.get('scheduleDate')
                );
            }
            when 'checkAppointmentWorkingDays' {
                return this.checkAppointmentWorkingDays(
                    (String) params.get('appointmentId')
                );
            }
            when 'approveTwoWeeksAppointment' {
                return this.approveTwoWeeksAppointment(
                    (String) params.get('appointmentId')
                );
            }
            when 'cancelTwoWeeksAppointment' {
                return this.cancelTwoWeeksAppointment(
                    (String) params.get('appointmentId')
                );
            }
            when 'updateScreen' {
                return this.updateScreen (
                    (String) params.get('appointmentId')
                );
            }
            when 'obtainSchedulerParams' {
                return this.obtainSchedulerParams(
                    (String) params.get('recordId'), // null
                    (String) params.get('patientId'),
                    (String) params.get('idType'),
                    (String) params.get('domainId'),
                    (String) params.get('procedureCode'),
                    (String) params.get('insurenceCode'),
                    (String) params.get('siteCode'),
                    (String) params.get('protocol')
                );
            }
            when 'isDocumentExists' {
                return this.isDocumentExists(
                    (String) params.get('recordId'), // null
                    (String) params.get('procedureCodes'),
                    (String) params.get('siteCode')
                );
            }
            when 'obtainUrgentForm' {
                return this.obtainUrgentForm(
                    (String) params.get('recordId')
                );
            }
            when 'hasFutureAppointments' {
                return this.hasFutureAppointments(
                    (String) params.get('caseId'),
                    (String) params.get('procedureCode')
                );
            }
            when 'searchAppointments' {
                return this.searchAppointments(
                    (String) params.get('caseId'),
                    (String) params.get('keyWord'),
                    (String) params.get('operationType'),
                    (Boolean) params.get('isRestricted')
                );
            }
            when 'cancelAppointment' {
                return this.cancelAppointment(
                    (String) params.get('caseId'),
                    (String) params.get('appointmentId'),
                    (String) params.get('canceledReason'),
                    (String) params.get('reasonFreeText')
                );
            }
            when 'isSaveSlot' {
                return this.isSaveSlot(
                    (String) params.get('recordId'),
                    (String) params.get('procedureId'),
                    (String) params.get('calendarCode')
                );
            }

            when else {
                throw new LC_AppointmentScreenException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response getAppointment(String recordId) {
        System.debug('LC_AppointmentScreenController.getAppointment ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).getAppointment());
    }

    private Response getSequenceOfAppointments(String recordId, String operationType) {
        System.debug('LC_AppointmentScreenController.getSequenceOfAppointments ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).getSequenceOfAppointments(
            String.isBlank(operationType) ? null : operationType
        ));
    }

    private Response isAvailable(String recordId) {
        System.debug('LC_AppointmentScreenController.isAvailable ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).isAvailable());
    }

    private Response getPreferredChannels(String recordId) {
        System.debug('LC_AppointmentScreenController.getPreferredChannels ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).getPreferredChannels());
    }

    private Response updatePreferredChannel(String recordId, String preferredChannel, String additionalInput) {
        System.debug('LC_AppointmentScreenController.updatePreferredChannel ...');
        LC_AppointmentScreenService.getInstance(recordId).updatePreferredChannel(
            String.isBlank(preferredChannel) ? null : preferredChannel,
            String.isBlank(additionalInput) ? null : additionalInput
        );
        return new Response(LC_AppointmentScreenUtil.MSG_SUCCESS);
    }

    private Response init(String recordId, String clinicId, String doctorId, String procedureId, String payerFactorId) {
        System.debug('LC_AppointmentScreenController.init ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).init(
            String.isBlank(clinicId) ? null : clinicId,
            String.isBlank(doctorId) ? null : doctorId,
            String.isBlank(procedureId) ? null : procedureId,
            String.isBlank(payerFactorId) ? null : payerFactorId
        ));
    }

    private Response searchDomains(String recordId, String screenMode, String keyword) {
        System.debug('LC_AppointmentScreenController.searchDomains ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchDomains(
            String.isBlank(screenMode) ? null : screenMode,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchProcedures(String recordId, String domainId, String screenMode, String procedureCodes, String keyword) {
        System.debug('LC_AppointmentScreenController.searchProcedures ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchProcedures(
            String.isBlank(domainId) ? null : domainId,
            String.isBlank(screenMode) ? null : screenMode,
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class),
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchSites(String recordId, String procedureCodes, String keyword) {
        System.debug('LC_AppointmentScreenController.searchSites ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchSites(
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class),
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchTechnicians(String recordId, String procedureCode, String keyword) {
        System.debug('LC_AppointmentScreenController.searchTechnicians ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchTechnicians(
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchTechnicianProcedures(String recordId, String techId, String siteCode, String procedureCode, String keyword) {
        System.debug('LC_AppointmentScreenController.searchTechnicianProcedures ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchTechnicianProcedures(
            String.isBlank(techId) ? null : techId,
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchExpertClinics(String recordId, String doctorId, String keyword) {
        System.debug('LC_AppointmentScreenController.searchExpertClinics ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchExpertClinics(
            String.isBlank(doctorId) ? null : doctorId,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchExpertCalendars(String recordId, String doctorId, String siteCode, String keyword) {
        System.debug('LC_AppointmentScreenController.searchExpertCalendars ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchExpertCalendars(
            String.isBlank(doctorId) ? null : doctorId,
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchExpertProcedures(String recordId, String calendarCode, String procedureCodes, String keyword) {
        System.debug('LC_AppointmentScreenController.searchExpertProcedures ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchExpertProcedures(
            String.isBlank(calendarCode) ? null : calendarCode,
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class),
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchSitesForced(String recordId, String procedureCode, String keyword) {
        System.debug('LC_AppointmentScreenController.searchSitesForced ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchSitesForced(
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchCalendarsForced(String recordId, String siteCode, String procedureCode, String keyword) {
        System.debug('LC_AppointmentScreenController.searchCalendarsForced ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchCalendarsForced(
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchQFlowCalendars(String recordId, String siteCode, String procedureCode) {
        System.debug('LC_AppointmentScreenController.searchQFlowCalendars ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchQFlowCalendars(
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(procedureCode) ? null : procedureCode
        ));
    }

    private Response checkProcedure(String recordId, String procedureCodes) {
        System.debug('LC_AppointmentScreenController.checkProcedure ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).checkProcedure(
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class)
        ));
    }

    private Response retrieveReferrals(String recordId, String domainId, String procedureCode) {
        System.debug('LC_AppointmentScreenController.retrieveReferrals ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).retrieveReferrals(
            String.isBlank(domainId) ? null : domainId,
            String.isBlank(procedureCode) ? null : procedureCode
        ));
    }

    private Response isFileMandatory(String recordId, String domainId, String pfCode) {
        System.debug('LC_AppointmentScreenController.isFileMandatory ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).isFileMandatory(
            String.isBlank(domainId) ? null : domainId,
            String.isBlank(pfCode) ? null : pfCode
        ));
    }

    private Response obtainDraftFile(String recordId, String procedureCode) {
        System.debug('LC_AppointmentScreenController.obtainDraftFile ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainDraftFile(
            String.isBlank(procedureCode) ? null : procedureCode
        ));
    }

    private Response searchFiles(String recordId, String domainId, String keyword) {
        System.debug('LC_AppointmentScreenController.searchFiles ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchFiles(
            String.isBlank(domainId) ? null : domainId,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response obtainSlots(String recordId, String idNumber, String idType, String pfCode, String procedureCodes, String startDate, String endDate, String fromHour, String toHour, String calendarCode, String siteCode, String protocols, String domainId, String jsonedTech, String techProcedureCode, Boolean techProcedureLeading) {
        System.debug('LC_AppointmentScreenController.obtainSlots ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainSlots(
            String.isBlank(idNumber) ? null : idNumber,
            String.isBlank(idType) ? null : idType,
            String.isBlank(pfCode) ? null : pfCode,
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class),
            String.isBlank(startDate) ? Date.today() : Date.valueOf(startDate),
            String.isBlank(endDate) ? null : Date.valueOf(endDate),
            String.isBlank(fromHour) ? 0 : Integer.valueOf(fromHour),
            String.isBlank(toHour) ? 23 : Integer.valueOf(toHour),
            String.isBlank(calendarCode) ? null : calendarCode,
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(protocols) ? new List<String>() : (List<String>) JSON.deserialize(protocols, List<String>.class),
            String.isBlank(domainId) ? null : domainId,
            String.isBlank(jsonedTech) ? null : (LC_AppointmentScreenService.TechnicianWrp) JSON.deserialize(jsonedTech, LC_AppointmentScreenService.TechnicianWrp.class),
            String.isBlank(techProcedureCode) ? null : techProcedureCode,
            techProcedureLeading == null ? false : techProcedureLeading
        ));
    }

    private Response obtainSlotsForced(String recordId, String siteCode, String calendarCode, String procedureCode, String startDate, Boolean isRestricted, String doctorId) {
        System.debug('LC_AppointmentScreenController.obtainSlotsForced ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainSlotsForced(
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(calendarCode) ? null : calendarCode,
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBlank(startDate) ? Date.today() : Date.valueOf(startDate),
            isRestricted == null ? false : isRestricted,
            String.isBlank(doctorId) ? null : doctorId
        ));
    }

    private Response obtainExpertSlots(String recordId, String siteCode, String calendarCode, String procedureCode, String startDate, String doctorId) {
        System.debug('LC_AppointmentScreenController.obtainExpertSlots ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainExpertSlots(
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(calendarCode) ? null : calendarCode,
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBlank(startDate) ? Date.today() : Date.valueOf(startDate),
            String.isBlank(doctorId) ? null : doctorId
        ));
    }

    private Response lockSlots(String recordId, String jsonedSlots, String lockIds, String doctorId) {
        System.debug('LC_AppointmentScreenController.lockSlots ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).lockSlots(
            String.isBlank(jsonedSlots) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlots, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(lockIds) ? new List<String>() : (List<String>) JSON.deserialize(lockIds, List<String>.class),
            String.isBlank(doctorId) ? null : doctorId
        ));
    }

    private Response unlockSlots(String recordId, String jsonedSlots, String lockIds, String doctorId) {
        System.debug('LC_AppointmentScreenController.unlockSlots ...');
        LC_AppointmentScreenService.getInstance(recordId).unlockSlots(
            String.isBlank(jsonedSlots) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlots, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(lockIds) ? new List<String>() : (List<String>) JSON.deserialize(lockIds, List<String>.class),
            String.isBlank(doctorId) ? null : doctorId
        );
        return new Response(LC_AppointmentScreenUtil.MSG_SUCCESS);
    }

    private Response relockSlots(String recordId, String jsonedSlots, String lockIds, String doctorId) {
        System.debug('LC_AppointmentScreenController.relockSlots ...');
        LC_AppointmentScreenService.getInstance(recordId).relockSlots(
            String.isBlank(jsonedSlots) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlots, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(lockIds) ? new List<String>() : (List<String>) JSON.deserialize(lockIds, List<String>.class),
            String.isBlank(doctorId) ? null : doctorId
        );
        return new Response(LC_AppointmentScreenUtil.MSG_SUCCESS);
    }

    private Response unlockRelockSlots(String recordId, String jsonedSlotsToUnlock, String lockIdsToUnlock, String jsonedSlotsToRefresh, String lockIdsToRefresh, String doctorId) {
        System.debug('LC_AppointmentScreenController.unlockRelockSlots ...');
        LC_AppointmentScreenService.getInstance(recordId).unlockSlots(
            String.isBlank(jsonedSlotsToUnlock) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlotsToUnlock, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(lockIdsToUnlock) ? new List<String>() : (List<String>) JSON.deserialize(lockIdsToUnlock, List<String>.class),
            String.isBlank(doctorId) ? null : doctorId
        );
        LC_AppointmentScreenService.getInstance(recordId).relockSlots(
            String.isBlank(jsonedSlotsToRefresh) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlotsToRefresh, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(lockIdsToRefresh) ? new List<String>() : (List<String>) JSON.deserialize(lockIdsToRefresh, List<String>.class),
            String.isBlank(doctorId) ? null : doctorId
        );
        return new Response(LC_AppointmentScreenUtil.MSG_SUCCESS);
    }

    private Response createAppointments(String recordId, String docInClinicId, String idNumber, String idType, String assists, String protocols, String urgentReason, String pfCode, String procedureCodes, String jsonedSlots, String jsonedTech, String techProcedureCode, Boolean techProcedureLeading, String doctorId) {
        System.debug('LC_AppointmentScreenController.createAppointments ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).createAppointments(
            String.isBlank(docInClinicId) ? null : docInClinicId,
            String.isBlank(idNumber) ? null : idNumber,
            String.isBlank(idType) ? null : idType,
            String.isBlank(assists) ? new List<String>() : (List<String>) JSON.deserialize(assists, List<String>.class),
            String.isBlank(protocols) ? new List<String>() : (List<String>) JSON.deserialize(protocols, List<String>.class),
            String.isBlank(urgentReason) ? null : urgentReason,
            String.isBlank(pfCode) ? null : pfCode,
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class),
            String.isBlank(jsonedSlots) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlots, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(jsonedTech) ? null : (LC_AppointmentScreenService.TechnicianWrp) JSON.deserialize(jsonedTech, LC_AppointmentScreenService.TechnicianWrp.class),
            String.isBlank(techProcedureCode) ? null : techProcedureCode,
            techProcedureLeading == null ? false : techProcedureLeading,
            String.isBlank(doctorId) ? null : doctorId
        ));
    }

    private Response setAppointments(String recordId, String jsonedSlots, String idNumber, String idType, String apptIds, String fileIds, String forcedCode) {
        System.debug('LC_AppointmentScreenController.setAppointments ...');
        LC_AppointmentScreenService.getInstance(recordId).setAppointments(
            String.isBlank(jsonedSlots) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlots, List<ws_AppointmentNew.CalenderSlot>.class),
            String.isBlank(idNumber) ? null : idNumber,
            String.isBlank(idType) ? null : idType,
            String.isBlank(apptIds) ? new List<String>() : (List<String>) JSON.deserialize(apptIds, List<String>.class),
            String.isBlank(fileIds) ? new List<String>() : (List<String>) JSON.deserialize(fileIds, List<String>.class),
            String.isBlank(forcedCode) ? null : forcedCode
        );
        return new Response(LC_AppointmentScreenUtil.MSG_SUCCESS);
    }

    private Response validateAppointments(String recordId, String recordIds) {
        System.debug('LC_AppointmentScreenController.validateAppointments ...');
        LC_AppointmentScreenService.getInstance(recordId).validateAppointments(
            String.isBlank(recordIds) ? new Set<Id>() : (Set<Id>) JSON.deserialize(recordIds, Set<Id>.class)
        );
        return new Response(LC_AppointmentScreenUtil.MSG_SUCCESS);
    }

    private Response rescheduleAppointments(String recordId, String docInClinicId, String idNumber, String idType, String assists, String pfCode, String appointmentIds, String jsonedSlots) {
        System.debug('LC_AppointmentScreenController.rescheduleAppointments ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).rescheduleAppointments(
            String.isBlank(docInClinicId) ? null : docInClinicId,
            String.isBlank(idNumber) ? null : idNumber,
            String.isBlank(idType) ? null : idType,
            String.isBlank(assists) ? new List<String>() : (List<String>) JSON.deserialize(assists, List<String>.class),
            String.isBlank(pfCode) ? null : pfCode,
            String.isBlank(appointmentIds) ? new List<String>() : (List<String>) JSON.deserialize(appointmentIds, List<String>.class),
            String.isBlank(jsonedSlots) ? new List<ws_AppointmentNew.CalenderSlot>() : (List<ws_AppointmentNew.CalenderSlot>) JSON.deserialize(jsonedSlots, List<ws_AppointmentNew.CalenderSlot>.class)
        ));
    }

    private Response transferToDepartment(String recordId, String siteCode, String procedureCode, String insurenceCode, String domainId, String queueId) {
        System.debug('LC_AppointmentScreenController.transferToDepartment ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).transferToDepartment(
            String.isBlank(siteCode) ? null : siteCode,
            String.isBlank(procedureCode) ? null : procedureCode,
            String.isBLank(insurenceCode) ? null : insurenceCode,
            String.isBlank(domainId) ? null : domainId,
            String.isBlank(queueId) ? null : queueId
        ));
    }

    private Response getCalendarProcedure(String recordId, String calendarCode) {
        System.debug('LC_AppointmentScreenController.getCalendarProcedure ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).getCalendarProcedure(
            String.isBlank(calendarCode) ? null : calendarCode
        ));
    }

    private Response obtainUpdateCancelForm(String recordId) {
        System.debug('LC_AppointmentScreenController.obtainUpdateCancelForm...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainUpdateCancelForm());
    }
    // legacy move, doesn`t work from 15/07/2020
    private Response checkWorkingDays(String recordId, String scheduleDate) {
        System.debug('LC_AppointmentScreenController.checkWorkingDays...');
        return new Response('');
    }
    // legacy move, doesn`t work from 15/07/2020
    private Response checkAppointmentWorkingDays(String recordId) {
        System.debug('LC_AppointmentScreenController.checkAppointmentWorkingDays...');
        return new Response(false);
    }
    // legacy move, doesn't run because checkAppointmentWorkingDays is disabled
    private Response approveTwoWeeksAppointment(String recordId) {
        System.debug('LC_AppointmentScreenController.approveTwoWeeksAppointment...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).approveTwoWeeksAppointment());
    }
    // leagecy move, doesn't run because checkAppointmentWorkingDays is disabled
    private Response cancelTwoWeeksAppointment(String recordId) {
        System.debug('LC_AppointmentScreenController.cancelTwoWeeksAppointment...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).cancelTwoWeeksAppointment());
    }

    private Response updateScreen(String recordId) {
        System.debug('LC_AppointmentScreenController.updateScreen...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).updateScreen());
    }

    private Response obtainSchedulerParams(String recordId, String idNumber, String idType, String domainId, String procedureCode, String pfCode, String siteCode, String protocol) {
        System.debug('LC_AppointmentScreenController.obtainSchedulerParams ...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainSchedulerParams(
            String.isBlank(idNumber) ? '' : idNumber,
            String.isBlank(idType) ? '' : idType,
            String.isBlank(domainId) ? '' : domainId,
            String.isBlank(procedureCode) ? '' : procedureCode,
            String.isBlank(pfCode) ? '' : pfCode,
            String.isBlank(siteCode) ? '' : siteCode,
            String.isBlank(protocol) ? '' : protocol
        ));
    }

    private Response isDocumentExists(String recordId, String procedureCodes, String siteCode) {
        System.debug('LC_AppointmentScreenController.isDocumentExists...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).isDocumentExists(
            String.isBlank(procedureCodes) ? new List<String>() : (List<String>) JSON.deserialize(procedureCodes, List<String>.class),
            String.isBlank(siteCode) ? '' : siteCode
        ));
    }

    private Response obtainUrgentForm(String recordId) {
        System.debug('LC_AppointmentScreenController.obtainUrgentForm...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).obtainUrgentForm());
    }

    private Response hasFutureAppointments(String pRecordId, String pProcedureCode) {
        System.debug('LC_AppointmentScreenController.hasFutureAppointments...');
        return new Response(LC_AppointmentScreenService.getInstance(pRecordId).hasFutureAppointments(
            String.isBlank(pProcedureCode) ? '' : pProcedureCode
        ));
    }

    private Response searchAppointments(String recordId, String keyword, String operationType, Boolean isRestricted) {
        System.debug('LC_AppointmentScreenController.searchAppointments...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).searchAppointments(
            String.isBlank(keyword) ? '' : keyword,
            String.isBlank(operationType) ? null : operationType,
            isRestricted == null ? true : Boolean.valueOf(operationType)
        ));
    }

    private Response cancelAppointment(String recordId, String appointmentId, String reason, String reasonText) {
        System.debug('LC_AppointmentScreenController.cancelAppointment...');
        Object result = LC_AppointmentScreenService.getInstance(recordId).cancelAppointment(
            String.isBlank(appointmentId) ? null : appointmentId,
            String.isBlank(reason) ? null : reason,
            String.isBlank(reasonText) ? null : reasonText,
            false
        );
        return new Response(result instanceOf String, result);
    }

    private Response isSaveSlot(String recordId, String procedureId, String calendarCode) {
        System.debug('LC_AppointmentScreenController.isSaveSlot...');
        return new Response(LC_AppointmentScreenService.getInstance(recordId).isSaveSlot(
            String.isBlank(procedureId) ? null : procedureId,
            String.isBlank(calendarCode) ? null : calendarCode
        ));
    }
}