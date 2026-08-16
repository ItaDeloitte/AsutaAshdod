@isTest
public class IdentificationBotChatTest {

    
  static TestMethod void getRandomNumberTest(){

    IdentificationBotChat.RandomNumberOutput outputParameter = new IdentificationBotChat.RandomNumberOutput();
    test.startTest();
      List<IdentificationBotChat.RandomNumberOutput> outputParameters = IdentificationBotChat.getRandomNumner();
    test.stopTest();
    System.assert(outputParameters.size() > 0);
  }


}