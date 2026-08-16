public without sharing class LiveAgentChatUtil {

    public final static String baseEndpoint = 'https://4cv.la1-c2cs-lo2.salesforceliveagent.com/chat/rest';
    public final static String apiVersion = '46';
    
    // utilites for make calloues
    public static String doGet(String enpoint, Map <String, String> headers){
        HttpRequest req = new HttpRequest();   
        Http h = new Http();  
        
        req.setEndPoint(enpoint); 
        System.debug('GET enpoint '+enpoint);
        req.setMethod('GET');
        req.setTimeout(120000);
        for (String key : headers.keySet()){
            //System.debug('header '+key+' value '+headers.get(key));
            req.setHeader(key, headers.get(key));
        }
        
        HttpResponse res = h.send(req);
        String responseBody = res.getBody();
        System.debug('responseBody '+responseBody);
        return responseBody;
    }

    public static String doPost(String enpoint, Map <String, String> headers, String jsonedBody){
        HttpRequest req = new HttpRequest();   
        Http h = new Http();  
        
        req.setEndPoint(enpoint); 
        System.debug('POST enpoint '+enpoint);
        req.setTimeout(120000);
        req.setMethod('POST');
        for (String key : headers.keySet()){
            //System.debug('header '+key+' value '+headers.get(key));
            if (!Test.isRunningTest()) {
            	req.setHeader(key, headers.get(key));
            }
        }
        
        req.setBody(jsonedBody);
        System.debug('jsonedBody '+jsonedBody);
        HttpResponse res = h.send(req);
        String responseBody = res.getBody();
        System.debug('responseBody '+responseBody);
        return responseBody;
    }

    // models 
    // session from login call 
    public class SessionWrapper {
        public String key {get;set;}
        public Integer clientPollTimeout {get;set;}
        public String affinityToken {get;set;}
        public String id {get;set;}
    }
    // request to init chat
    public class ChatInitRequestWrapper {
        public String organizationId {get;set;}
        public String deploymentId {get;set;}
        public String buttonId {get;set;}
        public String sessionId {get;set;}
        public String trackingId {get;set;}
        public String userAgent {get;set;}
        public String language {get;set;}
        public String screenResolution {get;set;}
        public String visitorName {get;set;}
        public Boolean receiveQueueUpdates {get;set;}
        public Boolean isPost {get;set;}

        public List <PrechatDetailsWrapper> prechatDetails {get;set;}
        public List <PrechatEntitiesWrapper> prechatEntities {get;set;}

        public ChatInitRequestWrapper(String visitorName){
            // some peace of hardcode in constructor
            this.buttonId = '5738E00000000aw';
            this.deploymentId = '5728E00000000Pq'; 
            this.organizationId = '00D8E0000000ot9';
            this.trackingId = '';
            this.language = 'ru';
            this.screenResolution = '1920x1080';
            this.visitorName = visitorName;
            this.userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36';
            this.isPost = true;
            this.receiveQueueUpdates = true;

            this.prechatDetails = new List <PrechatDetailsWrapper> ();
            this.prechatEntities = new List <PrechatEntitiesWrapper> ();
        }

      
    }

    public class PrechatDetailsWrapper {
        public String label {get;set;}
        public String value {get;set;}
        public Boolean displayToAgent {get;set;}
        public Boolean doKnowledgeSearch {get;set;}
        public List <String> entityMaps {get;set;}
        public List <String> transcriptFields {get;set;}
    }    

    public class PrechatEntitiesWrapper {
        public String entityName {get;set;}
        public String linkToEntityName {get;set;}
        public String linkToEntityField {get;set;}
        public String saveToTranscript {get;set;}
        public Boolean showOnCreate {get;set;}
        
        public List <EntityFieldsMapWrapper> entityFieldsMaps {get;set;}  
    }

    public class EntityFieldsMapWrapper {
        public String fieldName {get;set;}
        public String label {get;set;}
        public Boolean doFind {get;set;}
        public Boolean doCreate {get;set;}
        public Boolean isExactMatch {get;set;}
    }

    // incomming message from agent to client
    //{"messages":[{"type":"ChatMessage", "message":{"text":"hello","name":"Anatoly","schedule":{"responseDelayMilliseconds":0.0},"agentId":"0058E000004B14r"}}], "sequence":6, "offset":49343374}
    // "type":"ChatMessage" or "AgentTyping" or "AgentNotTyping" or "ChatRequestSuccess"
    public class IncommingMessagesWrapper {
        public List <IncommingMessageWrapper> messages {get;set;}
        public Integer sequence {get;set;}
        public Long offset {get;set;}
    }

    public class IncommingMessageWrapper {
        public String type {get;set;}
        public MessageWrapper message {get;set;}
    }

    public class MessageWrapper {
        public string text {get;set;}
        public string name {get;set;}
        public string agentId {get;set;}
    }

    // message from client to agent
    //{"text":"test"}
    public class OutGoingMessageWrapper {
        public string text {get;set;}

        public OutGoingMessageWrapper(String message){
            this.text = message;
        }
    }

    public static SessionWrapper createSession(){
        String jsonedSession = doGet(baseEndpoint + '/System/SessionId?SessionId.ClientType=snapins',
                                    new Map <String, String> {'X-LIVEAGENT-API-VERSION' => apiVersion, 
                                                              'X-LIVEAGENT-AFFINITY' => 'null'});
        return (SessionWrapper) JSON.deserialize(jsonedSession, SessionWrapper.class);
    }
      // OK or Error
    public static String startSession(SessionWrapper session, String customerName){
        String response = doPost(baseEndpoint + '/Chasitor/ChasitorInit', 
                                 new Map <String, String> { 'X-LIVEAGENT-API-VERSION' => apiVersion, 
                                                            'X-LIVEAGENT-AFFINITY' => session.affinityToken,
                                                            'X-LIVEAGENT-SEQUENCE' => '1' ,
                                                            'X-LIVEAGENT-SESSION-KEY' => session.key},
                                JSON.serialize(new ChatInitRequestWrapper(customerName)));
        return response;
    }

      // OK or Error
    public static String sendNewMessageToAgent(SessionWrapper session, String messageText, Integer sequence){
        System.debug('sequence '+sequence);
        String response = doPost(baseEndpoint + '/Chasitor/ChatMessage',
                                new Map <String, String> { 'X-LIVEAGENT-API-VERSION' => apiVersion, 
                                                        'X-LIVEAGENT-AFFINITY' => session.affinityToken,
                                                        'X-LIVEAGENT-SEQUENCE' => String.valueOf(sequence),
                                                        'X-LIVEAGENT-SESSION-KEY' => session.key},
                                JSON.serialize(new OutGoingMessageWrapper(messageText)));
                              
        return response;
    }

    //message or null
    public static IncommingMessagesWrapper checkChanel(SessionWrapper session, Integer sequence, Integer orderNumber){
        String repsonse = doGet(baseEndpoint + '/System/Messages?ack='+sequence+'&pc=' + orderNumber, 
                                 new Map <String, String> { 'X-LIVEAGENT-API-VERSION' => apiVersion, 
                                                            'X-LIVEAGENT-AFFINITY' => session.affinityToken,
                                                            'X-LIVEAGENT-SESSION-KEY' => session.key});
        System.debug('repsonse '+repsonse);
        if (String.isBlank(repsonse)){
            return null;
        }
        return (IncommingMessagesWrapper) JSON.deserialize(repsonse, IncommingMessagesWrapper.class);
    }
}