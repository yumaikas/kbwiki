import os, strutils

proc envOrDefault(key, fallback: string): string =
  result = getEnv(key)
  if not existsEnv(key):
    result = fallback

let USERNAME*: string = envOrDefault("USERNAME", "anon")
let PASSWORD*: string = envOrDefault("PASSWORD", "password")
