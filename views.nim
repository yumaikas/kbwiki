import sugar, strutils, strformat
import htmlgen, markdown
import database, kb_config

proc css*(): string =
  # TODO: make this select from a list of themes, or pull from the database
  var back_color = "#191e2a"
  var fore_color = "#21EF9F"
  var link_color = "aqua"
  var visted_color = "darkcyan"
  if THEME == "AQUA":
    discard
  elif THEME == "AUTUMN":
    back_color = "#2a2319"
    fore_color = "#EFC121"
    link_color = "F0FF00"
    visted_color = "#a5622a"
  # Right now, the implicit default theme is AQUA, if we don't recognize the current theme.
    

  return style(&"""
body {{
  max-width: 800px;
  width: 90%;
}}
body,input,textarea {{
  font-family: Iosevka, monospace;
  background: {back_color};
  color: {fore_color};
}}
td {{ margin: 5px; }}
a {{ color: {link_color}; }}
a:visited {{ color: {visted_color}; }}
""")


proc pageBase(inner: string): string =
  return "<!DOCTYPE html>" & html(
    head(
      meta(charset="utf-8"),
      meta(name="viewport", content="width=device-width, initial-scale=1.0"),
    ),
    body(
      css(),
      inner
    )
  )


# HTML inputs for editing various fields on ideas
proc titleEditor(idea: Idea): string =
  return input(`type`="text", name="description", size=($idea.title.len), value=idea.title)

proc tagEditor(idea: Idea): string =
  return input(`type`="text", name="tag", size=($idea.tag.len), value=idea.tag)

proc notesEditor(idea: Idea): string =
  return textarea(name="notes", rows="50", cols="75", idea.content)

# Links that hang off of various parts of the idea
proc tagLink(idea: Idea): string =
  return a(href="/view/bytag/" & idea.tag, idea.tag)
proc editLink(idea: Idea): string =
  return a(href="/admin/view/" & $idea.id, "Edit")
proc viewLink(idea: Idea, str: string = "View"): string =
  return a(href="/view/idea/" & $idea.id, str)

proc linkIfNotes(idea: Idea): string =
  if idea.content.len == 0:
    return idea.title
  else:
    return idea.viewLink(idea.title)

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

proc createIdeaForm(): string =
  return form(id="new-idea", action="/admin/create/new", `method`="POST", enctype="multipart/form-data",
    table(
      tr(
        td(label(`for`="tag", "Tag: ")),
        td(input(`type`="text", name="tag"))
      ),
      tr(
        td(label(`for`="description", "Description: ")),
        td(input(`type`="text", name="description"))
      ),
      tr(
        td(label(`for`="notes", "Notes: ")),
        td(textarea(name="notes", rows="50", cols="75", ""))
      )
    ),
    button(`type`="submit", "Add Idea")
  )

proc viewIdea*(idea: Idea): string =
  return pageBase(`div`(
      h2(a(href="/", idea.title)),
      `div`(id="tag", "Tag: ", idea.tagLink),
      idea.editLink(),
      `div`(id="notes", markdown(idea.content))
  ))

proc viewEditIdea*(idea: Idea): string =
  return pageBase(
    form(id = "idea-to-save", action= ("/admin/update/" & $idea.id), `method`="POST", enctype="multipart/form-data",
      h2("Description"), idea.titleEditor,
      `div`("Tag:"), idea.tagEditor,
      `div`("Notes:"), idea.notesEditor,
      button(type="submit", "Save")
    )
  )

proc viewIdeaList*(ideas: seq[Idea]): string =
  return pageBase(tableWith(() => ideaRows(ideas)) )

proc adminIdeaList*(ideas: seq[Idea]): string =
  return pageBase(
    tableWith(() => adminIdeaRows(ideas)) &
    h2("Create Page") &
    createIdeaForm())

proc errorPage*(message: string): string =
  return pageBase(message)

