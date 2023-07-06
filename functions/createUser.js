exports = async function(authEvent) {
  const mongodb = context.services.get("mongodb-atlas");
  const users = mongodb.db("app_database").collection("users");

  const { user, time } = authEvent;
  const newUser = { ...user, eventLog: [ { "created": time } ] };
  
  await users.insertOne(newUser);
  await users.updateOne({ id: newUser.id },
   { $set:
      {
        "displayName": "",
        "profilePic":[],
        "username": "",
      }
   }
  )
}