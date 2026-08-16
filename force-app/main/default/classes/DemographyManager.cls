//Test:LC_DemographyTest
public  class DemographyManager {

    public static AccountWithDisabilities updateAccountWithExtendedDetails(Account targetAcc, String personId, String idType) {
        Boolean isAshdodEmployee = isAshdodEmployee();
        ws_DemographyExtended.PatientDemographicRequest req = new ws_DemographyExtended.PatientDemographicRequest();
        
        req.PatientID = personId;
        req.IdType = Long.valueOf(idType);
        // hardcoded for now, should be moved in to custom setings
        req.SourceSysNo = isAshdodEmployee ? 13 : 16 ; 
        req.HMOCode = 2;
        req.GetADdata = true;

        List<Callout_Timeout__mdt> metadata = [SELECT Timeout__c FROM Callout_Timeout__mdt WHERE DeveloperName = 'Demography'];
        if (!metadata.isEmpty()) {
            Integer timeoutMinutes = Integer.valueOf(metadata.get(0).Timeout__c);
            System.debug('timeoutMinutes: ' + timeoutMinutes);
            if ((targetAcc.Last_update_demographic__c == null || targetAcc.Last_update_demographic__c.addMinutes(timeoutMinutes) < Datetime.now())
                && (targetAcc.AccountStatus__c == 'לקוח מלא' || isAshdodEmployee)) {
                targetAcc.Last_update_demographic__c = Datetime.now();

                System.debug('****START****GetCombinedDemography');
                ws_DemographyExtended.PatientDemographicExtended extendedResp = new ws_DemographyExtended.GetCombinedDemographySoap().GetCombinedDemography(req);

                System.debug('extendedResp ' + JSON.serialize(extendedResp));
                return accountMapping(extendedResp, targetAcc);
            }
        }

        return new AccountWithDisabilities(new Account(), false);
    }

    public static AccountWithDisabilities accountMapping(ws_DemographyExtended.PatientDemographicExtended data, Account accRecord) {
        Set <String> otherIdTypesSet = new Set <String> {'3', '4', '5', '8'};
        if (accRecord.Id == null) {
            accRecord.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SObjectType = 'Account'].Id;
        }
        if (data.IsDemographyExist == 0) {
            System.debug('Demography does not exist');
            return new AccountWithDisabilities(accRecord, false);
        }

        accRecord.DisableValidation__c = !accRecord.DisableValidation__c;
        System.debug('accRecord.DisableValidation__c ' + accRecord.DisableValidation__c);
        // errors info
        if (!data.InfoSorceSystems.InfoSorceSystem.isEmpty()) {
            accRecord.SorceSysCode__c = '';
            accRecord.QueryStatus__c = '';
            accRecord.ErrorMessage__c = '';
            accRecord.ErrorCode__c = '';
            for (DemographyExtended.InfoSorceSystem infoSys_i : data.InfoSorceSystems.InfoSorceSystem) {
                accRecord.SorceSysCode__c += '; ' + infoSys_i.SorceSysCode;
                accRecord.QueryStatus__c += '; ' + infoSys_i.QueryStatus;
                accRecord.ErrorMessage__c += '; ' + infoSys_i.ErrorMessage;
                accRecord.ErrorCode__c += '; ' + infoSys_i.ErrorCode;
            }
            accRecord.SorceSysCode__c = accRecord.SorceSysCode__c.replaceFirst('; ', '');
            accRecord.Create_Tafnit_AC__c = accRecord.SorceSysCode__c.contains('T') ? false : true;
            accRecord.QueryStatus__c = accRecord.QueryStatus__c.replaceFirst('; ', '');
            accRecord.ErrorMessage__c = accRecord.ErrorMessage__c.replaceFirst('; ', '');
            accRecord.ErrorCode__c = accRecord.ErrorCode__c.replaceFirst('; ', '');
        }

        // id type and number
        if (data.PatientID.length() < 9){
            accRecord.ID_Number__c = '000000000'.substring(data.PatientID.length()) + data.PatientID;
        } else {
            accRecord.ID_Number__c = data.PatientID;
        }
        if (otherIdTypesSet.contains(String.valueOf(data.IdType))){
            accRecord.ID_Type__c = '8';
        } else {
            accRecord.ID_Type__c = String.valueOf(data.IdType);
        }

        // phone
        if (String.isNotBlank(data.CellNumber) && String.isNotBlank(data.HomeNumber) && data.CellNumber != '0' && data.HomeNumber != '0') {
            accRecord.Phone = parsePhone(data.CellNumber); // '+972' + parsePhone(data.CellNumber).substring(1);
            accRecord.PersonOtherPhone = parsePhone(data.HomeNumber); // '+972' + parsePhone(data.HomeNumber).substring(1);
        } else if (String.isNotBlank(data.CellNumber) && data.CellNumber != '0' && (String.isBlank(data.HomeNumber) || data.HomeNumber == '0')) {
            accRecord.Phone = parsePhone(data.CellNumber); // '+972' + parsePhone(data.CellNumber).substring(1);
            if (String.isNotBlank(data.WorkNumber) && data.WorkNumber != '0') {
                accRecord.PersonOtherPhone = parsePhone(data.WorkNumber); // '+972' + parsePhone(data.WorkNumber).substring(1);
            }
        } else if ((String.isBlank(data.CellNumber) || data.CellNumber == '0') && String.isNotBlank(data.HomeNumber) && data.HomeNumber != '0') {
            accRecord.Phone = parsePhone(data.HomeNumber); // '+972' + parsePhone(data.HomeNumber).substring(1);
            if (String.isNotBlank(data.WorkNumber) && data.WorkNumber != '0') {
                accRecord.PersonOtherPhone = parsePhone(data.WorkNumber); // '+972' + parsePhone(data.WorkNumber).substring(1);
            }
        } else {
            if (String.isNotBlank(data.WorkNumber) && data.WorkNumber != '0') {
                accRecord.Phone = parsePhone(data.WorkNumber); // '+972' + parsePhone(data.WorkNumber).substring(1);
            }
        }

        if (String.isNotBlank(data.Fax)) {
            accRecord.Fax = data.Fax;
        }
        if (String.isNotBlank(data.FirstName)) {
            accRecord.FirstName = data.FirstName;
        }
        if (String.isNotBlank(data.LastName)) {
            accRecord.LastName = data.LastName;
        }
        if (String.isNotBlank(data.ParentName)) {
            accRecord.Father_Name__c = data.ParentName;
        }
        if (String.isNotBlank(data.Email)) {
            accRecord.PersonEmail = data.Email;
        }
        System.debug('data.HMOCode ' + data.HMOCode);
        if (String.isNotBlank(String.valueOf(data.HMOCode)) && data.HMOCode != 0) { // != 0 was added to avoid an error
            accRecord.Insurer_factor__c = String.valueOf(data.HMOCode);
        } else {
            accRecord.Other_Health_Services__c = null; // for prevent dependecy error
        }
        if (String.isNotBlank(data.BirthDate)) {
            accRecord.PersonBirthdate = Date.valueOf(data.BirthDate);
        }
        if (String.isNotBlank(data.Gender)) {
            accRecord.Gender__c = data.Gender;
        }
        /*if (String.isNotBlank(data.PrimaryLanguage)) {
            accRecord.Preferred_Language_Service__c = data.PrimaryLanguage; 
        }*/
        // added by Anatoly 05.08.2019
        if (String.isNotBlank(data.PrimaryLanguageCode)) {
            accRecord.Preferred_Language_Service__c = data.PrimaryLanguageCode; 
        }
        if (String.isNotBlank(String.valueOf(data.IsEligble))) {
            accRecord.Maccabi_Member__c = data.IsEligble; 
        }
        if (String.isNotBlank(String.valueOf(data.BeginMembership))) {
            // accRecord.Begin_Insurance__c = Date.valueOf(data.BeginMembership); // commented because of invalid date
        }

        // address array
        if (data.Address != null) {
            System.debug('data.Address '+data.Address);
            accRecord.PersonMailingStreet = data.Address.Street + ' ' + data.Address.HouseNumber + '/' + data.Address.Apartment;
            accRecord.PersonMailingCountry = data.Address.StateName;
            accRecord.PersonMailingCity = data.Address.City; // city code was skipped
            accRecord.PersonMailingPostalCode = data.Address.ZipCode;
        }

        // patient disabilities array
        // List<Disabilities__c> disabilities = new List<Disabilities__c>();
        /*if (data.Disabilities != null) {
            System.debug('data.Disabilities '+data.Disabilities);
            Map<String, Id> nameToIdMap = new Map<String, Id>();
            Id disabilityRTId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Disability' AND SObjectType = 'Disabilities__c'].Id;

            if (accRecord.Id != null) {
                Map<String, Disabilities__c> idToDisabilityMap = new Map<String, Disabilities__c>();
                for (ws_DemographyExtended.Patient_Disability disability_i : data.Disabilities.Patient_Disabilities.Patient_Disability) {
                    System.debug('there are Patient_Disability in existing account');
                    if (String.isNotBlank(disability_i.Dis_Code) && String.isNotBlank(disability_i.Date_Of_Disability)) {
                        String keyForMap = String.valueOf(accRecord.Id).substring(0, 15) + disability_i.Dis_Code + Date.valueOf(disability_i.Date_Of_Disability);
                        System.debug('keyForMap ' + keyForMap);
                        idToDisabilityMap.put(keyForMap.substringBefore(' '), populateDisability(disability_i, disabilityRTId));
                    }
                }
                if ( data.Disabilities != null && data.Disabilities.Patient_Assistance != null){
                    for (ws_DemographyExtended.Patient_Assist assistance_i : data.Disabilities.Patient_Assistance.Patient_Assist) {
                        System.debug('there are Patient_Assist in existing account');
                        if (String.isNotBlank(assistance_i.Assist_Code) && String.isNotBlank(assistance_i.Date_Of_Assist)) {
                            String keyForMap = String.valueOf(accRecord.Id).substring(0, 15) + assistance_i.Assist_Code + Date.valueOf(assistance_i.Date_Of_Assist);
                            System.debug('keyForMap ' + keyForMap);
                            idToDisabilityMap.put(keyForMap.substringBefore(' '), populateAssistance(assistance_i, disabilityRTId));
                        }
                    }
                }
                for (Disabilities__c disability_i : [SELECT Id, Disability_Identifier__c, Assistance_Identifier__c
                                                     FROM Disabilities__c
                                                     WHERE Disability_Identifier__c IN :idToDisabilityMap.keySet() OR Assistance_Identifier__c IN :idToDisabilityMap.keySet()]) {
                    if (idToDisabilityMap.containsKey(disability_i.Disability_Identifier__c)) {
                        idToDisabilityMap.get(disability_i.Disability_Identifier__c).Id = disability_i.Id;
                    } else if (idToDisabilityMap.containsKey(disability_i.Assistance_Identifier__c)) {
                        idToDisabilityMap.get(disability_i.Assistance_Identifier__c).Id = disability_i.Id;
                    }
                }
                disabilities = idToDisabilityMap.values();
                System.debug('idToDisabilityMap '+idToDisabilityMap);
                System.debug('disabilities '+disabilities);
            } else {
                for (ws_DemographyExtended.Patient_Disability disability_i : data.Disabilities.Patient_Disabilities.Patient_Disability) {
                    System.debug('there are Patient_Disability in new account');
                    if (String.isNotBlank(disability_i.Dis_Code) && String.isNotBlank(disability_i.Date_Of_Disability)) {
                        disabilities.add(populateDisability(disability_i, disabilityRTId));
                    }
                }
                for (ws_DemographyExtended.Patient_Assist assistance_i : data.Disabilities.Patient_Assistance.Patient_Assist) {
                    System.debug('there are Patient_Assist in new account');
                    if (String.isNotBlank(assistance_i.Assist_Code) && String.isNotBlank(assistance_i.Date_Of_Assist)) {
                        disabilities.add(populateAssistance(assistance_i, disabilityRTId));
                    }
                }
                System.debug('disabilities '+disabilities);
            }
        }*/

        // picklist Other_Health_Services__c
        Set<String> picklistAPIs = new Set<String>();
        for (PicklistUtil.PicklistValue entry_i : PicklistUtil.buildPickListOptionsBySchema('Account', 'Other_Health_Services__c', false)) {
            picklistAPIs.add(entry_i.value);
        }
        System.debug('picklistAPIs ' + picklistAPIs);
        // member insurance
        Map<String, String> insuranceCodeMap = new Map<String, String>{'1' => null, '2' => '10', '3' => '15 ', '7' => '16'};
        //System.debug('data.MemberInsurances.MemberInsuranceExtended.isEmpty() '+data.MemberInsurances.MemberInsuranceExtended.isEmpty());
        if (data.MemberInsurances != null && data.MemberInsurances.MemberInsuranceExtended != null && !data.MemberInsurances.MemberInsuranceExtended.isEmpty()) {
            Integer j = 0;
            for (Integer i = 1; i < data.MemberInsurances.MemberInsuranceExtended.size(); i++) {
                if (data.MemberInsurances.MemberInsuranceExtended[j].StartDate < data.MemberInsurances.MemberInsuranceExtended[i].StartDate) {
                    j = i;
                }
            }
            System.debug('IsInsuranceExist '+data.MemberInsurances.MemberInsuranceExtended[j].IsInsuranceExist);
            accRecord.Insurance_is_valid__c = data.MemberInsurances.MemberInsuranceExtended[j].IsInsuranceExist == '1' ? true : false;

            SYstem.debug('data.AdditionalHealthService.AdditionalHealthServiceItem ' + data.AdditionalHealthService.AdditionalHealthServiceItem.get(0));
            if (accRecord.Insurance_is_valid__c && insuranceCodeMap.containsKey(data.MemberInsurances.MemberInsuranceExtended[j].Code)) {
                accRecord.Other_Health_Services__c = insuranceCodeMap.get(data.MemberInsurances.MemberInsuranceExtended[j].Code);
                accRecord.Start_Date_shaban_maccabi__c = data.MemberInsurances.MemberInsuranceExtended[j].StartDate;
                accRecord.End_Date_shaban_maccabi__c = data.MemberInsurances.MemberInsuranceExtended[j].EndDate;
            } else if (!accRecord.Insurance_is_valid__c &&
                       data.AdditionalHealthService != null &&
                       data.AdditionalHealthService.AdditionalHealthServiceItem != null &&
                       !data.AdditionalHealthService.AdditionalHealthServiceItem.isEmpty() &&
                       picklistAPIs.contains(String.valueOf(data.AdditionalHealthService.AdditionalHealthServiceItem.get(0)))) {
                accRecord.Other_Health_Services__c = String.valueOf(data.AdditionalHealthService.AdditionalHealthServiceItem.get(0)); // data.MemberInsurances.MemberInsuranceExtended[j].Code;
            }
        }

        if (!accRecord.Insurance_is_valid__c && data.HMOCode == 2) {
            accRecord.Insurer_factor__c = null;
        } else if (accRecord.Insurance_is_valid__c) {
            accRecord.Insurer_factor__c = '2';
        }

        accRecord.Last_sync_datetime__c = Datetime.now();
        System.debug('****END****GetCombinedDemography');
        return new AccountWithDisabilities(accRecord, true); // new AccountWithDisabilities(accRecord, disabilities); //return accRecord;
    }

    /*private static Disabilities__c populateDisability(ws_DemographyExtended.Patient_Disability disability, Id rtId) {
        return new Disabilities__c(RecordTypeId = rtId,
                                   Type_of_disability__c = disability.Dis_Code,
                                   Description__c = disability.Dis_Desc,
                                   Date_of_start__c = Date.valueOf(disability.Date_Of_Disability),
                                   Side__c = disability.Side_Code,
                                   Permanency__c = disability.Permanence,
                                   Notes__c = disability.Disability_Remark);
    }

    private static Disabilities__c populateAssistance(ws_DemographyExtended.Patient_Assist assistance, Id rtId) {
        return new Disabilities__c(RecordTypeId = rtId,
                                   Type_of_Assist__c = assistance.Assist_Code,
                                   Description__c = assistance.Assist_Desc,
                                   Notes__c = assistance.Assist_Remark,
                                   Date_of_start__c = Date.valueOf(assistance.Date_Of_Assist));
    }*/

    private static String parsePhone(String phone) {
        if (!phone.startsWith('0')) {
            phone = '0' + phone;
        }
        if (phone.contains('-')) {
            phone = phone.replaceAll('-', '');
        }
        return phone;
    }

    public class AccountWithDisabilities {
        public Boolean isDemographyExist {get;set;}
        public Account acct {get;set;}

        public AccountWithDisabilities(Account acct, Boolean isDemographyExist) {
            this.isDemographyExist = isDemographyExist;
            this.acct = acct;
        }
    }

    public static Boolean isAshdodEmployee(){
        User currentUser = [SELECT Id, Ashdod_employee__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(currentUser.Ashdod_employee__c){
            return true;
        }
        return false;
    }
}