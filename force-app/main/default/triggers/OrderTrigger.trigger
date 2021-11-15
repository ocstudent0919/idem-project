trigger OrderTrigger on Order(before update, after delete) {
  // Before Update
  if (Trigger.isUpdate && Trigger.isBefore) {
    // Call handler method to prevent order status update
    Handler.preventOrderStatusUpdate(Trigger.newMap, Trigger.oldMap);
  }
  // After Delete
  if (Trigger.isDelete && Trigger.isAfter) {
    // Call handler method to deactivate accounts without orders
    Handler.deactivateAccountWithNoOrders(Trigger.old);
  }
}
