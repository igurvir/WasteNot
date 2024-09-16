//
//  LoginView.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-15.
//

import Foundation
import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State private var isUnlocked = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            if isUnlocked {
                ContentView()  // Once authenticated, show the main content
            } else {
                Text("Please authenticate to access the app")
                    .padding()
                    .onAppear(perform: authenticate)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Authentication Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
            }
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Check if Face ID/Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock the app"

            // Request biometric authentication
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true  // Unlock the app on success
                    } else {
                        // Authentication failed, show an alert
                        self.alertMessage = authenticationError?.localizedDescription ?? "Failed to authenticate"
                        self.showAlert = true
                    }
                }
            }
        } else {
            // Biometrics not available, show fallback message
            self.alertMessage = "Face ID / Touch ID is not available on this device"
            self.showAlert = true
        }
    }
}
