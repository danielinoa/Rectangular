//
//  Created by Daniel Inoa on 1/4/24.
//

/// A layout that arranges its items along the vertical axis.
public struct VStackLayout: Layout {

    private typealias Priority = Int
    private typealias SizedItem = (size: Size, item: any LayoutItem)
    private typealias IndexedItem = (index: Int, item: any LayoutItem)

    /// The vertical distance between adjacent items within the stack.
    public var spacing: Double

    public var alignment: HorizontalAlignment

    public init(alignment: HorizontalAlignment = .center, spacing: Double = .zero) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public func minimumSize(for items: [any LayoutItem]) -> Size {
        let totalInteritemSpacing = totalInteritemSpacing(for: items)
        let itemsHeight = items.map(\.intrinsicSize.height).reduce(.zero, +)
        let totalHeight = itemsHeight + totalInteritemSpacing
        let maxWidth = items.map(\.intrinsicSize.width).max() ?? .zero
        return .init(width: maxWidth, height: totalHeight)
    }

    public func sizeThatFits(items: [any LayoutItem], within size: Size) -> Size {
        let totalInteritemSpacing = totalInteritemSpacing(for: items)
        let itemsMaxHeight = items.map { $0.sizeThatFits(size).height }.reduce(.zero, +)
        let fittingWidth = items.map { $0.sizeThatFits(size).width }.max() ?? .zero
        let fittingHeight = (itemsMaxHeight + totalInteritemSpacing)
        let size = Size(width: fittingWidth, height: fittingHeight)
        return size
    }
    
    public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        var topOffset = bounds.topY
        let itemSizePairs = sizes(for: items, within: bounds.size)
        let frames = itemSizePairs.map { pair in
            let x = Self.leadingOffset(for: pair.size, aligned: alignment, within: bounds)
            let y = topOffset
            let frame = Rectangle(x: x, y: y, size: pair.size)
            topOffset += pair.size.height + spacing
            return frame
        }
        return frames
    }

    private func sizes(for items: [any LayoutItem], within size: Size) -> [SizedItem] {
        let pairs: [IndexedItem] = items.enumerated().map { ($0, $1) }
        var availableHeight = size.height - totalInteritemSpacing(for: items)
        var sizeTable: [Int: SizedItem] = [:]
        let priorityGroups: [Priority: [VStackLayout.IndexedItem]] = Dictionary(grouping: pairs, by: \.item.priority)
        for index in priorityGroups.keys.sorted(by: >) {
            let group = priorityGroups[index]!
            let availableSize = Size(width: size.width, height: availableHeight)
            let (groupSizeTable, remainingHeight) = fittingSizes(for: group, within: availableSize)
            sizeTable.merge(groupSizeTable) { current, new in current } // No duplicate values are expected.
            availableHeight = remainingHeight
        }
        return sizeTable
            .sorted { $0.key < $1.key } // ensures that items are in the order they were received.
            .map { ($0.value.size, $0.value.item) }
    }

    private func fittingSizes(
        for pairs: [IndexedItem], within size: Size
    ) -> (sizeTable: [Priority: SizedItem], remainingHeight: Double) {
        var sizeTable: [Priority: SizedItem] = .init()

        // The space that remains as views occupy the proposed size.
        var sharedAvailableHeight = size.height

        // The specified array of views, sorted in ascending manner based on their fitting width.
        // This ensures that each item gets as much available space as it needs.
        var heightAscendingPairs = pairs.sorted { $0.item.sizeThatFits(size).height < $1.item.sizeThatFits(size).height }

        // When calculating sizes all views start with an equal amount space within the "shared available space".
        // Any remaining space unused by a view is then returned to the "shared available space" for other views to use.
        // In order to ensure no space is wasted in the aforementioned step, the algorithm starts with the thinnest view
        // and works itself towards the widest view.
        while !heightAscendingPairs.isEmpty {
            // An equal amount of space for views yet to be added to the size-table.
            let equalAllotmentHeight = sharedAvailableHeight / Double(heightAscendingPairs.count)
            let pair = heightAscendingPairs.removeFirst()
            let fittingSize = pair.item.sizeThatFits(.init(width: size.width, height: equalAllotmentHeight))
            sizeTable[pair.index] = (fittingSize, pair.item)
            sharedAvailableHeight = max(sharedAvailableHeight - fittingSize.height, .zero)
        }
        return (sizeTable, sharedAvailableHeight)
    }

    private static func leadingOffset(for size: Size, aligned: HorizontalAlignment, within bounds: Rectangle) -> Double {
        let shift: Double
        switch aligned {
        case .leading: shift = .zero
        case .center: shift = (bounds.width - size.width) / 2
        case .trailing: shift = bounds.width - size.width
        }
        return bounds.leadingX + shift
    }

    private func totalInteritemSpacing(for items: [any LayoutItem]) -> Double {
        !items.isEmpty ? spacing * Double(items.count - 1) : .zero
    }
}
