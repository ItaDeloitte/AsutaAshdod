public with sharing class StatusTizkuritRequest {
    
    public StatusTizkuritRequest() {}
    
    public String methodName; 
    public Record[] Records;

    class Record{
        public String AccessionNumber;    
        public String FollowUpTypeCode; 
    }
    public static StatusTizkuritRequest parse(String json){
        return (StatusTizkuritRequest) System.JSON.deserialize(json, StatusTizkuritRequest.class);
    }    
}