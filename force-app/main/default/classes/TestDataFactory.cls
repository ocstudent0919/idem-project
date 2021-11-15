@isTest
public with sharing class TestDataFactory {
  // Construct a list of Account records for unit tests
  public static List<Account> createAccounts(
    Integer numAccounts,
    Integer startCount
  ) {
    List<Account> accounts = new List<Account>();

    for (Integer i = 1; i <= numAccounts; i++) {
      Account acct = new Account();
      acct.Name = 'Test Account ' + (startCount + i);
      accounts.add(acct);
    }
    return accounts;
  }

  // Construct a Product2 record for unit tests
  public static Product2 createProduct() {
    Product2 product = new Product2();
    product.Name = 'Test Poduct';
    product.IsActive = true;
    return product;
  }

  // Construct a PricebookEntry record for unit tests
  public static PriceBookEntry createPricebookEntry(Product2 product) {
    PricebookEntry entry = new PricebookEntry();
    entry.Pricebook2Id = Test.getStandardPricebookId();
    entry.Product2Id = product.Id;
    entry.UnitPrice = Constants.UNIT_PRICE;
    entry.IsActive = true;
    return entry;
  }

  // Construct a list of Order records for unit tests
  public static List<Order> createOrders(
    Integer numOrders,
    List<Account> accounts
  ) {
    List<Order> orders = new List<Order>();
    for (Account account : accounts) {
      for (Integer i = 0; i < numOrders; i++) {
        Order order = new Order();
        order.AccountId = account.Id;
        order.EffectiveDate = Date.Today();
        order.Status = Constants.INITIAL_ORDER_STATUS;
        order.Pricebook2Id = Test.getStandardPricebookId();
        orders.add(order);
      }
    }
    return orders;
  }

  // Construct a list of OrderItem records for unit tests
  public static List<OrderItem> createOrderItems(
    Pricebookentry pbEntry,
    List<Order> orders
  ) {
    List<OrderItem> orderItems = new List<OrderItem>();
    for (Order order : orders) {
      OrderItem item = new OrderItem();
      item.OrderId = order.Id;
      item.PriceBookEntryId = pbEntry.Id;
      item.Quantity = Constants.ITEM_QUANTITY;
      item.UnitPrice = pbEntry.UnitPrice;
      orderItems.add(item);
    }
    return orderItems;
  }

  // Create orders with products
  public static List<Order> createOrdersWithProducts(
    Integer numAccounts,
    Integer numOrders
  ) {
    List<Account> accounts = createAccounts(numAccounts, 0);
    insert accounts;

    Product2 product = createProduct();
    insert product;

    PriceBookEntry pbEntry = createPricebookEntry(product);
    insert pbEntry;

    List<Order> orders = createOrders(numOrders, accounts);
    insert orders;

    List<OrderItem> items = createOrderItems(pbEntry, orders);
    insert items;

    return orders;
  }

  // Create orders without products
  public static List<Order> createOrdersWithoutProducts(
    Integer numAccounts,
    Integer numOrders
  ) {
    List<Account> accounts = createAccounts(numAccounts, 0);
    insert accounts;

    List<Order> orders = createOrders(numOrders, accounts);
    insert orders;

    return orders;
  }

  // Create accounts without orders
  public static List<Account> createAccountsWithoutOrders(
    Integer numAccounts,
    Integer startCount
  ) {
    List<Account> accounts = createAccounts(numAccounts, startCount);
    insert accounts;
    return accounts;
  }

  // Create accounts with orders
  public static List<Account> createAccountsWithOrders(
    Integer numAccounts,
    Integer startCount,
    Integer numOrders
  ) {
    List<Account> accounts = createAccountsWithoutOrders(
      numAccounts,
      startCount
    );

    List<Order> orders = createOrders(numOrders, accounts);
    insert orders;

    return accounts;
  }

  // Create accounts with Call tasks
  public static List<Account> createAccountsWithCallTasks(
    Integer numAccounts,
    Integer startCount
  ) {
    List<Account> accounts = createAccountsWithoutOrders(
      numAccounts,
      startCount
    );
    List<Task> tasks = new List<Task>();

    for (Account account : accounts) {
      tasks.add(
        new Task(
          WhatId = account.Id,
          Subject = 'Call',
          Status = 'In Progress',
          Priority = 'Normal'
        )
      );
    }

    insert tasks;
    return accounts;
  }
}
