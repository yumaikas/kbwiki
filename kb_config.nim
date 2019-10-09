import os, strutils

proc envOrDefault(key, fallback: string): string =
  result = getEnv(key)
  if not existsEnv(key):
    result = fallback

let APP_TITLE*: string = envOrDefault("APP_TITLE", "KB Wiki")
let DB_FILE*: string = envOrDefault("DB_FILE", "kbwiki.sqlite")
let PORT*: int = envOrDefault("PORT", "9999").parseInt
let THEME*: string = envOrDefault("THEME", "AQUA")
