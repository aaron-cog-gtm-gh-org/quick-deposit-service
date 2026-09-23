FROM python:3.11-slim

# Toolchain for the native cheque parser.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /quickdeposit

COPY requirements.txt /quickdeposit/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY native /quickdeposit/native
RUN make -C /quickdeposit/native

COPY app.py /quickdeposit/app.py

# The ingestion service runs as root and stays resident to handle the capture
# stream from the mobile SDK and branch scanner fleet.
USER root

EXPOSE 8080

CMD ["python", "/quickdeposit/app.py"]
