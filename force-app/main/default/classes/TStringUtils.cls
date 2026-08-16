public without sharing class TStringUtils {
	

	public class Bitset{
        public Map<String,Integer> AlphaNumCharCodes {get;set;}
        public Map<String, Integer> Base64CharCodes { get; set; }
        public Bitset(){
            LoadCharCodes();
        }
        //Method loads the char codes
        private void LoadCharCodes(){
            AlphaNumCharCodes = new Map<String,Integer>{
                '/'=>47,'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
            };
            Base64CharCodes = new Map<String, Integer>();
            //lower case
            Set<String> pUpperCase = AlphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
                Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //Base64CharCodes.put('+', 62);
            ///Base64CharCodes.put('/', 63);
            //numerics
            for (Integer i=0; i<=9; i++){
                AlphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                Base64CharCodes.put(string.valueOf(i), i + 52);
            }
        }
       
        public List<Integer>  validFor(String pValidFor) {
            // Target list
            List<Integer> ret = new List<Integer> ();
            
            // Start at offset 0
            Integer target = 0;
            
            // Process each character in order
            for(Integer i=0; i < pValidFor.length();i++){
                //get current character value
                Integer cur = (Base64CharCodes.get((pValidFor.Substring(i, i+1))));
                
                // 6 bits per character, starting at bit position 5
                for (Integer j = 0; j < 6; j++) {
                    // Is the current bit set?
                    if ((cur & 32) == 32) {
                        // Yes, this index is valid
                        ret.add(target);
                    }
                    // Shift the next bit into position
                    cur <<= 1;
                    
                    // Move to the next target index
                    target++;
                }
            }
            
            return ret;
        }
    }

    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public TPicklistEntry(){
            
        }
    }


    // Build a map of parents and their valid children (faster version)
    public static Map <String, List <String>> GetDependentOptions2(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map <String, List <String>> objResults = new Map <String, List <String>>();
        //Map<String, Map<String,Map<String,String>>> objResults = new Map<String, Map<String,Map<String,String>>>();
        // This list will hold the children during the build, and will be copied to the final map at the end
        List<List<String>> workingList = new List<List<String>>();
        
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        //List counts = new List();
        if (!objGlobalMap.containsKey(pObjName))
            return objResults;
        //get the type being dealt with
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
            return objResults;
        //get the control values
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        
        //iterate through the values and get the ones valid for the controlling field name
        Bitset objBitSet = new Bitset();
        
   
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
            workingList.add(new List<String>());
        }
        
        //check the dependent values
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){
            //get the pointer to the dependent index
            Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            //get the valid for
            String pEntryStructure = JSON.serialize(dep_entry);
            TPicklistEntry objDepPLE = (TPicklistEntry)JSON.deserialize(pEntryStructure, TPicklistEntry.class);
            //if valid for is empty, skip
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            
            List<Integer> valids = objBitSet.validFor(objDepPLE.validFor);
            for(Integer v : valids) {
                // As a safety valve, make sure we didn’t get an index out of range
                if (v < workingList.size()) {
                    workingList[v].add(objDepPLE.value);
                }
            }
        }
        objResults.put('', new List <String>());
        // Now populate the map
        for(Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++) {

            String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
            String pControllingValue = ctrl_ple[pControllingIndex].getValue();
            // System.debug('pControllingLabel '+pControllingLabel);
            if(!objResults.containsKey(pControllingValue)){
                objResults.put(pControllingValue, new List <String>() );
            }
            objResults.get(pControllingValue).addAll(workingList[pControllingIndex]);
        }
        return objResults;
    }
}