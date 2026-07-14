import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Layer?

    @State private var draftBedname: String = ""
    @State private var draftAmendment: String = ""
    @State private var draftDepthin: String = ""
    @State private var draftNotes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            LayerRow(item: item)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                    loadDraft(from: item)
                                    showingAdd = true
                                }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Beddepth")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            editingItem = nil
                            clearDraft()
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addEditSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .tint(Theme.accent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No layers yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to add your first entry.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var addEditSheet: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Bed name", text: $draftBedname)
                        .accessibilityIdentifier("field_bedName")
                        .keyboardType(.default)
                    TextField("Amendment", text: $draftAmendment)
                        .accessibilityIdentifier("field_amendment")
                        .keyboardType(.default)
                    TextField("Depth (in)", text: $draftDepthin)
                        .accessibilityIdentifier("field_depthIn")
                        .keyboardType(.decimalPad)
                    TextField("Notes", text: $draftNotes)
                        .accessibilityIdentifier("field_notes")
                        .keyboardType(.default)
                }
            }
            .navigationTitle(editingItem == nil ? "Add Layer" : "Edit Layer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAdd = false }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func loadDraft(from item: Layer) {
        draftBedname = item.bedName
        draftAmendment = item.amendment
        draftDepthin = String(item.depthIn)
        draftNotes = item.notes
    }

    private func clearDraft() {
        draftBedname = ""
        draftAmendment = ""
        draftDepthin = ""
        draftNotes = ""
    }

    private func save() {
        if let editing = editingItem {
            var updated = editing
            updated.bedName = draftBedname
            updated.amendment = draftAmendment
            updated.depthIn = Double(draftDepthin) ?? 0
            updated.notes = draftNotes
            store.update(updated)
        } else {
            let item = Layer(bedName: draftBedname, amendment: draftAmendment, depthIn: Double(draftDepthin) ?? 0, notes: draftNotes)
            store.add(item)
        }
        showingAdd = false
    }
}

struct LayerRow: View {
    let item: Layer

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.bedName.isEmpty ? "Untitled" : item.bedName)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
