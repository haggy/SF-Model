# Salesforce Models


## Examples


### Querying records by ID
```java
// Instatiate a new model for Contacts
DbModel model = new DbModel('Contact');

// Select Name, MailingStreet, and Account.Name
// then find a contact by it's ID
DbRecord firstContact = model.selectField('Name')
    .selectField('MailingStreet')
    .selectField('Account.Name')
    .findById('003i000000TQgjN');


System.debug('======> The contact\'s Name is ' + firstContact.getName());
System.debug('======> The contact\'s street is ' + firstContact.getString('MailingStreet'));
System.debug('======> The contact\'s Account Name is ' + firstContact.getRelatedFieldAsString('Account.Name'));
```

### Querying records by Name


### Saving records


### Deleting records