/**
* Generic model class for all sObjects
*
* This class depends on the SoqlBuilder library in the apex-lang package. This needs to be installed prior to
* this class being installed. 
* Apex-Lang download: https://code.google.com/p/apex-lang/
* SoqlBuilder reference: http://richardvanhook.com/2010/04/11/soql-builder/
*
**/
public class DbModel extends AbstractBaseModel {
	
	/* Keeps track of the fields that have been added */
	private Set<String> trackedFields;

	public DbModel(Schema.SObjectType objType) {
		super(String.valueOf(objType));
		trackedFields = new Set<String>();
	}

	public DbModel(String objType) {
		super(objType);
		trackedFields = new Set<String>();
	}

	public DbModel(String objType, sObject obj) {
		super(objType, obj);
		trackedFields = new Set<String>();
	}

	protected override List<DbRecord> castToModelObjects(List<sObject> objectList) {
		List<DbRecord> modelList = new List<DbRecord>();
		for(sObject obj : objectList) {
			modelList.add(new DbRecord( this.objectType, obj ));
		}
		return modelList;
	}

	public DbModel selectField(String field) {
		addField(field);
		return this;
	}

	public DbModel selectField(Schema.SObjectField field) {
		addField(String.valueOf(field));
		return this;
	}

	//public DbModel selectField(Schema.SObjectField relatedField, Schema.SObjectField fieldOnRelatedObject) {
	//	addField(getFullyQualifiedName(relatedField, fieldOnRelatedObject));
	//	return this;
	//}

	public DbModel selectFields(List<Schema.SObjectField> fields) {
		for(Schema.SObjectField field : fields) {
			addField(field.getDescribe().getName());
		}
		return this;
	}

	public DbModel selectChildRecords(String relatedName, Schema.SObjectType type, Set<Schema.SObjectField> fields) {
		Set<String> sFields = new Set<String>();
		for(Schema.SObjectField currField : fields) {
			// Add field as [TYPE].[FIELD_NAME]
			sFields.add(getFullyQualifiedName(type, currField));
		}
		return selectChildRecords(relatedName, sFields);
	}

	public DbModel selectChildRecords(String relatedName, Set<String> fields) {
		builder.selectx(
			new al.SoqlBuilder()
			.selectx(fields)
			.fromx(relatedName)
		);
		return this;
	}



	/**
	* --------------------------------------------------------|
	* | Private methods										  |
	* --------------------------------------------------------|
	**/

	/**
	* Adds the given set of fields to the SOQL builder
	* if it has not already been added
	**/
	private DbModel addFields(Set<String> fields) {
		Set<String> fieldsToAdd = new Set<String>();
		for(String field : fields) {
			if(!trackedFields.contains(field)) {
				trackedFields.add(field);
				fieldsToAdd.add(field);
			}
		}

		if(fieldsToAdd.isEmpty()) return this;

		explicitFieldsSet = true;
		builder.selectx(fieldsToAdd);
		return this;
	}

	private DbModel addField(String field) {
		addFields(new Set<String> { field });
		return this;
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

	/**
	* Returns a fully qualified name given 2 fields
	* @param Schema.SObjectField field1
	* @param Schema.SObjectField field2
	* @return String
	**/
	private static String getFullyQualifiedName(Schema.SObjectField field1, Schema.SObjectField field2) {
		return String.valueOf(field1) + '.' + String.valueOf(field2);
	}
}