public class PicklistUtil {

    public static Map<String, PicklistValue> buildPicklistMapping(String sObjectName, String picklistFieldAPIName) {
        Map<String, PicklistValue> picklistMap = new Map<String, PicklistValue>();
        for (PicklistValue entry_i : buildPickListOptionsBySchema(sObjectName, picklistFieldAPIName, false)) {
            picklistMap.put(entry_i.value, entry_i);
        }
        return picklistMap;
    }

    public static List<PicklistValue> buildPickListOptionsBySchema(String sObjectName, String picklistFieldAPIName, Boolean addEmptyValue) {
        return buildPickListOptionsBySchema(sObjectName, picklistFieldAPIName, new Set<String>(), addEmptyValue);
    }

    public static List<PicklistValue> buildPickListOptionsBySchema(String sObjectName, String picklistFieldAPIName, Set<String> exceptionValueSet, Boolean addEmptyValue) {
        List<PicklistValue> pickList = new List<PicklistValue>();

        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        if (fieldMap.containsKey(picklistFieldAPIName.toLowerCase())) {
            Schema.DescribeFieldResult fieldResult = fieldMap.get(picklistFieldAPIName.toLowerCase()).getDescribe();
            List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

            if (addEmptyValue) {
                pickList.add(new PicklistValue('--None--', ''));
            }

            if (!picklistValueList.isEmpty()) {
                for (Schema.PicklistEntry picklistEntry_i : picklistValueList) {
                    if (!exceptionValueSet.contains(picklistEntry_i.getValue())) {
                        pickList.add(new PicklistValue(picklistEntry_i.getLabel(), picklistEntry_i.getValue()));
                    }
                }
            }
        }

        return pickList;
    }

    public static Map<String, List<PicklistValue>> buildDependedPicklistSchema(String sObjectName, String parentFieldApiName, String childFieldApiName){
        Map<String, List<PicklistValue>> dependedMap = new Map<String, List<PicklistValue>>();

        Map<String, PicklistValue> valueToObjectMap = new Map<String, PicklistValue>();
        for (PicklistValue util_i : buildPickListOptionsBySchema(sObjectName, childFieldApiName, false)) {
           valueToObjectMap.put(util_i.value, util_i);
        }

        Map<String, List<String>> notConvertedDependedMap = TStringUtils.GetDependentOptions2(sObjectName, parentFieldApiName, childFieldApiName);
        for (String key_i : notConvertedDependedMap.keySet()) {
            dependedMap.put(key_i, new List <PicklistValue> ());
            for (String value_i : notConvertedDependedMap.get(key_i)) {
                dependedMap.get(key_i).add(valueToObjectMap.get(value_i));
            }
        }

        return dependedMap;
    }
    
    public class PicklistValue {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}

        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}