//
//  OverlayView.swift
//  BodyTracking
//

import SwiftUI

struct OverlayView: View {
    @ObservedObject var appState = AppState.shared
    @State private var showSettings = false
    
    var body: some View {
        VStack {
            // Status Bar
            HStack {
                Circle()
                    .fill(appState.isTracking ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                    .shadow(color: appState.isTracking ? .green : .red, radius: 5)
                
                Text(appState.statusMessage)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                if appState.isTracking {
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.4))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 50)
            
            Spacer()
            
            // Bottom Controls
            HStack(spacing: 30) {
                ControlButton(icon: appState.showSkeleton ? "eye.fill" : "eye.slash.fill", label: "Skeleton") {
                    appState.showSkeleton.toggle()
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 4)
                    )
                    .onTapGesture {
                        // Action for capture could be added here
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                
                ControlButton(icon: "gearshape.fill", label: "Settings") {
                    showSettings.toggle()
                }
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @ObservedObject var appState = AppState.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Visualization")) {
                    Toggle("Show Skeleton", isOn: $appState.showSkeleton)
                    
                    ColorPicker("Skeleton Color", selection: $appState.skeletonColor)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(appState.isTracking ? "Tracking Active" : "Searching...")
                            .foregroundColor(appState.isTracking ? .green : .red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct ControlButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(Blur(style: .systemThinMaterialDark))
            .clipShape(Circle())
        }
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    ZStack {
        Color.gray
        OverlayView()
    }
}
