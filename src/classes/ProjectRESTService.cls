@RestResource(urlMapping = '/project')
global with sharing class ProjectRESTService {
    
    @HttpPost
    global static String postProjectData(String projectRef, String projectName, String opportunityId,
                                            Date startDate, Date endDate, Double amount, String status) {

        Project__c project = new Project__c(
            ProjectRef__c = projectRef,
            Name = projectName,
            Opportunity__c = opportunityId,
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Billable_Amount__c = amount,
            Status__c = status
        );

        Opportunity relatedOpportunity = [SELECT DeliveryInstallationStatus__c FROM Opportunity
                                            WHERE Id = :opportunityId LIMIT 1];
        relatedOpportunity.DeliveryInstallationStatus__c = 'In progress';

        String returnMessage = 'OK';
        Savepoint savePoint = Database.setSavepoint();

        try {
            upsert project;
            update relatedOpportunity;
        
        } catch (System.DmlException ex) {
            returnMessage = ex.getMessage();
            Database.rollback(savePoint);
        }

        return returnMessage;
    }
}