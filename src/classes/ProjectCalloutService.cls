public class ProjectCalloutService {
	
    @InvocableMethod
    public static void PostOpportunityToPMS(List<Id> opportunities) {
        Opportunity opportunity = [SELECT Id, Name, Account.Name, CloseDate, Amount, StageName
                                    FROM Opportunity WHERE Id = :opportunities[0]];
        System.enqueueJob(new QueueablePMSCall(opportunity));
    }

    private class QueueablePMSCall implements Queueable, Database.AllowsCallouts {

        private Opportunity opportunity;
        private String body;
        private String token;

        private String constructBody() {
            return '{"opportunityId": "' + this.opportunity.ID + '",'
                    + '"opportunityName": "' + this.opportunity.Name + '",'
                    + '"accountName": "' + this.opportunity.Account.Name + '",'
                    + '"closeDate": "' + this.opportunity.CloseDate + '",'
                    + '"amount": ' + this.opportunity.amount + '}';
        }

        private QueueablePMSCall(Opportunity opportunity) {
            this.opportunity = opportunity;
            this.body = constructBody();
            this.token = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        }

        public void execute(QueueableContext context) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('token', this.token);
            request.setBody(this.body);

            Http http = new Http();
            HttpResponse response = http.send(request);

            this.opportunity.StageName = (response.getStatusCode() == 200) ? 'Submitted Project' : 'Resubmit Project';
            update opportunity;
        }
    }
}