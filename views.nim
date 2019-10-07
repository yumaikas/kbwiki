import htmlgen, markdown
import sugar, strutils
import database

proc pageBase(inner: string): string =
  return "<!DOCTYPE html>" & html(
    head(meta(charset="utf-8")),
    inner
  )


proc tagLink(idea: Idea): string =
  return a(href="/view/bytag/" & idea.tag, idea.tag)
proc editLink(idea: Idea): string =
  return a(href="/admin/view/" & $idea.id, "Edit")
proc viewLink(idea: Idea, str: string = "View"): string =
  return a(href="/view/idea" & $idea.id, str)

proc linkIfNotes(idea: Idea): string =
  if idea.content.len == 0:
    return idea.title
  else:
    return idea.viewLink(idea.title)

proc viewIdea*(idea: Idea): string =
  return htmlgen.`div`(
      h2(a(href="/", idea.title)),
      htmlgen.`div`(id="tag", "Tag", idea.tagLink),
      idea.editLink(),
      htmlgen.`div`(id="notes", markdown(idea.content))
  )

proc tableWith(inner: () -> string): string =
  var output = newSeq[string]()
  output.add("<table>")
  output.add(inner())
  output.add("</table>")
  return output.join("\n")

proc ideaRows(ideas: seq[Idea]): string =
  var output = newSeq[string]()
  for idea in ideas:
    output.add(
      tr(
        td(idea.tagLink),
        td(idea.linkIfNotes)
      )
    )
  return output.join("\n")


proc adminIdeaRows(ideas: seq[Idea]): string =
  var output = newSeq[string]()
  for idea in ideas:
    output.add(
      tr(
        td(idea.tagLink),
        td(a(href = ("/admin/view/" & $idea.id), "Edit")),
        td(a(href = ("/view/idea/" & $idea.id), "View")),
        td(a(href = ("/admin/delete/" & $idea.id), "Delete")),
        td(idea.title)
      )
    )
  return output.join("\n")

proc viewIdeaList*(ideas: seq[Idea]): string =
  return pageBase(tableWith(() => ideaRows(ideas)))
