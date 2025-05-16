'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "6ee776e4ea6b4806ac4e7ec737164426",
"assets/AssetManifest.bin.json": "6e4ed7a809c9132b1fcb79117ed1a5d6",
"assets/AssetManifest.json": "737f5ee182905eaa8c6a4a660f1cc14c",
"assets/assets/fonts/SpecialElite.ttf": "0361d96faa98b0a716bec7e56e794c3d",
"assets/assets/fonts/Staatliches.ttf": "0b1946eaefaeda766701618dba33e03c",
"assets/assets/images/drums.png": "c4ad94864001cfac83139fd40ce54cf3",
"assets/assets/images/grain.png": "baca1cccb8283761da93949da72b3aa8",
"assets/assets/images/guitar.png": "e4481264d50da2c794a68963d58b4368",
"assets/assets/images/jazz.png": "b07554baa94f9f8045cd498cb0a7013c",
"assets/assets/images/piano.png": "ea10aa1e7fe6d8b19946f9d3593a5bc8",
"assets/assets/images/pp.png": "d5ac021d1b57f589d1c2bb576e07473f",
"assets/assets/images/pp2.png": "3a59fab6ab801b1a93c21e86af83b750",
"assets/assets/images/Rock.png": "76b54a41d71e6e40920d22578223bb3e",
"assets/assets/sounds/A.mp3": "8193a29eec695b47ac77722f3a896925",
"assets/assets/sounds/A_oct.mp3": "ff8b871e5fd868b3fd2686dc36020165",
"assets/assets/sounds/A_sharp.mp3": "1b432aeee876e38309aea35ed36d253d",
"assets/assets/sounds/A_sharp_oct.mp3": "24f2b5a191248745bd7cac662cfe1a8b",
"assets/assets/sounds/B.mp3": "a1dd925ddc42dd89d83df70ff64e9863",
"assets/assets/sounds/B_oct.mp3": "3aef7b480be16561b1efd234d5a3f8d6",
"assets/assets/sounds/C.mp3": "9ccf6f38a3eb45e47ffb143243295bd5",
"assets/assets/sounds/C_oct.mp3": "1019d4a01f6b22d8b6c54859e6f4474b",
"assets/assets/sounds/C_sharp.mp3": "3f81ba76eeb966c6394317217ada748e",
"assets/assets/sounds/C_sharp_oct.mp3": "fdfb64391ae796f1867014b4e518ab68",
"assets/assets/sounds/D.mp3": "36987534eb513a02c018e05e2c799280",
"assets/assets/sounds/D_oct.mp3": "cadd9e2c7b7cae5ed0102a9af6fb6440",
"assets/assets/sounds/D_sharp.mp3": "6329711f80267d3ae5a045344b93cd09",
"assets/assets/sounds/D_sharp_oct.mp3": "b8aa655f0118b31c9ec083a41ff8e1a9",
"assets/assets/sounds/E.mp3": "40d0e5787a3e7a0e52de8a6a9098566e",
"assets/assets/sounds/E_oct.mp3": "5f1593883944be13a0d5cf42877a8c83",
"assets/assets/sounds/F.mp3": "3ef12c2a8c52d221ba757555aebec04b",
"assets/assets/sounds/FX_piano13.mp3": "f87479036bed50e89277ed72fbc902af",
"assets/assets/sounds/F_oct.mp3": "32aa01dda6c3747911acae6ee0826a8a",
"assets/assets/sounds/F_sharp.mp3": "ba5804077b2a7ae743e5f13273002331",
"assets/assets/sounds/F_sharp_oct.mp3": "0ebcf6db33857c6319a6a063ca51608e",
"assets/assets/sounds/G.mp3": "88659ba7c7cec8263fb081d9930a39bb",
"assets/assets/sounds/G_oct.mp3": "7d8a9d637c3c9540d57eeef83984c53b",
"assets/assets/sounds/G_sharp.mp3": "73fe0f7108d7b6feb07b43bf8705cdd2",
"assets/assets/sounds/G_sharp_oct.mp3": "4217d6d7c02f163ffd4136d235a01e56",
"assets/assets/sounds/met.mp3": "8005d8de3059a8f809b1ce4b7d33f65d",
"assets/FontManifest.json": "094534d6405579bd390abcf966954b1e",
"assets/fonts/MaterialIcons-Regular.otf": "47c4f62a8e09016f691a4e56d60208ce",
"assets/NOTICES": "83def9178beb4e3975dc9cae61128356",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "f4ba40a73161b4e564163d08ea426212",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "a812b16795cd92a78ff78e83f834ffcd",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "9e073fad999a184caac3e672c3a37050",
"/": "9e073fad999a184caac3e672c3a37050",
"main.dart.js": "302d9b6da5c94765064780dd802f3b57",
"manifest.json": "bf24c84c3bf99672a631c4f84464e793",
"sounds/A.mp3": "8193a29eec695b47ac77722f3a896925",
"sounds/A_oct.mp3": "ff8b871e5fd868b3fd2686dc36020165",
"sounds/A_sharp.mp3": "1b432aeee876e38309aea35ed36d253d",
"sounds/A_sharp_oct.mp3": "24f2b5a191248745bd7cac662cfe1a8b",
"sounds/B.mp3": "a1dd925ddc42dd89d83df70ff64e9863",
"sounds/B_oct.mp3": "3aef7b480be16561b1efd234d5a3f8d6",
"sounds/C.mp3": "9ccf6f38a3eb45e47ffb143243295bd5",
"sounds/C_oct.mp3": "1019d4a01f6b22d8b6c54859e6f4474b",
"sounds/C_sharp.mp3": "3f81ba76eeb966c6394317217ada748e",
"sounds/C_sharp_oct.mp3": "fdfb64391ae796f1867014b4e518ab68",
"sounds/D.mp3": "36987534eb513a02c018e05e2c799280",
"sounds/D_oct.mp3": "cadd9e2c7b7cae5ed0102a9af6fb6440",
"sounds/D_sharp.mp3": "6329711f80267d3ae5a045344b93cd09",
"sounds/D_sharp_oct.mp3": "b8aa655f0118b31c9ec083a41ff8e1a9",
"sounds/E.mp3": "40d0e5787a3e7a0e52de8a6a9098566e",
"sounds/E_oct.mp3": "5f1593883944be13a0d5cf42877a8c83",
"sounds/F.mp3": "3ef12c2a8c52d221ba757555aebec04b",
"sounds/FX_piano13.mp3": "f87479036bed50e89277ed72fbc902af",
"sounds/F_oct.mp3": "32aa01dda6c3747911acae6ee0826a8a",
"sounds/F_sharp.mp3": "ba5804077b2a7ae743e5f13273002331",
"sounds/F_sharp_oct.mp3": "0ebcf6db33857c6319a6a063ca51608e",
"sounds/G.mp3": "88659ba7c7cec8263fb081d9930a39bb",
"sounds/G_oct.mp3": "7d8a9d637c3c9540d57eeef83984c53b",
"sounds/G_sharp.mp3": "73fe0f7108d7b6feb07b43bf8705cdd2",
"sounds/G_sharp_oct.mp3": "4217d6d7c02f163ffd4136d235a01e56",
"sounds/met.mp3": "8005d8de3059a8f809b1ce4b7d33f65d",
"version.json": "eb99a5a1b6cb424c764a429055f1d477"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
