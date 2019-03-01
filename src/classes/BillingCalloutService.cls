public class BillingCalloutService {
    
    public static void callBillingService(Map<Id, Project__c> oldProjects, Map<Id, Project__c> newProjects) {
        Project__c oldProject;
        Project__c newProject;

        for(Id projectId : newProjects.keySet()) {
            oldProject = oldProjects.get(projectId);
            newProject = newProjects.get(projectId);

            if(oldProject.Status__c != 'Billable' && newProject.Status__c == 'Billable') {
                makeCallout(projectId);
            }
        }
    }

    @Future(callout = true)
    private static void makeCallout(Id newProjectId) {
        Project__c project = [SELECT ProjectRef__c, Billable_Amount__c FROM Project__c WHERE Id = :newProjectId];
        BillingServiceProxy.project calloutParameter = setCalloutParameters(project.ProjectRef__c, project.Billable_Amount__c);

        BillingServiceProxy.InvoicesPortSoap11 invoicesPort = new BillingServiceProxy.InvoicesPortSoap11();
        String response = invoicesPort.billProject(calloutParameter);

        if(response == 'OK') {
            project.Status__c = 'Billed';
        }
    }

    private static BillingServiceProxy.project setCalloutParameters(String projectRef, Decimal billableAmount) {
        ServiceCredentials__c serviceCredentials = ServiceCredentials__c.getValues('BillingServiceCredential');
                
        BillingServiceProxy.project calloutParameter = new BillingServiceProxy.project();
        calloutParameter.username = serviceCredentials.Username__c;
        calloutParameter.password = serviceCredentials.Password__c;
        calloutParameter.projectid = projectRef;
        calloutParameter.billAmount = billableAmount;

        return calloutParameter;
    }
}