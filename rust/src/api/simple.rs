use std::io::Write;

use rand::prelude::*;
use std::fs;
use tempfile::NamedTempFile;
static DB_BYTES: &[u8] = include_bytes!("tokens.db");
fn get_tag(conn: &sqlite::Connection, src: &str) -> String {
    let mut query: String = String::from("SELECT tags FROM tags WHERE word=\"");
    query += src;
    query += "\"";
    let mut tag: String = String::from("n");
    let _ = conn.iterate(query, |pairs| {
        for &(_name, value) in pairs.iter() {
            // println!("{} = {}", name, value.unwrap_or("n"));
            tag = String::from(value.unwrap_or("n"));
            return false;
        }
        true
    });
    return tag;
}
fn get_tags(conn: &sqlite::Connection, src: &Vec<String>) -> Vec<String> {
    let mut ret: Vec<String> = Vec::new();
    for i in src {
        ret.push(get_tag(conn, i.as_str()));
    }
    ret
}
fn exists_in_db(conn: &sqlite::Connection, src: String) -> bool {
    let mut query = String::from("SELECT 1 FROM tags WHERE word=\"");
    query += &src;
    query += &String::from("\"");
    let mut exists = false;
    let _ = conn.iterate(query, |pairs| {
        for &(_name, _value) in pairs.iter() {
            // println!("{} = {}", name, value.unwrap_or("n"));
            exists = true;
            return false;
        }
        true
    });
    exists
}
fn tokenize(conn: &sqlite::Connection, text: &str) -> Vec<String> {
    let mut result = Vec::new();
    let chars: Vec<char> = text.chars().collect();
    let len = chars.len();
    let mut i = 0;

    while i < len {
        let mut matched = false;
        // 从最长可能开始匹配：j 从 len 到 i+1
        for j in (i + 1..=len).rev() {
            let s: String = chars[i..j].iter().collect();
            if exists_in_db(&conn, s.clone()) {
                result.push(s);
                i = j;
                matched = true;
                break;
            }
        }
        if !matched {
            result.push(chars[i].to_string());
            i += 1;
        }
    }
    result
}
fn random_select_sentence(conn: &sqlite::Connection) -> String {
    let mut res = String::new();
    while res.len() < 1 {
        let query = "SELECT sentence from sentences ORDER BY RANDOM() LIMIT 1";
        conn.iterate(query, |pairs| {
            for &(_name, value) in pairs.iter() {
                // println!("{} = {}", name, value.unwrap_or(""));
                match value {
                    Some(value) => {
                        res = value.to_string();
                    }
                    None => (),
                }
            }
            true
        })
        .unwrap_or(());
    }
    res
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    // format!("Hellsadasasdadso, {name}!")
    let mut temp_file = NamedTempFile::new().expect("unable to initialize");
    temp_file.write_all(DB_BYTES).expect("unable to dump db");
    let mut result_string = String::new();

    {
        let connection: sqlite::Connection = sqlite::open(temp_file.path()).unwrap();
        let mut input = name.clone();
        input = input.trim().to_string();
        let input2 = input.clone();
        let binding = input2.replace("，", ",");
        let mut input_vec: Vec<&str> = binding.split(",").collect();
        let mut input_vec_string: Vec<String> = vec![];

        let mut rng = rand::rng();
        input_vec.shuffle(&mut rng);
        for i in input_vec {
            input_vec_string.push(i.to_string());
        }
        let mut input_tags = get_tags(&connection, &input_vec_string);

        while input_vec_string.len() > 0 {
            let mut tags: Vec<String> = Vec::new();
            let mut sentence: String;
            let mut tokenized: Vec<String> = vec![];
            while !tags.contains(&input_tags[0]) {
                sentence = random_select_sentence(&connection);
                tokenized = tokenize(&connection, &sentence);
                tags = get_tags(&connection, &tokenized);
            }
            for i in 0..tokenized.len() {
                if input_tags.len() == 0 {
                    continue;
                }
                if tags[i] == input_tags[0] {
                    tokenized[i] = input_vec_string[0].to_string();

                    input_vec_string.remove(0);
                    input_tags.remove(0);
                }
            }
            // println!("{:?}",tokenized);
            let mut res = String::new();
            for token in tokenized {
                res += &token;
            }
            // println!("{res}");
            result_string += &res;
        }
    }

    // fs::remove_file(temp_file.path()).unwrap_or(());
    // connection
    // let _ = connection;
    fs::remove_file(temp_file.path()).unwrap();
    result_string
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize

    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn destruct() {}
