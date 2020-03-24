/*
* @author:		Jerson Poblete
* @date:		24.MAR.2020
* @description: Test class for TaskGenerationBatchScheduler
*/ 
@isTest
public class TaskGenerationBatchSchedulerTest {
    @isTest
    public static void testTaskGenerationBatchScheduler() {
        Test.StartTest();
        TaskGenerationBatchScheduler sh = new TaskGenerationBatchScheduler();
        
        String sch = '0 0 0 * * ?'; 
        system.schedule('testTaskGenerationBatchScheduler', sch, sh); 
        Test.stopTest();
    }
}