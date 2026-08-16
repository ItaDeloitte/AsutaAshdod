// Test: LogSettingServiceTest
public inherited sharing class LogSettingService {

    private static LogSettingService instance;

    private Log_Setting__mdt setting;

    private LogSettingService() {
        System.debug('LogSettingService ...');
        this.obtainSetting();
    }

    public static LogSettingService getInstance() {
        if (instance == null) {
            instance = new LogSettingService();
        }
        return instance;
    }

    private void obtainSetting() {
        List<Log_Setting__mdt> settings = [
            SELECT ErrorsOnly__c
              FROM Log_Setting__mdt
             WHERE IsActive__c = true
             LIMIT 1];
        System.debug('settings: size: ' + settings.size() + ' users: ' + settings);

        if (!settings.isEmpty()) {
            this.setting = settings.get(0);
        }
        System.debug('setting: ' + this.setting);
    }

    // error without record id
    public List<Log__c> prepareLog(String className, Exception e) {
        List<Log__c> logList = new List<Log__c>();
        if (this.setting != null) {
            logList.addAll(this.prepareLog(className, null, e, null));
        }
        return logList;
    }

    // error with record id
    public List<Log__c> prepareLog(String className, String methodName, Exception e, String recordId) {
        List<Log__c> logList = new List<Log__c>();
        if (this.setting != null) {
            logList.addAll(this.prepareLog(className, methodName, e, recordId, null, null));
        }
        return logList;
    }

    // info with record id and without callout
    public List<Log__c> prepareLog(String className, String methodName, String recordId) {
        List<Log__c> logList = new List<Log__c>();
        if (this.setting != null && !this.setting.ErrorsOnly__c) {
            logList.addAll(this.prepareLog(className, methodName, recordId, null, null));
        }
        return logList;
    }

    // info without record id and with callout
    public List<Log__c> prepareLog(String className, String methodName, String requestJson, String responseJson) {
        List<Log__c> logList = new List<Log__c>();
        if (this.setting != null && !this.setting.ErrorsOnly__c) {
            logList.addAll(this.prepareLog(className, methodName, null, requestJson, responseJson));
        }
        return logList;
    }

    // info with record id and with callout
    public List<Log__c> prepareLog(String className, String methodName, String recordId, String requestJson, String responseJson) {
        List<Log__c> logList = new List<Log__c>();
        if (this.setting != null && !this.setting.ErrorsOnly__c) {
            logList.addAll(this.prepareLog(className, methodName, null, recordId, requestJson, responseJson));
        }
        return logList;
    }

    private List<Log__c> prepareLog(String className, String methodName, Exception e, String recordId, String requestJson, String responseJson) {
        Log__c log = new Log__c(
            Class__c = className,
            Method__c = methodName,
            RecordId__c = recordId,
            Request__c = requestJson,
            Response__c = responseJson,
            UserId__c = UserInfo.getUserId()
        );

        if (e != null) {
            log.Message__c = e.getMessage();
            log.TypeName__c = e.getTypeName();
            log.LineNumber__c = e.getLineNumber();
            log.StackTrace__c = e.getStackTraceString();
        } else {
            log.Message__c = 'info';
        }
        System.debug('log: ' + log);

        return new List<Log__c>{log};
    }
}