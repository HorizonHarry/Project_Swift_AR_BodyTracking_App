//
//  AppState.swift
//  BodyTracking
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isTracking: Bool = false
    @Published var statusMessage: String = "Searching for subject..."
    @Published var skeletonColor: Color = .cyan
    @Published var showSkeleton: Bool = true
    
    static let shared = AppState()
}
