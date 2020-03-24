/*
*	@author:	Jerson Poblete
*	@date:		22.Mar.2020
*	@description: Batch runs every monday to look for special programme shop task
*/
global class TaskGenerationBatch implements Database.Batchable<sObject> {
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String STATUS_CLOSED = 'Closed';
    private static final String NEWFEATURESTROUBLESHOOTING = 'New Feature & Troubleshooting';
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get all special programme account 
        String query = 'Select Id FROM Account Where RecordType.Name = \'Special Programme Shop\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Map<Id, List<Task>> accountTaskMap = new Map<Id, List<Task>>();
        List<Task> taskList = new List<Task>(); 
        //Datetime dateLastweek = System.today().AddDays(-7);
        Datetime dateLastweek = System.Now().addHours(-2); //for testing
        Set<Id> taskIds = new Set<Id>();
        Map<String, TaskMatrix__mdt> taskMatrixMap = new Map<String, TaskMatrix__mdt>();
        List<TaskMatrix__mdt> tasjMatrixList = [SELECT DeveloperName, WeekNum__c, Topic__c, Task_Name__c, Task_Description__c FROM TaskMatrix__mdt];
        List<TopicAssignment> topicAssignmentsList = new List<TopicAssignment>();
        try{
            //create a map of account and task
            for(Task tRec :[SELECT Id, OwnerId, WhatId, AccountId, Subject, Status, Description, CreatedDate, IsClosed 
                            FROM Task WHERE AccountId IN: scope AND CreatedDate > :dateLastweek ])
            {
                if(accountTaskMap.containsKey(tRec.AccountId)) {
                    List<Task> accTaskList = accountTaskMap.get(tRec.AccountId);
                    accTaskList.add(tRec);
                    accountTaskMap.put(tRec.AccountId, accTaskList);
                } else {
                    accountTaskMap.put(tRec.AccountId, new List<Task> { tRec });
                }
            }            
            //create a map of task matrix
            for( TaskMatrix__mdt tm : tasjMatrixList){
                String namDesc = tm.Task_Name__c + tm.Task_Description__c;
                taskMatrixMap.put(namDesc, tm);
            }
            //create the correct tasks base on matrix map
            for(Id aId : accountTaskMap.keyset()){	
                for(Task tsk : accountTaskMap.get(aId)){                    
                    String taskNamDesc = tsk.Subject + tsk.Description;
                    TaskMatrix__mdt tmat = taskMatrixMap.get(taskNamDesc);                    
                    if(tsk.IsClosed && tsk.Status == STATUS_COMPLETED){				
                        //create new task
                        Task tNew = new Task();
                        Decimal wCount = tmat.WeekNum__c + 1;
                        String tskTopic = tmat.Topic__c;
                        if(tmat.Topic__c == NEWFEATURESTROUBLESHOOTING){
                            tNew.Subject = tmat.Task_Name__c;
                            tNew.Description = tmat.Task_Description__c;
                            tNew.WhatId = tsk.WhatId;
                            taskList.add(tNew);
                        }else{
                            for(TaskMatrix__mdt tm : tasjMatrixList){	
                                if(tm.Topic__c == tskTopic && tm.WeekNum__c == wCount ){
                                    tNew.Subject = tm.Task_Name__c;
                                    tNew.Description = tm.Task_Description__c;
                                    tNew.WhatId = tsk.WhatId;
                                    taskList.add(tNew);	
                                    break;
                                }
                            }
                        }
                    }else{
                        for(TaskMatrix__mdt tm : tasjMatrixList){
                            if(tsk.Subject == tm.Task_Name__c && !tsk.IsClosed){
                                //recreate the old task                    
                                Task tclone = tsk.clone(false, false, false, false);
                                taskList.add(tclone);
                                //close current task
                                tsk.Status = STATUS_CLOSED;
                                taskList.add(tsk);
                                break;
                            }
                            
                        }
                        
                    }
                }
            }
            if(!taskList.isEmpty()){
                List<String> errString = new List<String>();
                Database.UpsertResult[] taskUpsert = Database.upsert(taskList, false);                        
                for(Database.UpsertResult res : taskUpsert){
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
        } catch (Exception e) {
            system.debug('Error = ' + e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}