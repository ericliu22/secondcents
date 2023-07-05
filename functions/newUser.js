exports = async function(authEvent){
  // This default function will get a value and find a document in MongoDB
  // To see plenty more examples of what you can do with functions see: 
  // https://www.mongodb.com/docs/atlas/app-services/functions/

  // Find the name of the MongoDB service you want to use (see "Linked Data Sources" tab)
  var serviceName = "mongodb-atlas";

  // Update these to reflect your db/collection
  var dbName = "app_database";
  var collName = "users";
  

  // Get a collection from the context
  var collection = context.services.get(serviceName).db(dbName).collection(collName);

  const { user, time } = authEvent;
    return collection.insertOne({ _id: user._id, ...user })
     .catch(console.error)

  // To call other named functions:
  // var result = context.functions.execute("function_name", arg1, arg2);

  return { result: findResult };
};