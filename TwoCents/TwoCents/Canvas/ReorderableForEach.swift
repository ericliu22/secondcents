//
//  ReorderableForEach.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/10/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ReorderableForEach<Content: View, Item: Identifiable & Equatable>: View {
    let items: [Item]
    let content: (Item) -> Content
    let moveAction: (IndexSet, Int) -> Void
    @State private var hasChangedLocation: Bool = false

    init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) {
        self.items = items
        self.content = content
        self.moveAction = moveAction
    }
    
    @State private var draggingItem: Item?
    
    var body: some View {
        ForEach(items) { item in
            content(item)
                .onDrag {
                    draggingItem = item
                    return NSItemProvider(object: "\(item.id)" as NSString)
                }.onDrop(
                    of: [UTType.text],
                    delegate: DragRelocateDelegate(
                        item: item,
                        listData: items,
                        current: $draggingItem,
                        hasChangedLocation: $hasChangedLocation
                    ) { from, to in
                        withAnimation {
                            moveAction(from, to)
                        }
                    }
                )
        }
    }
}

struct DragRelocateDelegate<Item: Equatable>: DropDelegate {
    let item: Item
    var listData: [Item]
    @Binding var current: Item?
    @Binding var hasChangedLocation: Bool

    var moveAction: (IndexSet, Int) -> Void

    func dropEntered(info: DropInfo) {
        guard item != current, let current = current else { return }
        guard let from = listData.firstIndex(of: current), let to = listData.firstIndex(of: item) else { return }
        
        hasChangedLocation = true

        if listData[to] != current {
            moveAction(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        current = nil
        return true
    }
}
