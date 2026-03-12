import Foundation

@Observable
class QuoteStore {
    var quotes: [Quote] = []
    var isLoading = false
    var errorMessage: String?
    var selectedCategory: QuoteCategory?
    var showFavouritesOnly = false

    var filteredQuotes: [Quote] {
        quotes.filter { quote in
            if showFavouritesOnly && !quote.isFavourite { return false }
            if let cat = selectedCategory, quote.category != cat.rawValue { return false }
            return true
        }
    }

    private let client = SupabaseClient()

    func loadQuotes() async {
        isLoading = true
        defer { isLoading = false }
        do {
            quotes = try await client.fetchQuotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteQuote(_ quote: Quote) async {
        guard let index = quotes.firstIndex(of: quote) else { return }
        let removed = quotes.remove(at: index)
        do {
            try await client.deleteQuote(id: quote.id)
        } catch {
            quotes.insert(removed, at: min(index, quotes.count))
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavourite(_ quote: Quote) async {
        guard let index = quotes.firstIndex(of: quote) else { return }
        quotes[index].isFavourite.toggle()
        do {
            _ = try await client.toggleFavourite(id: quote.id, isFavourite: quotes[index].isFavourite)
        } catch {
            quotes[index].isFavourite.toggle()
            errorMessage = error.localizedDescription
        }
    }

    func updateQuote(_ quote: Quote, category: String, source: String) async {
        guard let index = quotes.firstIndex(of: quote) else { return }
        let oldCategory = quotes[index].category
        let oldSource = quotes[index].source
        quotes[index].category = category
        quotes[index].source = source
        do {
            _ = try await client.updateQuote(id: quote.id, category: category, source: source)
        } catch {
            quotes[index].category = oldCategory
            quotes[index].source = oldSource
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
