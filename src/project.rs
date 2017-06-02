use reward::Reward;

#[derive(Serialize, Deserialize)]
pub struct Project {   
    pub name        : String,
    pub description : String,
    pub target      : i32,
    pub rewards     : Vec<Reward>,
    pub id          : i32
}