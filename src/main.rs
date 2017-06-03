#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;
extern crate hyper;
use rocket_contrib::{JSON};
use std::io;
use std::path::{Path, PathBuf};

mod reward;
mod project;
mod dbRead;
use reward::*;
use project::*;
use rocket::response::NamedFile;

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
    
   dbRead::readProjects()
}
   
#[get("/get_by_id/<id>")]
fn get_by_id(id: i32) -> String {    
  let projects: Projects = serde_json::from_str(&dbRead::readProjects()).
  expect(&format!("deserialize error get_by_id {0}", id));
  let project = projects.projects.iter().find(|&x| x.id == id);
  serde_json::to_string(&project).unwrap()
}

#[post("/new_project", format = "application/json", data = "<project>")]
fn add_project(project: JSON<Project>) {    
    dbRead::writeProject(project.into_inner());     
}

#[get("/")]
fn index() -> io::Result<NamedFile> {
    NamedFile::open("static/index.html")
}

#[get("/file/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).ok()
}

fn main() {   
    let mut rewards = vec!(Reward{name:"1".to_string(), cost: 2, id: 3});   
    rewards.push(Reward{name:"2".to_string(), cost: 2, id: 4});
    let project = Project{name:"Shar".to_string(), description:"my shar".to_string(), target: 3, rewards: rewards, id: 4};
    let my_json = serde_json::to_string(&project).unwrap();
   
   let p: Project = serde_json::from_str(&my_json).unwrap();
    println!("+++++ {0}", p.id);
    //dbRead::readProjects();

    println!("{0} ", my_json);

    rocket::ignite().mount("/", routes![index, files, get_projects, get_by_id, add_project]).launch();
}