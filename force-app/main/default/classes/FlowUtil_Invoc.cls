public with sharing class FlowUtil_Invoc {

    @InvocableMethod(label='Flow Util')
    public static List<FlowOutputs> invoke(List<FlowInputs> request){
        List<FlowUtil_Invoc.FlowOutputs> results = new List<FlowUtil_Invoc.FlowOutputs>();
        FlowOutputs res = new FlowOutputs();   
        try{     
            for(FlowInputs req : request){
                if(req.isIds){
                    res.ids = req.idsStr.split(';');
                }
                results.add(res);                
            }  
            return results;
        } catch(Exception e){
            res = generateErrorOutput(e.getMessage());
            results.add(res);
            return results;
        } 
    }

    private static FlowOutputs generateErrorOutput(String errorMsg){
        FlowOutputs res = new FlowOutputs();  
        res.isSuccsess = false;
        res.errorMessage = errorMsg;
        return res;
    }

    public class FlowInputs {
        @InvocableVariable(label='Is Id`s separator' description='If you want to get Id`s as List')
        public Boolean isIds;

        @InvocableVariable(label='Id`s separated with comma' description='Id`s separated with comma')
        public String idsStr;
    }

    public class FlowOutputs{
        @InvocableVariable
        public List<String> ids;

        @InvocableVariable
        public Boolean isSuccsess;      

        @InvocableVariable 
        public String errorMessage;
    }
}