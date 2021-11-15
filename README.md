# Create an Apex backend

```iDEM Connect``` launch a new project to help sales reps sell smarter and track sales, customers and contracts.

## Here is a list of features/rules to be implemented:

### RG-01
The user can pass the status of the order to "Active" only if the order in question has related products".

### RG-02
When an order is added to an account, a custom field "Active" is checked automatically.
If all the orders associated with this account are deleted, the "Active" checkbox of the account has to be unchecked.

### RG-03
A reminder task has to be sent to the account owner if there are no orders associated with his account.
This activity has to be created if there is no "Call" tasks added to the account in question. 
This treatment should be triggered on the first Monday of each month. 
