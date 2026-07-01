public with sharing class SendMessageByPopulation_Invoc {

    @InvocableMethod(label='Send message by population')
    public static List<FlowOutputs> invoke(List<FlowInputs> requests) {
        List<FlowOutputs> results = new List<FlowOutputs>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (FlowInputs req : requests) {
            FlowOutputs res = new FlowOutputs();
            res.isSuccsess = true;
            res.recordsCount = 0;
            res.errorMessage = null;
            System.debug('req: '+req);
            try {
                Set<Id> domainIds      = parseIds(req.domainIds);System.debug('domainIds: '+domainIds);
                Set<Id> siteIds        = parseIds(req.siteIds);System.debug('siteIds: '+siteIds);
                Set<Id> calendarIds    = parseIds(req.calendarIds);System.debug('calendarIds: '+calendarIds);
                Set<Id> medProcIds     = parseIds(req.medicalProcIds);System.debug('medProcIds: '+medProcIds);
                Set<Id> payerFactorIds = parseIds(req.payerFactorIds);System.debug('payerFactorIds: '+payerFactorIds);
                List<String> cities = req.isCanceledAppointments ? null : parseString(req.citiesList);System.debug('cities: '+cities);

                Date dateFrom = req.appDateFrom;
                Date dateTo   = req.appDateTo;
                Integer fromAge = req.fromAge;
                Integer toAge   = req.toAge;

                String query =
                    'SELECT Id, Name, Patient_Account__c, Patient_Account__r.Name, ' +
                    'Patient_Account__r.Phone, Patient_Account__r.SMS_Phone_Number__c, ' +
                    'Patient_Account__r.Age_Number__c, Patient_Account__r.PersonMailingCity, ' +
                    'Medical_Procedure__c, Medical_Procedure__r.Name, ' +
                    'Appointment_Status__c, Appointment_Date__c, ' +
                    'Site__c, Site__r.Name, Domain__c, Domain__r.Name, Calendar__c, Calendar__r.Name ' +
                    'FROM Appointment__c ';

                if(req.isCanceledAppointments){
                    query += 'WHERE Appointment_Status__c IN (\'Canceled\', \'not_arrived\', \'WaitingForCanceled\') ' +
                             'AND Appointment_Date__c >= :dateFrom ' +
                             'AND Appointment_Date__c <= :dateTo';
                } else {
                    query += 'WHERE Appointment_Status__c NOT IN (\'Canceled\', \'not_arrived\', \'WaitingForCanceled\') ' +
                             'AND Appointment_Date__c >= :dateFrom ';
                    if (!cities.isEmpty()) {
                        query += ' AND Patient_Account__r.PersonMailingCity IN:cities';
                    }
                }

                if (!domainIds.isEmpty()) {
                    query += ' AND Domain__c IN :domainIds';
                }
                if (!siteIds.isEmpty()) {
                    query += ' AND Site__c IN :siteIds';
                }
                if (!calendarIds.isEmpty()) {
                    query += ' AND Calendar__c IN :calendarIds';
                }
                if (!medProcIds.isEmpty()) {
                    query += ' AND Medical_Procedure__c IN :medProcIds';
                }
                if (!payerFactorIds.isEmpty()) {
                    query += ' AND Patient_Account__r.Payer_Factor_Insurance__c IN :payerFactorIds';
                }
                if (fromAge != null) {
                    query += ' AND Patient_Account__r.Age_Number__c >= :fromAge';
                }
                if (toAge != null) {
                    query += ' AND Patient_Account__r.Age_Number__c <= :toAge';
                }

                System.debug('query: '+query);
                List<Appointment__c> appList = Database.query(query);
                System.debug('appList size: '+appList.size());
                if (appList.isEmpty()) {
                    results.add(res);
                    continue;
                }

                Set<Id> patientIds = new Set<Id>();
                Set<Id> appIdsToSend = new Set<Id>();
                Map<String, Set<Id>> medProcPatientKeyToAppIds = new Map<String, Set<Id>>();


                for (Appointment__c app : appList) {
                    if (app.Patient_Account__c == null || app.Medical_Procedure__c == null) {
                        continue;
                    }

                    patientIds.add(app.Patient_Account__c);
                    appIdsToSend.add(app.Id);

                    String key = buildKey(app.Medical_Procedure__c, app.Patient_Account__c);

                    if (!medProcPatientKeyToAppIds.containsKey(key)) {
                        medProcPatientKeyToAppIds.put(key, new Set<Id>());
                    }
                    medProcPatientKeyToAppIds.get(key).add(app.Id);
                }

                if (req.isCanceledAppointments && !patientIds.isEmpty()) {
                    Date todayDate = Date.today();

                    String futureQuery =
                        'SELECT Id, Patient_Account__c, Medical_Procedure__c ' +
                        'FROM Appointment__c ' +
                        'WHERE Appointment_Status__c NOT IN (\'Canceled\', \'WaitingForCanceled\') ' +
                        'AND Appointment_Date__c >= :todayDate ' +
                        'AND Patient_Account__c IN :patientIds';

                    if (!medProcIds.isEmpty()) {
                        futureQuery += ' AND Medical_Procedure__c IN :medProcIds';
                    }
                    System.debug('futureQuery: '+futureQuery);
                    List<Appointment__c> futureAppList = Database.query(futureQuery);
                    System.debug('futureAppList size: '+futureAppList.size());
                    for (Appointment__c futureApp : futureAppList) {
                        if (futureApp.Patient_Account__c == null || futureApp.Medical_Procedure__c == null) {
                            continue;
                        }

                        String key = buildKey(futureApp.Medical_Procedure__c, futureApp.Patient_Account__c);

                        if (medProcPatientKeyToAppIds.containsKey(key)) {
                            appIdsToSend.removeAll(medProcPatientKeyToAppIds.get(key));
                        }
                    }
                }

                res.recordsCount = appIdsToSend.size();

                List<Appointment__c> finalPopulation = new List<Appointment__c>();
                for (Appointment__c app : appList) {
                    if (appIdsToSend.contains(app.Id)) {
                        finalPopulation.add(app);
                    }
                }

                res.recordsCount = finalPopulation.size();

                if (!finalPopulation.isEmpty()) {
                    ContentVersion cv = createPopulationCsv(finalPopulation);
                    res.contentDocumentId = cv.ContentDocumentId;
                    res.fileDownloadUrl = '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
                }

                if(appIdsToSend.size() > 0 && req.sendNow){
                    Id batchJobId = Database.executeBatch(new SendMessageByPopulation_Batch(appIdsToSend, req.templateAPIName), 25);                    
                }
            } catch (Exception e) {
                res = generateErrorOutput(e.getMessage());
            }

            results.add(res);
        }

        return results;
    }

    private static ContentVersion createPopulationCsv(List<Appointment__c> appointments) {
        String csv = '';

        csv += 'Appointment Id,Appointment Name,Patient Id,Patient Name,Phone,SMS Phone,Age,';
        csv += 'Medical Procedure Id,Medical Procedure Name,Status,Appointment Date,';
        csv += 'Site,Domain,Calendar\n';

        for (Appointment__c app : appointments) {
            csv += csvCell(app.Id) + ',';
            csv += csvCell(app.Name) + ',';
            csv += csvCell(app.Patient_Account__c) + ',';
            csv += csvCell(app.Patient_Account__r != null ? app.Patient_Account__r.Name : null) + ',';
            csv += csvCell(app.Patient_Account__r != null ? app.Patient_Account__r.Phone : null) + ',';
            csv += csvCell(app.Patient_Account__r != null ? app.Patient_Account__r.SMS_Phone_Number__c : null) + ',';
            csv += csvCell(app.Patient_Account__r != null ? app.Patient_Account__r.Age_Number__c : null) + ',';
            csv += csvCell(app.Medical_Procedure__c) + ',';
            csv += csvCell(app.Medical_Procedure__r != null ? app.Medical_Procedure__r.Name : null) + ',';
            csv += csvCell(app.Appointment_Status__c) + ',';
            csv += csvCell(app.Appointment_Date__c) + ',';
            csv += csvCell(app.Site__r != null ? app.Site__r.Name : null) + ',';
            csv += csvCell(app.Domain__r != null ? app.Domain__r.Name : null) + ',';
            csv += csvCell(app.Calendar__r != null ? app.Calendar__r.Name : null) + '\n';
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Filtered_Population_' + DateTime.now().format('yyyyMMdd_HHmmss');
        cv.PathOnClient = cv.Title + '.csv';
        cv.VersionData = Blob.valueOf('\uFEFF' + csv); // BOM for Excel
        insert cv;

        return [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];
    }

    private static String csvCell(Object value) {
        String s = value == null ? '' : String.valueOf(value);
        s = s.replace('"', '""');
        return '"' + s + '"';
    }

    private static Set<Id> parseIds(String rawIds) {
        Set<Id> result = new Set<Id>();

        if (String.isBlank(rawIds) || rawIds == null) {
            return result;
        }

        for (String token : rawIds.split('[,;]')) {
            String cleaned = token != null ? token.trim() : null;
            if (!String.isBlank(cleaned)) {
                result.add((Id) cleaned);
            }
        }

        return result;
    }

    private static List<String> parseString(String rawStr) {
        List<String> result = new List<String>();

        if (String.isBlank(rawStr)) {
            return result;
        }

        for (String token : rawStr.split('[,;]')) {
            String cleaned = token != null ? token.trim() : null;
            if (!String.isBlank(cleaned)) {
                result.add(cleaned);
            }
        }

        return result;
    }

    private static String buildKey(Id medProcId, Id patientId) {
        return String.valueOf(medProcId) + '|' + String.valueOf(patientId);
    }

    private static FlowOutputs generateErrorOutput(String errorMsg) {
        FlowOutputs res = new FlowOutputs();
        res.isSuccsess = false;
        res.recordsCount = 0;
        res.errorMessage = errorMsg;
        return res;
    }

    public class FlowInputs {
        @InvocableVariable(label='Is Canceled Appointments' description='If there is messages for patients with canceled appointment')
        public Boolean isCanceledAppointments;

        @InvocableVariable(label='Need to Send Message now' description='If send message now')
        public Boolean sendNow;

        @InvocableVariable(label='Domain Ids' description='The list of Domain Ids separated with comma')
        public String domainIds;

        @InvocableVariable(label='Site Ids' description='The list of Site Ids separated with comma')
        public String siteIds;

        @InvocableVariable(label='Calendar Ids' description='The list of Calendar Ids separated with comma')
        public String calendarIds;

        @InvocableVariable(label='Medical Procedure Ids' description='The list of Medical Procedure Ids separated with comma')
        public String medicalProcIds;

        @InvocableVariable(required=true label='Appointment date from' description='Appointment date sending from - Date')
        public Date appDateFrom;

        @InvocableVariable(label='Appointment date to' description='Appointment date sending to - Date')
        public Date appDateTo;

        @InvocableVariable(label='Payer factor Ids' description='Patient payer factor Ids separated with comma')
        public String payerFactorIds;

        @InvocableVariable(label='List of Cities' description='The list of cities separated with comma')
        public String citiesList;

        @InvocableVariable(label='From age' description='Patient from age')
        public Integer fromAge;

        @InvocableVariable(label='To age' description='Patient to age')
        public Integer toAge;

        @InvocableVariable(label='Template name' description='Message template API name')
        public String templateAPIName;
    }

    public class FlowOutputs {
        @InvocableVariable
        public Integer recordsCount;

        @InvocableVariable
        public Boolean isSuccsess;

        @InvocableVariable
        public String errorMessage;

        @InvocableVariable
        public String fileDownloadUrl;

        @InvocableVariable
        public Id contentDocumentId;
    }
}