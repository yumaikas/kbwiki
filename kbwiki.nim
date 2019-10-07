import htmlgen
import jester
import database
import strutils


let db = newDatabase()

routes:
  # / -> home
  get "/":
    resp h1 ("Kilobyte Wiki!")
    # TODO: revisit jester's approach to building web responses later
    
  # /view/@type/@arg -> tag handler
  #  @type == bytag -> get_ideas_html(@arg)
  get "/view/bytag/@tag":
    resp (h1("View by tag:" & @"tag"))
  get "/view/idea/@id":
    #  @type == idea -> get_idea_html_for(@arg.int32)
    let id = parseInt(@"id")
    let idea = db.getIdeaById(id)
    echo idea.title
    resp (h1("View idea by id:" & $id))
  
  # /admin/@action/@id -> ideas_admin
  #   @action = "create"
  post "/admin/create/@id":
    discard
  #   @action = "update"
  post "/admin/update/@id":
    discard
  #   @action = "delete"
  #   @action = "bytag"
  #   @action = "view"
  # /admin/ -> ideas_admin_ui
  #

  get "/admin/view":
    discard
  post "/admin/create/new":
    discard
  post "/admin/delete":
    discard
    
