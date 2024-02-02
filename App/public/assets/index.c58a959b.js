const p = function polyfill() {
  const relList = document.createElement("link").relList;
  if (relList && relList.supports && relList.supports("modulepreload")) {
    return;
  }
  for (const link of document.querySelectorAll('link[rel="modulepreload"]')) {
    processPreload(link);
  }
  new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type !== "childList") {
        continue;
      }
      for (const node of mutation.addedNodes) {
        if (node.tagName === "LINK" && node.rel === "modulepreload")
          processPreload(node);
      }
    }
  }).observe(document, { childList: true, subtree: true });
  function getFetchOpts(script) {
    const fetchOpts = {};
    if (script.integrity)
      fetchOpts.integrity = script.integrity;
    if (script.referrerpolicy)
      fetchOpts.referrerPolicy = script.referrerpolicy;
    if (script.crossorigin === "use-credentials")
      fetchOpts.credentials = "include";
    else if (script.crossorigin === "anonymous")
      fetchOpts.credentials = "omit";
    else
      fetchOpts.credentials = "same-origin";
    return fetchOpts;
  }
  function processPreload(link) {
    if (link.ep)
      return;
    link.ep = true;
    const fetchOpts = getFetchOpts(link);
    fetch(link.href, fetchOpts);
  }
};
p();
var roboto = "";
var musefont = "";
var index = "";
const scriptRel = "modulepreload";
const seen = {};
const base = "/";
const __vitePreload = function preload(baseModule, deps) {
  if (!deps || deps.length === 0) {
    return baseModule();
  }
  return Promise.all(deps.map((dep) => {
    dep = `${base}${dep}`;
    if (dep in seen)
      return;
    seen[dep] = true;
    const isCss = dep.endsWith(".css");
    const cssSelector = isCss ? '[rel="stylesheet"]' : "";
    if (document.querySelector(`link[href="${dep}"]${cssSelector}`)) {
      return;
    }
    const link = document.createElement("link");
    link.rel = isCss ? "stylesheet" : scriptRel;
    if (!isCss) {
      link.as = "script";
      link.crossOrigin = "";
    }
    link.href = dep;
    document.head.appendChild(link);
    if (isCss) {
      return new Promise((res, rej) => {
        link.addEventListener("load", res);
        link.addEventListener("error", () => rej(new Error(`Unable to preload CSS for ${dep}`)));
      });
    }
  })).then(() => baseModule());
};
/*! Capacitor: https://capacitorjs.com/ - MIT License */
const createCapacitorPlatforms = (win) => {
  const defaultPlatformMap = /* @__PURE__ */ new Map();
  defaultPlatformMap.set("web", { name: "web" });
  const capPlatforms = win.CapacitorPlatforms || {
    currentPlatform: { name: "web" },
    platforms: defaultPlatformMap
  };
  const addPlatform = (name, platform) => {
    capPlatforms.platforms.set(name, platform);
  };
  const setPlatform = (name) => {
    if (capPlatforms.platforms.has(name)) {
      capPlatforms.currentPlatform = capPlatforms.platforms.get(name);
    }
  };
  capPlatforms.addPlatform = addPlatform;
  capPlatforms.setPlatform = setPlatform;
  return capPlatforms;
};
const initPlatforms = (win) => win.CapacitorPlatforms = createCapacitorPlatforms(win);
const CapacitorPlatforms = /* @__PURE__ */ initPlatforms(typeof globalThis !== "undefined" ? globalThis : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : typeof global !== "undefined" ? global : {});
CapacitorPlatforms.addPlatform;
CapacitorPlatforms.setPlatform;
var ExceptionCode;
(function(ExceptionCode2) {
  ExceptionCode2["Unimplemented"] = "UNIMPLEMENTED";
  ExceptionCode2["Unavailable"] = "UNAVAILABLE";
})(ExceptionCode || (ExceptionCode = {}));
class CapacitorException extends Error {
  constructor(message, code, data) {
    super(message);
    this.message = message;
    this.code = code;
    this.data = data;
  }
}
const getPlatformId = (win) => {
  var _a, _b;
  if (win === null || win === void 0 ? void 0 : win.androidBridge) {
    return "android";
  } else if ((_b = (_a = win === null || win === void 0 ? void 0 : win.webkit) === null || _a === void 0 ? void 0 : _a.messageHandlers) === null || _b === void 0 ? void 0 : _b.bridge) {
    return "ios";
  } else {
    return "web";
  }
};
const createCapacitor = (win) => {
  var _a, _b, _c, _d, _e;
  const capCustomPlatform = win.CapacitorCustomPlatform || null;
  const cap = win.Capacitor || {};
  const Plugins = cap.Plugins = cap.Plugins || {};
  const capPlatforms = win.CapacitorPlatforms;
  const defaultGetPlatform = () => {
    return capCustomPlatform !== null ? capCustomPlatform.name : getPlatformId(win);
  };
  const getPlatform = ((_a = capPlatforms === null || capPlatforms === void 0 ? void 0 : capPlatforms.currentPlatform) === null || _a === void 0 ? void 0 : _a.getPlatform) || defaultGetPlatform;
  const defaultIsNativePlatform = () => getPlatform() !== "web";
  const isNativePlatform = ((_b = capPlatforms === null || capPlatforms === void 0 ? void 0 : capPlatforms.currentPlatform) === null || _b === void 0 ? void 0 : _b.isNativePlatform) || defaultIsNativePlatform;
  const defaultIsPluginAvailable = (pluginName) => {
    const plugin = registeredPlugins.get(pluginName);
    if (plugin === null || plugin === void 0 ? void 0 : plugin.platforms.has(getPlatform())) {
      return true;
    }
    if (getPluginHeader(pluginName)) {
      return true;
    }
    return false;
  };
  const isPluginAvailable = ((_c = capPlatforms === null || capPlatforms === void 0 ? void 0 : capPlatforms.currentPlatform) === null || _c === void 0 ? void 0 : _c.isPluginAvailable) || defaultIsPluginAvailable;
  const defaultGetPluginHeader = (pluginName) => {
    var _a2;
    return (_a2 = cap.PluginHeaders) === null || _a2 === void 0 ? void 0 : _a2.find((h) => h.name === pluginName);
  };
  const getPluginHeader = ((_d = capPlatforms === null || capPlatforms === void 0 ? void 0 : capPlatforms.currentPlatform) === null || _d === void 0 ? void 0 : _d.getPluginHeader) || defaultGetPluginHeader;
  const handleError = (err) => win.console.error(err);
  const pluginMethodNoop = (_target, prop, pluginName) => {
    return Promise.reject(`${pluginName} does not have an implementation of "${prop}".`);
  };
  const registeredPlugins = /* @__PURE__ */ new Map();
  const defaultRegisterPlugin = (pluginName, jsImplementations = {}) => {
    const registeredPlugin = registeredPlugins.get(pluginName);
    if (registeredPlugin) {
      console.warn(`Capacitor plugin "${pluginName}" already registered. Cannot register plugins twice.`);
      return registeredPlugin.proxy;
    }
    const platform = getPlatform();
    const pluginHeader = getPluginHeader(pluginName);
    let jsImplementation;
    const loadPluginImplementation = async () => {
      if (!jsImplementation && platform in jsImplementations) {
        jsImplementation = typeof jsImplementations[platform] === "function" ? jsImplementation = await jsImplementations[platform]() : jsImplementation = jsImplementations[platform];
      } else if (capCustomPlatform !== null && !jsImplementation && "web" in jsImplementations) {
        jsImplementation = typeof jsImplementations["web"] === "function" ? jsImplementation = await jsImplementations["web"]() : jsImplementation = jsImplementations["web"];
      }
      return jsImplementation;
    };
    const createPluginMethod = (impl, prop) => {
      var _a2, _b2;
      if (pluginHeader) {
        const methodHeader = pluginHeader === null || pluginHeader === void 0 ? void 0 : pluginHeader.methods.find((m) => prop === m.name);
        if (methodHeader) {
          if (methodHeader.rtype === "promise") {
            return (options) => cap.nativePromise(pluginName, prop.toString(), options);
          } else {
            return (options, callback) => cap.nativeCallback(pluginName, prop.toString(), options, callback);
          }
        } else if (impl) {
          return (_a2 = impl[prop]) === null || _a2 === void 0 ? void 0 : _a2.bind(impl);
        }
      } else if (impl) {
        return (_b2 = impl[prop]) === null || _b2 === void 0 ? void 0 : _b2.bind(impl);
      } else {
        throw new CapacitorException(`"${pluginName}" plugin is not implemented on ${platform}`, ExceptionCode.Unimplemented);
      }
    };
    const createPluginMethodWrapper = (prop) => {
      let remove2;
      const wrapper = (...args) => {
        const p2 = loadPluginImplementation().then((impl) => {
          const fn = createPluginMethod(impl, prop);
          if (fn) {
            const p3 = fn(...args);
            remove2 = p3 === null || p3 === void 0 ? void 0 : p3.remove;
            return p3;
          } else {
            throw new CapacitorException(`"${pluginName}.${prop}()" is not implemented on ${platform}`, ExceptionCode.Unimplemented);
          }
        });
        if (prop === "addListener") {
          p2.remove = async () => remove2();
        }
        return p2;
      };
      wrapper.toString = () => `${prop.toString()}() { [capacitor code] }`;
      Object.defineProperty(wrapper, "name", {
        value: prop,
        writable: false,
        configurable: false
      });
      return wrapper;
    };
    const addListener = createPluginMethodWrapper("addListener");
    const removeListener = createPluginMethodWrapper("removeListener");
    const addListenerNative = (eventName, callback) => {
      const call = addListener({ eventName }, callback);
      const remove2 = async () => {
        const callbackId = await call;
        removeListener({
          eventName,
          callbackId
        }, callback);
      };
      const p2 = new Promise((resolve) => call.then(() => resolve({ remove: remove2 })));
      p2.remove = async () => {
        console.warn(`Using addListener() without 'await' is deprecated.`);
        await remove2();
      };
      return p2;
    };
    const proxy = new Proxy({}, {
      get(_, prop) {
        switch (prop) {
          case "$$typeof":
            return void 0;
          case "toJSON":
            return () => ({});
          case "addListener":
            return pluginHeader ? addListenerNative : addListener;
          case "removeListener":
            return removeListener;
          default:
            return createPluginMethodWrapper(prop);
        }
      }
    });
    Plugins[pluginName] = proxy;
    registeredPlugins.set(pluginName, {
      name: pluginName,
      proxy,
      platforms: /* @__PURE__ */ new Set([
        ...Object.keys(jsImplementations),
        ...pluginHeader ? [platform] : []
      ])
    });
    return proxy;
  };
  const registerPlugin2 = ((_e = capPlatforms === null || capPlatforms === void 0 ? void 0 : capPlatforms.currentPlatform) === null || _e === void 0 ? void 0 : _e.registerPlugin) || defaultRegisterPlugin;
  if (!cap.convertFileSrc) {
    cap.convertFileSrc = (filePath) => filePath;
  }
  cap.getPlatform = getPlatform;
  cap.handleError = handleError;
  cap.isNativePlatform = isNativePlatform;
  cap.isPluginAvailable = isPluginAvailable;
  cap.pluginMethodNoop = pluginMethodNoop;
  cap.registerPlugin = registerPlugin2;
  cap.Exception = CapacitorException;
  cap.DEBUG = !!cap.DEBUG;
  cap.isLoggingEnabled = !!cap.isLoggingEnabled;
  cap.platform = cap.getPlatform();
  cap.isNative = cap.isNativePlatform();
  return cap;
};
const initCapacitorGlobal = (win) => win.Capacitor = createCapacitor(win);
const Capacitor = /* @__PURE__ */ initCapacitorGlobal(typeof globalThis !== "undefined" ? globalThis : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : typeof global !== "undefined" ? global : {});
const registerPlugin = Capacitor.registerPlugin;
Capacitor.Plugins;
class WebPlugin {
  constructor(config) {
    this.listeners = {};
    this.windowListeners = {};
    if (config) {
      console.warn(`Capacitor WebPlugin "${config.name}" config object was deprecated in v3 and will be removed in v4.`);
      this.config = config;
    }
  }
  addListener(eventName, listenerFunc) {
    const listeners = this.listeners[eventName];
    if (!listeners) {
      this.listeners[eventName] = [];
    }
    this.listeners[eventName].push(listenerFunc);
    const windowListener = this.windowListeners[eventName];
    if (windowListener && !windowListener.registered) {
      this.addWindowListener(windowListener);
    }
    const remove2 = async () => this.removeListener(eventName, listenerFunc);
    const p2 = Promise.resolve({ remove: remove2 });
    Object.defineProperty(p2, "remove", {
      value: async () => {
        console.warn(`Using addListener() without 'await' is deprecated.`);
        await remove2();
      }
    });
    return p2;
  }
  async removeAllListeners() {
    this.listeners = {};
    for (const listener in this.windowListeners) {
      this.removeWindowListener(this.windowListeners[listener]);
    }
    this.windowListeners = {};
  }
  notifyListeners(eventName, data) {
    const listeners = this.listeners[eventName];
    if (listeners) {
      listeners.forEach((listener) => listener(data));
    }
  }
  hasListeners(eventName) {
    return !!this.listeners[eventName].length;
  }
  registerWindowListener(windowEventName, pluginEventName) {
    this.windowListeners[pluginEventName] = {
      registered: false,
      windowEventName,
      pluginEventName,
      handler: (event) => {
        this.notifyListeners(pluginEventName, event);
      }
    };
  }
  unimplemented(msg = "not implemented") {
    return new Capacitor.Exception(msg, ExceptionCode.Unimplemented);
  }
  unavailable(msg = "not available") {
    return new Capacitor.Exception(msg, ExceptionCode.Unavailable);
  }
  async removeListener(eventName, listenerFunc) {
    const listeners = this.listeners[eventName];
    if (!listeners) {
      return;
    }
    const index2 = listeners.indexOf(listenerFunc);
    this.listeners[eventName].splice(index2, 1);
    if (!this.listeners[eventName].length) {
      this.removeWindowListener(this.windowListeners[eventName]);
    }
  }
  addWindowListener(handle) {
    window.addEventListener(handle.windowEventName, handle.handler);
    handle.registered = true;
  }
  removeWindowListener(handle) {
    if (!handle) {
      return;
    }
    window.removeEventListener(handle.windowEventName, handle.handler);
    handle.registered = false;
  }
}
const encode = (str) => encodeURIComponent(str).replace(/%(2[346B]|5E|60|7C)/g, decodeURIComponent).replace(/[()]/g, escape);
const decode = (str) => str.replace(/(%[\dA-F]{2})+/gi, decodeURIComponent);
class CapacitorCookiesPluginWeb extends WebPlugin {
  async getCookies() {
    const cookies = document.cookie;
    const cookieMap = {};
    cookies.split(";").forEach((cookie) => {
      if (cookie.length <= 0)
        return;
      let [key, value] = cookie.replace(/=/, "CAP_COOKIE").split("CAP_COOKIE");
      key = decode(key).trim();
      value = decode(value).trim();
      cookieMap[key] = value;
    });
    return cookieMap;
  }
  async setCookie(options) {
    try {
      const encodedKey = encode(options.key);
      const encodedValue = encode(options.value);
      const expires = `; expires=${(options.expires || "").replace("expires=", "")}`;
      const path = (options.path || "/").replace("path=", "");
      const domain = options.url != null && options.url.length > 0 ? `domain=${options.url}` : "";
      document.cookie = `${encodedKey}=${encodedValue || ""}${expires}; path=${path}; ${domain};`;
    } catch (error) {
      return Promise.reject(error);
    }
  }
  async deleteCookie(options) {
    try {
      document.cookie = `${options.key}=; Max-Age=0`;
    } catch (error) {
      return Promise.reject(error);
    }
  }
  async clearCookies() {
    try {
      const cookies = document.cookie.split(";") || [];
      for (const cookie of cookies) {
        document.cookie = cookie.replace(/^ +/, "").replace(/=.*/, `=;expires=${new Date().toUTCString()};path=/`);
      }
    } catch (error) {
      return Promise.reject(error);
    }
  }
  async clearAllCookies() {
    try {
      await this.clearCookies();
    } catch (error) {
      return Promise.reject(error);
    }
  }
}
registerPlugin("CapacitorCookies", {
  web: () => new CapacitorCookiesPluginWeb()
});
const readBlobAsBase64 = async (blob) => new Promise((resolve, reject) => {
  const reader = new FileReader();
  reader.onload = () => {
    const base64String = reader.result;
    resolve(base64String.indexOf(",") >= 0 ? base64String.split(",")[1] : base64String);
  };
  reader.onerror = (error) => reject(error);
  reader.readAsDataURL(blob);
});
const normalizeHttpHeaders = (headers = {}) => {
  const originalKeys = Object.keys(headers);
  const loweredKeys = Object.keys(headers).map((k) => k.toLocaleLowerCase());
  const normalized = loweredKeys.reduce((acc, key, index2) => {
    acc[key] = headers[originalKeys[index2]];
    return acc;
  }, {});
  return normalized;
};
const buildUrlParams = (params, shouldEncode = true) => {
  if (!params)
    return null;
  const output = Object.entries(params).reduce((accumulator, entry) => {
    const [key, value] = entry;
    let encodedValue;
    let item;
    if (Array.isArray(value)) {
      item = "";
      value.forEach((str) => {
        encodedValue = shouldEncode ? encodeURIComponent(str) : str;
        item += `${key}=${encodedValue}&`;
      });
      item.slice(0, -1);
    } else {
      encodedValue = shouldEncode ? encodeURIComponent(value) : value;
      item = `${key}=${encodedValue}`;
    }
    return `${accumulator}&${item}`;
  }, "");
  return output.substr(1);
};
const buildRequestInit = (options, extra = {}) => {
  const output = Object.assign({ method: options.method || "GET", headers: options.headers }, extra);
  const headers = normalizeHttpHeaders(options.headers);
  const type = headers["content-type"] || "";
  if (typeof options.data === "string") {
    output.body = options.data;
  } else if (type.includes("application/x-www-form-urlencoded")) {
    const params = new URLSearchParams();
    for (const [key, value] of Object.entries(options.data || {})) {
      params.set(key, value);
    }
    output.body = params.toString();
  } else if (type.includes("multipart/form-data") || options.data instanceof FormData) {
    const form = new FormData();
    if (options.data instanceof FormData) {
      options.data.forEach((value, key) => {
        form.append(key, value);
      });
    } else {
      for (const key of Object.keys(options.data)) {
        form.append(key, options.data[key]);
      }
    }
    output.body = form;
    const headers2 = new Headers(output.headers);
    headers2.delete("content-type");
    output.headers = headers2;
  } else if (type.includes("application/json") || typeof options.data === "object") {
    output.body = JSON.stringify(options.data);
  }
  return output;
};
class CapacitorHttpPluginWeb extends WebPlugin {
  async request(options) {
    const requestInit = buildRequestInit(options, options.webFetchExtra);
    const urlParams = buildUrlParams(options.params, options.shouldEncodeUrlParams);
    const url = urlParams ? `${options.url}?${urlParams}` : options.url;
    const response = await fetch(url, requestInit);
    const contentType = response.headers.get("content-type") || "";
    let { responseType = "text" } = response.ok ? options : {};
    if (contentType.includes("application/json")) {
      responseType = "json";
    }
    let data;
    let blob;
    switch (responseType) {
      case "arraybuffer":
      case "blob":
        blob = await response.blob();
        data = await readBlobAsBase64(blob);
        break;
      case "json":
        data = await response.json();
        break;
      case "document":
      case "text":
      default:
        data = await response.text();
    }
    const headers = {};
    response.headers.forEach((value, key) => {
      headers[key] = value;
    });
    return {
      data,
      headers,
      status: response.status,
      url: response.url
    };
  }
  async get(options) {
    return this.request(Object.assign(Object.assign({}, options), { method: "GET" }));
  }
  async post(options) {
    return this.request(Object.assign(Object.assign({}, options), { method: "POST" }));
  }
  async put(options) {
    return this.request(Object.assign(Object.assign({}, options), { method: "PUT" }));
  }
  async patch(options) {
    return this.request(Object.assign(Object.assign({}, options), { method: "PATCH" }));
  }
  async delete(options) {
    return this.request(Object.assign(Object.assign({}, options), { method: "DELETE" }));
  }
}
registerPlugin("CapacitorHttp", {
  web: () => new CapacitorHttpPluginWeb()
});
const Storage = registerPlugin("Storage", {
  web: () => __vitePreload(() => import("./web.ff23833e.js"), true ? [] : void 0).then((m) => new m.StorageWeb())
});
async function set(key, value) {
  await Storage.set({
    key,
    value: JSON.stringify(value)
  });
}
async function get(key) {
  const item = await Storage.get({ key });
  return item && item.value ? JSON.parse(item.value) : "";
}
async function remove(key) {
  await Storage.remove({
    key
  });
}
const Device = registerPlugin("Device", {
  web: () => __vitePreload(() => import("./web.027039f8.js"), true ? [] : void 0).then((m) => new m.DeviceWeb())
});
const translations = {
  fr: {
    welcomeMessage: "Bienvenue sur Muse Mobile 2",
    ok: "OK",
    login: "SE CONNECTER",
    makeChoice: "Choisir un site",
    connectionInfos: "Muse Mobile requiert un compte utilisateur et un mot de passe fournis lors de l'acquisition d'une licence aupr\xE8s de Cit\xE9gestion SA.",
    clientCode: "Code client",
    barcodeCameraPermission: "Nous avons besoin de votre permission pour utiliser la cam\xE9ra afin de scanner des code-barres",
    badNetwork: "Connexion r\xE9seau introuvable"
  },
  en: {
    welcomeMessage: "Welcome to Muse Mobile 2",
    ok: "OK",
    login: "LOG IN",
    makeChoice: "Choose an site",
    connectionInfos: "Muse Mobile requires a user account and password provided upon the acquisition of a license from Cit\xE9gestion SA.",
    clientCode: "Client code",
    barcodeCameraPermission: "We need your permission to use your camera to be able to scan barcodes",
    badNetwork: "Network connection not found"
  }
};
async function getLanguage() {
  const { value } = await Device.getLanguageCode();
  if (value && translations.hasOwnProperty(value)) {
    return value;
  }
  return "fr";
}
function updateTranslations(language) {
  const elements = document.querySelectorAll("[data-translate-key]");
  elements.forEach((element) => {
    var _a;
    const key = element.getAttribute("data-translate-key");
    if (key && ((_a = translations[language]) == null ? void 0 : _a[key])) {
      if (element instanceof HTMLInputElement) {
        element.placeholder = translations[language][key];
      } else {
        element.textContent = translations[language][key];
      }
    }
  });
}
const Geolocation = registerPlugin("Geolocation", {
  web: () => __vitePreload(() => import("./web.632cf669.js"), true ? [] : void 0).then((m) => new m.GeolocationWeb())
});
var CameraSource;
(function(CameraSource2) {
  CameraSource2["Prompt"] = "PROMPT";
  CameraSource2["Camera"] = "CAMERA";
  CameraSource2["Photos"] = "PHOTOS";
})(CameraSource || (CameraSource = {}));
var CameraDirection;
(function(CameraDirection2) {
  CameraDirection2["Rear"] = "REAR";
  CameraDirection2["Front"] = "FRONT";
})(CameraDirection || (CameraDirection = {}));
var CameraResultType;
(function(CameraResultType2) {
  CameraResultType2["Uri"] = "uri";
  CameraResultType2["Base64"] = "base64";
  CameraResultType2["DataUrl"] = "dataUrl";
})(CameraResultType || (CameraResultType = {}));
const Camera = registerPlugin("Camera", {
  web: () => __vitePreload(() => import("./web.ed342ba4.js"), true ? [] : void 0).then((m) => new m.CameraWeb())
});
const BarcodeScanner = registerPlugin("BarcodeScanner", {
  web: () => __vitePreload(() => import("./web.372fc2d2.js"), true ? [] : void 0).then((m) => new m.BarcodeScannerWeb())
});
const App = registerPlugin("App", {
  web: () => __vitePreload(() => import("./web.3f7681f7.js"), true ? [] : void 0).then((m) => new m.AppWeb())
});
class ApiError extends Error {
  constructor(message, errCode) {
    super(message);
    this.code = errCode;
  }
  get json() {
    return {
      message: this.message,
      code: this.code
    };
  }
}
const CAPACITOR_VERSION = "5.1.0";
const EVENTS$1 = {
  MESSAGE_EVENT: {
    ACTIONS: {
      GET_GEOLOCATION: "getGeolocation",
      WATCH_GEOLOCATION: "watchGeolocation",
      CLEAR_WATCH: "clearWatch",
      GET_PICTURE: "getPicture",
      START_BARCODE_SCANNER: "startBarcodeScanner",
      GET_DEVICE_INFO: "getDeviceInfo"
    },
    TYPES: {
      GEOLOCATION: "geolocation",
      WATCH_ID: "watchId",
      PICTURE: "picture",
      BARCODE: "barcode",
      DEVICE: "device",
      ERROR: "error"
    }
  }
};
function sendMessage(event, type, data) {
  var _a;
  (_a = event.source) == null ? void 0 : _a.postMessage({ type, data, id: event.data.id }, event.origin);
}
async function checkAndRequestPermission(feature) {
  const isWeb = (await Device.getInfo()).platform === "web";
  switch (feature) {
    case "camera":
      return isWeb ? handleWebCameraPermission() : handleNativeCameraPermission();
    case "geolocation":
      return isWeb ? handleWebGeolocationPermission() : handleNativeGeolocationPermission();
    default:
      throw new Error(`Unknown feature: ${feature}`);
  }
}
function handleWebCameraPermission() {
  return Promise.resolve(true);
}
function handleWebGeolocationPermission() {
  return new Promise((resolve) => {
    if (!navigator.geolocation) {
      resolve(false);
      return;
    }
    navigator.geolocation.getCurrentPosition(
      () => resolve(true),
      (error) => resolve(error.code === GeolocationPositionError.PERMISSION_DENIED ? false : true),
      {
        timeout: 1e3
      }
    );
  });
}
async function handleNativeCameraPermission() {
  let permissions = await Camera.checkPermissions();
  if (permissions.camera !== "granted") {
    permissions = await Camera.requestPermissions({ permissions: ["camera"] });
  }
  return permissions.camera === "granted";
}
async function handleNativeGeolocationPermission() {
  let permissions = await Geolocation.checkPermissions();
  if (permissions.location !== "granted") {
    permissions = await Geolocation.requestPermissions({ permissions: ["location"] });
  }
  return permissions.location === "granted";
}
async function handleGeolocation(event) {
  const geolocationPermissionIsGranted = await checkAndRequestPermission("geolocation");
  if (geolocationPermissionIsGranted) {
    Geolocation.getCurrentPosition(event.data.options).then((position) => {
      sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.GEOLOCATION, position);
    }).catch((error) => {
      sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, new ApiError(error.message, error.code).json);
    });
  } else {
    sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, new ApiError("GEOLOCATION_PERMISSION_DENIED", 1).json);
  }
}
async function handleWatchGeolocation(event) {
  const geolocationPermissionIsGranted = await checkAndRequestPermission("geolocation");
  if (geolocationPermissionIsGranted) {
    Geolocation.watchPosition(event.data.options, (position, err) => {
      if (err) {
        sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, new ApiError(err.message, err.code).json);
      } else if (position) {
        const simplifiedPosition = {
          coords: {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy || 0,
            altitude: position.coords.altitude || null,
            altitudeAccuracy: position.coords.altitudeAccuracy || null,
            heading: position.coords.heading || null,
            speed: position.coords.speed || null
          },
          timestamp: position.timestamp
        };
        sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.GEOLOCATION, simplifiedPosition);
      }
    });
  } else {
    sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, new ApiError("GEOLOCATION_PERMISSION_DENIED", 1).json);
  }
}
function handleClearWatch(event) {
  if (event.data.watchId) {
    Geolocation.clearWatch({ id: event.data.watchId });
  }
}
async function handlePicture(event) {
  const cameraPermissionIsGranted = await checkAndRequestPermission("camera");
  if (cameraPermissionIsGranted) {
    Camera.getPhoto({
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.DataUrl
    }).then((photo) => {
      sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.PICTURE, photo.dataUrl);
    }).catch((error) => {
      sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, error);
    });
  } else {
    sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, new ApiError("CAMERA_PERMISSION_DENIED", 1).json);
  }
}
const stopScan = async (htmlElements) => {
  var _a;
  try {
    await BarcodeScanner.stopScan();
    htmlElements == null ? void 0 : htmlElements.forEach((e) => document.body.removeChild(e));
    (_a = document.querySelector("body")) == null ? void 0 : _a.classList.remove("barcode-scanner-active");
  } catch (err) {
    console.error("Failed to stop scanner", err);
  }
};
async function handleBarcode(event) {
  var _a;
  try {
    const cameraPermissionIsGranted = await checkAndRequestPermission("camera");
    if (cameraPermissionIsGranted) {
      await BarcodeScanner.prepare();
      (_a = document.querySelector("body")) == null ? void 0 : _a.classList.add("barcode-scanner-active");
      const scannerModal = document.createElement("div");
      const closeScannerButton = document.createElement("button");
      const htmlElements = [scannerModal, closeScannerButton];
      scannerModal.className = "barcode-scanner-modal";
      closeScannerButton.innerText = "X";
      closeScannerButton.className = "close-scanner-button";
      closeScannerButton.onclick = () => stopScan(htmlElements);
      htmlElements.forEach((e) => document.body.appendChild(e));
      const result = await BarcodeScanner.startScan();
      if (result.hasContent) {
        stopScan(htmlElements);
        sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.BARCODE, result.content);
      }
    } else {
      throw new ApiError("CAMERA_PERMISSION_DENIED", 1);
    }
  } catch (error) {
    stopScan();
    sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.ERROR, new ApiError(error == null ? void 0 : error.message, error == null ? void 0 : error.code).json);
  }
}
async function handleDeviceInfo(event) {
  const deviceInfo = await Device.getInfo();
  const appInfo = await App.getInfo();
  const id = await Device.getId();
  const informations = {
    os: deviceInfo.operatingSystem,
    osVersion: deviceInfo.osVersion,
    model: deviceInfo.model,
    uuid: id,
    appVersion: appInfo.version,
    capacitorVersion: CAPACITOR_VERSION
  };
  sendMessage(event, EVENTS$1.MESSAGE_EVENT.TYPES.DEVICE, informations);
}
const actionHandlers = {
  [EVENTS$1.MESSAGE_EVENT.ACTIONS.GET_GEOLOCATION]: handleGeolocation,
  [EVENTS$1.MESSAGE_EVENT.ACTIONS.WATCH_GEOLOCATION]: handleWatchGeolocation,
  [EVENTS$1.MESSAGE_EVENT.ACTIONS.CLEAR_WATCH]: handleClearWatch,
  [EVENTS$1.MESSAGE_EVENT.ACTIONS.GET_PICTURE]: handlePicture,
  [EVENTS$1.MESSAGE_EVENT.ACTIONS.START_BARCODE_SCANNER]: handleBarcode,
  [EVENTS$1.MESSAGE_EVENT.ACTIONS.GET_DEVICE_INFO]: handleDeviceInfo
};
async function hardwareAccess(event) {
  const handler = actionHandlers[event.data.action];
  if (handler) {
    await handler(event);
  }
}
const Network = registerPlugin("Network", {
  web: () => __vitePreload(() => import("./web.cffe3e3d.js"), true ? [] : void 0).then((m) => new m.NetworkWeb())
});
const STORAGE_KEY = {
  MUSE_URL: "museUrl"
};
const API = {
  SERVICE_URL: `https://${"dev"}.musesoftware.citegestion.fr/_exploitIIS/InfosClients/MobiliteService.svc/GetUrlsMobiliteV4`,
  METHOD: "GET",
  PARAMS: {
    REF: "ref"
  },
  CACHE: "no-store"
};
const ELEMENT_IDS = {
  CLIENT_CODE_INPUT: "code-client-input",
  GET_SITE_BUTTON: "code-client-button",
  SITE_SELECT: "client-site-select",
  REDIRECT_BUTTON: "login-button",
  FORM_CONTAINER: "portal-container",
  IFRAME_CONTAINER: "iframe-container",
  IFRAME: "muse-mobile-iframe",
  LOADER: "loader-container",
  NETWORK: "network-infobox"
};
const EVENTS = {
  CHANGE_SITE: "changeSite"
};
let siteSelected = false;
const fetchClientData = async (codeClient) => {
  const url = new URL(API.SERVICE_URL);
  url.searchParams.append(API.PARAMS.REF, encodeURIComponent(codeClient));
  const response = await fetch(url.toString(), {
    method: API.METHOD,
    cache: API.CACHE
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  } else {
    return response.json();
  }
};
async function changeSite(selectedURL) {
  const iframe = document.getElementById(ELEMENT_IDS.IFRAME);
  if (selectedURL && /^(http|https):\/\//.test(selectedURL)) {
    iframe.src = selectedURL;
    await set(STORAGE_KEY.MUSE_URL, selectedURL);
    siteSelected = true;
    updateDisplay();
  }
}
function updateDisplay() {
  document.getElementById(ELEMENT_IDS.FORM_CONTAINER).style.display = siteSelected ? "none" : "block";
  document.getElementById(ELEMENT_IDS.IFRAME_CONTAINER).style.display = siteSelected ? "block" : "none";
}
function updateNetworkDisplay(isConnected) {
  document.getElementById(ELEMENT_IDS.NETWORK).style.display = isConnected ? "none" : "flex";
}
async function addNetworkListener() {
  const status = await Network.getStatus();
  updateNetworkDisplay(status.connected);
  Network.addListener("networkStatusChange", (status2) => {
    updateNetworkDisplay(status2.connected);
  });
}
document.addEventListener("DOMContentLoaded", async () => {
  const museUrl = await get(STORAGE_KEY.MUSE_URL);
  if (museUrl) {
    changeSite(museUrl);
  }
  const language = await getLanguage();
  updateTranslations(language);
  const loader = document.getElementById(ELEMENT_IDS.LOADER);
  const btnGetSite = document.getElementById(ELEMENT_IDS.GET_SITE_BUTTON);
  const siteSelect = document.getElementById(ELEMENT_IDS.SITE_SELECT);
  const btnRedirect = document.getElementById(ELEMENT_IDS.REDIRECT_BUTTON);
  const iframe = document.getElementById(ELEMENT_IDS.IFRAME);
  loader.style.display = "none";
  siteSelect == null ? void 0 : siteSelect.setAttribute("disabled", "disabled");
  btnRedirect == null ? void 0 : btnRedirect.setAttribute("disabled", "disabled");
  updateDisplay();
  btnGetSite == null ? void 0 : btnGetSite.addEventListener("click", async () => {
    const codeClientInput = document.getElementById(ELEMENT_IDS.CLIENT_CODE_INPUT);
    const codeClient = codeClientInput.value;
    loader.style.display = "flex";
    if (codeClient) {
      try {
        const clientData = await fetchClientData(codeClient);
        if (clientData.SITES) {
          siteSelect.innerHTML = "";
          siteSelect.removeAttribute("disabled");
          btnRedirect.removeAttribute("disabled");
          clientData.SITES.forEach((site) => {
            const option = document.createElement("option");
            option.value = site.URL;
            option.text = site.Site;
            siteSelect.appendChild(option);
          });
        }
      } catch (e) {
        console.error(e);
      }
    }
    loader.style.display = "none";
  });
  btnRedirect == null ? void 0 : btnRedirect.addEventListener("click", () => {
    const selectedURL = siteSelect.value;
    if (selectedURL) {
      loader.style.display = "flex";
      changeSite(selectedURL);
    }
  });
  iframe.addEventListener("load", () => {
    loader.style.display = "none";
  });
  window.addEventListener("message", async (event) => {
    if (event.data === EVENTS.CHANGE_SITE) {
      await remove(STORAGE_KEY.MUSE_URL);
      siteSelected = false;
      updateDisplay();
    }
    hardwareAccess(event);
  });
  addNetworkListener();
});
export { CameraSource as C, WebPlugin as W, CameraDirection as a, CapacitorException as b };
