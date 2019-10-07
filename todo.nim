import os
import nre except toSeq
import strutils

proc searchPath(path: string) =
  var text = readFile(path)
  for m in text.findAll(re"TODO:.+"):
    echo m


# Emit from code files before text files
for path in walkFiles("*.nim"):
  if not path.contains("todo.nim"):
    searchPath(path)
echo("------")
for path in walkFiles("*.txt"): searchPath(path)
