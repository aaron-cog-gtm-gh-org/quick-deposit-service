(function () {
  "use strict";

  var form = document.getElementById("deposit-form");
  var input = document.getElementById("file");
  var zone = document.getElementById("dropzone");
  var submit = document.getElementById("submit");
  var filename = document.getElementById("filename");
  var result = document.getElementById("result");
  var badge = document.getElementById("result-badge");
  var title = document.getElementById("result-title");
  var fields = document.getElementById("fields");
  var raw = document.getElementById("raw");

  function setFile(file) {
    if (!file) return;
    input.files = filesFrom(file);
    filename.textContent = file.name + " selected";
    submit.disabled = false;
    zone.classList.add("has-file");
  }

  // DataTransfer shim so a dropped file populates the <input>.
  function filesFrom(file) {
    var dt = new DataTransfer();
    dt.items.add(file);
    return dt.files;
  }

  zone.addEventListener("click", function () { input.click(); });
  zone.addEventListener("keydown", function (e) {
    if (e.key === "Enter" || e.key === " ") { e.preventDefault(); input.click(); }
  });

  input.addEventListener("change", function () {
    if (input.files && input.files[0]) setFile(input.files[0]);
  });

  ["dragenter", "dragover"].forEach(function (ev) {
    zone.addEventListener(ev, function (e) {
      e.preventDefault();
      zone.classList.add("dragover");
    });
  });
  ["dragleave", "drop"].forEach(function (ev) {
    zone.addEventListener(ev, function (e) {
      e.preventDefault();
      zone.classList.remove("dragover");
    });
  });
  zone.addEventListener("drop", function (e) {
    var f = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
    if (f) setFile(f);
  });

  function row(term, value, mono) {
    var d = document.createElement("div");
    var dt = document.createElement("dt");
    var dd = document.createElement("dd");
    dt.textContent = term;
    dd.textContent = value;
    if (mono) dd.className = "mono";
    d.appendChild(dt);
    d.appendChild(dd);
    return d;
  }

  function showParsed(data) {
    result.hidden = false;
    badge.textContent = "Parsed";
    badge.classList.remove("err");
    title.textContent = "Ready to deposit";
    fields.innerHTML = "";
    fields.appendChild(row("Payee", data.payee || "\u2014"));
    fields.appendChild(row("Memo", data.memo || "\u2014"));
    fields.appendChild(row("MICR line", data.micr || "\u2014", true));
    fields.appendChild(row("Records read", String(data.records)));
    raw.hidden = true;
  }

  function showError(data, status) {
    result.hidden = false;
    badge.textContent = "Rejected";
    badge.classList.add("err");
    title.textContent = data.error || ("Upload failed (" + status + ")");
    fields.innerHTML = "";
    if (typeof data.parser_exit !== "undefined") {
      fields.appendChild(row("Parser exit code", String(data.parser_exit)));
    }
    if (data.parser_stderr) {
      raw.hidden = false;
      raw.textContent = data.parser_stderr.trim();
    } else {
      raw.hidden = true;
    }
  }

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    if (!input.files || !input.files[0]) return;

    var body = new FormData();
    body.append("file", input.files[0]);
    submit.classList.add("loading");
    submit.disabled = true;

    fetch("/api/v1/deposit/cheque", { method: "POST", body: body })
      .then(function (res) {
        return res.json().then(function (data) {
          return { ok: res.ok, status: res.status, data: data };
        });
      })
      .then(function (r) {
        if (r.ok) showParsed(r.data);
        else showError(r.data, r.status);
      })
      .catch(function () {
        showError({ error: "Could not reach the ingestion service." }, 0);
      })
      .finally(function () {
        submit.classList.remove("loading");
        submit.disabled = false;
      });
  });
})();
