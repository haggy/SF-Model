# Salesforce Models


## Examples


### Querying records by ID
```java
// Instatiate a new model for Contacts
DbModel model = new DbModel('Account');

// Select Name, NumberOfEmployees and AccountNumber
// and find an account by ID
DbRecord acct = model.selectFields(new List<Schema.SObjectField> {
        Account.Name, 
        Account.NumberOfEmployees,
        Account.AccountNumber
    })
    .findById('001i000000QiYDY');

System.debug('======> The account\'s Name is: ' + acct.getName());
System.debug('======> Number of employees: ' + acct.getInteger(Account.NumberOfEmployees));

// You can also pass findById a set of ID's to look for
List<DbRecord> accounts = model.selectFields(new List<Schema.SObjectField> {
        Account.Name, 
        Account.NumberOfEmployees,
        Account.AccountNumber
    })
    .findById(new Set<Id> { '001i000000QiYDY' });
```

### Querying records by Name
```java
// Get an account with the name GenePoint
DbModel model = new DbModel('Account');
DbRecord acct = model.selectFields(new List<Schema.SObjectField> {
        Account.Name, 
        Account.NumberOfEmployees,
        Account.AccountNumber
    })
    .findByName('GenePoint');

System.debug('Account ID is: ' + acct.getId());


// You can also pass findByName a set of strings to search on
List<DbRecord> accounts = model.selectFields(new List<Schema.SObjectField> {
        Account.Name, 
        Account.NumberOfEmployees,
        Account.AccountNumber
    })
    .findByName(new Set<String> { 'GenePoint', 'ABC Company' });

System.debug('How many did we find? ' + accounts.size());
```


### Querying child records
```java
// Add all child Contacts to the query
// The first parameter is the child records related name
// and the second parameter is what fields you want to select
// In this case we are retrieving all contacts linked to this
// account and we are pulling in the Name and Title fields
DbRecord acct = model.selectField(Account.Name)
    .selectChildRecords('Contacts', new Set<String> {
        'Name',
        'Title'
    })
    .findById('001i000000QiYDY');

// Use the getChildRecords() method to retrieve the records
List<Contact> contacts = acct.getChildRecords('Contacts');
System.debug('======> The first contact name is: ' + contacts[0].Name);
```

### Saving records


### Deleting records