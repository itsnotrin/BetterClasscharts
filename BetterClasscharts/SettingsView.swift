import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.loginState) var loginState
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Large Title
                Text("Settings")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Rest of the view
                VStack(spacing: 20) {
                    // Theme Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appearance")
                            .font(.headline)
                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Theme")
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            Spacer()
                            Picker("", selection: $appTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        }
                        .padding()
                        .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Version Info Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Version")
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            Spacer()
                            Text("0.0.1")
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.7))
                        }
                        .padding()
                        .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Account Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.headline)
                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
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
                            .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleTextColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
        .tint(Theme.accentColor(for: appTheme))
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                StudentClient.clearSavedCredentials()
                loginState.isLoggedIn = false
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
} 