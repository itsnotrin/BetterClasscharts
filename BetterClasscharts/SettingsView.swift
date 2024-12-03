import SwiftUI

enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.base.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Version Info Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Version")
                                    .foregroundColor(Theme.text)
                                Spacer()
                                Text("0.0.1")
                                    .foregroundColor(Theme.subtext0)
                            }
                            .padding()
                            .background(Theme.surface0)
                        }
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Account Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .padding(.horizontal)
                        
                        Button(action: { showingLogoutAlert = true }) {
                            HStack {
                                Text("Log Out")
                                    .foregroundColor(Theme.red)
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(Theme.red)
                            }
                            .padding()
                            .background(Theme.surface0)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Settings")
            .navigationBarTitleTextColor(Theme.text)
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {
                    // Do nothing
                }
                .foregroundColor(Theme.text)
                
                Button("Log Out", role: .destructive) {
                    StudentClient.clearSavedCredentials()
                    dismiss()
                }
                .foregroundColor(Theme.red)
            } message: {
                Text("Are you sure you want to log out?")
                    .foregroundColor(Theme.text)
            }
        }
    }
} 