import Foundation

/// Builds a well-formed `.chq` capture container — the exact binary format the
/// backend's native parser (`service/native/chqparse.c`) reads.
///
/// Layout (little-endian):
/// ```
/// magic         char[4]   "CHQ1"
/// record_count  uint32
/// records[]:
///   type        uint8     0x01 MICR, 0x02 payee, 0x03 memo
///   field_len   uint32    length of the field payload
///   field       uint8[field_len]
/// ```
///
/// This encoder only ever emits benign, bounded fields. The parser trims each
/// field into a fixed struct (micr[64], payee[64], memo[128]); we keep well
/// under those sizes so a valid deposit round-trips cleanly.
enum ChqEncoder {
    enum RecordType: UInt8 {
        case micr = 0x01
        case payee = 0x02
        case memo = 0x03
    }

    /// Fields carried by a benign capture container.
    struct Fields {
        var micr: String
        var payee: String
        var memo: String
    }

    /// Longest field payload the encoder will emit. The parser's smallest
    /// destination buffer is 64 bytes; staying under it keeps every field valid.
    static let maxFieldBytes = 48

    static func encode(_ fields: Fields) -> Data {
        let records: [(RecordType, String)] = [
            (.micr, fields.micr),
            (.payee, fields.payee),
            (.memo, fields.memo),
        ]

        var body = Data()
        for (type, value) in records {
            let payload = clamp(value)
            body.append(type.rawValue)
            body.append(uint32LE(UInt32(payload.count)))
            body.append(payload)
        }

        var out = Data("CHQ1".utf8)
        out.append(uint32LE(UInt32(records.count)))
        out.append(body)
        return out
    }

    // MARK: - Helpers

    private static func clamp(_ value: String) -> Data {
        var bytes = Array(value.utf8)
        if bytes.count > maxFieldBytes {
            bytes = Array(bytes.prefix(maxFieldBytes))
        }
        return Data(bytes)
    }

    private static func uint32LE(_ value: UInt32) -> Data {
        var le = value.littleEndian
        return withUnsafeBytes(of: &le) { Data($0) }
    }
}
