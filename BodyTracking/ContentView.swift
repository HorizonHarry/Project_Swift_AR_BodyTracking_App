//
//  ContentView.swift
//  BodyTracking
//
//  Created by Harry Horizon on 9/12/2567 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            OverlayView()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
