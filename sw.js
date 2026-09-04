const CACHE_NAME = 'hillguard-pwa-v1';

const PRECACHE_RESOURCES = [
  './',
  'index.html',
  'manifest.json',
  'favicon.png',
  'flutter.js',
  'flutter_bootstrap.js',
  'main.dart.js',
  'version.json',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[HillGuard PWA] Pre-caching core offline assets');
      return cache.addAll(PRECACHE_RESOURCES).catch((err) => {
        console.warn('[HillGuard PWA] Some assets could not be precached during install:', err);
      });
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((name) => {
          if (name !== CACHE_NAME) {
            console.log('[HillGuard PWA] Purging outdated cache:', name);
            return caches.delete(name);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET' || !event.request.url.startsWith('http')) {
    return;
  }

  // Offline-First strategy: Return cache immediately if available, else fetch and cache
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        // Fetch in background to update cache if online
        fetch(event.request)
          .then((networkResponse) => {
            if (networkResponse && networkResponse.status === 200) {
              caches.open(CACHE_NAME).then((cache) => cache.put(event.request, networkResponse));
            }
          })
          .catch(() => {
            // Offline - ignore network error and rely on cache
          });
        return cachedResponse;
      }

      return fetch(event.request)
        .then((networkResponse) => {
          if (!networkResponse || networkResponse.status !== 200 || networkResponse.type !== 'basic') {
            return networkResponse;
          }
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
          return networkResponse;
        })
        .catch(() => {
          if (event.request.mode === 'navigate') {
            return caches.match('index.html') || caches.match('./');
          }
        });
    })
  );
});
