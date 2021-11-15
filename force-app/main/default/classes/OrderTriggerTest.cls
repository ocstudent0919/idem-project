@isTest
private class OrderTriggerTest {
  @isTest
  static void testOrderStatusUpdatePreventionOnBulkOrdersWithNoItems() {
    // Test data setup
    // Declare a new Set of Order Ids
    Set<Id> resultOrderIds = new Set<Id>();
    // Create several orders with no associated products for one account by calling a utility method
    Order[] orders = TestDataFactory.createOrdersWithoutProducts(1, 10);
    // Declare a new list of orders to update
    List<Order> ordersToUpdate = new List<Order>();
    // Set a new order status for each order and populate the list of orders to update
    for (Order order : orders) {
      order.Status = Constants.ACTIVATED_ORDER_STATUS;
      ordersToUpdate.add(order);
    }
    // Perform test
    Test.startTest();
    Database.SaveResult[] results = Database.update(ordersToUpdate, false);
    Test.stopTest();
    // The update should have been stopped by the trigger,
    // so check that we got back an error for each record
    for (Database.SaveResult result : results) {
      System.assert(!result.isSuccess());
      System.assert(result.getErrors().size() > 0);
      System.assertEquals(
        Constants.NOPRODUCT_ERROR_MESSAGE,
        result.getErrors()[0].getMessage()
      );
      // Populate the set with the Ids of the orders concerned by the update
      resultOrderIds.add(result.getId());
    }
    // For each order concerned by the update, verify that its status has not been updated
    for (Order resultOrder : [
      SELECT Status
      FROM Order
      WHERE Id IN :resultOrderIds
    ]) {
      System.assertEquals(
        Constants.INITIAL_ORDER_STATUS,
        resultOrder.Status,
        'Incorrect value of Order Status'
      );
    }
  }

  @isTest
  static void testOrderStatusUpdateOnBulkOrdersWithProducts() {
    // Test data setup
    // Declare a new Set of Order Ids
    Set<Id> resultOrderIds = new Set<Id>();
    // Create several orders with associated products for one account by calling a utility method
    Order[] orders = TestDataFactory.createOrdersWithProducts(1, 10);
    // Declare a new list of orders to update
    List<Order> ordersToUpdate = new List<Order>();
    // Set a new order status for each order and populate the list of orders to update
    for (Order order : orders) {
      order.Status = Constants.ACTIVATED_ORDER_STATUS;
      ordersToUpdate.add(order);
    }
    // Perform test
    Test.startTest();
    Database.SaveResult[] results = Database.update(ordersToUpdate, false);
    Test.stopTest();
    // For each record, verify that the update was successful
    for (Database.SaveResult result : results) {
      System.assert(result.isSuccess());
      // Populate the set with the Ids of updated orders
      resultOrderIds.add(result.getId());
    }
    // For each updated order, verify that its status has been updated properly
    for (Order resultOrder : [
      SELECT Status
      FROM Order
      WHERE Id IN :resultOrderIds
    ]) {
      System.assertEquals(
        Constants.ACTIVATED_ORDER_STATUS,
        resultOrder.Status,
        'Incorrect value of Order Status'
      );
    }
  }

  @isTest
  static void testIsAccountActiveIfNoOrdersLeftAfterDeletion() {
    // Test data setup
    // Create an account with one order
    Account acc = TestDataFactory.createAccountsWithOrders(1, 0, 1)[0];
    // Activate account
    acc.Active__c = true;
    update acc;
    // Select an order to delete
    Order order = [SELECT Id FROM Order WHERE AccountId = :acc.Id];
    // Perform test
    Test.startTest();
    Database.DeleteResult result = Database.delete(order, false);
    Test.stopTest();
    // Verify that the deletion was successful
    System.assert(result.isSuccess());
    Account accountWithoutOrders = [
      SELECT Active__c, (SELECT Id FROM Orders)
      FROM Account
      WHERE Id = :acc.Id
    ];
    // Verify that after the deletion, the account contains no orders
    System.assertEquals(
      0,
      accountWithoutOrders.Orders.size(),
      'Account should not contain orders'
    );
    // Verify that the account without orders is not active
    System.assertEquals(
      false,
      accountWithoutOrders.Active__c,
      'Account without orders must be deactivated'
    );
  }

  @isTest
  static void testIsAccountActiveIfSomeOrdersLeftAfterDeletion() {
    // Test data setup
    // Create an account with several orders
    Account acc = TestDataFactory.createAccountsWithOrders(1, 0, 3)[0];
    // Activate account
    acc.Active__c = true;
    update acc;
    // Select one order to delete
    Order order = [SELECT Id FROM Order WHERE AccountId = :acc.Id LIMIT 1];
    // Perform test
    Test.startTest();
    Database.DeleteResult result = Database.delete(order, false);
    Test.stopTest();
    System.assert(result.isSuccess());
    Account accountWithOrders = [
      SELECT Active__c, (SELECT Id FROM Orders)
      FROM Account
      WHERE Id = :acc.Id
    ];
    // Verify that after the deletion, the account still contains orders
    System.assertEquals(
      true,
      accountWithOrders.Orders.size() > 0,
      'Account should contain orders'
    );
    // Verify that the account with orders is active
    System.assertEquals(
      true,
      accountWithOrders.Active__c,
      'Account with orders must be marked as active'
    );
  }
}
