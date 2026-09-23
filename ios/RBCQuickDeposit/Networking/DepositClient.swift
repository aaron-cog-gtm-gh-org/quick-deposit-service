import Foundation

/// Parsed fields the ingestion API returns for a valid capture.
struct ParsedCheque: Decodable {
    let micr: String
    let payee: String
    let memo: String
    let records: Int
}

/// Error body returned by the ingestion API when the parser rejects a capture.
struct DepositErrorBody: Decodable {
    let error: String
    let parserExit: Int?
    let parserStderr: String?

    enum CodingKeys: String, CodingKey {
        case error
        case parserExit = "parser_exit"
        case parserStderr = "parser_stderr"
    }
}

enum DepositError: LocalizedError {
    case badStatus(code: Int, body: DepositErrorBody?)
    case transport(Error)
    case decoding

    var errorDescription: String? {
        switch self {
        case .badStatus(_, let body):
            return body?.error ?? "We couldn't read that cheque. Try re-adding the images."
        case .transport:
            return "Can't reach the deposit service. Check that the backend is running."
        case .decoding:
            return "The deposit service returned an unexpected response."
        }
    }
}

/// Uploads a `.chq` capture container to the QuickDeposit ingestion endpoint.
///
/// The request is sent as `multipart/form-data` with a single `file` part — the
/// same shape the web client and capture SDK use — so the on-stage proxy shows
/// exactly the request the app makes.
struct DepositClient {
    /// The Simulator shares the host network, so the local backend is reachable
    /// on `localhost`. Override via the `QD_BACKEND_URL` env var when pointing
    /// at a different demo host.
    static let baseURL: URL = {
        if let raw = ProcessInfo.processInfo.environment["QD_BACKEND_URL"],
           let url = URL(string: raw) {
            return url
        }
        return URL(string: "http://localhost:8080")!
    }()

    var baseURL: URL = DepositClient.baseURL
    var session: URLSession = .shared

    func submit(chq: Data, filename: String = "cheque.chq") async throws -> ParsedCheque {
        let endpoint = baseURL.appendingPathComponent("/api/v1/deposit/cheque")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"

        let boundary = "QuickDeposit-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = multipartBody(chq: chq, filename: filename, boundary: boundary)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DepositError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw DepositError.decoding
        }

        guard http.statusCode == 200 else {
            let body = try? JSONDecoder().decode(DepositErrorBody.self, from: data)
            throw DepositError.badStatus(code: http.statusCode, body: body)
        }

        guard let parsed = try? JSONDecoder().decode(ParsedCheque.self, from: data) else {
            throw DepositError.decoding
        }
        return parsed
    }

    private func multipartBody(chq: Data, filename: String, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: application/octet-stream\r\n\r\n")
        body.append(chq)
        body.append("\r\n--\(boundary)--\r\n")
        return body
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
