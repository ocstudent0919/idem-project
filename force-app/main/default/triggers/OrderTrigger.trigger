trigger OrderTrigger on Order(before update, after delete) {
  OrderTriggerHandler handler = new OrderTriggerHandler();
  //Before Update
  if (Trigger.isUpdate && Trigger.isBefore) {
    // Call handler method
    handler.preventOrderStatusUpdate(Trigger.newMap, Trigger.oldMap);
  }
  //After Delete
  if (Trigger.isDelete && Trigger.isAfter) {
    //ToDo
  }
}
