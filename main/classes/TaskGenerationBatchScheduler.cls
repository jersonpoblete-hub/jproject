/*
*	@author:	Jerson Poblete
*	@date:		22.Mar.2020
*	@description:Scheduleable class to generate Task
*/

global class TaskGenerationBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        TaskGenerationBatch batch = new TaskGenerationBatch();
        database.executebatch(batch, 200);
    }
}