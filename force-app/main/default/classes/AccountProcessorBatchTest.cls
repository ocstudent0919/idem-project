@isTest
private class AccountProcessorBatchTest {
  @isTest
  static void testAccountCallTaskCreation() {
    // Create accounts without orders and having no related call tasks
    // They are the target for the batch processor action (new tasks creation)
    List<Account> expectedAccounts = TestDataFactory.createAccountsWithoutOrders(
      Constants.NUM_RECORDS,
      0
    );
    // Extract the Ids of the above accounts
    Set<Id> expectedAccountsIds = (new Map<Id, SObject>(expectedAccounts))
      .keySet();
    // Create another type of accounts that will be excluded by batch processor's business logic
    // e.g. accounts with orders
    TestDataFactory.createAccountsWithOrders(
      Constants.NUM_RECORDS,
      Constants.NUM_RECORDS,
      1
    );
    // and accounts with related call tasks
    TestDataFactory.createAccountsWithCallTasks(
      Constants.NUM_RECORDS,
      Constants.NUM_RECORDS * 2
    );

    // Perform the test
    Test.startTest();
    AccountProcessorBatch processor = new AccountProcessorBatch();
    Id batchId = Database.executeBatch(processor, Constants.NUM_RECORDS * 3);
    Test.stopTest();

    // Select newly created tasks and extract the Ids of the related accounts
    List<Task> newTasks = [
      SELECT AccountId
      FROM Task
      WHERE Status = 'Not Started'
    ];
    Set<Id> processedAccountsIds = new Set<Id>();
    for (Task task : newTasks) {
      processedAccountsIds.add(task.AccountId);
    }

    // The number of new tasks should be equal to the number of target accounts
    System.assertEquals(
      Constants.NUM_RECORDS,
      newTasks.size(),
      'ERROR: Number of created tasks is incorrect'
    );

    // The Ids of the target accounts should be the same as
    // the Ids of the accounts related to the newly created tasks
    System.assertEquals(
      expectedAccountsIds,
      processedAccountsIds,
      'ERROR: Account records not processed correctly'
    );
  }
}
