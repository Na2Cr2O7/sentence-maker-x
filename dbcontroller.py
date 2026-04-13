import sqlite3
import threading
import time
def cmdfrom(file) ->str:
    return open(f"{file}.sql" if '.sql' not in file else file,'r',encoding='utf8').read()

# cur.execute(cmdfrom('createTable'))

# def insert(word:tokens.Word):
#     cur.execute(cmdfrom("insert").replace("{WORD_PLACEHOLDER}",word.word).replace("{TAGS_PLACEHOLDER}",word.tag))
    # con.commit()
class DBController:
    def __init__(self,file:str) -> None:
        self.con = sqlite3.connect(file)
        self.cur = self.con.cursor()
        self.t=None
    def cmd(self,command):
        # print(command)
        return self.cur.execute(command)
    def commit(self):
        self.con.commit()
    def __del__(self):
        self.commit()