#!/usr/bin/env python3
"""Generate a well-formed .chq capture container.

Usage: python make_cheque.py <out.chq>
"""
import struct
import sys

CHQ_REC_MICR = 0x01
CHQ_REC_PAYEE = 0x02
CHQ_REC_MEMO = 0x03


def record(rec_type: int, field: bytes) -> bytes:
    return struct.pack("<BI", rec_type, len(field)) + field


def build() -> bytes:
    records = [
        record(CHQ_REC_MICR, b"C0001234567C 001234 56789012"),
        record(CHQ_REC_PAYEE, b"Jane Doe"),
        record(CHQ_REC_MEMO, b"Rent"),
    ]
    return b"CHQ1" + struct.pack("<I", len(records)) + b"".join(records)


def main() -> None:
    out = sys.argv[1] if len(sys.argv) > 1 else "valid_cheque.chq"
    with open(out, "wb") as f:
        f.write(build())
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
