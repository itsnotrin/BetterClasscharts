import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccin
    @AppStorage("catppuccinVariant") private var catppuccinVariant: CatppuccinVariant = .macchiato
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.loginState) var loginState
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                Text("Settings")
                    .font(.largeTitle.bold())
                    .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
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
                        
                        // Catppuccin Variant Selector (only show when Catppuccin is selected)
                        if appTheme == .catppuccin {
                            HStack(spacing: 0) {
                                ForEach(CatppuccinVariant.allCases, id: \.self) { variant in
                                    Button(action: { catppuccinVariant = variant }) {
                                        Text(variant.rawValue)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(
                                                catppuccinVariant == variant ?
                                                Theme.accentColor(for: appTheme) :
                                                Theme.surfaceColor(for: appTheme, colorScheme: colorScheme)
                                            )
                                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                    }
                                    if variant != CatppuccinVariant.allCases.last {
                                        Divider()
                                            .background(Theme.textColor(for: appTheme, colorScheme: colorScheme).opacity(0.2))
                                    }
                                }
                            }
                            .frame(height: 44)
                            .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
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