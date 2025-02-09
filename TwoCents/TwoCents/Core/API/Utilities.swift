//
//  Utilities.swift
//  TwoCents
//
//  Created by Eric Liu on 2024/8/11.
//

import Foundation
import SwiftUI

func waitForVariable<T>(_ variable: @escaping () -> T?) -> T {
    let semaphore = DispatchSemaphore(value: 0)
    var result: T?

    DispatchQueue.global().async {
        while result == nil {
            if let value = variable() {
                result = value
                semaphore.signal()
            } else {
                usleep(100_000)  // sleep for 100ms to prevent busy waiting
            }
        }
    }

    semaphore.wait()
    return result!
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {

    static func fromString(name: String) -> Color {

        switch name {

        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "green":
            return Color.green
        case "mint":
            return Color.mint
        case "teal":
            return Color.teal
        case "cyan":
            return Color.cyan
        case "blue":
            return Color.blue
        case "indigo":
            return Color.indigo
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "brown":
            return Color.brown
        default:
            return Color.gray
        }

    }
}

//Size multiplier is width/height divided by TILE_SIZE
func roundToTile(number: CGFloat) -> CGFloat {
    let tile = WIDGET_SPACING
    return tile * CGFloat(Int(round(number / (tile))))
}

func getMultipliedSize(widthMultiplier: Int, heightMultiplier: Int) -> (
    CGFloat, CGFloat
) {
    let width: CGFloat =
        TILE_SIZE * CGFloat(widthMultiplier)
        + (max(CGFloat(widthMultiplier - 1), 0) * TILE_SPACING)
    let height: CGFloat =
        TILE_SIZE * CGFloat(heightMultiplier)
        + (max(CGFloat(heightMultiplier - 1), 0) * TILE_SPACING)

    return (width, height)
}

func getUID() async throws -> String? {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    return authDataResult.uid
}

func convertSwiftUIPointToUIKit(
    swiftUIPoint: CGPoint,
    geometry: GeometryProxy,
    hostView: UIView
) -> CGPoint {
    // 1) Get the SwiftUI view’s frame in the global (screen) coordinate space.
    let globalRect = geometry.frame(in: .global)
    // This rect’s origin is where the SwiftUI view starts on the screen.

    // 2) Add the SwiftUI point to the SwiftUI view’s global origin.
    //    That yields a "screen coordinate" in UIKit terms.
    let screenX = globalRect.origin.x + swiftUIPoint.x
    let screenY = globalRect.origin.y + swiftUIPoint.y
    let screenPoint = CGPoint(x: screenX, y: screenY)

    // 3) Convert from screen coords into `hostView`’s local coords.
    //    Passing `nil` for `from`/`to` generally means "the window’s coordinate space."
    let uiKitPoint = hostView.convert(screenPoint, from: nil)

    return uiKitPoint
}

/// Convert a point in hostView's UIKit coords to SwiftUI coords
/// (e.g., geometry's .global or .local).
func convertUIKitPointToSwiftUI(
    uiKitPoint: CGPoint,
    geometry: GeometryProxy,
    hostView: UIView
) -> CGPoint {
    // 1) Convert from the hostView’s local coords to the screen coords
    let screenPoint = hostView.convert(uiKitPoint, to: nil)

    // 2) Get the SwiftUI view’s global frame
    let globalRect = geometry.frame(in: .global)

    // 3) Subtract the SwiftUI view’s global origin from the screen point
    //    to get a local SwiftUI coordinate
    let swiftUIX = screenPoint.x - globalRect.origin.x
    let swiftUIY = screenPoint.y - globalRect.origin.y

    return CGPoint(x: swiftUIX, y: swiftUIY)
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

struct IdentifiedCollection<Element: Identifiable & Hashable>:
    RandomAccessCollection
{
    private var elements: [Element]
    private var elementsByID: [Element.ID: Int]  // store index for O(1) lookups

    init(_ elements: [Element] = []) {
        self.elements = elements
        self.elementsByID = Dictionary(
            uniqueKeysWithValues: elements.enumerated().map {
                (index, element) in
                (element.id, index)
            }
        )
    }

    // MARK: - RandomAccessCollection

    var startIndex: Int { elements.startIndex }
    var endIndex: Int { elements.endIndex }

    func index(after i: Int) -> Int {
        elements.index(after: i)
    }

    subscript(position: Int) -> Element {
        elements[position]
    }

    // MARK: - Custom lookups

    subscript(id id: Element.ID) -> Element? {
        guard let idx = elementsByID[id] else { return nil }
        return elements[idx]
    }

    // Example mutation
    mutating func append(_ element: Element) {
        elements.append(element)
        elementsByID[element.id] = elements.endIndex - 1
    }
    
    /// Removes the element with the given ID, if it exists.
    /// Returns the removed element or nil if not found.
    ///
    /// **Note:** Removing from the middle of the array is O(n),
    /// because we have to shift elements and update their indices.
    @discardableResult
    mutating func remove(id: Element.ID) -> Element? {
        guard let index = elementsByID[id] else {
            return nil
        }
        
        // Remove the element from the array
        let removedElement = elements.remove(at: index)
        
        // Remove the ID from our dictionary
        elementsByID[id] = nil
        
        // Update indices for all elements after the removed index
        for i in index..<elements.count {
            elementsByID[elements[i].id] = i
        }
        
        return removedElement
    }
    
    /// Removes and returns the element at the specified index.
    ///
    /// **Note:** Removing from the middle is O(n) because of shifting elements
    /// and updating dictionary entries for subsequent items.
    @discardableResult
    mutating func remove(at index: Int) -> Element {
        precondition(index >= startIndex && index < endIndex, "Index out of range.")
        
        let removedElement = elements.remove(at: index)
        elementsByID[removedElement.id] = nil
        
        // Update dictionary entries for all subsequent elements
        for i in index..<elements.count {
            elementsByID[elements[i].id] = i
        }
        
        return removedElement
    }
}
