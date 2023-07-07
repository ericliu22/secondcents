//
//  TwoCentsApp.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/7.
//

import SwiftUI
import RealmSwift
import UIKit
typealias SwiftApp = SwiftUI.App
typealias RealmApp = RealmSwift.App
typealias SwiftList = SwiftUI.List
typealias RealmList = RealmSwift.List

func imageToByteArray(imageData:NSData) -> Array<UInt8>
{

  // the number of elements:
  let count = imageData.length / MemoryLayout<Int8>.size

  // create array of appropriate length:
  var bytes = [UInt8](repeating: 0, count: count)

  // copy bytes into array
  imageData.getBytes(&bytes, length:count * MemoryLayout<Int8>.size)

  var byteArray:Array = Array<UInt8>()

  for i in 0 ..< count {
    byteArray.append(bytes[i])
  }

  return byteArray


}
func arrayToList<T>(array:Array<T>) -> RealmList<Int>
{
    var intArray: Array<Int> = []
    for i in array {
        var int8: Int8 = Int8(i as! UInt8)
        var int: Int = Int(int8)
        intArray.append(int)
    }
    let outputList = RealmList<Int>()
    outputList.append(objectsIn: array)
    return outputList
}

let imageName = "yourImage.png"
let image = UIImage(named: "ASDf.png")
let data = image!.jpegData(compressionQuality: 1.0)
let byteArray = imageToByteArray(imageData: NSData(data: data!))
let imageBytes = arrayToList(array: byteArray)
let user = User(displayName: "Jennie Kim", profilePic: imageBytes, username: "jennierubyjane")

@main
struct TwoCentsApp: SwiftApp {
    let realm = try! Realm()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


