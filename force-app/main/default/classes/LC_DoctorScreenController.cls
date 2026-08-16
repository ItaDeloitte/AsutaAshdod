/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Scheduling Screen Apex Controller class to keep main logical entries
 *
 * Test                 LC_DoctorScreenTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_DoctorScreenController implements ILCController {

    public class LC_DoctorScreenException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'isAvailable' {
                return this.isAvailable(
                    (String) params.get('caseId')
                );
            }
            when 'init' {
                return this.init(
                    (String) params.get('caseId')
                );
            }
            when 'searchExpertises' {
                return this.searchExpertises(
                    (String) params.get('caseId'),
                    (String) params.get('keyword')
                );
            }
            when 'searchSubExpertises' {
                return this.searchSubExpertises(
                    (String) params.get('caseId'),
                    (String) params.get('expertiseId'),
                    (String) params.get('keyword')
                );
            }
            when 'searchProcedures' {
                return this.searchProcedures(
                    (String) params.get('caseId'),
                    (String) params.get('subExpertiseId'),
                    (String) params.get('keyword')
                );
            }
            when 'searchDoctors' {
                return this.searchDoctors(
                    (String) params.get('caseId'),
                    (String) params.get('searchType'),
                    (String) params.get('doctorName'),
                    (String) params.get('procedureId'),
                    (String) params.get('expertiseId'),
                    (String) params.get('subExpertiseId'),
                    (String) params.get('arrangements'),
                    (String) params.get('settlements'),
                    (Boolean) params.get('onlyRecommended')
                );
            }
            when 'obtainClosestAvailableSlotInfo' {
                return this.obtainClosestAvailableSlotInfo(
                    (String) params.get('caseId'),
                    (String) params.get('doctorIds'),
                    (String) params.get('expertiseId'),
                    (String) params.get('subExpertiseId')
                );
            }
            when 'recommendDoctors' {
                return this.recommendDoctors(
                    (String) params.get('caseId'),
                    (String) params.get('doctorIds')
                );
            }
            when 'sendDoctorAdvisor' {
                return this.sendDoctorAdvisor(
                    (String) params.get('caseId'),
                    (String) params.get('doctorIds')
                );
            }
            when 'obtainClinics' {
                return this.obtainClinics(
                    (String) params.get('caseId'),
                    (String) params.get('doctorId')
                );
            }
            when 'chooseClinic' {
                return this.chooseClinic(
                    (String) params.get('caseId'),
                    (String) params.get('clinicId')
                );
            }
            when 'schedule' {
                return this.schedule(
                    (String) params.get('caseId'),
                    (String) params.get('selectedDoctorId'),
                    (String) params.get('arrangementId'),
                    (String) params.get('doctorIds')
                );
            }
            when else {
                throw new LC_DoctorScreenException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response isAvailable(String caseId) {
        System.debug('LC_DoctorScreenController.isAvailable...');
        LC_DoctorScreenService.getInstance(caseId).isAvailable();
        return new Response(LC_DoctorScreenUtil.MSG_SUCCESS);
    }

    private Response init(String caseId) {
        System.debug('LC_DoctorScreenController.init...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).init());
    }

    private Response searchExpertises(String caseId, String keyword) {
        System.debug('LC_DoctorScreenController.searchExpertises...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).searchExpertises(
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchSubExpertises(String caseId, String expertiseId, String keyword) {
        System.debug('LC_DoctorScreenController.searchSubExpertises...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).searchSubExpertises(
            String.isBlank(expertiseId) ? null : expertiseId,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchProcedures(String caseId, String subExpertiseId, String keyword) {
        System.debug('LC_DoctorScreenController.searchProcedures...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).searchProcedures(
            String.isBlank(subExpertiseId) ? null : subExpertiseId,
            String.isBlank(keyword) ? '' : keyword
        ));
    }

    private Response searchDoctors(String caseId, String searchType, String doctorName, String procedureId, String expertiseId, String subExpertiseId, String arrangements, String settlements, Boolean onlyRecommended) {
        System.debug('LC_DoctorScreenController.searchDoctors...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).searchDoctors(
            String.isBlank(searchType) ? LC_DoctorScreenUtil.BY_SPECIALIZATION : searchType,
            String.isBlank(doctorName) ? '' : doctorName,
            String.isBlank(procedureId) ? null : procedureId,
            String.isBlank(expertiseId) ? null : expertiseId,
            String.isBlank(subExpertiseId) ? null : subExpertiseId,
            String.isBlank(arrangements) ? null : (List<String>) JSON.deserialize(arrangements, List<String>.class),
            String.isBlank(settlements) ? null : (List<String>) JSON.deserialize(settlements, List<String>.class),
            onlyRecommended == null ? false : onlyRecommended
        ));
    }

    private Response obtainClosestAvailableSlotInfo(String caseId, String doctorIds, String expertiseId, String subExpertiseId) {
        System.debug('LC_DoctorScreenController.obtainClosestAvailableSlotInfo...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).obtainClosestAvailableSlotInfo(
            String.isBlank(doctorIds) ? new Set<String>() : (Set<String>) JSON.deserialize(doctorIds, Set<String>.class),
            String.isBlank(expertiseId) ? null : expertiseId,
            String.isBlank(subExpertiseId) ? null : subExpertiseId
        ));
    }

    private Response recommendDoctors(String caseId, String doctorIds) {
        System.debug('LC_DoctorScreenController.recommendDoctors...');
        LC_DoctorScreenService.getInstance(caseId).recommendDoctors(
            String.isBlank(doctorIds) ? new Set<String>() : (Set<String>) JSON.deserialize(doctorIds, Set<String>.class)
        );
        return new Response(LC_DoctorScreenUtil.MSG_RECOMMENDED);
    }

    private Response sendDoctorAdvisor(String caseId, String doctorIds) {
        System.debug('LC_DoctorScreenController.sendDoctorAdvisor...');
        LC_DoctorScreenService.getInstance(caseId).sendDoctorAdvisor(
            String.isBlank(doctorIds) ? new Set<String>() : (Set<String>) JSON.deserialize(doctorIds, Set<String>.class)
        );
        return new Response(LC_DoctorScreenUtil.MSG_RECOMMENDED);
    }

    private Response obtainClinics(String caseId, String doctorId) {
        System.debug('LC_DoctorScreenController.obtainClinics...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).obtainClinics(
            String.isBlank(doctorId) ? null : doctorId
        ));
    }

    private Response chooseClinic(String caseId, String recordId) {
        System.debug('LC_DoctorScreenController.chooseClinic...');
        return new Response(LC_DoctorScreenService.getInstance(caseId).chooseClinic(
            String.isBlank(recordId) ? null : recordId
        ));
    }

    private Response schedule(String caseId, String selectedDoctorId, String arrangementId, String doctorIds) {
        System.debug('LC_DoctorScreenController.schedule...');
        LC_DoctorScreenService.getInstance(caseId).schedule(
            String.isBlank(selectedDoctorId) ? null : selectedDoctorId,
            String.isBlank(arrangementId) ? null : arrangementId,
            String.isBlank(doctorIds) ? new Set<String>() : (Set<String>) JSON.deserialize(doctorIds, Set<String>.class)
        );
        return new Response(LC_DoctorScreenUtil.MSG_SUCCESS);
    }
}