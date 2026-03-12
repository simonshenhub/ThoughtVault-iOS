import Foundation
import SwiftUI

// MARK: - Enums

enum QuoteCategory: String, CaseIterable, Codable, Identifiable {
    case mindset = "Mindset"
    case relationships = "Relationships"
    case health = "Health"
    case parenting = "Parenting"
    case career = "Career"
    case philosophy = "Philosophy"
    case general = "General"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .mindset:       .purple
        case .relationships: .pink
        case .health:        .green
        case .parenting:     .orange
        case .career:        .blue
        case .philosophy:    .indigo
        case .general:       .gray
        }
    }

    var icon: String {
        switch self {
        case .mindset:       "brain.head.profile"
        case .relationships: "heart.text.square"
        case .health:        "figure.run"
        case .parenting:     "figure.and.child.holdinghands"
        case .career:        "briefcase"
        case .philosophy:    "books.vertical"
        case .general:       "text.quote"
        }
    }
}

enum QuoteSource: String, CaseIterable, Codable, Identifiable {
    case ai = "AI"
    case book = "Book"
    case podcast = "Podcast"
    case article = "Article"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .ai:      "sparkles"
        case .book:    "book"
        case .podcast: "headphones"
        case .article: "doc.text"
        case .other:   "ellipsis"
        }
    }
}

// MARK: - Quote Model

struct Quote: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var text: String
    var category: String
    var source: String
    let createdAt: Date
    var isFavourite: Bool

    enum CodingKeys: String, CodingKey {
        case id, text, category, source
        case createdAt = "created_at"
        case isFavourite = "is_favourite"
    }
}
