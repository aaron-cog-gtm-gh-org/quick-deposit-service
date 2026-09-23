"""
QuickDeposit ingestion API.

Customers submit a cheque image capture (a .chq container produced by the mobile
capture SDK or a branch scanner) to be indexed for deposit. The upload endpoint
is intentionally reachable pre-authentication so the "snap a cheque before you
log in" convenience flow works; the deposit is only posted once the customer
authenticates in a later step.
"""

import os
import subprocess
import tempfile

from flask import Flask, jsonify, render_template, request

app = Flask(__name__)

# Absolute path to the compiled native cheque parser.
CHQPARSE_BIN = os.environ.get("CHQPARSE_BIN", "/quickdeposit/native/chqparse")


@app.get("/")
def index():
    """Serve the customer-facing cheque deposit page."""
    return render_template("index.html")


@app.get("/api")
def api_index():
    return jsonify(
        service="RBC QuickDeposit ingestion API",
        endpoints={
            "POST /api/v1/deposit/cheque": "upload a .chq cheque capture for indexing",
            "GET /healthz": "health check",
        },
    )


@app.get("/healthz")
def healthz():
    return jsonify(status="ok")


@app.post("/api/v1/deposit/cheque")
def deposit_cheque():
    """Accept a cheque capture and hand it to the native parser for indexing.

    No authentication is required here (pre-login capture convenience). The raw
    uploaded bytes are written to a temp file and passed straight to the native
    parser.
    """
    if "file" in request.files:
        raw = request.files["file"].read()
    else:
        raw = request.get_data()

    if not raw:
        return jsonify(error="empty upload"), 400

    with tempfile.NamedTemporaryFile(suffix=".chq", delete=False) as tf:
        tf.write(raw)
        path = tf.name

    try:
        proc = subprocess.run(
            [CHQPARSE_BIN, path],
            capture_output=True,
            timeout=10,
        )
    except subprocess.TimeoutExpired:
        return jsonify(error="parser timed out"), 504
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass

    if proc.returncode != 0:
        return (
            jsonify(
                error="could not parse cheque capture",
                parser_exit=proc.returncode,
                parser_stderr=proc.stderr.decode("utf-8", "replace"),
            ),
            422,
        )

    return app.response_class(
        response=proc.stdout, status=200, mimetype="application/json"
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
