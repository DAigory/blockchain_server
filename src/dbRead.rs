#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate hyper;

use std::env;
use std::io;
use std::io::Read;
use std::borrow;

use hyper::Client;
use hyper::header::Connection;
use dbRead;

static URL: &'static str = "http://192.168.1.237:8080";

pub fn readProjects()
{
    read(URL);
}

pub fn readRewards()
{
    let newURL = format!("{}{}", URL, "/rewards");
    read(&newURL);
}

pub fn writeProjects()
{
    //let newURL = format!("{}/addNewProj/{id}/{name}/{desc}/{target}/", URL, id = "2", name = "Project2", desc = "Desc2", target = "Trget2");
    //read(&newURL);
}

pub fn writeRewards()
{
    let newURL = format!("{}/addNewRew/{id}/{name}/{cost}", URL, id = "2", name = "Name2", cost = "123");
    read(&newURL);
}

fn read(param: &str)
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
}


