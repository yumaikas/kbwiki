import db_postgres, times
import database
import cligen


proc doDbexport(file:string = "ideawiki.db", conn: string = "localhost:postgres:postgres:folio_dev") =
    let sqliteDb = newDatabase(file)

    let ideas = sqliteDb.ideasSortedByModTime()

    let connparts = conn.split(':')
    let pgDb = open(connparts[0], connparts[1], connparts[2], connparts[3])

    try: 
        for idea in ideas:
            pgDb.exec(sql"""
                INSERT INTO public.ideas (id, tag, title, content, inserted_at, updated_at)
                values (?, ?, ?, ?, ?, ?);
                 """,
                idea.id, idea.tag, idea.title, idea.content, idea.created.local(), idea.modified.local())
    except:
        echo getCurrentExceptionMsg()
    finally:
        pgDb.close()



cligen.dispatch(doDbexport)