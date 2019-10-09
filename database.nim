import times, db_sqlite, strutils

type 
  Database* = ref object
    db*: DbConn

  Idea* = object
    id*: int
    tag*: string
    title*: string
    content*: string
    created*: Time
    modified*: Time

proc newDatabase*(filename = "kbwiki.db"): Database =
  new result
  result.db = open(filename, "", "", "")

proc close*(database: Database) =
  database.db.close()

proc setup*(database: Database) =
  database.db.exec(sql"""
  Create Table if not exists idea_entry(
    id INT PRIMARY KEY,
    tag text DEFAULT "TODO",
    title text,
    content text,
    created integer,
    modified integer
  );
  """)

  database.db.exec(sql"""
  Create Table if not exists idea_entry_history(
    id INT PRIMARY KEY,
    idea_id integer,
    tag text DEFAULT "TODO",
    title text,
    content text,
    created integer,
    modified integer
  );
  """)

proc ideaFromRow(row: seq[string]): Idea =
  result.id = row[0].parseInt
  result.tag = row[1]
  result.title = row[2]
  result.content = row[3]
  result.created = row[4].parseInt().fromUnix
  result.modified = row[5].parseInt().fromUnix

proc getIdeasByTag*(database: Database, tag: string): seq[Idea] =
  var ideas = newSeq[Idea]()
  var query = sql"""
  SELECT id, tag, title, content, created, modified 
  FROM idea_entry 
  WHERE tag = ?
  ORDER BY modified;"""
  for row in database.db.fastRows(query, tag):
    ideas.add(ideaFromRow(row))
  return ideas


proc getIdeaById*(database: Database, id: int): Idea =
  let row = database.db.getRow(
    sql"SELECT id, tag, title, content, created, modified from idea_entry where id = ?;", id)
  result = ideaFromRow(row)
  
proc ideasSortedByModTime*(database: Database): seq[Idea] =
  var ideas = newSeq[Idea]()
  var query = sql"SELECT id, tag, title, content, created, modified from idea_entry order by modified;"
  for row in database.db.fastRows(query):
    ideas.add(ideaFromRow(row))
  return ideas

proc createIdea*(database: Database, idea: Idea): int64=
  let currTime = getTime().toUnix
  return database.db.tryInsertId(
    sql"INSERT into idea_entry(tag, title, content, created, modified) values(?,?,?,?,?)",
      idea.tag, idea.title, idea.content, currTime, currTime)

proc deleteIdea*(database: Database, id: int) =
  database.db.exec(
    sql"""
    INSERT INTO idea_entry_history(idea_id, tag, title, content, created, updated)
    SELECT id, tag, title, content, created, ? from idea_entry where idea_entry.id = ?
    """, getTime().toUnix, id)
  database.db.exec(sql"DELETE FROM idea_entry where id = ?", id)

proc updateIdea*(database: Database, idea: Idea) =
  # Start by copying the current idea into the history table
  database.db.exec(
    sql"""
    INSERT INTO idea_entry_history(idea_id, tag, title, content, created, updated)
    SELECT id, tag, title, content, created, ? from idea_entry where idea_entry.id = ?
    """, getTime().toUnix, idea.id)

  # And then update the current entry
  database.db.exec(sql"""
  Update idea_entry
  SET tag = ?, title = ?, content = ?, updated = ?
  WHERE id = ?
  """,
    idea.tag, idea.title, idea.content, getTime().toUnix, idea.id)

