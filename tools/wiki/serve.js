#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const { spawn } = require("node:child_process");

const ROOT = fs.realpathSync(path.resolve(__dirname, "../.."));
const HOST = "127.0.0.1";
const BLOCKED_SEGMENTS = new Set([".git", ".godot", "build", "dist", "node_modules"]);
const BLOCKED_EXTENSIONS = new Set([".aab", ".apk", ".jks", ".keystore", ".save"]);
const MIME_TYPES = new Map([
  [".css", "text/css; charset=utf-8"],
  [".gd", "text/plain; charset=utf-8"],
  [".html", "text/html; charset=utf-8"],
  [".import", "text/plain; charset=utf-8"],
  [".jpeg", "image/jpeg"],
  [".jpg", "image/jpeg"],
  [".js", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".md", "text/markdown; charset=utf-8"],
  [".pck", "application/octet-stream"],
  [".png", "image/png"],
  [".svg", "image/svg+xml"],
  [".tres", "text/plain; charset=utf-8"],
  [".tscn", "text/plain; charset=utf-8"],
  [".txt", "text/plain; charset=utf-8"],
  [".wasm", "application/wasm"],
  [".webmanifest", "application/manifest+json; charset=utf-8"],
  [".webp", "image/webp"],
]);

function parseArgs(argv) {
  let port = Number(process.env.WIKI_PORT || 8000);
  let openBrowser = true;

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--no-browser") {
      openBrowser = false;
    } else if (argument === "--port") {
      index += 1;
      port = Number(argv[index]);
    } else if (argument.startsWith("--port=")) {
      port = Number(argument.slice("--port=".length));
    } else {
      throw new Error(`Argumento desconhecido: ${argument}`);
    }
  }

  if (!Number.isInteger(port) || port < 0 || port > 65535) {
    throw new Error("A porta deve ser um inteiro entre 0 e 65535.");
  }
  return { port, openBrowser };
}

function sendText(response, status, message) {
  const body = `${message}\n`;
  response.writeHead(status, {
    "Content-Type": "text/plain; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
    "X-Content-Type-Options": "nosniff",
    "Cache-Control": "no-store",
  });
  response.end(body);
}

function resolveFile(urlPath) {
  let decodedPath;
  try {
    decodedPath = decodeURIComponent(urlPath);
  } catch {
    return { error: 400, message: "URL inválida." };
  }
  if (decodedPath.includes("\0")) {
    return { error: 400, message: "URL inválida." };
  }

  const segments = decodedPath.split(/[\\/]+/).filter(Boolean);
  if (segments.some((segment) => segment === "." || segment === ".." || segment.includes(":"))) {
    return { error: 403, message: "Caminho não permitido." };
  }
  if (segments.some((segment) => segment.startsWith(".") || BLOCKED_SEGMENTS.has(segment.toLowerCase()))) {
    return { error: 403, message: "Arquivo não disponível pelo servidor local." };
  }

  const candidate = path.resolve(ROOT, ...segments);
  if (candidate !== ROOT && !candidate.startsWith(`${ROOT}${path.sep}`)) {
    return { error: 403, message: "Caminho fora do projeto." };
  }
  if (BLOCKED_EXTENSIONS.has(path.extname(candidate).toLowerCase())) {
    return { error: 403, message: "Arquivo não disponível pelo servidor local." };
  }

  let realPath;
  try {
    realPath = fs.realpathSync(candidate);
  } catch (error) {
    if (error.code === "ENOENT" || error.code === "ENOTDIR") {
      return { error: 404, message: "Arquivo não encontrado." };
    }
    if (error.code === "EACCES") {
      return { error: 403, message: "Acesso negado." };
    }
    throw error;
  }
  if (realPath !== ROOT && !realPath.startsWith(`${ROOT}${path.sep}`)) {
    return { error: 403, message: "Caminho fora do projeto." };
  }

  let stat;
  try {
    stat = fs.statSync(realPath);
  } catch (error) {
    if (error.code === "ENOENT" || error.code === "ENOTDIR") {
      return { error: 404, message: "Arquivo não encontrado." };
    }
    if (error.code === "EACCES") {
      return { error: 403, message: "Acesso negado." };
    }
    throw error;
  }

  let filePath = realPath;
  const directory = stat.isDirectory();
  if (directory) {
    try {
      filePath = fs.realpathSync(path.join(realPath, "index.html"));
    } catch (error) {
      if (error.code === "ENOENT" || error.code === "ENOTDIR") {
        return { error: 404, message: "Arquivo não encontrado." };
      }
      if (error.code === "EACCES") {
        return { error: 403, message: "Acesso negado." };
      }
      throw error;
    }
    if (filePath !== ROOT && !filePath.startsWith(`${ROOT}${path.sep}`)) {
      return { error: 403, message: "Caminho fora do projeto." };
    }
    stat = fs.statSync(filePath);
  }
  if (!stat.isFile()) {
    return { error: 404, message: "Arquivo não encontrado." };
  }
  return { filePath, directory };
}

function openBrowser(url) {
  let command;
  let args;
  if (process.platform === "win32") {
    command = "cmd.exe";
    args = ["/c", "start", "", url];
  } else if (process.platform === "darwin") {
    command = "open";
    args = [url];
  } else {
    command = "xdg-open";
    args = [url];
  }

  const child = spawn(command, args, { detached: true, stdio: "ignore", windowsHide: true });
  child.on("error", (error) => {
    console.error(`Não foi possível abrir o navegador automaticamente: ${error.message}`);
    console.log(`Acesse manualmente: ${url}`);
  });
  child.unref();
}

function createServer() {
  return http.createServer((request, response) => {
    if (request.method !== "GET" && request.method !== "HEAD") {
      response.setHeader("Allow", "GET, HEAD");
      sendText(response, 405, "Método não permitido.");
      return;
    }

    let requestUrl;
    try {
      requestUrl = new URL(request.url || "/", `http://${HOST}`);
    } catch {
      sendText(response, 400, "URL inválida.");
      return;
    }

    if (requestUrl.pathname === "/") {
      response.writeHead(302, { Location: "/docs/wiki/", "Cache-Control": "no-store" });
      response.end();
      return;
    }

    const result = resolveFile(requestUrl.pathname);
    if (result.error) {
      sendText(response, result.error, result.message);
      return;
    }

    if (result.directory && !requestUrl.pathname.endsWith("/")) {
      response.writeHead(301, { Location: `${requestUrl.pathname}/${requestUrl.search}` });
      response.end();
      return;
    }

    let stat;
    try {
      stat = fs.statSync(result.filePath);
    } catch (error) {
      if (error.code === "ENOENT" || error.code === "ENOTDIR") {
        sendText(response, 404, "Arquivo não encontrado.");
        return;
      }
      throw error;
    }
    if (!stat.isFile()) {
      sendText(response, 404, "Arquivo não encontrado.");
      return;
    }

    response.writeHead(200, {
      "Content-Type": MIME_TYPES.get(path.extname(result.filePath).toLowerCase()) || "application/octet-stream",
      "Content-Length": stat.size,
      "X-Content-Type-Options": "nosniff",
      "Cache-Control": "no-cache",
    });
    if (request.method === "HEAD") {
      response.end();
      return;
    }

    const stream = fs.createReadStream(result.filePath);
    stream.on("error", (error) => {
      console.error(`Falha ao ler ${path.relative(ROOT, result.filePath)}: ${error.message}`);
      if (!response.headersSent) sendText(response, 500, "Não foi possível ler o arquivo.");
      else response.destroy(error);
    });
    stream.pipe(response);
  });
}

function listen(server, requestedPort) {
  return new Promise((resolve, reject) => {
    const onError = (error) => {
      server.off("listening", onListening);
      reject(error);
    };
    const onListening = () => {
      server.off("error", onError);
      resolve(server.address().port);
    };
    server.once("error", onError);
    server.once("listening", onListening);
    server.listen(requestedPort, HOST);
  });
}

async function main() {
  if (Number(process.versions.node.split(".")[0]) < 18) {
    throw new Error("Node.js 18 ou superior é necessário.");
  }
  const { port, openBrowser: shouldOpenBrowser } = parseArgs(process.argv.slice(2));
  const server = createServer();
  let selectedPort;
  try {
    selectedPort = await listen(server, port);
  } catch (error) {
    if (error.code !== "EADDRINUSE" || port === 0) throw error;
    console.log(`A porta ${port} está ocupada; vou selecionar uma porta livre.`);
    selectedPort = await listen(server, 0);
  }

  const url = `http://${HOST}:${selectedPort}/docs/wiki/`;
  console.log(`Wiki do projeto: ${url}`);
  console.log("Servidor ativo em 127.0.0.1. Pressione Ctrl+C para encerrar.");
  if (shouldOpenBrowser) openBrowser(url);

  const shutdown = () => server.close(() => process.exit(0));
  process.once("SIGINT", shutdown);
  process.once("SIGTERM", shutdown);
}

main().catch((error) => {
  console.error(`Não foi possível iniciar o servidor da wiki: ${error.message}`);
  process.exitCode = 1;
});
