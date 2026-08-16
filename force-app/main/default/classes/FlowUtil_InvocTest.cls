@isTest
public with sharing class FlowUtil_InvocTest {

    @IsTest
    static void testInvoke_WithIds() {
        // Arrange
        FlowUtil_Invoc.FlowInputs input = new FlowUtil_Invoc.FlowInputs();
        input.isIds = true;
        input.idsStr = '001000000000001;001000000000002';

        List<FlowUtil_Invoc.FlowInputs> inputs = 
            new List<FlowUtil_Invoc.FlowInputs>{ input };

        // Act
        Test.startTest();
        List<FlowUtil_Invoc.FlowOutputs> results = FlowUtil_Invoc.invoke(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'One output should be returned');
        System.assertNotEquals(null, results[0].ids, 'Ids list should not be null');
        System.assertEquals(2, results[0].ids.size(), 'Ids list should contain 2 values');
        System.assertEquals('001000000000001', results[0].ids[0]);
        System.assertEquals('001000000000002', results[0].ids[1]);
    }

    @IsTest
    static void testInvoke_WithoutIds() {
        // Arrange
        FlowUtil_Invoc.FlowInputs input = new FlowUtil_Invoc.FlowInputs();
        input.isIds = false;
        input.idsStr = 'shouldNotMatter';

        List<FlowUtil_Invoc.FlowInputs> inputs = 
            new List<FlowUtil_Invoc.FlowInputs>{ input };

        // Act
        Test.startTest();
        List<FlowUtil_Invoc.FlowOutputs> results = FlowUtil_Invoc.invoke(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals(null, results[0].ids, 'Ids should be null when isIds = false');
    }

    @IsTest
    static void testInvoke_ExceptionPath() {
        // Arrange
        FlowUtil_Invoc.FlowInputs input = new FlowUtil_Invoc.FlowInputs();
        input.isIds = true;
        input.idsStr = null; // Will cause NullPointerException on split()

        List<FlowUtil_Invoc.FlowInputs> inputs = 
            new List<FlowUtil_Invoc.FlowInputs>{ input };

        // Act
        Test.startTest();
        List<FlowUtil_Invoc.FlowOutputs> results = FlowUtil_Invoc.invoke(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccsess);
        System.assertNotEquals(null, results[0].errorMessage);
    }
}