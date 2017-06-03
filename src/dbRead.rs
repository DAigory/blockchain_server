#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate hyper;
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

use std::env;
use std::io;
use std::io::Read;
use std::borrow;

use hyper::Client;
use hyper::header::Connection;
use dbRead;
use reward::Reward;
use project::Project;

static URL: &'static str = "http://192.168.1.237:8081";

pub fn readProjects() -> String
{
    return read(URL);
}

pub fn readRewards() -> String
{
    let newURL = format!("{}{}", URL, "/rewards");
    return read(&newURL);
}

pub fn writeProject(project: Project)
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
    let newURL = format!("{}/addData/{data}", URL, data = my_json);
    println!("{}", newURL);
    read(&newURL);
}

pub fn writeReward(reward: Reward) 
{
    let newURL = format!("{}/addNewRew/{id}/{name}/{cost}", URL, id = reward.id, name = reward.name, cost = reward.cost);
    read(&newURL);
}

fn read(param: &str) -> String
{
    let client = Client::new();

    let mut res = client.get(param)
        .header(Connection::close())
        .send().unwrap();

    println!("Read: {}", param);
    println!("Response: {}", res.status);
    println!("Headers:\n{}", res.headers);
    io::copy(&mut res, &mut io::stdout()).unwrap();

    let mut body = String::new();
    res.read_to_string(&mut body).unwrap();

    return body;
}


