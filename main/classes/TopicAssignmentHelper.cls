/*
*	@author:	Jerson Poblete
*	@date:		24.MAR.2020
*	@description: Topic Assignment Helper
*/

public class TopicAssignmentHelper {
    /*
     * @description: This method assign topic to task.
     * @param:		 Set<Id>
     * @return:		 List<TopicAssignment>
     */ 
    public static List<TopicAssignment> assignTopicToTask(Set<Id> taskId){       
        List<TaskMatrix__mdt> tasjMatrixList = [SELECT DeveloperName, WeekNum__c, Topic__c, Task_Name__c, Task_Description__c FROM TaskMatrix__mdt];
        Map<String, TaskMatrix__mdt> taskMatrixMap = new Map<String, TaskMatrix__mdt>();
        List<Topic> topicList = [SELECT Id, Name FROM Topic];
        List<TopicAssignment> topicAssignmentsList = new List<TopicAssignment>();
        try{
            for( TaskMatrix__mdt tm : tasjMatrixList){
                String namDesc = tm.Task_Name__c + tm.Task_Description__c;
                taskMatrixMap.put(namDesc, tm);
            }
            
            for(Task tsk : [SELECT Id, Subject, Description FROM Task WHERE Id in :taskId]){
                String taskNamDesc = tsk.Subject + tsk.Description;
                TaskMatrix__mdt tmat = taskMatrixMap.get(taskNamDesc);
                for(Topic topic: topicList){
                    if(topic.Name == tmat.Topic__c){
                        TopicAssignment ta = new TopicAssignment();
                        ta.TopicId = topic.Id;
                        ta.EntityId = tsk.Id;
                        topicAssignmentsList.add(ta);
                    }
                }
            }
            
        } catch (Exception e) {
            system.debug('Error = ' + e.getMessage());
        }
        return topicAssignmentsList;
    }
}