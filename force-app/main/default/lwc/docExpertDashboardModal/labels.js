//@ts-nocheck
import NumbersOfDoctorsFound from '@salesforce/label/c.Number_of_Doctors_found';
import DoctorsNotFound from '@salesforce/label/c.DoctorsNotFound';
import OnlyExperts from '@salesforce/label/c.Only_experts';
import Operated2Times from '@salesforce/label/c.Operated_2_times';
import Gender from '@salesforce/label/c.DocGender';
import DoctorDegree from '@salesforce/label/c.DoctorDegree';
import MedicalProcedure from '@salesforce/label/c.DocMedicalProcedure';
import MedicalProcedureHelpText from '@salesforce/label/c.Up_to_3_procedures_messaxe';
import Agreements from '@salesforce/label/c.Agreements';
import Arrangements from '@salesforce/label/c.Arrangments';
import Area from '@salesforce/label/c.DocArea';
import Expertise from '@salesforce/label/c.DocExpertise';
import SubExpertise from '@salesforce/label/c.DocSubExpertise';
import Site from '@salesforce/label/c.Site';
import SortBy from '@salesforce/label/c.DocSortBy';
import SortByQuantity from '@salesforce/label/c.DocQuantity';
import SortByArrangement from '@salesforce/label/c.DocArrangement';
import None from '@salesforce/label/c.None';
import All from '@salesforce/label/c.All';
import Search from '@salesforce/label/c.Search';
import Reset from '@salesforce/label/c.Reset';
import SendDocAdv from '@salesforce/label/c.DocSendDocAdv';
import Save from '@salesforce/label/c.DocSave';
import DoctorSelectedMessage from '@salesforce/label/c.DocSelected';
import Doctor from '@salesforce/label/c.DocExpertDashboard_Doctor';
import SearchByDoctorName from '@salesforce/label/c.DocExpertDashboard_SearchByDoctorName';
import SearchByExpertise from '@salesforce/label/c.DocExpertDashboard_SearchByExpertise';
import SearchByComingWeek from '@salesforce/label/c.DocExpertDashboard_SearchByComingWeek';

export const labels = {
  Filter_OnlyExperts: OnlyExperts,
  Filter_Operated2Times: Operated2Times,
  Filter_Gender: Gender,
  Filter_DoctorDegree: DoctorDegree,
  Filter_MedicalProcedureHelpText: MedicalProcedureHelpText,
  Filter_Arrangement: Arrangements,
  Filter_Agreement: Agreements,
  Filter_Site: Site,

  SortBy,
  SortByNone: None,
  SortByQuantity,
  SortByArrangement,

  Search,
  Reset,

  Expertise,
  SubExpertise,
  MedicalProcedure,
  Agreements,
  Arrangements,
  Area,
  Sites: Site,

  SearchPlaceholder: Search,
  Save,
  SendDocAdv,
  AllPlaceholder: All,
  DoctorSelectedMessage,
  NumbersOfDoctorsFound,
  DoctorsNotFound,

  Doctor,
  SearchByDoctorName,
  SearchByExpertise,
  SearchByComingWeek
};