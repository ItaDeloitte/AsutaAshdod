public with sharing class RelatedDocumentTriggerService {

    public static void checkDuplicateRecords(List<RDWR> rdwrs) {
        Boolean logicExecuted = false;
        Map<Id, List<RDWR>> mpIdToExistingRDWRs = new Map<Id, List<RDWR>>();
        Set<String> rdIds = new Set<String>();
        Set<String> mpIds = new Set<String>();
        Set<String> apptRTs = new Set<String>();
        Set<String> languages = new Set<String>();
        Set<String> sites = new Set<String>();
        Set<String> asthmas = new Set<String>();
        Set<String> iodineSensitivity = new Set<String>();
        Set<String> fromHours = new Set<String>();
        Set<String> toHours = new Set<String>();

        for (RDWR rdwr_i : rdwrs) {
            rdIds.add(rdwr_i.rd.Id);
            mpIds.add(rdwr_i.mpId);
            apptRTs.addAll(rdwr_i.apptRTs);
            languages.addAll(rdwr_i.languages);
            sites.addAll(rdwr_i.sites);
            asthmas.addAll(rdwr_i.asthmas);
            iodineSensitivity.addAll(rdwr_i.iodineSensitivity);
            fromHours.add(rdwr_i.fromHour);
            toHours.add(rdwr_i.toHour);
            mpIdToExistingRDWRs.put(rdwr_i.mpId, new List<RelatedDocumentTriggerService.RDWR>());
        }
        System.debug('rdIds: size: ' + rdIds.size() + ' value: ' + rdIds);
        System.debug('mpIds: size: ' + mpIds.size() + ' value: ' + mpIds);
        System.debug('apptRTs: size: ' + apptRTs.size() + ' value: ' + apptRTs);
        System.debug('languages: size: ' + languages.size() + ' value: ' + languages);
        System.debug('sites: size: ' + sites.size() + ' value: ' + sites);
        System.debug('asthmas: size: ' + asthmas.size() + ' value: ' + asthmas);
        System.debug('iodineSensitivity: size: ' + iodineSensitivity.size() + ' value: ' + iodineSensitivity);
        System.debug('fromHours: size: ' + fromHours.size() + ' value: ' + fromHours);
        System.debug('toHours: size: ' + toHours.size() + ' value: ' + toHours);

        String query = 'SELECT Id'
                          + ', Name'
                          + ', Medical_Procedure__c'
                          + ', AppointmentRecordType__c'
                          + ', Language__c'
                          + ', Site__c'
                          + ', Asthma__c'
                          + ', Iodine_sensitivity__c'
                          + ', FromHour__c'
                          + ', ToHour__c'
                      + ' FROM Related_document__c'
                     + ' WHERE Active__c = true'
                       + ' AND GastroGuidelines__c = false'
                       + ' AND Id NOT IN :rdIds'
                       + ' AND Medical_Procedure__c IN :mpIds'
                       + ' AND ToHour__c IN :toHours'
                       + ' AND FromHour__c IN :fromHours'
                       + ' AND Site__c INCLUDES (\'' + String.join(new List<String>(sites), '\',\'') + '\')'
                       + ' AND Language__c INCLUDES (\'' + String.join(new List<String>(languages), '\',\'') + '\')'
                       + ' AND AppointmentRecordType__c INCLUDES (\'' + String.join(new List<String>(apptRTs), '\',\'') + '\')'
                       + ' AND (Asthma__c = null OR Asthma__c INCLUDES (\'' + String.join(new List<String>(asthmas), '\',\'') + '\'))'
                       + ' AND (Iodine_sensitivity__c = null OR Iodine_sensitivity__c INCLUDES (\'' + String.join(new List<String>(iodineSensitivity), '\',\'') + '\'))';

        for (Related_document__c rd_i : Database.query(query)) {
            RDWR rdwr_i = new RDWR(rd_i);
            mpIdToExistingRDWRs.get(rdwr_i.mpId).add(rdwr_i);
        }

        for (RDWR rdwrNew_i : rdwrs) {
            for (RDWR rdwrOld_i : mpIdToExistingRDWRs.get(rdwrNew_i.mpId)) {
                if (rdwrNew_i.isDuplicate(rdwrOld_i)) {
                    rdwrNew_i.rd.addError(Label.Duplicate_related_ducument + ' ' + rdwrOld_i.rd.Name);
                    logicExecuted = true;
                }
            }
        }

        if (logicExecuted) {
            System.debug('LOG Related_document__c checkDuplicateRecords2 ... logic has been executed');
        }
    }

    public class RDWR {
        public Related_document__c rd {get;set;}
        public String mpId {get;set;}
        public Set<String> apptRTs {get;set;}
        public Set<String> languages {get;set;}
        public Set<String> sites {get;set;}
        public Set<String> asthmas {get;set;}
        public Set<String> iodineSensitivity {get;set;}
        public String fromHour {get;set;}
        public String toHour {get;set;}

        private RDWR() {
            this.asthmas = new Set<String>();
            this.iodineSensitivity = new Set<String>();
        }

        public RDWR(Related_document__c rd) {
            this();
            this.rd = rd;
            this.mpId = rd.Medical_Procedure__c;
            this.apptRTs = new Set<String>(rd.AppointmentRecordType__c.split(';'));
            this.languages = new Set<String>(rd.Language__c.split(';'));
            this.sites = new Set<String>(rd.Site__c.split(';'));
            if (rd.Asthma__c != null) {
                this.asthmas = new Set<String>(rd.Asthma__c.split(';'));
            }
            if (rd.Iodine_sensitivity__c != null) {
                this.iodineSensitivity = new Set<String>(rd.Iodine_sensitivity__c.split(';'));
            }
            this.fromHour = rd.FromHour__c;
            this.toHour = rd.ToHour__c;
        }

        public Boolean isDuplicate(RDWR compareTo) {
            Boolean isDuplicate = false;
            if (this.apptRTs.removeAll(compareTo.apptRTs) &&
                    this.languages.removeAll(compareTo.languages) &&
                    this.sites.removeAll(compareTo.sites) &&
                    ((this.asthmas.isEmpty() && compareTo.asthmas.isEmpty()) ||
                        this.asthmas.removeAll(compareTo.asthmas)) &&
                    ((this.iodineSensitivity.isEmpty() && compareTo.iodineSensitivity.isEmpty()) ||
                        this.iodineSensitivity.removeAll(compareTo.iodineSensitivity)) &&
                    this.fromHour == compareTo.fromHour &&
                    this.toHour == compareTo.toHour) {
                isDuplicate = true;
            }
            return isDuplicate;
        }
    }
}