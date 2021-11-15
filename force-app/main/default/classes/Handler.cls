public with sharing class Handler {
  public static void preventOrderStatusUpdate(
    Map<Id, Order> newOrdersMap,
    Map<Id, Order> oldOrdersMap
  ) {
    // Declare a new Set of Order IDs
    Set<Id> orderIds = new Set<Id>();
    // Select the orders to update
    for (Order order : [
      SELECT Id, (SELECT Id FROM OrderItems)
      FROM Order
      WHERE Id IN :newOrdersMap.keySet()
    ]) {
      // Verify the order to update is concerned by the trigger's action
      if (
        order.OrderItems.size() == 0 &&
        newOrdersMap.get(order.Id).Status == Constants.ACTIVATED_ORDER_STATUS &&
        newOrdersMap.get(order.Id).Status != oldOrdersMap.get(order.Id).Status
      ) {
        // Populate the set with the IDs of the orders whose update should be stopped by the trigger
        orderIds.add(order.Id);
      }
    }
    // Prevent the update operation from occurring
    // by calling the addError() method on each concerned record
    for (Order newOrder : newOrdersMap.values()) {
      if (orderIds.contains(newOrder.Id)) {
        newOrder.addError(Constants.NOPRODUCT_ERROR_MESSAGE);
      }
    }
  }
  public static void deactivateAccountWithNoOrders(List<Order> oldOrders) {
    // Get account Ids related to deleted orders
    List<Account> accountsToUpdate = new List<Account>();
    Set<Id> accountIds = new Set<Id>();
    for (Order order : oldOrders) {
      accountIds.add(order.AccountId);
    }
    // Select previously activated accounts with no orders left
    // Deactivate those accounts
    for (Account account : [
      SELECT Active__c, (SELECT Id FROM Orders)
      FROM Account
      WHERE Id IN :accountIds
    ]) {
      if (account.Orders.size() == 0 && account.Active__c) {
        account.Active__c = false;
        accountsToUpdate.add(account);
      }
    }
    // Update deactivated accounts if any
    if (accountsToUpdate.size() > 0) {
      update accountsToUpdate;
    }
  }

  public static void createCallTasks(List<Account> accounts) {
    List<Task> newTasks = new List<Task>();
    // Create a Call Task with reminder for each preselected account having no orders & no call tasks
    for (Account account : accounts) {
      if (account.Orders.size() == 0 && account.Tasks.size() == 0) {
        newTasks.add(
          new Task(
            WhatId = account.Id,
            OwnerId = account.OwnerId,
            Subject = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            IsReminderSet = true,
            ReminderDateTime = Date.today().addDays(5)
          )
        );
      }
    }
    // Insert created Call tasks in the database
    if (newTasks.size() > 0) {
      insert newTasks;
    }
  }
}
