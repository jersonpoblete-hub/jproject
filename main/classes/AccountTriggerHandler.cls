/*
*	@author: 	Jerson Poblete
*	@date:		24.MAR.2020
*	@description:Handler class for Account Trigger
*/
public class AccountTriggerHandler{    
    public void execute(){
        if(trigger.isAfter && trigger.isInsert){
            createSpecialProgrammeTask(trigger.new);
        }
    }
    /*
     * @description: This method create a tasks for Special Programme Shop account.
     * @param:		 List<Accounts>
     * @return:		 n/a	
     */ 
    public static void createSpecialProgrammeTask(List<Account> accounts){        
        Set<Id> accountIds = new Set<Id>();
        List<Task> taskList = new List<Task>();
        Set<Id> taskIds = new Set<Id>();
        List<TaskMatrix__mdt> tasjMatrixList = new List<TaskMatrix__mdt>();
        List<TopicAssignment> topicAssignmentsList = new List<TopicAssignment>();
        try{
            for(Account acc : accounts){
                if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Special Programme Shop').getRecordTypeId()){
                    accountIds.add(acc.Id);
                }
            }
            if(!accountIds.isEmpty()){
                //create task for each account
                tasjMatrixList = [SELECT WeekNum__c, Topic__c, Task_Name__c, Task_Description__c FROM TaskMatrix__mdt WHERE WeekNum__c = 1];
                for(Id acId : accountIds){
                    for(TaskMatrix__mdt tm : tasjMatrixList){
                        Task tNew = new Task();
                        tNew.Subject = tm.Task_Name__c;
                        tNew.Description = tm.Task_Description__c;
                        tNew.WhatId = acId;
                        taskList.add(tNew);	
                    }
                }			
            }
            if(!taskList.isEmpty()){
                List<String> errString = new List<String>();            
                Database.SaveResult[] taskInsert = Database.insert(taskList, false);
                for(Database.SaveResult res : taskInsert){
                    if(res.isSuccess()){
                        taskIds.add(res.getId());
                    }else{
                        for(Database.Error err : res.getErrors()) {
                            system.debug('====>' + err.getMessage());
                            errString.add(err.getMessage());                        
                        }
                    }
                }
                
            }
            //assign topic to task
            if(!taskIds.isEmpty()){
                topicAssignmentsList = TopicAssignmentHelper.assignTopicToTask(taskIds);
                if(!topicAssignmentsList.isEmpty()){
                    insert topicAssignmentsList;
                }
            }
        } catch(Exception e) {
            system.debug('Error = ' + e.getMessage());
        }
    }
}