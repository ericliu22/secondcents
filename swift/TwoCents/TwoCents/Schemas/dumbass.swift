import Foundation
import RealmSwift

class dumbass: Object {
    @Persisted(primaryKey: true) var _id: ObjectId?

    @Persisted var name: String = ""
}
