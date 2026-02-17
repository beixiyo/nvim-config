/**
 * 扫描 lazy 下所有插件的 lua 目录，更新 .luarc.json 的 Lua.workspace.library
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

function collectLibraryPaths(): string[] {
  if (!existsSync(lazyRoot)) {
    console.warn("Lazy root not found:", lazyRoot)
    return []
  }
  const paths: string[] = []
  for (const name of readdirSync(lazyRoot, { withFileTypes: true })) {
    if (!name.isDirectory()) continue
    const luaDir = join(lazyRoot, name.name, "lua")
    if (existsSync(luaDir)) {
      paths.push(luaDir)
    }
  }
  return paths.sort()
}

function updateLuarc(libraryPaths: string[]) {
  const raw = readFileSync(luarcPath, "utf-8")
  const luarc = JSON.parse(raw) as Record<string, unknown>

  luarc["Lua.workspace.library"] = libraryPaths
  writeFileSync(luarcPath, JSON.stringify(luarc, null, 2), "utf-8")
}

const paths = collectLibraryPaths()
if (paths.length === 0) {
  console.error("No plugin lua dirs found under", lazyRoot)
  process.exit(1)
}

console.log("Found", paths.length, "plugin lua dirs")
updateLuarc(paths)
console.log("Updated", luarcPath)
