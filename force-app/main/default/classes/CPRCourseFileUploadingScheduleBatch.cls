/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * CPR Course Files Schedule Batch Apex class to upload files from Salesforce to Tafnit system
 *
 * Test                 CPRCourseFileUploadingScheduleBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-11-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class CPRCourseFileUploadingScheduleBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {

    private static final String QUERY =
        'SELECT Remarks__c'
           + ', file_type__c'
           + ', DocDateEnd__c'
           + ', DocDateBegin__c'
           + ', FileExtension__c'
           + ', is_succeed_CPR_Tafnit__c'
           + ', Case__r.Approval_Topic__c'
           + ', Case__r.Approval_Sub_Topic__c'
           + ', DoctorName__r.Doctor_Code__c'
           + ', (SELECT ContentDocumentId'
               + ' FROM ContentDocumentLinks)'
       + ' FROM File__c'
      + ' WHERE RecordType.DeveloperName = \'DoctorsFiles\''
        + ' AND file_type__c = \'36\''
        + ' AND IsApproved__c = true'
        + ' AND is_succeed_CPR_Tafnit__c = false'
        + ' AND Approved_date__c = LAST_N_DAYS:6'
   + ' ORDER BY DoctorName__c';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CPRCourseFileUploadingScheduleBatch ... start');
        System.debug('query: ' + QUERY);
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<File__c> scope) {
        System.debug('CPRCourseFileUploadingScheduleBatch ... execute');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        List<File__c> filesToUpdate = new List<File__c>();
        Map<String, List<File__c>> doctorCodeToFilesMap = new Map<String, List<File__c>>();

        for (File__c file_i : scope) {
            if (!doctorCodeToFilesMap.containsKey(file_i.DoctorName__r.Doctor_Code__c)) {
                doctorCodeToFilesMap.put(file_i.DoctorName__r.Doctor_Code__c, new List<File__c>());
            }
            doctorCodeToFilesMap.get(file_i.DoctorName__r.Doctor_Code__c).add(file_i);
        }
        System.debug('doctorCodeToFilesMap: size: ' + doctorCodeToFilesMap.size() + ' value: ' + doctorCodeToFilesMap);

        for (String doctorCode_i : doctorCodeToFilesMap.keySet()) {
            ws_UploadCPRCourseFileToTafnit.PostFilesResponse response = ws_UploadCPRCourseFileToTafnit.postFiles(doctorCode_i, doctorCodeToFilesMap.get(doctorCode_i));

            for (File__c file_i : doctorCodeToFilesMap.get(doctorCode_i)) {
                file_i.is_succeed_CPR_Tafnit__c = response.ResultStatus == '0';
                if (response.ResultStatus != '0') {
                    file_i.Status_Send_File_toTtafnit__c = response.ErrCodes.get(0).Message;
                }
                filesToUpdate.add(file_i);
            }
        }
        System.debug('filesToUpdate: size: ' + filesToUpdate.size() + ' value: ' + filesToUpdate);

        Set<Id> fileIds = AsyncUtil.doUpdate(filesToUpdate);
        System.debug('fileIds: size: ' + fileIds.size() + ' value: ' + fileIds);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('CPRCourseFileUploadingScheduleBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new CPRCourseFileUploadingScheduleBatch(), 100);
    }
}