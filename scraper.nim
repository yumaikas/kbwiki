import httpclient, nre, base64
import htmlparser, xmltree, strtabs, strutils
import terminal, database, algorithm
from os import sleep
import scraper_config

let baseLink = "https://drift.junglecoder.com"

proc viewLink(id: string): string =
  return baseLink & "/admin/view/" & id

proc namedInputValue(tree: XmlNode, name: string): string =
  for input in tree.findAll("input"):
    if input.attrs().hasKey("name") and input.attrs["name"] == name:
      return input.attrs()["value"]

proc textareaValue(tree: XmlNode): string =
  var output = newSeq[string]()
  for c in tree.findAll("textarea")[0].items():
    output.add($c)
  return output.join("")

proc pageToIdea(page: string, id: int): Idea =
  let tree = parseHtml(page)
  var idea = Idea()
  idea.id = id
  idea.tag = tree.namedInputValue("tag")
  idea.title = tree.namedInputValue("description")
  idea.content = tree.textareaValue()
  return idea

var db = newDatabase("driftwiki.db")
db.setup()
echo "HEX"
try:
  echo "XEH"
  var client = newHttpClient()
  client.headers["Authorization"] = "Basic " & base64.encode(USERNAME & ":" & PASSWORD)
  var resp = client.getContent(baseLink & "/admin")
  var ids: seq[string] = resp.findAll(re"(?<=/view/idea/)\d+")
  for id in ids.reversed():
    # if not (id == "1"): continue
    # Ok, so now we need to request follow-up things.
    discard db.createIdeaWithId(id.parseInt(), pageToIdea(client.getContent(viewLink(id)), id.parseInt))
    os.sleep(200)
finally:
  db.close()
