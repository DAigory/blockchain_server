#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;
extern crate hyper;

mod reward;
mod project;
mod db_read;

use rocket_contrib::{JSON};
use std::io;
use std::path::{Path, PathBuf};
use reward::*;
use project::*;
use rocket::response::NamedFile;
use rocket::Data;

#[derive(Serialize, Deserialize)]
struct Projects {
   projects : Vec<Project>
}

#[derive(Serialize, Deserialize)]
struct Rewards {
    rewards : Vec<Reward>
}

#[get("/get_list")]
fn get_projects() -> String{
   println!("get projects");    
   db_read::read_projects()
}
   
#[get("/get_by_id/<id>")]
fn get_by_id(id: i32) -> String {      
   db_read::read_by_id(id)
}

#[get("/delete_by_id/<id>")]
fn delete_by_id(id: i32) {    
    println!("deleta id:{0}", id);
    db_read::delete_by_id(id);     
}

#[post("/new_project", format = "application/json", data = "<project>")]
fn add_project(project: JSON<Project>) {    
    println!("post__");
    db_read::write_project(project.into_inner());     
}

#[get("/")]
fn index() -> io::Result<NamedFile> {
    NamedFile::open("static/index.html")
}

#[get("/file/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).ok()
}

#[post("/post_data", data = "<paste>")]
fn upload(paste: Data) -> io::Result<String> {   
    let url = format!("\n");
    paste.stream_to_file(Path::new(&"1"))?;
    Ok(url)
}

fn main() {   
    let mut rewards = vec!(Reward{name:"1".to_string(), cost: 2, id: 3});   
    rewards.push(Reward{name:"2".to_string(), cost: 2, id: 4});
    let project = Project{name:"Shar".to_string(), description:"my shar".to_string(), target: 3, rewards: rewards, id: 4};
    let projects = vec!(project);   
    let my_json = serde_json::to_string(&projects).unwrap(); 
    println!("{0} ", my_json);

    rocket::ignite().mount("/", routes![index, delete_by_id, files, upload, 
                                        get_projects, get_by_id, add_project])
                                        .launch();
}