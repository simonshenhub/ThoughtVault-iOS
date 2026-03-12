import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(QuoteStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: QuoteCategory
    @State private var selectedSource: QuoteSource
    @State private var showDeleteConfirmation = false

    private var categoryEnum: QuoteCategory {
        QuoteCategory(rawValue: quote.category) ?? .general
    }

    init(quote: Quote) {
        self.quote = quote
        _selectedCategory = State(initialValue: QuoteCategory(rawValue: quote.category) ?? .general)
        _selectedSource = State(initialValue: QuoteSource(rawValue: quote.source) ?? .other)
    }

    var body: some View {
        List {
            // Quote display section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.title)
                        .foregroundStyle(categoryEnum.color.opacity(0.4))

                    Text(quote.text)
                        .font(.body)
                        .lineSpacing(4)
                        .textSelection(.enabled)

                    HStack {
                        Spacer()
                        Text(quote.createdAt, format: .dateTime.year().month(.wide).day())
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }

            // Details section
            Section {
                Picker(selection: $selectedCategory) {
                    ForEach(QuoteCategory.allCases) { cat in
                        Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                    }
                } label: {
                    Label("Category", systemImage: "folder")
                        .foregroundStyle(.primary)
                }

                Picker(selection: $selectedSource) {
                    ForEach(QuoteSource.allCases) { src in
                        Label(src.rawValue, systemImage: src.icon).tag(src)
                    }
                } label: {
                    Label("Source", systemImage: "link")
                        .foregroundStyle(.primary)
                }
            }

            // Delete section
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Quote", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Quote")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedCategory) { _, newValue in
            Task {
                await store.updateQuote(quote, category: newValue.rawValue, source: selectedSource.rawValue)
            }
        }
        .onChange(of: selectedSource) { _, newValue in
            Task {
                await store.updateQuote(quote, category: selectedCategory.rawValue, source: newValue.rawValue)
            }
        }
        .alert("Delete Quote?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.deleteQuote(quote)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This quote will be permanently deleted.")
        }
    }
}
