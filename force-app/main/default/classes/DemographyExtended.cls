//Test:LC_DemographyTest, DemographyExtendedTest
public class DemographyExtended {

    // ── Request / Response DTOs ───────────────────────────────────────────

    public class PatientDemographicRequest {
        public String  PatientID;
        public Long    IdType;
        public Long    HMOCode;
        public String  BirthDate;
        public Long    SourceSysNo;
        public Boolean GetADdata;
    }

    public class PatientDemographicExtended {
        public Long   IsDemographyExist;
        public String PatientID;
        public String FirstName;
        public String LastName;
        public String PrimaryLanguage;
        public Long   IdType;
        public String CellNumber;
        public String HomeNumber;
        public String WorkNumber;
        public String Fax;
        public String Email;
        public Long   HMOCode;
        public String BirthDate;
        public String Gender;
        public AddressExtended                               Address;
        public Disabilities                                  Disabilities;
        public ArrayOfInfoSorceSystemInfoSorceSystem         InfoSorceSystems;
        public ArrayOfMemberInsuranceExtendedMemberInsuranceExtended MemberInsurances;
        public ResultMessge                                  ResultMessage;
        public String  IdentificationCode;
        public String  UserSecurityAreaLevel;
        public ArrayOfAdditionalHealthServiceItemLong        AdditionalHealthService;
        public Date    BeginMembership;
        public Boolean IsEligble;
    }

    public class AddressExtended {
        public String StateName;
        public String Street;
        public String HouseNumber;
        public String Apartment;
        public String CityCode;
        public String City;
        public String ZipCode;
    }

    public class Disabilities {
        public String Patient_Approve;
        public ArrayOfPatient_DisabilityPatient_Disability Patient_Disabilities;
        public ArrayOfPatient_AssistPatient_Assist         Patient_Assistance;
    }

    public class InfoSorceSystem {
        public String SorceSysCode;
        public String QueryStatus;
        public String ErrorMessage;
        public String ErrorCode;
    }

    public class ArrayOfInfoSorceSystemInfoSorceSystem {
        public DemographyExtended.InfoSorceSystem[] InfoSorceSystem;
    }

    public class MemberInsuranceExtended {
        public String IsInsuranceExist;
        public Date   StartDate;
        public Date   EndDate;
        public String Code;
        public String SickFundDesc;
    }

    public class ArrayOfMemberInsuranceExtendedMemberInsuranceExtended {
        public DemographyExtended.MemberInsuranceExtended[] MemberInsuranceExtended;
    }

    public class ResultMessge {
        public String  Status;
        public String  ErrorDescription;
        public Integer ErrorCode;
    }

    public class Patient_Disability {
        public String Dis_Code;
        public String Dis_Desc;
        public String Date_Of_Disability;
        public String Side_Code;
        public String Side_Desc;
        public String Permanence;
        public String Disability_Remark;
    }

    public class ArrayOfPatient_DisabilityPatient_Disability {
        public DemographyExtended.Patient_Disability[] Patient_Disability;
    }

    public class Patient_Assist {
        public String Assist_Code;
        public String Assist_Desc;
        public String Date_Of_Assist;
        public String Assist_Remark;
    }

    public class ArrayOfPatient_AssistPatient_Assist {
        public DemographyExtended.Patient_Assist[] Patient_Assist;
    }

    public class ArrayOfAdditionalHealthServiceItemLong {
        public Long[] AdditionalHealthServiceItem;
    }

    // ── Callout ───────────────────────────────────────────────────────────

    public class GetCombinedDemographySoap {

        public Integer timeout_x = 120000;

        public PatientDemographicExtended GetCombinedDemography(PatientDemographicRequest r) {
            ENV__c env = ENV__c.getInstance();

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Ensemble_AssutaMain_' + env.Env_value__c + '/Assuta.Demography.BS.DemographyExtended');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(r));
            req.setTimeout(timeout_x);

            HttpResponse res = new Http().send(req);
            return (PatientDemographicExtended) JSON.deserialize(res.getBody(), PatientDemographicExtended.class);
        }
    }
}
