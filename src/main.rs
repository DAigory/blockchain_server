#![feature(plugin)]
#![plugin(rocket_codegen)]

#[macro_use] extern crate rocket;
#[macro_use] extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;

extern crate serde;
extern crate serde_json;


use rocket_contrib::{JSON, Value};



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

#[derive(Serialize, Deserialize)]
struct Message {
    id: Option<i32>,
    contents: String
}

fn main() {
    rocket::ignite().mount("/", routes![get_list, get_by_name, new]).launch();
    //rocket::ignite().mount("/", routes![hello]).launch();
}