/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy     
* @version        1.0
* @created        03-06-2019
* @modified       DD-MM-YYYY
* @Test           SurgeryReferralsTest  
* @see 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is responsible for processing Spincal (surgery room reservation) and surgery referrals 
* that were received by ws_SurgeryReferrlas and creating/updating the appropriate records in SF.
* ──────────────────────────────────────────────────────────────────────────────────────────────────           
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class ws_SurgeryReferralsService {

    public Map<String, ID> sfIdMap = new Map<String, ID>();
    public ws_SurgeryReferrals.spincalData sData {get; set;}
    public ws_SurgeryReferrals.referralData rData {get; set;}
    public String originSystem {get; set;}

    public ws_SurgeryReferralsService(ws_SurgeryReferrals.spincalData data){
        this.sData = data;
        originSystem = 'SpinCal';
    }

    public ws_SurgeryReferralsService(ws_SurgeryReferrals.referralData data){
        this.rData = data;
        originSystem = 'Referral';
    }
    
    public GeneralResponse processData() {
        try {
            Appointment__c apt = new Appointment__c();

            if(originSystem == 'SpinCal') {
                String context = sData.status == '1'? 'create' : 'update';

                if(isFieldBlank(sData.patientId)){
                    return new GeneralResponse(false,'patientId is empty');
                }else if(isFieldBlank(sData.idType)){
                    return new GeneralResponse(false,'idType is empty');
                }else if(isFieldBlank(sData.doctorLicense)){
                    return new GeneralResponse(false,'doctorLicense is empty');
                }else if(isFieldBlank(sData.siteCode)){
                    return new GeneralResponse(false,'siteCode is empty');
                }else if(isFieldBlank(sData.surgeryDateTime)){
                    return new GeneralResponse(false,'surgeryDateTime is empty');
                }else if(isFieldBlank(sData.medicalOp1)){
                    return new GeneralResponse(false,'medicalOp1 is empty');
                }else if(isFieldBlank(sData.insurerCode)){
                    return new GeneralResponse(false,'insurerCode is empty');
                }else if(isFieldBlank(sData.status)){
                    return new GeneralResponse(false,'status is empty');
                }else if(isFieldBlank(sData.tafnitId)){
                    return new GeneralResponse(false,'tafnitId is empty');
                }

                SpinCal__c spincal = new SpinCal__c();
                if(findSpinCal(spincal)) {
                    if(context == 'create') {
                        return new GeneralResponse(false, 'Attempt to create an existing spincal record');
                    }
                    sfIdMap.put(sData.tafnitId, spincal.ID);
                }
                else {
                    if(context == 'update') {
                        context = 'create';
                    }
                }

                List <String> opCodes = buildMedicalOpsList(sData.medicalOp1, sData.medicalOp2, sData.medicalOp3, sData.medicalOp4);

                if (!getSFIds(sData.patientId, sData.idType, sData.doctorLicense, sData.siteCode, sData.insurerCode, opCodes)) {
                    return new GeneralResponse(false, 'Doctor, site, payer factor or one of the medical procedures does not exist in Salesforce');
                }

                if(context == 'create') {
                    //check if the patient exists
                    if(!sfIdMap.containsKey(sData.patientId)) {
                        return conditionalRecordCreator('no patient', sData.patientId, opCodes, sData.doctorLicense, sData.insurerCode, sData.tafnitId, sData.siteCode, sData.surgeryDateTime, 
                        new Appointment__c(), sData.status,null,null);
                    }
                }

                //check whether an appointment exists or not
                if(!findSurgeryApt(apt, sData.surgeryDateTime, sData.doctorLicense, sData.patientId, sData.siteCode, context)) {
                    return conditionalRecordCreator('no appointment', sData.patientId, opCodes, sData.doctorLicense, sData.insurerCode, sData.tafnitId, sData.siteCode, sData.surgeryDateTime, 
                    new Appointment__c(), sData.status,null,null);
                }
                
                if(context == 'create') {
                    return conditionalRecordCreator('nothing missing', sData.patientId, opCodes, sData.doctorLicense, sData.insurerCode, sData.tafnitId, sData.siteCode, sData.surgeryDateTime, 
                    apt, sData.status,null,null);
                }
                else {
                    spincal = upsertSpinCal(opCodes);
                    //Updates the surgery room status in the appointment for an updated SpinCal record
                    apt.status_surgery_room__c = sData.status;
                    update apt;
                    return new GeneralResponse(true, 'Data updated successfully');
                }
            }
            else {
                String context = rData.status == '1'? 'create' : 'update';

                if(isFieldBlank(rData.patientId)){
                    return new GeneralResponse(false,'patientId is empty');
                }else if(isFieldBlank(rData.idType)){
                    return new GeneralResponse(false,'idType is empty');
                }else if(isFieldBlank(rData.doctorLicense)){
                    return new GeneralResponse(false,'doctorLicense is empty');
                }else if(isFieldBlank(rData.siteCode)){
                    return new GeneralResponse(false,'siteCode is empty');
                }else if(isFieldBlank(rData.surgeryDateTime)){
                    return new GeneralResponse(false,'surgeryDateTime is empty');
                }else if(isFieldBlank(rData.medicalOp1)){
                    return new GeneralResponse(false,'medicalOp1 is empty');
                }else if(isFieldBlank(rData.insurerCode)){
                    return new GeneralResponse(false,'insurerCode is empty');
                }else if(isFieldBlank(rData.status)){
                    return new GeneralResponse(false,'status is empty');
                }else if(isFieldBlank(rData.refNumber)){
                    return new GeneralResponse(false,'refNumber is empty');
                }else if(rData.homeRehabilitation!=null && rData.homeRehabilitation){
                    if(isFieldBlank(rData.homeRehabilitationDate)){
                        return new GeneralResponse(false,'homeRehabilitationDate is empty');
                    }
                }
                    

                Referral_from_doctor_website__c referral = new Referral_from_doctor_website__c();
                if(findReferral(referral)) {
                    if(context == 'create') {
                        return new GeneralResponse(false, 'Attempt to create an existing referral record');
                    }
                    sfIdMap.put(rData.refNumber, referral.ID);
                }
                else {
                    if(context == 'update') {
                        context = 'create';
                    }
                }

                List <String> opCodes = buildMedicalOpsList(rData.medicalOp1, rData.medicalOp2, rData.medicalOp3, rData.medicalOp4);

                if (!getSFIds(rData.patientId, rData.idType, rData.doctorLicense, rData.siteCode, rData.insurerCode, opCodes)) {
                    return new GeneralResponse(false, 'Doctor, site, payer factor or one of the medical procedures does not exist in Salesforce');
                }
                if(context == 'create') {
                    //check if the patient exists
                    if(!sfIdMap.containsKey(rData.patientId)) {
                        return conditionalRecordCreator('no patient', rData.patientId, opCodes, rData.doctorLicense, rData.insurerCode, rData.refNumber, rData.siteCode, rData.surgeryDateTime, 
                        new Appointment__c(), rData.status,rData.homeRehabilitation,rData.homeRehabilitationDate != null ? Datetime.valueOf(rData.homeRehabilitationDate) : null);
                    }
                }
                //check whether an appointment exists or not
                if(!findSurgeryApt(apt, rData.surgeryDateTime, rData.doctorLicense, rData.patientId, rData.siteCode, context)) {
                    return conditionalRecordCreator('no appointment', rData.patientId, opCodes, rData.doctorLicense, rData.insurerCode, rData.refNumber, rData.siteCode, rData.surgeryDateTime, 
                    new Appointment__c(), rData.status,rData.homeRehabilitation,rData.homeRehabilitationDate != null ? Datetime.valueOf(rData.homeRehabilitationDate) : null);
                }
                if(context == 'create') {
                    System.debug('inside conditional record creator');
                    return conditionalRecordCreator('nothing missing', rData.patientId, opCodes, rData.doctorLicense, rData.insurerCode, rData.refNumber, rData.siteCode, rData.surgeryDateTime, 
                    apt, rData.status,rData.homeRehabilitation,rData.homeRehabilitationDate != null ? Datetime.valueOf(rData.homeRehabilitationDate) : null);
                }
                else {
                    System.debug('Reached update referral!');
                    referral = upsertReferral(opCodes);
                    return new GeneralResponse(true, 'Data updated successfully');
                }
            }
        }
        catch(Exception e) {
            System.debug('Error on line :'+e.getLineNumber()+' stack trace '+e.getStackTraceString()+ ' message '+e.getMessage());
            return new GeneralResponse(e);
        }
    }

    public void updateAppointmentLookup(Appointment__c apt){
        if(originSystem == 'SpinCal') {
            apt.Spincal__c = sfIdMap.get(sData.tafnitId);
            update apt;
        }
        else {
            System.debug('trying to update appointment');
            apt.Referral_from_doctor_website__c = sfIdMap.get(rData.refNumber);

            List<Referral_from_doctor_website__c> referrals = [SELECT Payment_needed__c, Payment_for_surgeon__c, Home_Rehabilitation__c, Home_Rehabilitation_Time_Approval__c FROM Referral_from_doctor_website__c WHERE Id = :sfIdMap.get(rData.refNumber)];
            apt.Payment_needed__c = referrals[0].Payment_needed__c;
            apt.Payment_to_Doctor__c = referrals[0].Payment_for_surgeon__c;
            apt.Shikum_Bait_Doctor_Rec__c = referrals[0].Home_Rehabilitation__c ? 'Recommended' : 'Not_Recommended';
            apt.Recommendation_Time__c = referrals[0].Home_Rehabilitation__c!=null ? referrals[0].Home_Rehabilitation_Time_Approval__c : null;
            update apt;
        }
    }

    public GeneralResponse conditionalRecordCreator(String condition, String patientId, List<String> opCodes, String doctorLicense, String insurerCode, String identifier, String siteCode, 
    String surgeryDateTime, Appointment__c apt, String status, Boolean homeRehabilitation,DateTime homeRehabilitationDate){

        if(condition == 'no patient') {
            Account patient = createPatient();
            sfIdMap.put(patientId, patient.ID);
        }

        if(originSystem == 'SpinCal'){
            //create the spincal record and connect to apt
            SpinCal__c spincal = upsertSpinCal(opCodes);
            sfIdMap.put(identifier, spincal.ID);
        }
        else{
            //create the referral record and connect to apt
            Referral_from_doctor_website__c referral = upsertReferral(opCodes);
            sfIdMap.put(identifier, referral.ID);
        }

        if(!(condition == 'nothing missing')) {
            //create the case
            Case surgeryCase = createCase(opCodes[0], doctorLicense, patientId, insurerCode);
            sfIdMap.put('case', surgeryCase.ID);
        }

        if(condition == 'no appointment' || condition == 'no patient') {
            //create the appointment
            apt = createAppointment(patientId, doctorLicense, siteCode, opCodes, identifier, insurerCode, surgeryDateTime, status,homeRehabilitation,homeRehabilitationDate);
            sfIdMap.put('appointment', apt.ID);
            //create a junction between the case and appointment
            //insertJunction();
        }
        
        if(condition == 'nothing missing'){
            //update the appointment's spincal or referral lookup
            updateAppointmentLookup(apt);
        }
        return new GeneralResponse(true, 'Data inserted successfully');
    }

    public List<String> buildMedicalOpsList(String opCode1, String opCode2, String opCode3, String opCode4){
        List <String> opCodes = new List <String>{opCode1};
        if(!String.isBlank(opCode2)) opCodes.add(opCode2);
        if(!String.isBlank(opCode3)) opCodes.add(opCode3);
        if(!String.isBlank(opCode4)) opCodes.add(opCode4);
        return opCodes;
    } 

    public boolean checkIfBlanks(List<String> fields) {
        Integer i = 0;
        for(String field : fields){
            if(String.isBlank(field)){
                return false;
            }
            i++;
        }
        return true;
    }

    public boolean isFieldBlank(String field){
        if(String.isBlank(field)){
            return true;
        }
        return false;
    }

    public boolean getSFIds(String patientId, String idType, String doctorLicense, String siteCode, String payerFactor, List<String> opCodes) {
        List<Account> accs = new List<Account>();
        List<Site__c> sites = new List<Site__c>();
        List<Medical_Procedure__c> procedures = new List<Medical_Procedure__c>();
        List<Payer_Factor__c> pfs = new List<Payer_Factor__c>();
        List<String> opCodesUnique = new List<String>();

        if(opCodes.size() > 1) {
            for(String opCode_i :opCodes){
            	if(opCodesUnique.isEmpty() || !opCodesUnique.contains(opCode_i)) opCodesUnique.add(opCode_i);                   
            } 
        }       
        procedures = [SELECT ID, Procedure_Code__c FROM Medical_Procedure__c WHERE Procedure_Code__c IN :opCodes];
        if(procedures.size() < opCodesUnique.size()) {
            return false;
        }

        for(Medical_Procedure__c procedure : procedures){
            sfIdMap.put(procedure.Procedure_Code__c, procedure.ID);
        }

        accs = [SELECT ID FROM Account WHERE Doctor_Code__c = :doctorLicense LIMIT 1];
        if(accs.isEmpty()) {
            return false;
        }
        sfIdMap.put(doctorLicense, accs[0].ID);

        sites = [SELECT ID FROM Site__c WHERE Site_Code__c = :siteCode LIMIT 1];
        if(sites.isEmpty()) {
            return false;
        }
        sfIdMap.put(siteCode, sites[0].ID);

        pfs = [SELECT ID FROM Payer_Factor__c WHERE InsuranceCode__c = :payerFactor LIMIT 1];
        if(pfs.isEmpty()) {
            return false;
        }
        sfIdMap.put(payerFactor, pfs[0].ID);

        accs = [SELECT ID FROM Account WHERE ID_Number__c = :patientId AND ID_Type__c = :idType LIMIT 1];
        if(!accs.isEmpty()) {
            sfIdMap.put(patientId, accs[0].ID);
        }

        return true;
    }

    public boolean findSpinCal(SpinCal__c spincal) {
        List<SpinCal__c> spincals = [SELECT ID FROM SpinCal__c WHERE tafnitID__c = :sData.tafnitId LIMIT 1];
        //Check if a spincal record exists
        if(spincals.isEmpty()){
            return false;
        }
        spincal.ID = spincals[0].ID;
        return true;
    }

    public boolean findReferral(Referral_from_doctor_website__c referral) {
        List<Referral_from_doctor_website__c> referrals = [SELECT ID FROM Referral_from_doctor_website__c WHERE Referral_Code__c = :rData.refNumber LIMIT 1];
        //Check if a referral record exists
        if(referrals.isEmpty()){
            return false;
        }
        referral.ID = referrals[0].ID;
        return true;
    }

    public boolean findSurgeryApt(Appointment__c apt, String surgeryDateTime, String doctorLicense, String patientId, String site, String context) {
        List<Appointment__c> apts = new List<Appointment__c>();

        if(context == 'create'){
            apts = [SELECT ID, Medical_Procedure__r.Domain__r.SurgerySideCheck__c, Medical_Procedure2__r.Domain__r.SurgerySideCheck__c, Medical_Procedure3__r.Domain__r.SurgerySideCheck__c, Medical_Procedure4__r.Domain__r.SurgerySideCheck__c FROM Appointment__c WHERE Patient_Account__c = :sfIdMap.get(patientId) AND Doctor_Account__c = :sfIdMap.get(doctorLicense) AND 
                Site__c = :sfIdMap.get(site) AND Appointment_Date_Time__c >= :Datetime.now() AND RecordType.DeveloperName = 'Surgeries' AND Appointment_Status__c != 'Canceled' 
                AND Appointment_Status__c != '2' ORDER BY Appointment_Date_Time__c ASC LIMIT 1];
            
            if(apts.isEmpty()) {
            	return false;
        	}
            
            Appointment__c appointment = apts[0];
            if (appointment.Medical_Procedure__r.Domain__r.SurgerySideCheck__c ||
                 (appointment.Medical_Procedure2__c != null && appointment.Medical_Procedure2__r.Domain__r.SurgerySideCheck__c) ||
                 (appointment.Medical_Procedure3__c != null && appointment.Medical_Procedure3__r.Domain__r.SurgerySideCheck__c) ||
                 (appointment.Medical_Procedure4__c != null && appointment.Medical_Procedure4__r.Domain__r.SurgerySideCheck__c)
               ) {
                return false;
            }
        }
        else {
            if(originSystem == 'SpinCal') {
                apts = [SELECT ID FROM Appointment__c WHERE Spincal__c =: sfIdMap.get(sData.tafnitId) AND RecordType.DeveloperName = 'Surgeries' LIMIT 1];
            }
            else {
                apts = [SELECT ID FROM Appointment__c WHERE Referral_from_doctor_website__c =: sfIdMap.get(rData.refNumber) AND RecordType.DeveloperName = 'Surgeries' LIMIT 1];
                // System.debug('apts are: '+apts);
                // if(apts.isEmpty()) {
                //     apts = [SELECT ID FROM Appointment__c WHERE Patient_Account__c = :sfIdMap.get(patientId) AND Doctor_Account__c = :sfIdMap.get(doctorLicense) AND 
                //             Site__c = :sfIdMap.get(site) AND Appointment_Date_Time__c >= :Datetime.now() AND RecordType.DeveloperName = 'Surgeries' AND Appointment_Status__c != 'Canceled' 
                //             AND Appointment_Status__c != '2' ORDER BY Appointment_Date_Time__c ASC LIMIT 1];  
                // }
            }
        }
        System.debug('apts are: '+apts);

        if(apts.isEmpty()) {
            return false;
        }
        apt.ID = apts[0].ID;
        return true;
    }

    public Account createPatient() {
        Account patient = new Account();
        patient.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        if(originSystem == 'SpinCal'){
            patient.FirstName = sData.fName;
            patient.LastName = sData.lName;
            patient.ID_Number__c = sData.patientId;
            patient.ID_Type__c = sData.idType;
            patient.PersonEmail = sData.email;
            patient.PersonBirthdate = date.valueOf(sData.birthDate);
            patient.Gender__c = sData.gender;

            if(!String.isBlank(sData.mainPhone)) {
                patient.Phone = sData.mainPhone;
                if(!String.isBlank(sData.otherPhone)) patient.PersonOtherPhone = sData.otherPhone;
                if(sData.mainPhone.length() > 9){
                    patient.Use_for_SMS__c =true;
                    patient.SMS_Phone_Number__c = sData.mainPhone;
                }
            }
            else if(!String.isBlank(sData.otherPhone)){
                patient.Phone = sData.otherPhone;
            }

        }
        else {
            patient.FirstName = rData.fName;
            patient.LastName = rData.lName;
            patient.ID_Number__c = rData.patientId;
            patient.ID_Type__c = rData.idType;
            patient.PersonBirthdate = date.valueOf(rData.birthDate);
            patient.Gender__c = rData.gender;

            if(!String.isBlank(rData.mobilePhone)) {
                patient.Phone = rData.mobilePhone;
                patient.Use_for_SMS__c =true;
                patient.SMS_Phone_Number__c = rData.mobilePhone;

                if(!String.isBlank(rData.homePhone)) {
                    patient.PersonOtherPhone = rData.homePhone;
                }
                else
                {
                    if(!String.isBlank(rData.workPhone)) {
                        patient.PersonOtherPhone = rData.workPhone;
                    }
                }
            }
            else {
                if(!String.isBlank(rData.homePhone)) {
                    patient.Phone = rData.homePhone;

                    if(!String.isBlank(rData.workPhone)) {
                         patient.PersonOtherPhone = rData.workPhone;
                    }
                }
                else {
                    if(!String.isBlank(rData.workPhone)) {
                        patient.Phone = rData.workPhone;
                    }
                }
            }
        }

        DemographyManager.AccountWithDisabilities accountWithDemography = DemographyManager.updateAccountWithExtendedDetails(patient, patient.ID_Number__c, patient.ID_Type__c);
        
        if (accountWithDemography.IsDemographyExist) {
            insert accountWithDemography.acct;

            /*for (Disabilities__c disability_i : accountWithDemography.disabilities) {
                disability_i.Patient_Account__c = accountWithDemography.acct.ID;
            }

            insert accountWithDemography.disabilities;*/
            return accountWithDemography.acct;
        }
        else {
            patient.Create_Tafnit_AC__c = true;
            patient.DisableValidation__c = true;
            insert patient;
            return patient;
        }
    }

    public Appointment__c createAppointment(String patientId, String doctorLicense, String siteCode, List<String> opCodes, String identifier, String insurerCode, String surgeryDateTime, 
    String status, Boolean homeRehabilitation,DateTime homeRehabilitationDate) {
        Appointment__c apt = new Appointment__c(Name = 'Surgery');
        apt.RecordTypeId = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Surgeries').getRecordTypeId();

        apt.Patient_Account__c = sfIdMap.get(patientId);
        apt.Doctor_Account__c = sfIdMap.get(doctorLicense);
        apt.Site__c = sfIdMap.get(siteCode);
        apt.Case__c = sfIdMap.get('case');
        apt.PayerFactor__c = sfIdMap.get(insurerCode);
        apt.Appointment_Date_Time__c = DateTime.valueOf(surgeryDateTime);
        apt.Opportunity__c = sfIdMap.get('Opportunity');

        if(originSystem == 'SpinCal'){
            apt.Spincal__c = sfIdMap.get(identifier);
            apt.status_surgery_room__c = status;
            apt.SourceSystem__c = 'SpinCal';
        }
        else {
            apt.Referral_from_doctor_website__c = sfIdMap.get(identifier);
            apt.SourceSystem__c = 'Doctor Referral';

            List<Referral_from_doctor_website__c> referrals = [SELECT Payment_needed__c, Payment_for_surgeon__c, IsCovid19__c FROM Referral_from_doctor_website__c WHERE Id = :sfIdMap.get(identifier)];
            apt.Payment_needed__c = referrals[0].Payment_needed__c;
            apt.Payment_to_Doctor__c = referrals[0].Payment_for_surgeon__c;
            if (homeRehabilitation != null && homeRehabilitationDate != null){
                apt.Shikum_Bait_Doctor_Rec__c = homeRehabilitation ? 'Recommended':'Not_Recommended';
                apt.Recommendation_Time__c = homeRehabilitationDate;
            }
            apt.IsCovid19__c = referrals[0].IsCovid19__c; 
        }

        switch on opCodes.size() {
            when 1 {
                apt.Medical_Procedure__c = sfIdMap.get(opCodes[0]);
            }
            when 2 {
                apt.Medical_Procedure__c = sfIdMap.get(opCodes[0]);
                apt.Medical_Procedure2__c = sfIdMap.get(opCodes[1]);
            }
            when 3 {
                apt.Medical_Procedure__c = sfIdMap.get(opCodes[0]);
                apt.Medical_Procedure2__c = sfIdMap.get(opCodes[1]);
                apt.Medical_Procedure3__c = sfIdMap.get(opCodes[2]);
            }
            when 4 {
                apt.Medical_Procedure__c = sfIdMap.get(opCodes[0]);
                apt.Medical_Procedure2__c = sfIdMap.get(opCodes[1]);
                apt.Medical_Procedure3__c = sfIdMap.get(opCodes[2]);
                apt.Medical_Procedure4__c = sfIdMap.get(opCodes[3]);
            }
        }

        insert apt;
        System.debug('The apt is: ' + apt);
        return apt;
    }

	public Case createCase(String medicalOp, String doctorLicense, String patientId, String insurerCode){
        // Check if there is a CaseAfterSale from the last six months
        List<Case> caseAfterSale = [SELECT Id, Opportunity__c FROM Case WHERE RecordType.DeveloperName = 'CaseAfterSale' AND AccountId = :sfIdMap.get(patientId) 
                                    AND (CreatedDate = LAST_N_MONTHS:5 OR CreatedDate = THIS_MONTH) AND Status != 'preSale' AND Status != 'Closed' ORDER BY CreatedDate DESC];
        if(!caseAfterSale.isEmpty()){
            sfIdMap.put('Opportunity', caseAfterSale[0].Opportunity__c);
            return caseAfterSale[0];
        }else{
            Case surgeryCase = new Case(Origin = 'מערכות מקור', Case_subject__c = 'טיפול אדמיניסטרטיבי טרום הניתוח');
            surgeryCase.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surgery').getRecordTypeId();
            surgeryCase.Medical_Procedure__c = sfIdMap.get(medicalOp);
            surgeryCase.Opearator__c = sfIdMap.get(doctorLicense);
            surgeryCase.AccountId = sfIdMap.get(patientId);
            surgeryCase.PayerFactor__c = sfIdMap.get(insurerCode);
    
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Name = 'Cases Record type and Origin Assignment' LIMIT 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            surgeryCase.setOptions(dmlOpts);
    
            insert surgeryCase;
            return surgeryCase;
        }
    }

    public SpinCal__c upsertSpinCal(List<String> opCodes){
        SpinCal__c spincal = new SpinCal__c();

        if (sfIdMap.containsKey(sData.tafnitId)) {
            spincal.Id = sfIdMap.get(sData.tafnitId);
        }
        else {
            spincal.Name = sData.tafnitId;
        }

        spincal.Patient_Account__c = sfIdMap.get(sData.patientId);
        spincal.PayerFactor__c = sfIdMap.get(sData.insurerCode);
        spincal.statuscode__c = sData.status;
        spincal.Remarks__c = sData.notes;
        spincal.branchname__c = sfIdMap.get(sData.siteCode);
        spincal.tafnitID__c = sData.tafnitId;
        spincal.doctorID__c = sfIdMap.get(sData.doctorLicense);
        spincal.operationDateTime__c = DateTime.valueOf(sData.surgeryDateTime);
        
        switch on opCodes.size() {
            when 1 {
                spincal.Opercode__c = sfIdMap.get(opCodes[0]);
            }
            when 2 {
                spincal.Opercode__c = sfIdMap.get(opCodes[0]);
                spincal.Opercode2__c = sfIdMap.get(opCodes[1]);
            }
            when 3 {
                spincal.Opercode__c = sfIdMap.get(opCodes[0]);
                spincal.Opercode2__c = sfIdMap.get(opCodes[1]);
                spincal.Opercode3__c = sfIdMap.get(opCodes[2]);
            }
            when 4 {
                spincal.Opercode__c = sfIdMap.get(opCodes[0]);
                spincal.Opercode2__c = sfIdMap.get(opCodes[1]);
                spincal.Opercode3__c = sfIdMap.get(opCodes[2]);
                spincal.Opercode4__c = sfIdMap.get(opCodes[3]);
            }
        }

        upsert spincal;
        return spincal;
    }

    public Referral_from_doctor_website__c upsertReferral(List<String> opCodes) {
        Referral_from_doctor_website__c referral = new Referral_from_doctor_website__c();

        if (sfIdMap.containsKey(rData.refNumber)) {
            referral.Id = sfIdMap.get(rData.refNumber);
        }
        else {
            referral.Name = rData.refNumber;
            referral.Referral_Code__c = rData.refNumber;
        }

        referral.Patient_Account__c = sfIdMap.get(rData.patientId);
        referral.Doctor_Account__c = sfIdMap.get(rData.doctorLicense);
        referral.Date_Time_Surgery__c = DateTime.valueOf(rData.surgeryDateTime);
        referral.Physical_Check__c = rData.physicalCheck;
        referral.Findings__c = rData.findings;
        referral.Medications__c = rData.medications;
        referral.Remarks__c = rData.remarks;
        referral.Allergies__c = rData.allergies;
        referral.Background_Disease__c = rData.backgroundIllnesses;
        referral.Anamnesis__c = rData.anamnesis;
        referral.ICU__c = rData.needEmergencyTreatment;
        referral.Anesthesia_Type__c = rData.anesthesiaType;
        referral.Hospitalization__c = rData.hospType;
        referral.Status__c = rData.status;
        referral.Status_update_date__c = Date.valueOf(rData.statusDate);
        referral.PayerFactor__c = sfIdMap.get(rData.insurerCode);
        referral.Site__c = sfIdMap.get(rData.siteCode);
        referral.Pathologist__c = rData.pathologist;
        referral.Radiologist__c = rData.radiologist;
        referral.Payment_needed__c = rData.isFeeRequired;
        referral.Payment_for_surgeon__c = rData.surgeonFee;

        if(rData.homeRehabilitation != null) {
            referral.Home_Rehabilitation__c = rData.homeRehabilitation;
            if(rData.homeRehabilitationDate != null){
                 referral.Home_Rehabilitation_Time_Approval__c = Datetime.valueOf(rData.homeRehabilitationDate);
            }
        }
  
        referral.Department_Code__c = rData.depCode;
        referral.Phone_Home__c = rData.homePhone;
        referral.Mobile_Phone__c = rData.mobilePhone;
        referral.pre_surgery_required__c = rData.IsPreSurgery;
        referral.MainComplaint__c = rData.mainComplaint;
        referral.IsCovid19__c = rData.isCovid19;
        if(rData.hadBloodTestsLastThreeM != null) { // new 2147484784
            referral.HadBloodTestsLastThreeMonths__c = rData.hadBloodTestsLastThreeM;
        }
        if(referral.SensitivityToIodine__c != null) { // new 2147484784
            referral.SensitivityToIodine__c = rData.sensitivityToIodine;
        }
        if(referral.PreparationInstructionsProvided__c != null){ // new 2147484784
            referral.PreparationInstructionsProvided__c = rData.preparationInst;
        }
        if(referral.TakingBloodThinners__c != null){ // new 2147484784
            referral.TakingBloodThinners__c = rData.takingBloodThinners;
        }
        if(referral.ContinuedTreatmentInstructionsProvided__c != null){ // new 2147484784 
           referral.ContinuedTreatmentInstructionsProvided__c = rData.continuedTreatmentInst;
        }
        if(referral.KidneyProblem__c != null){ // new 2147484784
            referral.KidneyProblem__c = rData.kidneyProblem;
        }        
        referral.TypeOfBloodThinner__c = rData.typeOfBloodThinner; // new 2147484784
        
        if(rData.surgerySource != null){ //new 20.05.26
            referral.Surgery_Source__c = rData.surgerySource;
        } 

        switch on opCodes.size() {
            when 1 {
                referral.Medical_Procedure_1__c = sfIdMap.get(opCodes[0]);
            }
            when 2 {
                referral.Medical_Procedure_1__c = sfIdMap.get(opCodes[0]);
                referral.Medical_Procedure_2__c = sfIdMap.get(opCodes[1]);
            }
            when 3 {
                referral.Medical_Procedure_1__c = sfIdMap.get(opCodes[0]);
                referral.Medical_Procedure_2__c = sfIdMap.get(opCodes[1]);
                referral.Medical_Procedure_3__c = sfIdMap.get(opCodes[2]);
            }
            when 4 {
                referral.Medical_Procedure_1__c = sfIdMap.get(opCodes[0]);
                referral.Medical_Procedure_2__c = sfIdMap.get(opCodes[1]);
                referral.Medical_Procedure_3__c = sfIdMap.get(opCodes[2]);
                referral.Medical_Procedure_4__c = sfIdMap.get(opCodes[3]);
            }
        }

        if(rData.surgeries != NULL && !rData.surgeries.isEmpty()){
            if(rData.surgeries.size() >= 1){
                referral.Side_1__c = rData.surgeries[0].surgerySide;
                referral.Organ_1__c = rData.surgeries[0].organ;
                referral.LensName1__c = rData.surgeries[0].lensName;
                referral.LensType1__c = rData.surgeries[0].lensType;
            }  
            if(rData.surgeries.size() >= 2){
                referral.Side_2__c = rData.surgeries[1].surgerySide;
                referral.Organ_2__c = rData.surgeries[1].organ;
                referral.LensName2__c = rData.surgeries[1].lensName;
                referral.LensType2__c = rData.surgeries[1].lensType;
            }  
            if(rData.surgeries.size() >= 3){
                referral.Side_3__c = rData.surgeries[2].surgerySide;
                referral.Organ_3__c = rData.surgeries[2].organ;
                referral.LensName3__c = rData.surgeries[2].lensName;
                referral.LensType3__c = rData.surgeries[2].lensType;
            } 
            if(rData.surgeries.size() == 4){
                referral.Side_4__c = rData.surgeries[3].surgerySide;
                referral.Organ_4__c = rData.surgeries[3].organ;
                referral.LensName4__c = rData.surgeries[3].lensName;
                referral.LensType4__c = rData.surgeries[3].lensType;
            }
        }

        if(!String.isBlank(rData.resources)) {
            List<String> resources = rData.resources.split(',');
            referral.Resources_for_surgery__c = String.join(resources, ';');
        }

        upsert referral;
        return referral;
    }
}