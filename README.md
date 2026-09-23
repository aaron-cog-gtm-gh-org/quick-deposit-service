# RBC QuickDeposit — cheque ingestion service (demo)

QuickDeposit is the ingestion tier for mobile and branch cheque capture. Customers
snap a cheque in the mobile app (or a branch scanner captures one) and the client
uploads a `.chq` capture container to this service, which extracts the MICR line,
payee and memo and returns them as JSON for the deposit-posting tier to index.

> This is a self-contained demo application. It is not connected to any real RBC
> system and contains no real customer data.

## Components

- `service/app.py` — Flask ingestion API. Exposes `POST /api/v1/deposit/cheque`,
  which accepts a `.chq` upload and returns the parsed cheque fields.
- `service/native/chqparse.c` — native C parser for the `.chq` capture container
  (the same binary format emitted by the mobile capture SDK and branch scanners).
- `service/Dockerfile`, `docker-compose.yml` — containerized service.
- `samples/` — a well-formed sample capture and a generator script.

## The `.chq` capture format

Little-endian binary container:

```
magic         char[4]   "CHQ1"
record_count  uint32
records[]:
  type        uint8     0x01 MICR, 0x02 payee, 0x03 memo
  field_len   uint32    length of the field payload
  field       uint8[field_len]
```

## Run it

With Docker:

```bash
docker compose up --build
# service listens on http://localhost:8080
```

Locally without Docker:

```bash
make -C service/native
pip install -r service/requirements.txt
CHQPARSE_BIN=$(pwd)/service/native/chqparse python service/app.py
```

## Try it

```bash
python samples/make_cheque.py samples/valid_cheque.chq
curl -s -F file=@samples/valid_cheque.chq http://localhost:8080/api/v1/deposit/cheque
# {"micr":"...","payee":"Jane Doe","memo":"Rent","records":3}
```

## Health

```bash
curl -s http://localhost:8080/healthz
```
