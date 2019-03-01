trigger ProjectTrigger on Project__c (before update) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        BillingCalloutService.callBillingService(Trigger.oldMap, Trigger.newMap);
    }
}