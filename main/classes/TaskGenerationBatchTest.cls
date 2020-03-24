/*
* @author:		Jerson Poblete
* @date:		24.MAR.2020
* @description: Test class for TaskGenerationBatch
*/ 
@isTest
public class TaskGenerationBatchTest {
    @isTest 
    public static void testTaskGenerationBatch() {   
        List<Task> tasks = new List<Task>();
        List<Task> newtasks = new List<Task>();
        List<TaskMatrix__mdt> tasjMatrixList = [SELECT DeveloperName, WeekNum__c, Topic__c, Task_Name__c, Task_Description__c FROM TaskMatrix__mdt WHERE WeekNum__c = 2]; //week 2 task
        List<String> specialProgrammTasks = new List<String>();
        Id specialAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Special Programme Shop').getRecordTypeId();
        Account acc = new Account(Name = 'Acc1', RecordTypeId = specialAccRecordTypeId);
        insert acc;
        
        for(Task tsk : [SELECT Id, Status, Subject FROM Task WHERE WhatId =: acc.Id]){
            if(tsk.Subject != 'Seller Profiling'){
                tsk.Status = 'Completed';
                tasks.add(tsk);
            }
        }
        update tasks;
        Test.startTest();
        TaskGenerationBatch obj = new TaskGenerationBatch();
        DataBase.executeBatch(obj);             
        Test.stopTest();
        
        for(TaskMatrix__mdt tm : tasjMatrixList){
            specialProgrammTasks.add(tm.Task_Name__c);
        }        
        newtasks = [SELECT Id, Subject, Description, WhatId FROM Task WHERE WhatId =: acc.Id AND Subject in: specialProgrammTasks];
        System.assertEquals(2, tasks.size());
    }
}