//
//  Created by Daniel Inoa on 2/11/24.
//

// TODO: Add documentation

public struct HFlexLayout: Layout {

    public var distribution: Distribution
    public var alignment: VerticalAlignment

    /// The minimum interitem spacing.
    public var gap: Double

    public init(distribution: Distribution = .center, alignment: VerticalAlignment = .center, gap: Double = .zero) {
        self.alignment = alignment
        self.distribution = distribution
        self.gap = gap
    }

    public func sizeThatFits(items: [LayoutItem]) -> Size {
        let totalInteritemSpacing: Double = !items.isEmpty ? Double(items.count - 1) * gap : .zero
        let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
        let totalWidth = itemsWidth + totalInteritemSpacing
        let maxHeight = items.map(\.intrinsicSize.height).max() ?? .zero
        return .init(width: totalWidth, height: maxHeight)
    }
    
    public func sizeThatFits(items: [LayoutItem], within proposal: Size) -> Size {
        let fittingHeight = items.map { $0.sizeThatFits(proposal).height }.max() ?? .zero
        return .init(width: proposal.width, height: fittingHeight)
    }
    
    public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        switch distribution {
        case .start:
            var leadingOffset = bounds.leadingX
            let frames: [Rectangle] = items.map { item in
                // Unlike HStack, items in a HFlex do not compete for space and instead are free to overflow.
                // TODO: Check assumption
                let size = item.intrinsicSize
                let x = leadingOffset
                let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
                let frame = Rectangle(x: x, y: y, size: size)
                leadingOffset += size.width + gap
                return frame
            }
            return frames
        case .end:
            let intrinsicWidth = sizeThatFits(items: items).width
            let remainingWidth = bounds.width - intrinsicWidth
            var leadingOffset = bounds.leadingX + remainingWidth
            let frames: [Rectangle] = items.map { item in
                // Unlike HStack, items in a HFlex do not compete for space and instead are free to overflow.
                // TODO: Check assumption
                let size = item.intrinsicSize
                let x = leadingOffset
                let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
                let frame = Rectangle(x: x, y: y, size: size)
                leadingOffset += size.width + gap
                return frame
            }
            return frames
        case .center:
            let intrinsicWidth = sizeThatFits(items: items).width
            let remainingWidth = bounds.width - intrinsicWidth
            var leadingOffset = bounds.leadingX + (remainingWidth / 2)
            let frames: [Rectangle] = items.map { item in
                // Unlike HStack, items in a HFlex do not compete for space and instead are free to overflow.
                // TODO: Check assumption
                let size = item.intrinsicSize
                let x = leadingOffset
                let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
                let frame = Rectangle(x: x, y: y, size: size)
                leadingOffset += size.width + gap
                return frame
            }
            return frames
        case .spaceBetween:
            // TODO: Use `gap` as minimum interim spacing.
            let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
            let remainingSpace = bounds.width - itemsWidth
            let interitemSpacing = items.count == 1 ? remainingSpace : remainingSpace / Double(items.count - 1)
            var leadingOffset = bounds.leadingX
            let frames: [Rectangle] = items.map { item in
                // Unlike HStack, items in a HFlex do not compete for space and instead are free to overflow.
                // TODO: Check assumption
                let size = item.intrinsicSize
                let x = leadingOffset
                let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
                let frame = Rectangle(x: x, y: y, size: size)
                leadingOffset += size.width + interitemSpacing
                return frame
            }
            return frames
        case .spaceAround:
            // TODO: Use `gap` as minimum interim spacing.
            let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
            let remainingSpace = bounds.width - itemsWidth
            let interitemSpacing = items.count == 1 ? remainingSpace : remainingSpace / Double(items.count - 1)
            let horizontalPadding = interitemSpacing / 2 * Double(items.count)
            var leadingOffset = bounds.leadingX
            let frames: [Rectangle] = items.map { item in
                leadingOffset += horizontalPadding
                let size = item.intrinsicSize
                let x = leadingOffset
                let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
                let frame = Rectangle(x: x, y: y, size: size)
                leadingOffset += size.width + horizontalPadding
                return frame
            }
            return frames
        case .spaceEvenly:
            // TODO: Use `gap` as minimum interim spacing.
            let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
            let remainingSpace = bounds.width - itemsWidth
            let interitemSpacing = items.count == 1 ? remainingSpace : remainingSpace / Double(items.count - 1)
            var leadingOffset = bounds.leadingX + interitemSpacing
            let frames: [Rectangle] = items.map { item in
                // Unlike HStack, items in a HFlex do not compete for space and instead are free to overflow.
                // TODO: Check assumption
                let size = item.intrinsicSize
                let x = leadingOffset
                let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
                let frame = Rectangle(x: x, y: y, size: size)
                leadingOffset += size.width + interitemSpacing
                return frame
            }
            return frames
        }
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
}

extension HFlexLayout {

    /// The layout that defines the position of layout items along the horizontal axis.
    public enum Distribution {
        case start
        case end
        case center
        case spaceBetween
        case spaceAround
        case spaceEvenly
    }
}
