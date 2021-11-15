global class AccountSchedule implements Schedulable {
  global void execute(SchedulableContext cs) {
    // Execute batch job under Scheduled Apex
    Database.executeBatch(new AccountProcessorBatch());
  }
}
