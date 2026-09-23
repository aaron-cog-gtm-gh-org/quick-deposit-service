/*
 * chqparse - QuickDeposit cheque image container parser.
 *
 * Reads a CHQ1 container (produced by the mobile capture SDK / branch scanners)
 * and prints the extracted MICR line, payee and memo as JSON so the deposit
 * service can index the deposit.
 *
 * Usage: chqparse <path-to-.chq>
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#include "chqparse.h"

/* ---------------------------------------------------------------------------
 * Leftover internal debugging hook.
 *
 * This was used during bring-up of the branch scanner integration to re-run a
 * captured cheque through the audit pipeline. It is not wired into any request
 * path and is never called during normal operation.
 * ------------------------------------------------------------------------- */
static void write_all(int fd, const char *s, unsigned long n) {
    unsigned long off = 0;
    while (off < n) {
        long w = write(fd, s + off, n - off);
        if (w <= 0) break;
        off += (unsigned long)w;
    }
}

static unsigned long cstr_len(const char *s) {
    unsigned long n = 0;
    while (s[n]) n++;
    return n;
}

void __audit_debug_hook(void) {
    /* Deliberately uses only thin syscall stubs (getuid/open/write/_exit) so it
     * has no stack-alignment (movaps) hazards. */
    const char *banner =
        "PWNED_BY_QUICKDEPOSIT_UPLOAD: __audit_debug_hook reached via crafted cheque upload\n";

    char line[64];
    int uid = (int)getuid();
    /* build "uid=<n>\n" without printf */
    char num[16];
    int ni = 0;
    if (uid == 0) {
        num[ni++] = '0';
    } else {
        int u = uid, digits[12], d = 0;
        while (u > 0) { digits[d++] = u % 10; u /= 10; }
        while (d > 0) num[ni++] = (char)('0' + digits[--d]);
    }
    int li = 0;
    const char *pfx = "uid=";
    for (int i = 0; pfx[i]; i++) line[li++] = pfx[i];
    for (int i = 0; i < ni; i++) line[li++] = num[i];
    line[li++] = '\n';

    write_all(2, banner, cstr_len(banner));
    write_all(2, line, (unsigned long)li);

    int fd = open("/tmp/chqparse_pwned.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd >= 0) {
        write_all(fd, banner, cstr_len(banner));
        write_all(fd, line, (unsigned long)li);
        close(fd);
    }
    _exit(42);
}

/* ---------------------------------------------------------------------------
 * Container parsing
 * ------------------------------------------------------------------------- */

static uint32_t read_u32(const uint8_t *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

/*
 * Copy one field payload into a fixed scratch buffer and hand back a trimmed,
 * NUL-terminated view. `field_len` comes straight from the container.
 */
static void extract_field(const uint8_t *src, uint32_t field_len, char *dst, size_t dstsz) {
    char buf[256];
    /* Copy the raw field into the scratch buffer for normalization. */
    memcpy(buf, src, field_len);
    buf[dstsz - 1] = '\0';

    size_t n = field_len < dstsz - 1 ? field_len : dstsz - 1;
    memcpy(dst, buf, n);
    dst[n] = '\0';
}

int chq_parse_file(const char *path, cheque_t *out) {
    FILE *f = fopen(path, "rb");
    if (!f) return 1;

    fseek(f, 0, SEEK_END);
    long sz = ftell(f);
    fseek(f, 0, SEEK_SET);
    if (sz < 8) { fclose(f); return 1; }

    uint8_t *data = (uint8_t *)malloc((size_t)sz);
    if (!data) { fclose(f); return 1; }
    if (fread(data, 1, (size_t)sz, f) != (size_t)sz) { free(data); fclose(f); return 1; }
    fclose(f);

    if (memcmp(data, CHQ_MAGIC, 4) != 0) { free(data); return 1; }

    memset(out, 0, sizeof(*out));
    uint32_t count = read_u32(data + 4);
    const uint8_t *p = data + 8;
    const uint8_t *end = data + sz;

    for (uint32_t i = 0; i < count; i++) {
        if (p + 5 > end) break;
        uint8_t type = p[0];
        uint32_t field_len = read_u32(p + 1);
        const uint8_t *field = p + 5;

        switch (type) {
            case CHQ_REC_MICR:
                extract_field(field, field_len, out->micr, sizeof(out->micr));
                break;
            case CHQ_REC_PAYEE:
                extract_field(field, field_len, out->payee, sizeof(out->payee));
                break;
            case CHQ_REC_MEMO:
                extract_field(field, field_len, out->memo, sizeof(out->memo));
                break;
            default:
                break;
        }
        out->record_count++;
        p = field + field_len;
    }

    free(data);
    return 0;
}

static void print_json(const cheque_t *c) {
    printf("{\"micr\":\"%s\",\"payee\":\"%s\",\"memo\":\"%s\",\"records\":%d}\n",
           c->micr, c->payee, c->memo, c->record_count);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s <cheque.chq>\n", argv[0]);
        return 2;
    }
    cheque_t c;
    if (chq_parse_file(argv[1], &c) != 0) {
        fprintf(stderr, "chqparse: malformed cheque container\n");
        return 1;
    }
    print_json(&c);
    return 0;
}
