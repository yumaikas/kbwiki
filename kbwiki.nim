import jester
import database, views, kb_config
import strutils
from nativesockets import Port

let db = newDatabase(DB_FILE)
db.setup()

var bindAddr = "localhost"
if not BIND_LOCAL_ONLY:
  bindAddr = "0.0.0.0"

settings:
  port = nativesockets.Port(kb_config.PORT)
  bindAddr = bindAddr

routes:
  # / -> home
  get "/":
    resp viewIdeaList(db.ideasSortedByModTime())
  # /admin/ -> ideas_admin_ui
  get "/admin":
    resp adminIdeaList(db.adminIdeasSortedByModTime())
    
  # /view/@type/@arg -> tag handler
  #  @type == bytag -> get_ideas_html(@arg)
  get "/view/bytag/@tag":
    resp viewIdeaList(db.getIdeasByTag(@"tag"))
  get "/admin/bytag/@tag":
    resp adminIdeaList(db.getIdeasByTag(@"tag"))

  get "/admin/view/@id":
    resp viewEditIdea(db.getIdeaById(parseInt(@"id")))
  get "/view/idea/@id":
    #  @type == idea -> get_idea_html_for(@arg.int32)
    let id = parseInt(@"id")
    let idea = db.getIdeaById(id)
    resp viewIdea(idea)
  
  post "/admin/create/new":
    let formData = request.formData
    cond "tag" in formData
    cond "description" in formData
    cond "notes" in formData
    let idea = Idea(
      title: formData["description"].body,
      tag: formData["tag"].body,
      content: formData["notes"].body
    )
    let newId = db.createIdea(idea)
    redirect ("/view/idea/" & $newId)
    
  post "/admin/update/@id":
    #   @action = "update"
    let formData = request.formData
    cond "tag" in formData
    cond "description" in formData
    cond "notes" in formData
    let idea = Idea(
      id: parseInt(@"id"),
      title: formData["description"].body,
      tag: formData["tag"].body,
      content: formData["notes"].body
    )
    db.updateIdea(idea)
    redirect("/view/idea/" & $idea.id)

  post "/admin/delete/@id":
    resp Http500, "Route Not Implemented!"
    
  error Exception:
    resp Http500, errorPage("Something isn't quite right. Try again later")


