@isTest
private class ProjectRESTServiceTest {

  @TestSetup
  static void prepareData() {
    Opportunity opportunity = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = Date.today().addDays(3),
      ForecastCategoryName = 'Best Case',
      Probability = 75,
      StageName = 'Prospecting',
      DeliveryInstallationStatus__c = 'Not in progress'
    );
    insert opportunity;
  }

  @isTest
  private static void testPostProjectDataPositive() {
    Opportunity opportunity = [SELECT Id, DeliveryInstallationStatus__c
                                FROM Opportunity ];
    System.assertEquals('Not in progress', opportunity.DeliveryInstallationStatus__c);

    List<Project__c> projects = [SELECT ProjectRef__c, Name, Opportunity__c,
                                  Start_Date__c, End_Date__c, Billable_Amount__c,
                                  Status__c FROM Project__c];
    System.assertEquals(0, projects.size());

    Test.startTest();
    ProjectRESTService.postProjectData('projectRef', 'projectName', opportunity.ID,
                                        Date.today().addDays(-1),
                                        Date.today().addDays(3),
                                        4500, 'Billable');
    Test.stopTest();

    projects = [SELECT ProjectRef__c, Name, Opportunity__c, Start_Date__c, 
                End_Date__c, Billable_Amount__c, Status__c FROM Project__c];
    System.assertEquals(1, projects.size());
    System.assertEquals('projectRef', projects[0].ProjectRef__c);
    System.assertEquals('projectName', projects[0].Name);
    System.assertEquals(opportunity.ID, projects[0].Opportunity__c);
    System.assertEquals(Date.today().addDays(-1), projects[0].Start_Date__c);
    System.assertEquals(Date.today().addDays(3), projects[0].End_Date__c);
    System.assertEquals(4500, projects[0].Billable_Amount__c);
    System.assertEquals('Billable', projects[0].Status__c);

    opportunity = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity ];
    System.assertEquals('In progress', opportunity.DeliveryInstallationStatus__c);
  }

  @isTest
  private static void testPostProjectDataNegative() {
    Opportunity opportunity = [SELECT Id, DeliveryInstallationStatus__c
                                FROM Opportunity ];
    System.assertEquals('Not in progress', opportunity.DeliveryInstallationStatus__c);

    List<Project__c> projects = [SELECT ProjectRef__c, Name, Opportunity__c,
                                  Start_Date__c, End_Date__c, Billable_Amount__c,
                                  Status__c FROM Project__c];
    System.assertEquals(0, projects.size());

    Test.startTest();
    String returnMessage = ProjectRESTService.postProjectData('projectRef',
                                        'projectName', opportunity.ID,
                                        Date.today().addDays(-1),
                                        Date.today().addDays(3),
                                        4500, 'Some wrong status value');
    Test.stopTest();

    System.assertNotEquals('OK', returnMessage);

    projects = [SELECT ProjectRef__c, Name, Opportunity__c, Start_Date__c, 
                End_Date__c, Billable_Amount__c, Status__c FROM Project__c];
    System.assertEquals(0, projects.size());

    opportunity = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity ];
    System.assertEquals('Not in progress', opportunity.DeliveryInstallationStatus__c);
  }
}