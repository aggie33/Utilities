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
    var view: Wrapped
    
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
}
#endif


                

