@resultBuilder public struct ArrayBuilder<Element> {
    public static func buildBlock(_ components: Element...) -> [Element] { components }
    public static func buildArray(_ components: [[Element]]) -> [Element] { components.reduce([], +) }
    public static func buildOptional(_ component: [Element]?) -> [Element] { component ?? [] }
    public static func buildEither(first component: [Element]) -> [Element] { component }
    public static func buildEither(second component: [Element]) -> [Element] { component }
}

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
import SwiftUI
#endif

#if os(iOS) || os(tvOS)
import UIKit
public typealias PlatformView = UIView
@available(iOS 13.0, tvOS 13.0, *) public typealias PlatformViewRepresentable = UIViewRepresentable
@available(iOS 13.0, tvOS 13.0, *) public typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(watchOS)
import WatchKit
public typealias PlatformView = WKInterfaceObject
@available(watchOS 6.0, *) public typealias PlatformViewRepresentable = WKInterfaceObjectRepresentable
#elseif os(macOS)
import AppKit
public typealias PlatformView = NSView
@available(macOS 10.15, *) public typealias PlatformViewRepresentable = NSViewRepresentable
#endif

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
import Foundation

extension NSObjectProtocol where Self: NSObject {
    @discardableResult public func set<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to newValue: T) -> Self {
        self[keyPath: keyPath] = newValue
        return self
    }
    
    @discardableResult public func with(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@dynamicMemberLookup public struct ViewWrapper<Wrapped: PlatformView>: PlatformViewRepresentable {
    public var view: Wrapped
    
    #if os(macOS)
    public func makeNSView(context: Context) -> Wrapped { view }
    public func updateNSView(_ nsView: Wrapped, context: Context) { }
    #elseif os(iOS) || os(tvOS)
    public func makeUIView(context: Context) -> Wrapped { view }
    public func updateUIView(_ nsView: Wrapped, context: Context) { }
    #elseif os(watchOS)
    public func makeWKInterfaceObject(context: Context) -> Wrapped { view }
    public func updateWKInterfaceObject(_ nsView: Wrapped, context: Context) { }
    #endif
    
    public init(_ view: Wrapped)  {
        self.view = view
    }
    
    public init(_ view: () -> Wrapped) {
        self.view = view()
    }
    
    public subscript<T>(dynamicMember dynamicMember: ReferenceWritableKeyPath<Wrapped, T>) -> (T) -> Self {
        return { value in
            self.view[keyPath: dynamicMember] = value
            return self
        }
    }
 
    public func finalize() -> some View {
        let size: CGSize
        #if os(iOS) || os(tvOS)
        size = view.sizeThatFits(.zero)
        #elseif os(macOS)
        size = view.intrinsicContentSize
        #elseif os(watchOS)
        fatalError("Cannot finalize on watchOS")
        #endif
        
        return self.frame(width: size.width, height: size.height)
    }
}

@propertyWrapper public struct Copying<T: NSCopying> {
    var _wrappedValue: T
    
    public var wrappedValue: T {
        get {
            _wrappedValue.copy() as! T
        }
        set {
            _wrappedValue = newValue
        }
    }
}

@available(tvOS 13.0, iOS 13.0, watchOS 6.0, macOS 10.15, *)
extension Color {
    public static var random: Self {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

#endif

public func ?? <T> (lhs: T?, rhs: @autoclosure () -> Never) -> T {
    if let lhs {
        return lhs
    } else {
        rhs()
    }
}

prefix operator ++
postfix operator ++

public prefix func ++ <T: Numeric> (rhs: inout T) -> T {
    rhs += 1
    return rhs
}

public postfix func ++ <T: Numeric> (lhs: inout T) {
    lhs += 1
}

extension Sequence where Element: AdditiveArithmetic {
    public var sum: Element {
        reduce(.zero, +)
    }
}

extension Sequence where Element: Numeric {
    public var product: Element {
        reduce(1, *)
    }
}

prefix operator +-

public prefix func +- <T: SignedNumeric> (rhs: T) -> (T, T) {
    return (rhs, -rhs)
}

// public typealias Result<Success, Failure> = Either<Success, Failure> where Failure: Error
// public typealias Optional<Wrapped> = Either<Wrapped, Void>

public enum Either<First, Second> {
    case first(First)
    case seecond(Second)
    
    public var firstValue: First? {
        if case let .first(first) = self {
            return first
        } else {
            return nil
        }
    }
    
    public var secondValue: Second? {
        if case let .seecond(second) = self {
            return second
        } else {
            return nil
        }
    }
}

prefix operator √

public prefix func √ <T: BinaryFloatingPoint> (rhs: T) -> T {
    rhs.squareRoot()
}

infix operator **

public func ** (lhs: Double, rhs: Double) -> Double {
    pow(lhs, rhs)
}

public func ** (lhs: Decimal, rhs: Int) -> Decimal {
    pow(lhs, rhs)
}

public func ** <T: Numeric> (lhs: T, rhs: Int) -> T {
    precondition(rhs >= 0, "Negative powers are not allowed")
    if rhs == 0 { return 1 } else if rhs == 1 { return lhs }
    
    var value = lhs
    for _ in 2...rhs {
        value *= lhs
    }
    
    return value
}

extension Result where Failure == Never {
    public var value: Success {
        switch self {
        case let .success(success):
            return success
        }
    }
}

