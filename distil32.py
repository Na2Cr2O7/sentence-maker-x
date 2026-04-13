# import tokens
import dbcontroller
import json
import jieba.posseg as jieba
import requests
import os
if not os.path.exists("train.csv"):
    with open('train.csv','wb') as f:
        r=requests.get('https://www.modelscope.cn/datasets/modelscope/chinese-poetry-collection/resolve/master/train.csv')
        f.write(r.content)

MAX_COUNT=60000
print(f"使用数据集内{MAX_COUNT}条数据")

dcl=dbcontroller.DBController('tokens.db')
dcl.cmd('''
CREATE TABLE IF NOT EXISTS tags(
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    word TEXT UNIQUE,
    tags TEXT
);

''')
# dcl.create("sentencePatterns")
import tqdm


dcl.cmd(f'''
CREATE TABLE IF NOT EXISTS sentences(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sentence TEXT
)
        ''')

# conversations=extract_human_assistant_from_jsonl("train.jsonl")
conversations=[]
with open("train.csv",'r',encoding='utf8') as f:
    i=0
    for line in f:
        if i==0:
            i+=1
            continue
        conversations.append(line)
    count=0
    progress=tqdm.tqdm(total=MAX_COUNT)
    for jd in conversations:
            count+=1
            progress.update(1)
            if count>MAX_COUNT:
                break
            concaterated=jd.replace(' ','').replace('\n','').replace("**","")
            concaterated_sentences=concaterated.replace("？ ",'。').split("。")
            for sentence in concaterated_sentences:
                sentence+="。"
                if len(sentence)<4:
                    continue
                # print(f'INSERT OR IGNORE INTO sentences(sentence) VALUES ("{sentence}");')
                try:

                    dcl.cmd(f'''
                    INSERT OR IGNORE INTO sentences(sentence) VALUES ("{sentence.replace("\"","\\\"")}");
                    ''')
                except:
                    pass
                result:list=jieba.lcut(sentence)
                for word,tag in result:
                    if tag=="x" and word not in "。，；":
                        continue
                    if tag=="eng":
                        continue

                    try:
                        # dcl.insert_token2("tags",word,tag)
                        dcl.cmd(f'''
                            INSERT or ignore INTO "tags"(word,tags)
                            VALUES("{word}","{tag[0]}");
    ''')
                    except Exception as e:
                        # print(e,word,tag,end='\r')
                        pass
                # dcl.cmd(f'''INSERT or ignore INTO sentencePattern({','.join([f"tag{i}" for i in range(1,len(tags)+1)])})
                # VALUES({string});''')
