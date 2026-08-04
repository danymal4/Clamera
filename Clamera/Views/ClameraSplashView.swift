//
//  ClameraSplashView.swift
//  Clamera
//
//  Created by Dany Malaeb on 8/2/26.
//

import SwiftUI

struct ClameraSplashView<Content: View>: View {
    let content: Content
    
    // Uses the device screen height to cover the whole display
    let screenHeight = UIScreen.main.bounds.height
    
    // Curtain Drop State
    @State private var curtainOffset: CGFloat = 0
    
    // Logo Animation State
    @State private var logoScale: CGFloat = 0.1
    @State private var logoOpacity: Double = 0.0
    @State private var logoPopped: Bool = false
    
    @State private var splashComplete: Bool = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // MARK: - Layer 1: The Stationary App Content
            content
            
            // MARK: - Layer 2: The Solid Cyan Curtain
            if !splashComplete {
                Rectangle()
                    .fill(Color.cyan)
                    .ignoresSafeArea()
                    .offset(y: curtainOffset)
                    .zIndex(1)
            }
            
            // MARK: - Layer 3: The Intro Logo (Updated Name!)
            if !logoPopped {
                // Make sure you drag your flat white logo asset into the project and name it "SplashLogo"
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    // Increased size slightly from 150 to 200 to make it pop better
                    .frame(width: 200, height: 200)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .zIndex(2)
            }
        }
        .onAppear {
            // STEP 1: Logo springs into the center of the solid cyan screen
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // STEP 2: Logo pops, disappears, and the solid curtain slides down off the screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                // The quick pop effect
                withAnimation(.easeIn(duration: 0.2)) {
                    logoScale = 1.2
                    logoOpacity = 0.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    logoPopped = true
                    
                    // Slides the entire solid block down past the bottom of the screen
                    withAnimation(.easeInOut(duration: 0.8)) {
                        curtainOffset = screenHeight + 100
                    }
                    
                    // STEP 3: Cleanly remove the splash overlay from memory
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        splashComplete = true
                    }
                }
            }
        }
    }
}

#Preview {
    ClameraSplashView {
        SignInView()
            .environmentObject(AuthManager.shared)
    }
}
