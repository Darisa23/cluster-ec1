#!/bin/bash
# Estadísticas de la diferencia worker2 - worker1 (ms) a partir de resultados.txt
cd /home/ec1/shared
awk '
function ordenar(arr, m,   i, j, k) {
  for (i = 1; i < m; i++) { k = arr[i]; j = i - 1
    while (j >= 0 && arr[j] > k) { arr[j+1] = arr[j]; j-- }
    arr[j+1] = k }
}
BEGIN { n = 0 }
/^---/ { n++; next }
/^rank/ {
  split($0, a, "|")
  host = a[2]; gsub(/ |host=/, "", host)
  split(a[4], parts, " "); split(parts[2], h, ":")
  t[n, host] = h[1]*3600 + h[2]*60 + h[3]
}
END {
  N = n + 1
  for (i = 0; i <= n; i++) {
    dif[i] = (t[i,"worker2"] - t[i,"worker1"]) * 1000
    ad[i] = (dif[i] < 0) ? -dif[i] : dif[i]
    s += dif[i]; sa += ad[i]
    if (dif[i] < 0) w2++; else w1++
    if (i == 0 || ad[i] < mn) mn = ad[i]
    if (i == 0 || ad[i] > mx) mx = ad[i]
  }
  ms = s / N; ma = sa / N
  for (i = 0; i <= n; i++) { v += (dif[i]-ms)^2; va += (ad[i]-ma)^2 }
  sd = sqrt(v / (N-1)); sda = sqrt(va / (N-1))
  for (i = 0; i <= n; i++) srt[i] = ad[i]
  ordenar(srt, N)
  med = (N % 2) ? srt[(N-1)/2] : (srt[N/2-1] + srt[N/2]) / 2
  ci = 1.96 * sd / sqrt(N)
  # intervalo entre ejecuciones consecutivas (mediana, robusta a pausas)
  m = 0
  for (i = 2; i <= n; i++) iv[m++] = (t[i,"worker1"] - t[i-1,"worker1"]) * 1000
  ordenar(iv, m)
  mediv = (m % 2) ? iv[(m-1)/2] : (iv[m/2-1] + iv[m/2]) / 2

  printf "Ejecuciones analizadas:        %d\n", N
  printf "worker1 primero / worker2:     %d / %d\n", w1, w2
  printf "Dif. con signo (w2-w1):        media %+.3f ms | desv. est. %.3f ms\n", ms, sd
  printf "IC 95%% de la media:            [%+.3f, %+.3f] ms\n", ms-ci, ms+ci
  printf "Dif. absoluta |w2-w1|:         media %.3f | mediana %.3f | desv. %.3f ms\n", ma, med, sda
  printf "Dif. absoluta min / max:       %.3f / %.3f ms\n", mn, mx
  printf "Mediana entre ejecuciones:     %.1f ms\n", mediv
}' resultados.txt | tee analisis.txt
