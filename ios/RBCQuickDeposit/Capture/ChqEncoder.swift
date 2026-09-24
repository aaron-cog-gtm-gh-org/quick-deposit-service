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
/// The encoder emits each field's bytes verbatim, using the field's real length
/// as `field_len`. It does not bound field payloads against the parser's
/// destination buffers, so an oversized field (e.g. a long memo) is transmitted
/// as-is.
enum ChqEncoder {
    enum RecordType: UInt8 {
        case micr = 0x01
        case payee = 0x02
        case memo = 0x03
    }

    /// Fields carried by a capture container.
    struct Fields {
        var micr: String
        var payee: String
        var memo: String
        /// When set, the memo record's payload is these raw bytes verbatim
        /// instead of `memo`'s UTF-8. Lets the app carry a payload that is not
        /// valid UTF-8 or is larger than any text field would produce.
        var rawMemo: Data?
    }

    static func encode(_ fields: Fields) -> Data {
        let records: [(RecordType, Data)] = [
            (.micr, Data(fields.micr.utf8)),
            (.payee, Data(fields.payee.utf8)),
            (.memo, fields.rawMemo ?? Data(fields.memo.utf8)),
        ]

        var body = Data()
        for (type, payload) in records {
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

    private static func uint32LE(_ value: UInt32) -> Data {
        var le = value.littleEndian
        return withUnsafeBytes(of: &le) { Data($0) }
    }
}

extension Data {
    /// Decodes a hex string (optionally `0x`-prefixed, whitespace ignored) into
    /// raw bytes. Returns nil if the cleaned string has odd length or a
    /// non-hex digit.
    init?(hexString: String) {
        var hex = hexString.filter { !$0.isWhitespace }
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex.dropFirst(2))
        }
        guard hex.count % 2 == 0 else { return nil }
        var bytes = [UInt8]()
        bytes.reserveCapacity(hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<next], radix: 16) else { return nil }
            bytes.append(byte)
            index = next
        }
        self.init(bytes)
    }
}
