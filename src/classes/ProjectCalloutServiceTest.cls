@isTest
private class ProjectCalloutServiceTest {

  @TestSetup
  static void prepareData() {
    Account account = new Account(Name = 'TestAccount');
    insert account;

    Opportunity opportunity = new Opportunity(
                                    Name = 'Test Opportunity',
                                    CloseDate = Date.today().addDays(3),
                                    ForecastCategoryName = 'Best Case',
                                    Probability = 75,
                                    StageName = 'Prospecting',
                                    AccountId = account.ID,
                                    Amount = 4500);

    insert opportunity;

    ServiceTokens__c customSetting = new ServiceTokens__c();
    customSetting.Name = 'ProjectServiceToken';
    customSetting.Token__c = 'someTestToken';
    insert customSetting;
  }
  
  @isTest
  private static void testPostOpportunityToPMSPositive() {
    Opportunity opportunity = [SELECT StageName FROM Opportunity LIMIT 1];
    System.assertEquals('Prospecting', opportunity.StageName);

    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
    Test.startTest();
    ProjectCalloutService.postOpportunityToPMS(new List<Id>{ opportunity.ID });
    Test.stopTest();

    opportunity = [SELECT StageName FROM Opportunity LIMIT 1];
    System.assertEquals('Submitted Project', opportunity.StageName);
  }

  @isTest
  private static void testPostOpportunityToPMSNegative() {
    Opportunity opportunity = [SELECT StageName FROM Opportunity LIMIT 1];
    System.assertEquals('Prospecting', opportunity.StageName);

    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
    Test.startTest();
    ProjectCalloutService.postOpportunityToPMS(new List<Id>{ opportunity.ID });
    Test.stopTest();

    opportunity = [SELECT StageName FROM Opportunity LIMIT 1];
    System.assertEquals('Resubmit Project', opportunity.StageName);
  }
}