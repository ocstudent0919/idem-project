global class AccountProcessorBatch implements Database.Batchable<sObject> {
  // Collect the batches of records to be passed to execute
  global Database.QueryLocator start(Database.BatchableContext bc) {
    // Select accounts with related orders and related call tasks if any
    return Database.getQueryLocator(
      [
        SELECT
          OwnerId,
          (SELECT Id FROM Orders),
          (SELECT Id FROM Tasks WHERE Subject = 'Call')
        FROM Account
      ]
    );
  }
  // Process each batch of records
  global void execute(Database.BatchableContext bc, List<Account> scope) {
    // Call handler method to process preselected accounts
    Handler.createCallTasks(scope);
  }

  // Execute post-processing operations if any
  global void finish(Database.BatchableContext bc) {
  }
}
