global class GuidlinesWrapper {

    private static final Map<String, String> RELATIONSHIP_MAP = new Map<String, String>{
        'Guideline1_Sort_Order__c' => 'Guideline1__r',
        'Guideline2_Sort_Order__c' => 'Guideline2__r',
        'Guideline3_Sort_Order__c' => 'Guideline3__r',
        'Guideline4_Sort_Order__c' => 'Guideline4__r',
        'Guideline5_Sort_Order__c' => 'Guideline5__r',
        'Guideline6_Sort_Order__c' => 'Guideline6__r',
        'Guideline7_Sort_Order__c' => 'Guideline7__r',
        'Guideline8_Sort_Order__c' => 'Guideline8__r',
        'Guideline9_Sort_Order__c' => 'Guideline9__r',
        'Guideline10_Sort_Order__c' => 'Guideline10__r',
        'Guideline11_Sort_Order__c' => 'Guideline11__r',
        'Guideline12_Sort_Order__c' => 'Guideline12__r',
        'Guideline13_Sort_Order__c' => 'Guideline13__r',
        'Guideline14_Sort_Order__c' => 'Guideline14__r',
        'Guideline15_Sort_Order__c' => 'Guideline15__r',
        'Guideline16_Sort_Order__c' => 'Guideline16__r',
        'Guideline17_Sort_Order__c' => 'Guideline17__r',
        'Guideline18_Sort_Order__c' => 'Guideline18__r',
        'Guideline19_Sort_Order__c' => 'Guideline19__r',
        'Guideline20_Sort_Order__c' => 'Guideline20__r',
        'Guideline21_Sort_Order__c' => 'Guideline21__r',
        'Guideline22_Sort_Order__c' => 'Guideline22__r',
        'Guideline23_Sort_Order__c' => 'Guideline23__r'
    };

    public class ScenarioWrp {
        public String id;
        public String gender;
        public String protocol;
        public String siteId;
        public String procedureId;
        public String ageRange;
        public Decimal minAge;
        public Decimal maxAge;
        public Boolean isAsthma;
        public Boolean isDiabetes;
        public Boolean isThinBlood;
        public Boolean isBodyMetals;
        public Boolean isIodineSensitive;
        public List<String> pfList;
        public List<GuidelineWrp> guidelineList;

        public ScenarioWrp(Guidance_Scenario__c scenario) {
            this.id = scenario.Id;
            this.gender = scenario.Gender__c;
            this.protocol = scenario.Protocol__c;
            this.siteId = scenario.Site__c;
            this.procedureId = scenario.Medical_Procedure__c;
            this.ageRange = scenario.Age_Range__c;
            this.isAsthma = scenario.Asthma__c;
            this.isDiabetes = scenario.Diabetes__c;
            this.isBodyMetals = scenario.MetalsInBody__c;
            this.isThinBlood = scenario.Blood_Dilution__c;
            this.isIodineSensitive = scenario.Iodine_Sensitive__c;
            this.pfList = scenario.Payer_Factor__c != null
                ? scenario.Payer_Factor__c.split(';')
                : new List<String>();

            this.sortGuidelineList(scenario);
            this.processAgeRange();
        }

        public String getGuidelineMessage() {
            String guidelineMessage = '';
            List<String> admMessageList = new List<String>();
            List<String> medMessageList = new List<String>();

            for (GuidelineWrp guideline_i : this.guidelineList) {
                (guideline_i.type == 'A' ? admMessageList : medMessageList).add(guideline_i.message);
            }

            if (!medMessageList.isEmpty()) {
                guidelineMessage += '<div dir="rtl"><br><p style="display: inline-block; font-weight: bold;">הנחיות רפואיות:</p><br></div>';
                guidelineMessage += String.join(medMessageList, '');
            }

            if (!admMessageList.isEmpty()) {
                guidelineMessage += '<div dir="rtl"><p style="display: inline-block; font-weight: bold;">הנחיות אדמיניסטרטיביות:</p><br></div>';
                guidelineMessage += String.join(admMessageList, '');
            }

            return guidelineMessage;
        }

        private void processAgeRange() {
            if (this.ageRange != null) {
                List<String> ageRangeList = this.ageRange.split('-');
                this.minAge = Decimal.valueOf(ageRangeList.get(0));
                this.maxAge = Decimal.valueOf(ageRangeList.get(1));
            }
        }

        private void sortGuidelineList(Guidance_Scenario__c scenario) {
            this.guidelineList = new List<GuidelineWrp>();

            for (String index_i : RELATIONSHIP_MAP.keySet()) {
                Guidelines__c guidline_i = (Guidelines__c) scenario.getSObject(RELATIONSHIP_MAP.get(index_i));

                if (guidline_i != null) {
                    this.guidelineList.add(new GuidelineWrp(Integer.valueOf(scenario.get(index_i)), guidline_i));
                }
            }

            this.guidelineList.sort();
        }
    }

    public class GuidelineWrp implements Comparable {
        public String id;
        public String type;
        public String message;
        public Integer index;

        public GuidelineWrp(Integer index, Guidelines__c guideline) {
            this.index = index;
            this.id = guideline.Id;
            this.type = guideline.Guideline_Type__c;
            this.message = '<div dir="rtl"><ul><li>' + guideline.Guideline_Desc__c + '</li></ul></div>';
        }

        public Integer compareTo(Object compareTo) {
            GuidelineWrp that = (GuidelineWrp) compareTo;

            if ((this.index != null && that.index == null) || this.index < that.index) {
                return -1;
            }
            if ((this.index == null && that.index != null) || this.index > that.index) {
                return 1;
            }
            return 0;
        }
    }
}