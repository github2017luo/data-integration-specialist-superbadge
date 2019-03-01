@isTest
private class BillingCalloutServiceTest {

  @TestSetup
  static void prepareData() {
    ServiceCredentials__c customSetting = new ServiceCredentials__c();
    customSetting.Name = 'BillingServiceCredential';
    customSetting.Username__c = 'someUsername';
    customSetting.Password__c = 'somePassword';
    insert customSetting;

    Account account = new Account(Name = 'TestAccount');
    insert account;

    Opportunity opportunity = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = Date.today().addDays(3),
      ForecastCategoryName = 'Best Case',
      Probability = 75,
      StageName = 'Prospecting',
      AccountId = account.id,
      Amount = 4500
    );
    insert opportunity;

    List<Project__c> projects = new List<Project__c>();
    for(Integer i = 0; i < 5; i++) {
      projects.add(new Project__c(
          Name = 'TestProject' + i,
          Opportunity__c = opportunity.id,
          ProjectRef__c = 'SomeProjectRef' + i,
          Billable_Amount__c = opportunity.Amount,
          Status__c = 'Running'
        )
      );
    }
    insert projects;  
  }

  @isTest
  private static void testCallBillingServicePositive() {
    List<Project__c> projects = [SELECT Name, Status__c FROM Project__c];
    for(Project__c project : projects) {
      if(project.Name != 'TestProject4')
        project.Status__c = 'Billable';
    }

    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());

    Test.startTest();
    update projects;
    Test.stopTest();

    projects = [SELECT Name, Status__c FROM Project__c];
    for(Project__c project : projects) {
      if(project.Name != 'TestProject4')
        System.assertEquals('Billed', project.Status__c);

      else
        System.assertEquals('Running', project.Status__c);
    }
  }

  @isTest
  private static void testCallBillingServiceNegative() {
    List<Project__c> projects = [SELECT Name, Status__c FROM Project__c];
    for(Project__c project : projects) {
      if(project.Name != 'TestProject4')
        project.Status__c = 'Billable';
    }

    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());

    Test.startTest();
    update projects;
    Test.stopTest();

    projects = [SELECT Name, Status__c FROM Project__c];
    for(Project__c project : projects) {
      if(project.Name != 'TestProject4')
        System.assertEquals('Billable', project.Status__c);

      else
        System.assertEquals('Running', project.Status__c);
    }
  }
}