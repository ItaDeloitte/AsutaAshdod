// Test: LC_CaseAgreementTest
// Created: Evgeniy Kravchuk
// Date: 15.01.2020
public class LC_CaseAgreement implements ILCController {

    public class LC_CaseAgreementException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainAgreements' {
                return this.obtainAgreements((String) params.get('recordId'), (String) params.get('agreementName'));
            }
            when 'setAgreement'{
                return this.setAgreement((String) params.get('recordId'), (String) params.get('agreementId'));
            }
            when 'getAgreement'{
                return this.getAgreement((String) params.get('recordId'));
            }
            when else {
                throw new LC_CaseAgreementException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainAgreements(String recordId, String agreementName) {
        System.debug('LC_CaseAgreement.obtainAgreements...\nrecordId: ' + recordId + '\nagreementName: ' + agreementName);
        String sObjctName = String.valueOf(Id.valueOf(recordId).getSObjectType());
        SObject sObjct = Database.query('SELECT Id ' 
                                            + ', Channel__c '
                                            + ', Agreement__c '
                                            + ', Recommended_doc__c '
                                            + ', PayerFactor__c '
                                            + ', PayerFactor__r.InsuranceCode__c '
                                            + ', PayerFactor__r.Name_of_parent__c ' 
                                        + ' FROM ' + sObjctName
                                        + ' WHERE Id =: recordId');
        List<Agreement__c> agreements = new List<Agreement__c>();
        agreementName = '%' + agreementName + '%';
        System.debug('sObjct: ' + sObjct);

        if (sObjct.getSObject('PayerFactor__r') == null 
                || sObjct.getSObject('PayerFactor__r').get('InsuranceCode__c') == '0' 
                || sObjct.getSObject('PayerFactor__r').get('InsuranceCode__c') == '1111') {
            agreements = [SELECT Id
                                , Name 
                            FROM Agreement__c 
                            WHERE Doctor_Account__c =: String.valueOf(sObjct.get('Recommended_doc__c')) 
                                AND Name LIKE: agreementName];
            System.debug('agreements: size: ' + agreements.size() + ' value: ' + agreements);
            return new Response(agreements);
        }

        if (sObjct.get('Channel__c') == 'קופה' && sObjct.get('Recommended_doc__c') != null) {
            Map<Integer, List<Agreement__c>> agreementsMap = sortAgreements(sObjct, agreementName);

            if (!agreementsMap.get(1).isEmpty()) {
                return new Response(agreementsMap.get(1));
            } else if (!agreementsMap.get(2).isEmpty()) {
                return new Response(agreementsMap.get(2));
            } else if (!agreementsMap.get(3).isEmpty()) {
                return new Response(agreementsMap.get(3));
            } else if (!agreementsMap.get(4).isEmpty()) {
                for (Agreement__c agreement_i : agreementsMap.get(4)) {
                    if (String.isNotBlank(agreement_i.Notes__c)) {
                        throw new LC_CaseAgreementException(Label.Sentence_before_the_notes + ' ' + agreementsMap.get(4).get(0).Notes__c);
                    }
                }
            }
        }

        agreements = [SELECT Id
                            , Name 
                        FROM Agreement__c
                       WHERE Doctor_Account__c =: String.valueOf(sObjct.get('Recommended_doc__c'))
                         AND (PayerFactor__c =: String.valueOf(sObjct.get('PayerFactor__c')) OR PayerFactor__r.InsuranceCode__c = '0' OR PayerFactor__r.InsuranceCode__c = '1111')
                         AND Name LIKE: agreementName];
        System.debug('agreements: size: ' + agreements.size() + ' value: ' + agreements);

        return new Response(agreements);
    }

    private Response setAgreement(String recordId, String agreementId) {
        System.debug('LC_CaseAgreement.setAgreement...\recordId: ' + recordId + '\nagreementId: ' + agreementId);
        SObject sObjct = Id.valueOf(recordId).getSObjectType().newSObject(recordId);
     
        sObjct.put('Agreement__c', String.isBlank(agreementId) ? null : agreementId);
        update sObjct;
        System.debug('sObjct: ' + sObjct);
        return new Response('success');
    }

    private Response getAgreement(String recordId) {
        System.debug('LC_CaseAgreement.getAgreement...\nrecordId: ' + recordId);
        String sObjctName = String.valueOf(Id.valueOf(recordId).getSObjectType());
        SObject sObjct = Database.query('SELECT Id '
                                            + ', Channel__c '
                                            + ', Agreement__c '
                                            + ', Agreement__r.Name '
                                            + ', Recommended_doc__c '
                                            + ', PayerFactor__c '
                                            + ', PayerFactor__r.Name_of_parent__c '
                                        + ' FROM ' + sObjctName
                                        + ' WHERE Id =: recordId');
        Agreement__c agreement = new Agreement__c();
        if (sObjct.get('Agreement__c') != null) {
            agreement = [SELECT Id
                                , Name 
                            FROM Agreement__c 
                            WHERE Id =: String.valueOf(sObjct.get('Agreement__c'))];
            System.debug('agreement: ' + agreement);
            return new Response(agreement);
        }

        if (sObjct.get('Channel__c') == 'קופה' && sObjct.get('Recommended_doc__c') != null) {
            Map<Integer, List<Agreement__c>> agreementsMap = sortAgreements(sObjct, null);

            if (!agreementsMap.get(1).isEmpty()) {
                if (agreementsMap.get(1).size() == 1) {
                    sObjct.put('Agreement__c', agreementsMap.get(1).get(0).Id);
                    update sObjct;

                    System.debug('agreement: ' + agreementsMap.get(1).get(0));
                    return new Response(agreementsMap.get(1).get(0));
                }
            } else if (!agreementsMap.get(2).isEmpty()) {
                if (agreementsMap.get(2).size() == 1) {
                    sObjct.put('Agreement__c', agreementsMap.get(2).get(0).Id);
                    update sObjct;

                    System.debug('agreement: ' + agreementsMap.get(2).get(0));
                    return new Response(agreementsMap.get(2).get(0));
                }
            } else if (!agreementsMap.get(3).isEmpty()) {
                if (agreementsMap.get(3).size() == 1) {
                    sObjct.put('Agreement__c', agreementsMap.get(3).get(0).Id);
                    update sObjct;

                    System.debug('agreement: ' + agreementsMap.get(3).get(0));
                    return new Response(agreementsMap.get(3).get(0));
                }
            }
        }

        System.debug('agreement: ' + agreement);
        return new Response(agreement);
    }

    // INNER METHODS
    private Map<Integer, List<Agreement__c>> sortAgreements(SObject sObjct, String agreementName) {
        // 1 = samePF, 2 = parentPF, 3 = zeroPF, 4 = exluded
        Map<Integer, List<Agreement__c>> resultMap = new Map<Integer, List<Agreement__c>>{
            1 => new List<Agreement__c>(),
            2 => new List<Agreement__c>(), 
            3 => new List<Agreement__c>(), 
            4 => new List<Agreement__c>()};
        String query = 'SELECT Id'
                            + ', Name'
                            + ', not_scheduled_by_moked__c'
                            + ', Notes__c'
                            + ', PayerFactor__c'
                            + ', PayerFactor__r.InsuranceCode__c'
                            + ', PayerFactor__r.Name_of_parent__c'
                            + ' FROM Agreement__c '
                            + ' WHERE Doctor_Account__c = \'' + sObjct.get('Recommended_doc__c') + '\'';
        query += agreementName == null || agreementName == '%' ? '' : ' AND Name LIKE: agreementName';

        for (Agreement__c agreement_i : Database.query(query)) {
            if (sObjct.get('PayerFactor__c') != null && agreement_i.PayerFactor__c == sObjct.get('PayerFactor__c')) {
                if (agreement_i.not_scheduled_by_moked__c) {
                    resultMap.get(4).add(agreement_i);
                } else {
                    resultMap.get(1).add(agreement_i);
                }
            }
            if ((sObjct.get('PayerFactor__c') != null && agreement_i.PayerFactor__r.Name_of_parent__c == sObjct.get('PayerFactor__c')) 
                    || (sObjct.getSObject('PayerFactor__r').get('Name_of_parent__c') != null 
                        && (agreement_i.PayerFactor__c == sObjct.getSObject('PayerFactor__r').get('Name_of_parent__c') 
                            || agreement_i.PayerFactor__r.Name_of_parent__c == sObjct.getSObject('PayerFactor__r').get('Name_of_parent__c')))) {
                if (agreement_i.not_scheduled_by_moked__c) {
                    resultMap.get(4).add(agreement_i);
                } else {
                    resultMap.get(2).add(agreement_i);
                }
            }
            if (agreement_i.PayerFactor__r.InsuranceCode__c == '0' || agreement_i.PayerFactor__r.InsuranceCode__c == '1111') {
                if (agreement_i.not_scheduled_by_moked__c) {
                    resultMap.get(4).add(agreement_i);
                } else {
                    resultMap.get(3).add(agreement_i);
                }
            }
        }
        System.debug('samePF: size: ' + resultMap.get(1).size() + ' value: ' + resultMap.get(1));
        System.debug('parentPF: size: ' + resultMap.get(2).size() + ' value: ' + resultMap.get(2));
        System.debug('zeroPF: size: ' + resultMap.get(3).size() + ' value: ' + resultMap.get(3));
        System.debug('exluded: size: ' + resultMap.get(4).size() + ' value: ' + resultMap.get(4));

        return resultMap;
    }
}