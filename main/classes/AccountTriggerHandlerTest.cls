/*
* @author:		Jerson Poblete
* @date:		24.MAR.2020
* @description: Test class for AccountTriggerHandler
*/  
@isTest
public class AccountTriggerHandlerTest {
    @isTest
    private static void testCreateSpecialProgrammeTask(){
        Test.startTest();       
        Id specialAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Special Programme Shop').getRecordTypeId();
        Account acc = new Account(Name = 'Special Account 1', RecordTypeId = specialAccRecordTypeId);
        insert acc;        
        Test.stopTest();        
        List<TaskMatrix__mdt> tasjMatrixList = [SELECT DeveloperName, WeekNum__c, Topic__c, Task_Name__c, Task_Description__c FROM TaskMatrix__mdt WHERE WeekNum__c = 1];
        List<String> specialProgrammTasks = new List<String>();
        for(TaskMatrix__mdt tm : tasjMatrixList){
            specialProgrammTasks.add(tm.Task_Name__c);
        }        
        List<Task> tasks = [SELECT Id, Subject, Description, WhatId FROM Task WHERE WhatId =: acc.Id AND Subject in: specialProgrammTasks];
        System.assertEquals(3, tasks.size());
    }	
}