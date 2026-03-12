import SwiftUI

struct QuoteListView: View {
    @Environment(QuoteStore.self) private var store

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            VStack(spacing: 0) {
                header
                filterBar

                Group {
                    if store.isLoading && store.quotes.isEmpty {
                        loadingState
                    } else if store.filteredQuotes.isEmpty {
                        emptyState
                    } else {
                        quoteList
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .task {
                await store.loadQuotes()
            }
            .refreshable {
                await store.loadQuotes()
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.clearError() } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ThoughtVault")
                    .font(.title.bold())
                Text("\(store.quotes.count) thoughts captured")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundStyle(.accent.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: store.selectedCategory == nil, color: .accentColor) {
                    withAnimation { store.selectedCategory = nil }
                }

                ForEach(QuoteCategory.allCases) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: store.selectedCategory == category,
                        color: category.color,
                        icon: category.icon
                    ) {
                        withAnimation { store.selectedCategory = category }
                    }
                }

                Rectangle()
                    .fill(.separator)
                    .frame(width: 1, height: 20)
                    .padding(.horizontal, 4)

                FilterChip(
                    title: "Favourites",
                    isSelected: store.showFavouritesOnly,
                    color: .red,
                    icon: "heart.fill"
                ) {
                    withAnimation { store.showFavouritesOnly.toggle() }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Quote List

    private var quoteList: some View {
        List {
            ForEach(store.filteredQuotes) { quote in
                NavigationLink(value: quote) {
                    QuoteRowView(quote: quote) {
                        Task { await store.toggleFavourite(quote) }
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Quote.self) { quote in
            QuoteDetailView(quote: quote)
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your thoughts...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                store.quotes.isEmpty ? "No Quotes Yet" : "No Matches",
                systemImage: store.quotes.isEmpty ? "quote.opening" : "magnifyingglass"
            )
        } description: {
            Text(
                store.quotes.isEmpty
                    ? "Add quotes from the ThoughtVault web app."
                    : "Try changing your filters."
            )
        } actions: {
            if !store.quotes.isEmpty {
                Button("Clear Filters") {
                    withAnimation {
                        store.selectedCategory = nil
                        store.showFavouritesOnly = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .accentColor
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color.opacity(0.15) : Color(.tertiarySystemFill))
            .foregroundStyle(isSelected ? color : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
