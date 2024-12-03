import SwiftUI

struct SettingsView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @AppStorage("catppuccinFlavor") private var catppuccinFlavor: CatppuccinFlavor = .macchiato
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { theme in
                            Text(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if themeMode == .catppuccin {
                        Picker("Flavor", selection: $catppuccinFlavor) {
                            ForEach(CatppuccinFlavor.allCases, id: \.self) { flavor in
                                Text(flavor.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Text("Log Out")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    StudentClient.clearSavedCredentials()
                    // Pop to root view (login screen)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
} 