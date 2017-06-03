extern crate hyper;

extern crate serde;
extern crate serde_json;

use std::io::Read;


use hyper::Client;
use hyper::header::Connection;
use project::Project;

static URL: &'static str = "http://10.208.0.48:8081";

pub fn read_projects() -> String
{
    return read(URL);
}

pub fn read_by_id(id: i32) -> String {
    let new_url = format!("{}{}/{}", URL, "/searchId", id);
    read(&new_url)
}

pub fn delete_by_id(id: i32) {
    let new_url = format!("{}{}/{}", URL, "/delete", id);
    read(&new_url);
}

pub fn write_project(project: Project)
{ 
    let mut list = "".to_string();
    let count = project.rewards.len();
    for i in 0..count {
        list.push_str(&project.rewards[i].id.to_string());
        
        if i != count - 1
        {
            list.push_str(",");
        }
    }    

    let my_json = serde_json::to_string(&project).unwrap();
    let new_url = format!("{}/addData/{data}", URL, data = my_json);
    println!("{}", new_url);
    read(&new_url);
}

fn read(param: &str) -> String
{    
    let client = Client::new();
    println!("Read: {}", param);
    let mut res = client.get(param)
        .header(Connection::close())
        .send().unwrap();
 
    
    println!("Response: {}", res.status);
    println!("Headers:\n{}", res.headers);
   
    let mut body = String::new();
    res.read_to_string(&mut body).unwrap();

    return body;
}


