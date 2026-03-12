import SwiftUI

struct QuoteRowView: View {
    let quote: Quote
    var onToggleFavourite: () -> Void

    private var categoryEnum: QuoteCategory {
        QuoteCategory(rawValue: quote.category) ?? .general
    }

    private var sourceEnum: QuoteSource {
        QuoteSource(rawValue: quote.source) ?? .other
    }

    var body: some View {
        HStack(spacing: 0) {
            // Color accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(categoryEnum.color.gradient)
                .frame(width: 4)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 10) {
                // Quote text
                Text(quote.text)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundStyle(.primary)

                // Metadata row
                HStack(spacing: 12) {
                    // Category
                    Label(quote.category, systemImage: categoryEnum.icon)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(categoryEnum.color)

                    // Source
                    Label(quote.source, systemImage: sourceEnum.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(quote.createdAt, format: .dateTime.month(.abbreviated).day())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.leading, 12)
            .padding(.vertical, 2)

            // Favourite button
            Button {
                withAnimation(.bouncy(duration: 0.3)) {
                    onToggleFavourite()
                }
            } label: {
                Image(systemName: quote.isFavourite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(quote.isFavourite ? Color.red : Color.secondary.opacity(0.3))
                    .symbolEffect(.bounce, value: quote.isFavourite)
                    .frame(width: 32)
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}
