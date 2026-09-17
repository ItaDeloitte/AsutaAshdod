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

@RestResource(urlMapping='/SurgeryReferrals/*')
global with sharing class ws_SurgeryReferrals {

    global class spincalData {
        public String patientId;
        public String idType;
        public String fName;
        public String lName;
        public String email;
        public String mainPhone;
        public String otherPhone;
        public String birthDate;
        public String gender;
        public String insurerCode;
        public String insurerName;
        public String status;
        public String medicalOp1;
        public String medicalOp1Name;
        public String medicalOp2;
        public String medicalOp2Name;
        public String medicalOp3;
        public String medicalOp3Name;
        public String medicalOp4;
        public String medicalOp4Name;
        public String notes;
        public String siteCode;
        public String siteName;
        public String tafnitId;
        public String doctorId;
        public String doctorLicense;
        public String surgeryDateTime;
    }

    global class referralData {
        public String patientId;
        public String idType;
        public String fName;
        public String lName;
        public String birthDate;
        public String doctorLicense;
        public String homePhone;
        public String mobilePhone;
        public String workPhone;
        public String surgeryDateTime;
        public String physicalCheck;
        public String findings;
        public String refNumber;
        public String medications;
        public String remarks;
        public String allergies;
        public String backgroundIllnesses;
        public String anamnesis;
        public Boolean needEmergencyTreatment;
        public String gender;
        public String anesthesiaType;
        public String hospType;
        public String status;
        public String statusDate;
        public String insurerCode;
        public String resources;
        public String medicalOp1;
        public String medicalOp2;
        public String medicalOp3;
        public String medicalOp4;
        public String siteCode;
        public String HMO;
        public Boolean pathologist;
        public Boolean radiologist;
        public List<surgery> surgeries;
        public Boolean isFeeRequired;
        public Double surgeonFee;
        public Boolean homeRehabilitation;
        public String homeRehabilitationDate;
        public String depCode;
        public Boolean IsPreSurgery;
        public String mainComplaint;
        public String isCovid19;
        public Boolean hadBloodTestsLastThreeM;
        public Boolean sensitivityToIodine;
        public Boolean preparationInst;
        public Boolean takingBloodThinners;
        public Boolean continuedTreatmentInst;
        public Boolean kidneyProblem;
        public String typeOfBloodThinner;
        public String surgerySource;
    }

    global class surgery {
        public String surgeryCode;
        public String surgeryName;
        public String surgerySide;
        public String organ;
        public String lensName;
        public String lensType;
    }

    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String uri = req.requestURI;
        String body = req.requestBody != null ? req.requestBody.toString() : '';
        GeneralResponse result;
        try {
            if (uri.endsWith('/spincal')) {
                spincalData sData = (spincalData) JSON.deserialize(body, spincalData.class);
                result = new ws_SurgeryReferralsService(sData).processData();
            } else if (uri.endsWith('/referral')) {
                referralData rData = (referralData) JSON.deserialize(body, referralData.class);
                result = new ws_SurgeryReferralsService(rData).processData();
            } else {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"isSuccess":false,"message":"Unknown endpoint: ' + uri + '"}');
                return;
            }
        } catch (Exception e) {
            result = new GeneralResponse(false, e.getMessage());
        }
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(result));
    }
}
