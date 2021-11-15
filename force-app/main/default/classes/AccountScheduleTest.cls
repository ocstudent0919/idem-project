@isTest
private class AccountScheduleTest {
  // This test runs a scheduled job at midnight every first Monday of the month
  public static String CRON_EXP = '0 0 0 ? * 2#1 *';
  public static String JOB_NAME = 'Scheduled Apex Test';
  @isTest
  static void testScheduledJob() {
    // Create some accounts without related orders (they have no related call tasks either)
    List<Account> targetAccounts = TestDataFactory.createAccountsWithoutOrders(
      10,
      0
    );
    // Get the IDs of the accounts we just inserted
    List<Id> accountIds = new List<Id>(
      new Map<Id, Account>(targetAccounts).keySet()
    );

    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule(JOB_NAME, CRON_EXP, new AccountSchedule());

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    //Verify the Scheduled Apex job exists
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM CronTrigger
        WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name = :JOB_NAME
      ]
    );

    // Verify the expressions are the same
    System.assertEquals(CRON_EXP, ct.CronExpression);

    // Verify the scheduled job has not run yet.
    System.assertEquals(0, ct.TimesTriggered);
    System.assertEquals(
      0,
      [SELECT Id FROM Task WHERE WhatId IN :accountIds].size(),
      'Tasks exist before job has run'
    );

    // Calculate expected job run date
    Date jobRunDate = Date.today()
      .addMonths(1)
      .toStartOfMonth()
      .toStartOfWeek();
    // Add a week if "first Monday" is in last month
    if (jobRunDate < date.today().addMonths(1).toStartOfmonth()) {
      jobRunDate = jobRunDate.addDays(7);
    }

    // Verify the next date the job will run
    System.assertEquals(jobRunDate, ct.NextFireTime.date());

    Test.stopTest();
  }
}
