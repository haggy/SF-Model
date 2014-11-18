public abstract class AbstractBaseModel {
	/* API name for the object in context */
	protected String objectType;
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
	/* Holds the describe result for the object */
	protected Schema.DescribeSObjectResult objectDescribe {
		get {
			if(objectDescribe == null) {
				this.loadObjectDescribe();
			}
			return objectDescribe;
		}
		private set;
	}
	/* Instance of SoqlBuilder. This can be accessed by child classes for modification before querying. */
	protected al.SoqlBuilder builder {
		get {
			if(builder == null) {
				builder = new al.SoqlBuilder();
			}
			return builder;
		}
		private set;
	}

	protected AbstractBaseModel(String objType) { 
		this.objectType = objType;
		explicitFieldsSet = false;
	}

	protected AbstractBaseModel(String objType, sObject obj) {
		this.objectType = objType;
		this.record = obj;
		explicitFieldsSet = false;
	}

	// State var which keeps track of whether the user has set
	// fields or not
	protected Boolean explicitFieldsSet;

	// Global describe
	private static Map<String, Schema.SObjectType> globalDescribeMap;

	/*
	------------------------------------------------------------|
	| Mandatory overrides in child class						|
	------------------------------------------------------------|
	*/
	//protected abstract List<sObject> getRecords(Set<Id> objIdSet);

	protected abstract List<DbRecord> castToModelObjects(List<sObject> objectList);

	/**
	* Use this to add fields to select statement
	* @param al.SoqlBuilder builder
	**/
	private void setDefaultSelect(al.SoqlBuilder builder) {
		builder.selectx(getAllFields());
	}


	/*
	------------------------------------------------------------|
	| Public methods											|
	------------------------------------------------------------|
	*/


	/**
	* Retrieves list of models for the given set of ID's
	* @param Set<Id>
	* @return List<DbRecord>
	**/
	public List<DbRecord> findById(Set<Id> recordIdSet) {
		if(recordIdSet == null || recordIdSet.size() == 0) {
			return this.castToModelObjects(new List<sObject>());
		}

		this.buildQuery(recordIdSet);
		List<sObject> objectList = this.query(this.builder);
		return this.castToModelObjects(objectList);
	}

	/**
	* Retrieves a model for the given ID
	* @param Id
	* @return DbRecord
	**/
	public DbRecord findById(Id recordId) {
		if(recordId == null) {
			return null;
		}

		this.buildQuery(new Set<Id> {recordId});
		List<sObject> objectList = this.query(this.builder);
		List<DbRecord> modelList = this.castToModelObjects(objectList);

		if(modelList.isEmpty()) {
			return null;
		}
		
		return modelList[0];
	}

	/**
	* Retrieves a model models for the given name
	* @param String name
	* @return DbRecord
	**/
	public DbRecord findByName(String name) {
		if(name == null || name.trim().equals('')) {
			return null;
		}

		List<DbRecord> models = findByName(new Set<String> { name });
		if(models.isEmpty()) {
			return null;
		}
		return models[0];
	}

	/**
	* Retrieves list of models for the given set of names
	* @param Set<String>
	* @return List<DbRecord>
	**/
	public List<DbRecord> findByName(Set<String> nameSet) {
		if(nameSet == null || nameSet.size() == 0) {
			return this.castToModelObjects(new List<sObject>());
		}

		this.buildQuery();

		// Add name filter
		List<String> nameList = new List<String>();
		nameList.addAll(nameSet);
		this.builder.wherex(new al.SetCondition('Name', al.Operator.INX, nameList));

		List<sObject> objectList = this.query(this.builder);
		return this.castToModelObjects(objectList);
	}

    /**
    * Saves a single DbRecord
    **/
    public void save(DbRecord rec) {
        if(rec == null) return;

        if(rec.getId() != null) {
            update rec.record;
        } else {
            insert rec.record;
        }
    }

	/**
	* Bulkified save operation
	**/
	public virtual void save(List<DbRecord> recordList) {
		// When working with generic sObject's, upsert
		// operations are not allowed. To get around this, 
		// we check the ID attribute and either insert or update
		List<sObject> updateList = new List<sObject>();
		List<sObject> insertList = new List<sObject>();
		for(DbRecord model : recordList) {
			if(model.getId() == null) {
				insertList.add(model.record);
			} else {
				updateList.add(model.record);
			}
		}

		if(insertList.size() > 0) {
			insert insertList;
		}
		if(updateList.size() > 0) {
			update updateList;
		}
	}

    /**
    * Delete a single DbRecord 
    **/
    public void remove(DbRecord rec) {
        if(rec.getId() == null) return;

        delete rec.record;
    }

	/**
	* Bulkified delete operation
	**/
	public void remove(List<DbRecord> recordList) {
		List<sObject> deleteList = new List<sObject>();

		for(DbRecord model : recordList) {
			deleteList.add(model.record);
		}
		delete deleteList;
	}

	/**
	* Creates a new list of models based on the given list of records
	* @param List<sObject>
	* @return List<DbRecord>
	**/
	public List<DbRecord> createModels(List<sObject> recordList) {
		return castToModelObjects(recordList);
	}

	/**
	* Converts a list of models to a map of ID->Model
	* @param List<AbstractBaseModel> records
	* @return Map<Id, AbstractBaseModel>
	**/
	//public Map<Id, AbstractBaseModel> toMap(List<AbstractBaseModel> records) {
	//	Map<Id, AbstractBaseModel> modelMap = new Map<Id, AbstractBaseModel>();
	//	if(records == null || records.isEmpty()) {
	//		return modelMap;
	//	}

	//	for(AbstractBaseModel record : records) {
	//		modelMap.put(record.getId(), record);
	//	}
	//	return modelMap;
	//}


	/*
	------------------------------------------------------------|
	| Private/Protected methods									|
	------------------------------------------------------------|
	*/

	/**
	* Creates a new empty sObject
	* @return sObject
	**/
	private sObject newSObject() {
		return Schema.getGlobalDescribe().get(this.objectType).newSObject() ;
	}

	/**
	* Returns all fields for this object
	**/
	protected Set<String> getAllFields() {
		return this.objectDescribe.fields.getMap().keySet();
	}

	/**
	* Callback function called before a query is initiated
	* This can be used to change the query before it is initiated
	* @param al.SoqlBuilder builder
	* @return al.SoqlBuilder
	**/
	protected virtual void beforeQuery(al.SoqlBuilder builder) { }

	private void setFrom(al.SoqlBuilder builder) {
		builder.fromx(this.objectType);
	}

	/**
	* Use this to add conditions to where statement
	* @param al.SoqlBuilder builder
	* @return al.SoqlBuilder
	**/
	protected virtual void setWhere(al.SoqlBuilder builder) { }

	/**
	* Use this to add conditions to where statement
	* This must be changed from a Set to a List since SoqlBuilder does not support an "includes"
	* statement with a Set
	* @param al.SoqlBuilder builder
	* @return al.SoqlBuilder
	**/
	protected virtual void setWhere(al.SoqlBuilder builder, Set<Id> recordIdSet) { 
		List<Id> idList = new List<Id>();
		idList.addAll(recordIdSet);
		builder.wherex(new al.SetCondition('Id', al.Operator.INX, idList));
	}

	/**
	* Builds query within SoqlBuilder
	**/
	protected void buildQuery() {
		if(!explicitFieldsSet) {
			this.setDefaultSelect(this.builder);
		}
		this.setFrom(this.builder);
		this.setWhere(this.builder);
		this.beforeQuery(this.builder);
	}

	/**
	* Builds query within SoqlBuilder
	**/
	protected void buildQuery(Set<Id> recordIdSet) {
		if(!explicitFieldsSet) {
			this.setDefaultSelect(this.builder);
		}
		this.setFrom(this.builder);
		this.setWhere(this.builder, recordIdSet);
		this.beforeQuery(this.builder);
	}

	/**
	* Executes a query
	* @param al.SoqlBuilder
	* @return List<sObject>
	**/
	protected List<sObject> query(al.SoqlBuilder builder) {
		return Database.query(builder.toSoql());
	}

	/**
	* Returns a global describe map
	* @return Map<String, Schema.SObjectType>
	**/
	private static Map<String, Schema.SObjectType> getGlobalDescribe() {
		if(globalDescribeMap == null) {
			globalDescribeMap = Schema.getGlobalDescribe();
		}
		return globalDescribeMap;
	}

	/**
	* Finds and sets the object describe associated with the object type set
	* @throws CustomException.SchemaException - If it is an invalid object type
	**/
	private void loadObjectDescribe() {
		List<Schema.SObjectType> globalDescribe = getGlobalDescribe().values();   
		for(Schema.SObjectType objectDescribe : globalDescribe) {
			if(objectDescribe.getDescribe().getName() == this.objectType){
				this.objectDescribe = objectDescribe.getDescribe();

				// Make sure object can be queried. If not, throw an error
				if(!this.objectDescribe.isQueryable()) {
					throw new CustomException.ApplicationException(this.objectType + ' is not queryable.');
				}
				break;
			}
		}

		// If objectDescribe was never set, throw error
		if(this.objectDescribe == null) {
			throw new CustomException.ApplicationException('Invalid object type specified: ' + this.objectType);
		}
	}
}