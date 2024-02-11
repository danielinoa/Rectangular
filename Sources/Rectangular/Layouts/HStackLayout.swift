//
//  Created by Daniel Inoa on 12/30/23.
//

/// A layout that arranges its items along the horizontal axis.
public struct HStackLayout: Layout {

    private typealias Priority = Int
    private typealias SizedItem = (size: Size, item: any LayoutItem)
    private typealias IndexedItem = (index: Int, item: any LayoutItem)

    public var spacing: Double
    public var alignment: VerticalAlignment

    public init(alignment: VerticalAlignment = .center, spacing: Double = .zero) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public func sizeThatFits(items: [any LayoutItem]) -> Size {
        let totalInteritemSpacing = totalInteritemSpacing(for: items)
        let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
        let totalWidth = itemsWidth + totalInteritemSpacing
        let maxHeight = items.map(\.intrinsicSize.height).max() ?? .zero
        return .init(width: totalWidth, height: maxHeight)
    }

    public func sizeThatFits(items: [any LayoutItem], within size: Size) -> Size {
        let totalInteritemSpacing = totalInteritemSpacing(for: items)
        let itemsMaxWidth = items.map { $0.sizeThatFits(size).width }.reduce(.zero, +)
        // TODO: Should the fitting width be clamped or should it be allowed to overflow?
        let fittingWidth = (itemsMaxWidth + totalInteritemSpacing).clamped(upTo: size.width)
        let fittingHeight = items.map { $0.sizeThatFits(size).height }.max() ?? .zero
        let size = Size(width: fittingWidth, height: fittingHeight)
        return size
    }

    public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        var leadingOffset = bounds.leadingX
        let itemSizePairs = sizes(for: items, within: bounds.size)
        let frames = itemSizePairs.map { pair in
            let x = leadingOffset
            let y = Self.topOffset(for: pair.size, aligned: alignment, within: bounds)
            let frame = Rectangle(x: x, y: y, size: pair.size)
            leadingOffset += pair.size.width + spacing
            return frame
        }
        return frames
    }

    private func sizes(for items: [any LayoutItem], within size: Size) -> [SizedItem] {
        let pairs: [IndexedItem] = items.enumerated().map { ($0, $1) }
        var availableWidth = size.width - totalInteritemSpacing(for: items)
        var sizeTable: [Int: SizedItem] = [:]
        let priorityGroups: [Priority: [IndexedItem]] = Dictionary(grouping: pairs, by: \.item.priority)
        for index in priorityGroups.keys.sorted(by: >) {
            let group = priorityGroups[index]!
            let availableSize = Size(width: availableWidth, height: size.height)
            let (groupSizeTable, remainingWidth) = fittingSizes(for: group, within: availableSize)
            sizeTable.merge(groupSizeTable) { current, new in current } // No duplicate values are expected.
            availableWidth = remainingWidth
        }
        return sizeTable
            .sorted { $0.key < $1.key } // ensures that items are in the order they were received.
            .map { ($0.value.size, $0.value.item) }
    }

    private func fittingSizes(
        for pairs: [IndexedItem], within size: Size
    ) -> (sizeTable: [Priority: SizedItem], remainingWidth: Double) {
        var sizeTable: [Priority: SizedItem] = .init()

        // The space that remains as views occupy the proposed size.
        var sharedAvailableWidth = size.width

        // The specified array of views, sorted in ascending manner based on their fitting width.
        // This ensures that each item gets as much available space as it needs.
        var widthAscendingPairs = pairs.sorted { $0.item.sizeThatFits(size).width < $1.item.sizeThatFits(size).width }

        // When calculating sizes all views start with an equal amount space within the "shared available space".
        // Any remaining space unused by a view is then returned to the "shared available space" for other views to use.
        // In order to ensure no space is wasted in the aforementioned step, the algorithm starts with the thinnest view
        // and works itself towards the widest view.
        while !widthAscendingPairs.isEmpty {
            // An equal amount of space for views yet to be added to the size-table.
            let equalAllotmentWidth = sharedAvailableWidth / Double(widthAscendingPairs.count)
            let pair: IndexedItem = widthAscendingPairs.removeFirst()
            let sizeProposal = Size(width: equalAllotmentWidth, height: size.height)
            let fittingSize = pair.item.sizeThatFits(sizeProposal)
            sizeTable[pair.index] = (fittingSize, pair.item)
            sharedAvailableWidth = max(sharedAvailableWidth - fittingSize.width, .zero)
        }
        return (sizeTable, sharedAvailableWidth)
    }

    private static func topOffset(for size: Size, aligned: VerticalAlignment, within bounds: Rectangle) -> Double {
        let shift: Double
        switch aligned {
        case .top: shift = .zero
        case .center: shift = (bounds.height - size.height) / 2
        case .bottom: shift = bounds.height - size.height
        }
        return bounds.topY + shift
    }

    private func totalInteritemSpacing(for items: [any LayoutItem]) -> Double {
        !items.isEmpty ? spacing * Double(items.count - 1) : .zero
    }
}
