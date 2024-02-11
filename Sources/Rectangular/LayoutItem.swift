//
//  Created by Daniel Inoa on 1/1/24.
//

public protocol LayoutItem {
    var priority: Int { get }
    var intrinsicSize: Size { get }
    func sizeThatFits(_ size: Size) -> Size
}

public extension LayoutItem {
    var priority: Int { .zero }
    var intrinsicSize: Size { .zero }
}
