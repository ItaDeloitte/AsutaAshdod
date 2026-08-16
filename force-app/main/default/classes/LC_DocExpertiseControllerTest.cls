/** Deprecated as of 30-11-2023 */
@IsTest
public class LC_DocExpertiseControllerTest {

    @TestSetup
    static void makeData() {}

    @IsTest
    static void exceptionTest() {
        try {
            Test.startTest();
            new LC_DocExpertiseController().executeAction(new Map<String, Object>{
                'actionName' => 'exception'
            });
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('UNKNOWN ACTION', e.getMessage());
        }
    }
}