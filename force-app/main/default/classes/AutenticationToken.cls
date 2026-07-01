public with sharing class AutenticationToken {

        // UserToken Class
        public class UsernameToken {
            // Constructor for UsernameToken used to pass in username and password parameters
            public UsernameToken(String username, String password){
                this.Username = username;
                this.Password = password;
                this.Nonce = generateNounce();
                this.Created = generateTimestamp();
            }

            public String Username;
            public String Password;
            public String Nonce;
            public String Created;
            private String[] Username_type_info = new String[]{'wsse:Username','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] Password_type_info = new String[]{'wsse:Password','Type=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText','string','0','1','false'};
            private String[] Nonce_type_info = new String[]{'wsse:Nonce','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
            private String[] Created_type_info = new String[]{'wsu:Created','EncodingType=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary','string','0','1','false'};        
            private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
            private String[] field_order_type_info = new String[]{'Username','Password', 'Nonce','Created'};


            // Generate Nounce, random number base64 encoded
            public String generateNounce(){
                Long randomLong = Crypto.getRandomLong();
                return EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
            }

            // Generate timestamp in GMT
            public String generateTimestamp(){
                return Datetime.now().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
            
        }

        // SecurityHeaderType Class
        public class SecurityHeaderType {

            // Constructor for SecurityHeaderType used to pass in username and password parameters and instantiate the UsernameToken object     
            public SecurityHeaderType(String username, String password){

                this.UsernameToken = new AutenticationToken.UsernameToken(username, password);
            }

            public String wsuNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'; 
            public String wsseNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';              
            public AutenticationToken.UsernameToken UsernameToken;
            private String[] UsernameToken_type_info = new String[]{'wsse:UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','UsernameToken','1','1','false'};
            private String[] wsuNamespace_att_info = new String[]{'xmlns:wsu'};     
            private String[] wsseNamespace_att_info = new String[]{'xmlns:wsse'};     
                   
            private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
            private String[] field_order_type_info = new String[]{'UsernameToken'};
        }

}