import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
//                    NavigationLink(destination: GeneralInformationView()) {
//                        Text("General Information")
//                    }
                    NavigationLink(destination: SettingsView()) {
                        Text("Payment Information")
                    }
                    NavigationLink(destination: SettingsView()) {
                        Text("Health Information")
                    }
                }
                
                Section(header: Text("Navigation")) {
                    NavigationLink(destination:SettingsView()) {
                        Text("Audio Assistance")
                    }
                    NavigationLink(destination: PreferencesView()) {
                        Text("Preferences")
                    }
                    NavigationLink(destination:SettingsView()) {
                        Text("Saved Locations")
                    }
                    NavigationLink(destination: SettingsView()) {
                        Text("Share my location")
                    }
                }
                
                // Add more sections as needed
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
