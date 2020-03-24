/*
* @author:		Jerson Poblete
* @date:		24.MAR.2020
* @description: Test class for TopicAssignmentHelper
*/  
@isTest(seeAllData=true)
public class TopicAssignmentHelperTest {
    @isTest
    private static void testassignTopicToTask(){
        Id specialAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Special Programme Shop').getRecordTypeId();
        Account acc = new Account(Name = 'Special Account 1', RecordTypeId = specialAccRecordTypeId);
        List<TaskMatrix__mdt> tasjMatrixList = [SELECT Task_Name__c, Topic__c FROM TaskMatrix__mdt WHERE WeekNum__c = 1];
        List<String> specialProgrammTasks = new List<String>();
        for(TaskMatrix__mdt tm : tasjMatrixList){
            specialProgrammTasks.add(tm.Task_Name__c);         
        }            
        insert acc;
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId =: acc.Id AND Subject in: specialProgrammTasks];        
        List<TopicAssignment> topicAssignments = [Select Id, TopicId, EntityId FROM TopicAssignment WHERE EntityId in: tasks];        
        system.assertEquals(3, topicAssignments.size());        
    }
}