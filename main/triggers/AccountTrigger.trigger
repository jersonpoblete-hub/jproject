/*
*	@author: 	Jerson Poblete
*	@date:		24.MAR.2020
*	@description:Account Trigger
*/
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.execute();
}