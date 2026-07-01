// Test: LC_CaseDoctorArrangementTest
// Created: Evgeniy Kravchuk
// Date: 15.01.2020
public class LC_CaseDoctorArrangement implements ILCController {

    public class LC_CaseDoctorArrangementException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainDoctorArrangements' {
                return this.obtainDoctorArrangements((String) params.get('recordId'), (String) params.get('doctorArrangementName'));
            }
            when 'setDoctorArrangement'{
                return this.setDoctorArrangement((String) params.get('recordId'), (String) params.get('doctorArrangementId'));
            }
            when 'getDoctorArrangement'{
                return this.getDoctorArrangement((String) params.get('recordId'));
            }
            when else {
                throw new LC_CaseDoctorArrangementException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainDoctorArrangements(String recordId, String doctorArrangementName) {
        System.debug('LC_CaseDoctorArrangement.obtainDoctorArrangements...\nrecordId: ' + recordId + '\ndoctorArrangementName: ' + doctorArrangementName);
        String sObjctName = String.valueOf(Id.valueOf(recordId).getSObjectType());
        SObject sObjct = Database.query('SELECT Id'
                                            + ', Recommended_doc__c '
                                            + 'FROM ' + sObjctName
                                            + ' WHERE Id = :recordId');
        doctorArrangementName = '%' + doctorArrangementName + '%';
        System.debug('sObjct: ' + sObjct);

        List<Doctor_arrangement__c> doctorArrangements = [SELECT Id
                                                                , Arrangement__r.Name 
                                                            FROM Doctor_arrangement__c
                                                          WHERE Doctor__c =: String.valueOf(sObjct.get('Recommended_doc__c'))
                                                            AND Arrangement__r.Name LIKE: doctorArrangementName];
        System.debug('doctorArrangements: size: ' + doctorArrangements.size() + ' value: ' + doctorArrangements);

        return new Response(doctorArrangements);
    }

    private Response setDoctorArrangement(String recordId, String doctorArrangementId) {
        System.debug('LC_CaseDoctorArrangement.setDoctorArrangement...\nrecordId: ' + recordId + '\ndoctorArrangementId: ' + doctorArrangementId);
        SObject sObjct = Id.valueOf(recordId).getSObjectType().newSObject(recordId);
        
        sObjct.put('Doctor_Arrangement__c', String.isBlank(doctorArrangementId) ? null : doctorArrangementId);
        update sObjct;
        System.debug('sObjct: ' + sObjct);
        return new Response('success');
    }

    private Response getDoctorArrangement(String recordId) {
        System.debug('LC_CaseDoctorArrangement.getDoctorArrangement...\nrecordId: ' + recordId);
        String sObjctName = String.valueOf(Id.valueOf(recordId).getSObjectType());
        SObject sObjct = Database.query('SELECT Id'
                                            + ', Doctor_Arrangement__c'
                                            + ', Doctor_Arrangement__r.Name'
                                            + ' FROM ' + sObjctName 
                                            + ' WHERE Id = :recordId');
        
        Doctor_arrangement__c doctorArrangement = new Doctor_arrangement__c();
        if (sObjct.get('Doctor_Arrangement__c') != null) {
            doctorArrangement = [SELECT Id
                                        , Arrangement__r.Name 
                                    FROM Doctor_arrangement__c 
                                    WHERE Id =: String.valueOf(sObjct.get('Doctor_Arrangement__c'))];
        }
        System.debug('doctorArrangement: ' + doctorArrangement);
        return new Response(doctorArrangement);
    }
}