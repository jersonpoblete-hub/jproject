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
        Map<String, TaskMatrix__mdt> taskMatrixMap = new Map<String, TaskMatrix__mdt>(); //map use in matching topic and task
        Set<String> topicmtx = new set<String>(); //set of topic name to look for existing topic in the org. 
        List<String> topicRecStrs = new List<String>(); //set of topic name already in the org
        List<Topic> newtopicList = new List<Topic>();// new list of topic including the newly created topic.
        List<TopicAssignment> topicAssignmentsList = new List<TopicAssignment>();
        List<Topic> newtopics = new list<Topic>(); // list of new topics to insert
        try{
            for( TaskMatrix__mdt tm :  [SELECT DeveloperName, WeekNum__c, Topic__c, Task_Name__c, Task_Description__c FROM TaskMatrix__mdt]){
                String namDesc = tm.Task_Name__c + tm.Task_Description__c;
                taskMatrixMap.put(namDesc, tm);
                topicmtx.add(tm.Topic__c);
            }                     
            for(Topic trec : [SELECT Id, Name FROM Topic WHERE Name in: topicmtx]){
                topicRecStrs.add(trec.Name);
            }
            for(String toprec : topicmtx){
                if(!topicRecStrs.contains(toprec)){
                    Topic top = new Topic();
                    top.Name = toprec;
                    newtopics.add(top);
                }
            }
            if(!newtopics.isEmpty()){
                insert newtopics;
            }
			newtopicList = [SELECT Id, Name FROM Topic WHERE Name in: topicmtx];
            
            for(Task tsk : [SELECT Id, Subject, Description FROM Task WHERE Id in :taskId]){
                String taskNamDesc = tsk.Subject + tsk.Description;
                TaskMatrix__mdt tmat = taskMatrixMap.get(taskNamDesc);
                for(Topic topic: newtopicList){
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