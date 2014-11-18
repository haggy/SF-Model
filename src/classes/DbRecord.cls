public with sharing class DbRecord {
	/* Object type string */
	public String objectType { get; private set; }

	/* Instance of the record */
	public sObject record {
		get {
			if(record == null) {
				// This is a new record so create empty one
				record = newSObject();
			}
			return record;
		}

		/**
		* NOTE: Changing to public because of issue with using records in
		* VF pages. 
		* TODO: Need to dynamically typecast base records so that they can be used in VF
		**/
		public set;
	}

	public DbRecord(Schema.SObjectType objType) {
		this.objectType = String.valueOf(objType);
	}

	public DbRecord(String objType) {
		this.objectType = objType;
	}

	public DbRecord(String objType, sObject obj) {
		this.objectType = objType;
		record = obj;
	}

	public sObject getRecord() {
		return record;
	}

	/**
	* Sets a field on the record
	* @param Schema.SObjectField
	* @param Object
	**/
	public void set(Schema.SObjectField field, Object val) {
		set(String.valueOf(field), val);
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField field
	* @return Object value
	**/
	public Object get(Schema.SObjectField field) {
		return this.record.get(String.valueOf(field));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return Object value
	**/
	public Object get(String fieldName) {
		return this.record.get(fieldName);
	}

	/**
	* Returns the Id for the record
	* @return Id
	**/
	public Id getId() {
		return (Id)this.record.get('Id');
	}

	/**
	* Returns the name for the record
	* @return Id
	**/
	public String getName() {
		return String.valueOf(this.record.get('Name'));
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return Id value
	**/
	public Id getId(Schema.SObjectField fieldName) {
		return getId(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return Id value
	**/
	public Id getId(String fieldName) {
		return (Id)this.record.get(fieldName);
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return String value
	**/
	public String getString(Schema.SObjectField fieldName) {
		return getString(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return String value
	**/
	public String getString(String fieldName) {
		return String.valueOf(get(fieldName));
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return Integer value
	**/
	public Integer getInteger(Schema.SObjectField fieldName) {
		return getInteger(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return Integer value
	**/
	public Integer getInteger(String fieldName) {
		return Integer.valueOf(get(fieldName));
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return Double value
	**/
	public Double getDouble(Schema.SObjectField fieldName) {
		return getDouble(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return Double value
	**/
	public Double getDouble(String fieldName) {
		return Double.valueOf(get(fieldName));
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return Boolean value
	**/
	public Boolean getBoolean(Schema.SObjectField fieldName) {
		return getBoolean(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return Boolean value
	**/
	public Boolean getBoolean(String fieldName) {
		return Boolean.valueOf(get(fieldName));
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return Date value
	**/
	public Date getDate(Schema.SObjectField fieldName) {
		return getDate(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return Date value
	**/
	public Date getDate(String fieldName) {
		return Date.valueOf(get(fieldName));
	}

	/**
	* Returns a field from the record
	* @param Schema.SObjectField fieldName
	* @return DateTime value
	**/
	public DateTime getDateTime(Schema.SObjectField fieldName) {
		return getDateTime(String.valueOf(fieldName));
	}

	/**
	* Returns a field from the record
	* @param String fieldName
	* @return DateTime value
	**/
	public DateTime getDateTime(String fieldName) {
		return DateTime.valueOf(get(fieldName));
	}

	/**
	* Returns a related object field
	* @param String fullyQualifiedName
	* @return Object value
	**/
	public Object getRelatedField(String fullyQualifiedName) {
		List<String> parts = fullyQualifiedName.split('\\.');
		if(parts.size() <= 1) {
			throw new CustomException.ApplicationException('Invalid related lookup field specified: ' + fullyQualifiedName);
		}

		// We need to loop parts.size() - 1 times to get to the value
		// The related lookup could go upwards of 5 levels deep
		Integer index = 0;
		sObject relatedObj;
		do {
			if(relatedObj == null) {
				relatedObj = this.record.getSObject(parts[index]);
			} else {
				relatedObj = relatedObj.getSObject(parts[index]);
			}
			index++;

		} while(index < parts.size() - 1);
		String fieldName = parts[index];

		if(relatedObj == null) {
			// There was a null value for this related lookup
			return null;
		}

		return relatedObj.get(fieldName);
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return String
	**/
	public String getRelatedFieldAsString(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsString(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field
	* @param String fullyQualifiedName
	* @return String value
	**/
	public String getRelatedFieldAsString(String fullyQualifiedName) {
		return String.valueOf(this.getRelatedField(fullyQualifiedName));
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return Id
	**/
	public Id getRelatedFieldAsId(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsId(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field
	* @param String fullyQualifiedName
	* @return Id value
	**/
	public Id getRelatedFieldAsId(String fullyQualifiedName) {
		return (Id)this.getRelatedField(fullyQualifiedName);
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return Integer
	**/
	public Integer getRelatedFieldAsInteger(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsInteger(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field
	* @param String fullyQualifiedName
	* @return Integer value
	**/
	public Integer getRelatedFieldAsInteger(String fullyQualifiedName) {
		return Integer.valueOf(this.getRelatedField(fullyQualifiedName));
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return Double
	**/
	public Double getRelatedFieldAsDouble(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsDouble(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field as double
	* @param String fullyQualifiedName
	* @return Double value
	**/
	public Double getRelatedFieldAsDouble(String fullyQualifiedName) {
		return Double.valueOf(this.getRelatedField(fullyQualifiedName));
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return Boolean
	**/
	public Boolean getRelatedFieldAsBoolean(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsBoolean(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field as double
	* @param String fullyQualifiedName
	* @return Boolean value
	**/
	public Boolean getRelatedFieldAsBoolean(String fullyQualifiedName) {
		return Boolean.valueOf(this.getRelatedField(fullyQualifiedName));
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return Date
	**/
	public Date getRelatedFieldAsDate(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsDate(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field as Date
	* @param String fullyQualifiedName
	* @return Date value
	**/
	public Date getRelatedFieldAsDate(String fullyQualifiedName) {
		return Date.valueOf(this.getRelatedField(fullyQualifiedName));
	}

	/**
	* Returns a related object field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return DateTime
	**/
	public DateTime getRelatedFieldAsDateTime(Schema.SObjectType type, Schema.SObjectField field) {
		return getRelatedFieldAsDateTime(getFullyQualifiedName(type, field));
	}

	/**
	* Returns a related object field as DateTime
	* @param String fullyQualifiedName
	* @return DateTime value
	**/
	public DateTime getRelatedFieldAsDateTime(String fullyQualifiedName) {
		return DateTime.valueOf(this.getRelatedField(fullyQualifiedName));
	}

	/**
	* Returns the child records from a related lookup
	* @param String childRelName - The name of the related child object (ex. Contacts)
	* @return List<sObject>
	**/
	public List<sObject> getChildRecords(String childRelName) {
		return record.getSObjects(childRelName);
	}

	/*
	--------------------------------------------------------|
	| Private internal methods								|
	--------------------------------------------------------|
	*/
	/**
	* Sets a string field value on the record
	* @param String fieldName
	* @param String value
	**/
	private void set(String fieldName, Object value) {
		this.record.put(fieldName, value);
	}

	/**
	* Creates a new empty sObject
	* @return sObject
	**/
	private sObject newSObject() {
		return Schema.getGlobalDescribe().get(this.objectType).newSObject() ;
	}

	/**
	* Returns a fully qualified name given a type and field
	* @param Schema.SObjectType type
	* @param Schema.SObjectField field
	* @return String
	**/
	private static String getFullyQualifiedName(Schema.SObjectType type, Schema.SObjectField field) {
		return String.valueOf(type) + '.' + String.valueOf(field);
	}


}