exports = async function(name){
  // This default function will get a value and find a document in MongoDB
  // To see plenty more examples of what you can do with functions see: 
  // https://www.mongodb.com/docs/atlas/app-services/functions/

  // Find the name of the MongoDB service you want to use (see "Linked Data Sources" tab)
  var serviceName = "secondcents-crud";
  var dbName = "app_database";
  var collName = "dumbshit";

  // Get a collection from the context
  var collection = context.services.get(serviceName).db(dbName).collection(collName);
  try {
    // Get a value from the context (see "Values" tab)
    // Update this to reflect your value's name.

    // Execute a FindOne in MongoDB 
    insertOne = await collection.insertOne(
      {"_id": ObjectId, "name": name},
    );

  } catch(err) {
    console.log("Error occurred while executing findOne:", err.message);

    return { error: err.message };
  }
};
