(function () {
  function fmtBytes(b) {
    var tib = 1099511627776;
    var gib = 1073741824;
    if (b >= tib) return (b / tib).toFixed(1) + "T";
    return (b / gib).toFixed(b >= 100 * gib ? 0 : 1) + "G";
  }

  function fmtUptime(s) {
    var d = Math.floor(s / 86400);
    var h = Math.floor((s % 86400) / 3600);
    var m = Math.floor((s % 3600) / 60);
    if (d > 0) return "UP " + d + "d " + h + "h";
    if (h > 0) return "UP " + h + "h " + m + "m";
    return "UP " + m + "m";
  }

  function level(pct, warn, crit) {
    if (pct >= crit) return "crit";
    if (pct >= warn) return "warn";
    return "ok";
  }

  function render(data) {
    var sys = data.system;
    document.getElementById("uptime").textContent = fmtUptime(sys.uptime);

    var cpuEl = document.getElementById("m-cpu");
    var cpuText = sys.cpu.percent + "%";
    if (sys.cpu.temp_c !== null && sys.cpu.temp_c !== undefined) {
      cpuText += " · " + sys.cpu.temp_c + "°C";
    }
    cpuEl.textContent = cpuText;
    cpuEl.dataset.level = level(sys.cpu.percent, 80, 95);

    var memEl = document.getElementById("m-mem");
    memEl.textContent =
      fmtBytes(sys.memory.used_bytes) +
      "/" +
      fmtBytes(sys.memory.total_bytes) +
      " (" +
      sys.memory.percent +
      "%)";
    memEl.dataset.level = level(sys.memory.percent, 80, 90);

    var swapEl = document.getElementById("m-swap");
    swapEl.textContent =
      sys.swap.total_bytes > 0
        ? fmtBytes(sys.swap.used_bytes) +
          "/" +
          fmtBytes(sys.swap.total_bytes)
        : "N/A";
    swapEl.dataset.level = level(sys.swap.percent, 75, 90);

    document.getElementById("m-load").textContent = sys.load;

    var disksEl = document.getElementById("disks");
    disksEl.replaceChildren();
    data.disks.forEach(function (d) {
      var row = document.createElement("div");
      row.className = "disk";

      var head = document.createElement("div");
      head.className = "disk-head";

      var left = document.createElement("span");
      left.className = "disk-label";
      left.textContent = d.label;
      var mnt = document.createElement("span");
      mnt.className = "disk-mount";
      mnt.textContent = d.mount;
      left.appendChild(mnt);

      var right = document.createElement("span");
      right.className = "disk-info";

      if (!d.mounted) {
        right.textContent = "UNMOUNTED";
        right.dataset.level = "warn";
        head.appendChild(left);
        head.appendChild(right);
        row.appendChild(head);
      } else {
        var lvl = level(d.percent, 85, 90);
        right.textContent =
          d.percent +
          "% · " +
          fmtBytes(d.avail_bytes) +
          " free / " +
          fmtBytes(d.total_bytes);
        right.dataset.level = lvl;

        var bar = document.createElement("div");
        bar.className = "bar";
        var fill = document.createElement("div");
        fill.className = "bar-fill";
        fill.style.width = Math.min(100, d.percent) + "%";
        fill.dataset.level = lvl;
        bar.appendChild(fill);

        head.appendChild(left);
        head.appendChild(right);
        row.appendChild(head);
        row.appendChild(bar);
      }
      disksEl.appendChild(row);
    });

    var up = 0;
    var down = 0;
    var off = 0;
    var expected = 0;
    var labels = {
      up: "■ UP",
      starting: "■ INIT",
      off: "□ OFF",
      down: "■ DOWN",
    };

    document.querySelectorAll(".card[data-service]").forEach(function (card) {
      var name = card.dataset.service;
      var info = data.services[name];
      if (!info) return;

      var st = info.status;
      card.dataset.status = st;
      var badge = card.querySelector(".status");
      if (badge) {
        badge.dataset.status = st;
        badge.textContent = labels[st] || st.toUpperCase();
      }

      if (info.autoStart || st === "up" || st === "starting" || st === "down") {
        expected++;
        if (st === "up") up++;
        else if (st === "down") down++;
      } else if (st === "off") {
        off++;
      }
    });

    var sumEl = document.getElementById("summary");
    if (down > 0) {
      sumEl.textContent = up + "/" + expected + " UP · " + down + " DOWN";
      sumEl.dataset.state = "down";
    } else if (up < expected) {
      sumEl.textContent = up + "/" + expected + " UP · STARTING";
      sumEl.dataset.state = "warn";
    } else {
      sumEl.textContent =
        off > 0
          ? up + "/" + expected + " UP · " + off + " OFF"
          : up + "/" + expected + " UP";
      sumEl.dataset.state = "ok";
    }
  }

  function refresh() {
    fetch("/status.json?t=" + Date.now(), { cache: "no-store" })
      .then(function (r) {
        if (!r.ok) throw new Error("HTTP " + r.status);
        var hdr = r.headers.get("Date");
        var ms = hdr ? Date.parse(hdr) : NaN;
        var serverNow = Number.isFinite(ms) ? Math.floor(ms / 1000) : null;
        return r.json().then(function (data) {
          return { data: data, serverNow: serverNow };
        });
      })
      .then(function (res) {
        var data = res.data;
        if (
          res.serverNow !== null &&
          typeof data.updated_at === "number" &&
          res.serverNow - data.updated_at > 60
        ) {
          var sumEl = document.getElementById("summary");
          sumEl.textContent = "TELEMETRY STALE";
          sumEl.dataset.state = "warn";
          return;
        }
        render(data);
      })
      .catch(function () {
        var sumEl = document.getElementById("summary");
        sumEl.textContent = "TELEMETRY OFFLINE";
        sumEl.dataset.state = "warn";
      });
  }

  refresh();
  setInterval(refresh, 15000);
  document.addEventListener("visibilitychange", function () {
    if (!document.hidden) refresh();
  });
})();
