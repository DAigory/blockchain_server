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

mod reward;
mod project;
mod dbRead;
use reward::*;
use project::*;


#[get("/get_list")]
fn get_list() -> &'static str {
   "index test"
}

#[get("/get_by_name/<name>")]
fn get_by_name(name: &str) -> String {

   println!("{0}", name);
   name.to_string() + "return"
}

#[get("/new/<name>")]
fn new(name: &str) -> String {

   println!("{0}", name);
   name.to_string() + "new name"
}


#[post("/users", format = "application/json", data = "<project>")]
fn new_user(project: JSON<Project>) {
    println!("{0}", project.id);
}

fn main() {   
    let mut rewards = vec!(Reward{name:"1".to_string(), cost: 2, id: 3});   
    rewards.push(Reward{name:"2".to_string(), cost: 2, id: 4});
    let project = Project{name:"Shar".to_string(), description:"my shar".to_string(), target: 3, rewards: rewards, id: 4};
    let my_json = serde_json::to_string(&project).unwrap();

    //dbRead::writeProjects(project);
    dbRead::readProjects();

    println!("{0} ", my_json);
    rocket::ignite().mount("/", routes![get_list, get_by_name, new, new_user]).launch();
}