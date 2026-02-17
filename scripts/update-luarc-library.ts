// @ts-nocheck
/**
 * 扫描 lazy 下所有插件的 lua 目录 + my-nvim/lua 配置路径，更新 .luarc.json 的 Lua.workspace.library；
 * 并扫描 my-nvim/lua/plugins 下所有 ---@module / ---@type，写入 .luarc.json 供参考。
 * 用法（在 .config/nvim 下）:
 *   bun run scripts/update-luarc-library.ts
 * 安装新插件后执行一次即可获得新插件的类型提示
 */

import { readdirSync, readFileSync, writeFileSync, existsSync } from "fs"
import { join } from "path"

const dataDir = process.env.XDG_DATA_HOME || `${process.env.HOME || "~"}/.local/share`
const lazyRoot = join(dataDir, "nvim", "my-nvim", "lazy")

const scriptDir = import.meta.dir ?? __dirname
const configRoot = join(scriptDir, "..")
const luarcPath = join(configRoot, ".luarc.json")
const pluginsRoot = join(configRoot, "my-nvim", "lua", "plugins")
const configLuaRoot = join(configRoot, "my-nvim", "lua")

function collectPluginTypes(): PluginType[] {
  const result: PluginType[] = []
  if (!existsSync(pluginsRoot)) return result

  function scan(dir: string) {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name)
      if (e.isDirectory()) {
        scan(full)
        continue
      }
      if (!e.name.endsWith(".lua")) continue
      const content = readFileSync(full, "utf-8")
      const rel = full.slice(pluginsRoot.length + 1)
      let moduleName: string | undefined
      const types: string[] = []
      for (const line of content.split("\n")) {
        const m = line.match(/^\s*---@module\s+["']([^"']+)["']/)
        if (m) moduleName = m[1]
        const t = line.match(/^\s*---@type\s+(.+)$/)
        if (t) types.push(t[1].trim())
      }
      if (moduleName || types.length) {
        result.push({ module: moduleName, types, file: rel })
      }
    }
  }
  scan(pluginsRoot)
  return result
}

function collectLibraryPaths(): string[] {
  const paths: string[] = []
  if (existsSync(configLuaRoot)) {
    paths.push(configLuaRoot)
  }
  if (!existsSync(lazyRoot)) {
    console.warn("Lazy root not found:", lazyRoot)
    return paths
  }
  for (const name of readdirSync(lazyRoot, { withFileTypes: true })) {
    if (!name.isDirectory()) continue
    const luaDir = join(lazyRoot, name.name, "lua")
    if (existsSync(luaDir)) {
      paths.push(luaDir)
    }
  }
  return [...paths.slice(0, 1), ...paths.slice(1).sort()]
}

function updateLuarc(libraryPaths: string[], pluginTypes: PluginType[]) {
  const raw = readFileSync(luarcPath, "utf-8")
  const luarc = JSON.parse(raw) as Record<string, unknown>

  luarc["Lua.workspace.library"] = libraryPaths
  luarc["_pluginTypes"] = pluginTypes
  writeFileSync(luarcPath, JSON.stringify(luarc, null, 2), "utf-8")
}

const pluginTypes = collectPluginTypes()
const paths = collectLibraryPaths()
if (paths.length === 0) {
  console.error("No library dirs found (lazy or my-nvim/lua)")
  process.exit(1)
}

console.log("Found", pluginTypes.length, "plugin type(s) in my-nvim/lua/plugins")
console.log("Found", paths.length, "library path(s) (config lua + lazy plugins)")
updateLuarc(paths, pluginTypes)
console.log("Updated", luarcPath)

type PluginType = { module?: string; types: string[]; file: string }
