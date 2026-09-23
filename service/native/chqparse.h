#ifndef CHQPARSE_H
#define CHQPARSE_H

#include <stdint.h>

/*
 * QuickDeposit cheque image container ("CHQ1").
 *
 * Layout (little-endian):
 *   magic        char[4]     "CHQ1"
 *   record_count uint32
 *   records[]    record_count records, each:
 *                  type       uint8    (see CHQ_REC_* below)
 *                  field_len  uint32   length of the field payload in bytes
 *                  field      uint8[field_len]
 *
 * The parser extracts the MICR line, payee name and memo from a cheque image
 * so the deposit service can index the deposit. This is the same binary format
 * emitted by the mobile capture SDK and the branch scanner fleet.
 */

#define CHQ_MAGIC "CHQ1"

#define CHQ_REC_MICR  0x01
#define CHQ_REC_PAYEE 0x02
#define CHQ_REC_MEMO  0x03

typedef struct {
    char micr[64];
    char payee[64];
    char memo[128];
    int  record_count;
} cheque_t;

/* Parse the file at `path` into `out`. Returns 0 on success, non-zero on a
 * malformed container. */
int chq_parse_file(const char *path, cheque_t *out);

#endif /* CHQPARSE_H */
