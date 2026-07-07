import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: PlanItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.provider)
                                    .font(Theme.bodyFont.weight(.semibold))
                                Text("\(item.monthlyFee)")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityIdentifier("item_row_\(item.id.uuidString)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Storagecost")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settings_gear_button")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add_item_button")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddItemView { item in
                    store.add(item)
                }
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item, onSave: { updated in
                    store.update(updated)
                }, onDelete: {
                    store.delete(item)
                })
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var provider: String = ""
    @State private var monthlyFeeText: String = ""
    @State private var capacityGBText: String = ""
    @State private var usedGBText: String = ""
    var onSave: (PlanItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("New Plan") {
                    TextField("Provider", text: $provider)
                        .accessibilityIdentifier("add_provider_field")
                    TextField("Monthlyfee", text: $monthlyFeeText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("add_monthlyFee_field")
                    TextField("Capacitygb", text: $capacityGBText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("add_capacityGB_field")
                    TextField("Usedgb", text: $usedGBText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("add_usedGB_field")
                }
            }
            .background(
                Color.clear.contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .navigationTitle("Add Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("add_cancel_button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = PlanItem(
                        provider: provider,
                        monthlyFee: Double(monthlyFeeText) ?? 0,
                        capacityGB: Double(capacityGBText) ?? 0,
                        usedGB: Double(usedGBText) ?? 0
                        )
                        onSave(item)
                        dismiss()
                    }
                    .accessibilityIdentifier("add_save_button")
                }
            }
        }
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State var item: PlanItem
    var onSave: (PlanItem) -> Void
    var onDelete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan") {
                    Text(item.provider)
                }
                Section {
                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                    .accessibilityIdentifier("edit_delete_button")
                }
            }
            .navigationTitle("Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("edit_close_button")
                }
            }
        }
    }
}
