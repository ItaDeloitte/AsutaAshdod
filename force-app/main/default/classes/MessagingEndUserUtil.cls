public class MessagingEndUserUtil {    

    public static String validPhoneNumber(String phoneNumber) {
        if (phoneNumber.mid(3,1) == '-') {
            return  '972' + phoneNumber.mid(1, 2) + phoneNumber.right(7);
        }          
        return '972' + phoneNumber.right(9);
    }

    public static List<MessagingChannel> getMessagingChannel() {
        return [SELECT Id, 
                       DeveloperName 
                 FROM MessagingChannel 
                WHERE DeveloperName = 'Assuta_Enhanced_Bot']; 
    }

    public static List<MessagingEndUser> getMessagingEndUser(Id channelId, List<String> phoneNumbers) {
        return [SELECT Id
                    , AccountId
                    , MessageType 
                    , MessagingChannelId
                    , MessagingPlatformKey                                                                                                
                 FROM MessagingEndUser 
                WHERE MessageType = 'WhatsApp'                
                AND MessagingChannelId = : channelId
                AND MessagingPlatformKey IN : phoneNumbers];
    }

    public static MessagingEndUser createMessagingEndUser(Id channelId, Id accountId, String phoneNumber)  {
        return new MessagingEndUser (
            MessagingConsentStatus = 'ImplicitlyOptedIn',
            Name = phoneNumber,
            AccountId  = accountId,
            MessageType = 'WhatsApp',
            MessagingChannelId = channelId, 
            MessagingPlatformKey = phoneNumber   
        );
    }       
}