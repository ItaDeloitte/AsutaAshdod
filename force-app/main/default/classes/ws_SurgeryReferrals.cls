/*
* @author         Yoni Drutin   <ydrutin@deloitte.co.il>
* @modifiedBy
* @version        1.0
* @created        30-05-2019
* @modified       DD-MM-YYYY
* @see
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is responsible for receiving Spincal (surgery room reservation) and surgery referrals
* and sending them to ws_SurgeryReferralsService for further processing.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global with sharing class ws_SurgeryReferrals {

    global class spincalData {
        webservice String patientId;
        webservice String idType;
        webservice String fName;
        webservice String lName;
        webservice String email;
        webservice String mainPhone;
        webservice String otherPhone;
        webservice String birthDate;
        webservice String gender;
        webservice String insurerCode;
        webservice String insurerName;
        webservice String status;
        webservice String medicalOp1;
        webservice String medicalOp1Name;
        webservice String medicalOp2;
        webservice String medicalOp2Name;
        webservice String medicalOp3;
        webservice String medicalOp3Name;
        webservice String medicalOp4;
        webservice String medicalOp4Name;
        webservice String notes;
        webservice String siteCode;
        webservice String siteName;
        webservice String tafnitId;
        webservice String doctorId;
        webservice String doctorLicense;
        webservice String surgeryDateTime;
    }

    global class referralData {
        webservice String patientId;
        webservice String idType;
        webservice String fName;
        webservice String lName;
        webservice String birthDate;
        webservice String doctorLicense;
        webservice String homePhone;
        webservice String mobilePhone;
        webservice String workPhone;
        webservice String surgeryDateTime;
        webservice String physicalCheck;
        webservice String findings;
        webservice String refNumber;
        webservice String medications;
        webservice String remarks;
        webservice String allergies;
        webservice String backgroundIllnesses;
        webservice String anamnesis;
        webservice Boolean needEmergencyTreatment;
        webservice String gender;
        webservice String anesthesiaType;
        webservice String hospType;
        webservice String status;
        webservice String statusDate;
        webservice String insurerCode;
        webservice String resources;
        webservice String medicalOp1;
        webservice String medicalOp2;
        webservice String medicalOp3;
        webservice String medicalOp4;
        webservice String siteCode;
        webservice String HMO;
        webservice Boolean pathologist;
        webservice Boolean radiologist;
        webservice List<surgery> surgeries;
        webservice Boolean isFeeRequired;
        webservice double surgeonFee;
        webservice Boolean homeRehabilitation ;
        webservice String homeRehabilitationDate;
        webservice String depCode;
        webservice Boolean IsPreSurgery;
        webservice String mainComplaint;
        webservice String isCovid19;
        webservice Boolean hadBloodTestsLastThreeM;
        webservice Boolean sensitivityToIodine;
        webservice Boolean preparationInst;
        webservice Boolean takingBloodThinners;
        webservice Boolean continuedTreatmentInst;
        webservice Boolean kidneyProblem;
        webservice String typeOfBloodThinner;
        webservice String surgerySource;
    }

    global class surgery {
        webservice String surgeryCode;
        webservice String surgeryName;
        webservice String surgerySide;
        webservice String organ;
        webservice String lensName;
        webservice String lensType;
    }

    webservice static GeneralResponse getSpinkleData(spincalData sData) {
        ws_SurgeryReferralsService service = new ws_SurgeryReferralsService(sData);
        return service.processData();
    }

    webservice static GeneralResponse getDoctorReferralData(referralData rData) {
        ws_SurgeryReferralsService service = new ws_SurgeryReferralsService(rData);
        return service.processData();
    }
}