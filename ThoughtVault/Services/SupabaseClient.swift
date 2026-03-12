import Foundation

enum APIError: LocalizedError {
    case invalidResponse(Int)
    case decodingFailed(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let code): "Server error (HTTP \(code))"
        case .decodingFailed: "Failed to read server response"
        case .networkError(let err): err.localizedDescription
        }
    }
}

struct SupabaseClient {
    private let baseURL = "https://btwzesufypmtugrxigmp.supabase.co/rest/v1"
    private let apiKey = "sb_publishable_tvEXoAWvSiTrObR_Cr4tkA_6LKNPQqM"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: string) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Invalid date: \(string)"
            )
        }
        return d
    }()

    // MARK: - CRUD

    func fetchQuotes() async throws -> [Quote] {
        let request = makeRequest(path: "/quotes?select=*&order=created_at.desc", method: "GET")
        return try await perform(request)
    }

    func updateQuote(id: UUID, category: String, source: String) async throws -> Quote {
        let body = ["category": category, "source": source]
        let data = try JSONSerialization.data(withJSONObject: body)
        var request = makeRequest(path: "/quotes?id=eq.\(id.uuidString)", method: "PATCH", hasBody: true)
        request.httpBody = data
        let results: [Quote] = try await perform(request)
        guard let quote = results.first else { throw APIError.invalidResponse(200) }
        return quote
    }

    func toggleFavourite(id: UUID, isFavourite: Bool) async throws -> Quote {
        let body: [String: Any] = ["is_favourite": isFavourite]
        let data = try JSONSerialization.data(withJSONObject: body)
        var request = makeRequest(path: "/quotes?id=eq.\(id.uuidString)", method: "PATCH", hasBody: true)
        request.httpBody = data
        let results: [Quote] = try await perform(request)
        guard let quote = results.first else { throw APIError.invalidResponse(200) }
        return quote
    }

    func deleteQuote(id: UUID) async throws {
        let request = makeRequest(path: "/quotes?id=eq.\(id.uuidString)", method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.invalidResponse(code)
        }
    }

    // MARK: - Helpers

    private func makeRequest(path: String, method: String, hasBody: Bool = false) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        if hasBody {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        }
        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.invalidResponse(code)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
