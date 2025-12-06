self.addEventListener("message", (event) => {
  if (event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});

const CACHE_NAME = "campus-cat-cache-v2";
const urlsToCache = [
  "/",
  "index.html",
  "offline.html",
  "game.js",
  "love.js",
  "theme/love.css",
  "theme/bg.png",
  "sw.js",
  "game.love",
  "game.data",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then((cache) => {
        const smallFiles = [
          "/",
          "index.html",
          "offline.html",
          "game.js",
          "love.js",
          "theme/love.css",
          "theme/bg.png",
          "sw.js",
        ];

        const largeFiles = ["game.love", "game.data", "love.wasm"];

        return cache
          .addAll(smallFiles)
          .then(() => {
            return Promise.allSettled(
              largeFiles.map((url) => {
                return cache.add(url).catch((err) => {
                  console.warn("[SW] Failed to cache large file:", url, err);
                });
              }),
            );
          })
          .catch((err) => {
            console.warn(
              "[SW] Small files addAll failed, trying individual:",
              err,
            );
            return Promise.allSettled(
              smallFiles.concat(largeFiles).map((url) => {
                return cache.add(url).catch((err) => {
                  console.warn("[SW] Failed to cache:", url, err);
                });
              }),
            );
          });
      })
      .then(() => {
        return self.skipWaiting();
      })
      .catch((err) => {
        console.error("[SW] Install failed:", err);
        return self.skipWaiting();
      }),
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME) {
              return caches.delete(cacheName);
            }
          }),
        );
      })
      .then(() => {
        return self.clients.claim();
      })
      .then(() => {
        return caches.open(CACHE_NAME).then((cache) => {
          const criticalFiles = ["love.wasm", "game.love"];

          return Promise.allSettled(
            criticalFiles.map((url) => {
              return cache
                .match(url)
                .then((response) => {
                  if (response) {
                    return;
                  }

                  return fetch(url, { timeout: 60000 })
                    .then((res) => {
                      if (res.status === 200 && res.body) {
                        return cache.put(url, res.clone());
                      } else {
                        console.warn("[SW] Bad response for:", url, res.status);
                      }
                    })
                    .catch((err) => {
                      console.warn("[SW] Fetch failed for:", url, err.message);
                    });
                })
                .catch((err) => {
                  console.warn(
                    "[SW] Cache check failed for:",
                    url,
                    err.message,
                  );
                });
            }),
          );
        });
      }),
  );
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  if (url.hostname !== self.location.hostname) {
    return;
  }

  if (request.method !== "GET") {
    return;
  }

  event.respondWith(
    caches.match(request).then((response) => {
      if (response) {
        return response;
      }

      return fetch(request)
        .then((response) => {
          if (
            !response ||
            response.status !== 200 ||
            response.type === "error"
          ) {
            return response;
          }

          if (response.type !== "basic" && response.type !== "cors") {
            return response;
          }

          // For CSS files, ensure correct MIME type before caching
          let responseToCache = response.clone();
          if (request.url.endsWith(".css")) {
            const contentType = responseToCache.headers.get("content-type");
            if (!contentType || !contentType.includes("text/css")) {
              responseToCache.blob().then((blob) => {
                const headers = new Headers(responseToCache.headers);
                headers.set("content-type", "text/css; charset=utf-8");
                const fixedResponse = new Response(blob, {
                  status: responseToCache.status,
                  statusText: responseToCache.statusText,
                  headers: headers,
                });
                caches.open(CACHE_NAME).then((cache) => {
                  cache.put(request, fixedResponse);
                });
              });
            } else {
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(request, responseToCache);
              });
            }
          } else {
            caches
              .open(CACHE_NAME)
              .then((cache) => {
                cache.put(request, responseToCache).catch((err) => {
                  console.warn("[SW] Failed to cache:", request.url, err);
                });
              })
              .catch((err) => {
                console.warn("[SW] Could not open cache:", err);
              });
          }

          return response;
        })
        .catch((error) => {
          if (request.mode === "navigate") {
            return caches
              .match("/index.html")
              .then((indexResponse) => {
                if (indexResponse) {
                  return indexResponse;
                }
                return caches.match("index.html").then((response) => {
                  if (response) return response;
                  throw new Error("No cached page available");
                });
              })
              .catch((err) => {
                console.error("[SW] Could not serve offline page:", err);
                return new Response(
                  "Offline - Game not cached. Please load while online first.",
                  {
                    status: 503,
                    statusText: "Service Unavailable",
                    headers: new Headers({
                      "Content-Type": "text/plain",
                    }),
                  },
                );
              });
          }

          return caches.match(request).catch(() => {
            return new Response("Offline", {
              status: 503,
              statusText: "Service Unavailable",
            });
          });
        });
    }),
  );
});
