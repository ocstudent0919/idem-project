public with sharing class OrderTriggerHandler {
  public void preventOrderStatusUpdate(
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
      // Verify if the order to update is concerned by the trigger's action
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
}
