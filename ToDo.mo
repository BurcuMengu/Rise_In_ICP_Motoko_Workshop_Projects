import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

actor ToDo {
  let Tasks = HashMap.HashMap<Text, Task>(0, Text.equal, Text.hash);

  public type Task = {
    topic: Text;
    description: Text;
    completed: Bool;
  };

  // create
  public func add_task (id: Text, new_topic: Text, new_description: Text) : async Bool {
    if (id != "" and new_topic != "" and new_description != "")
    {
      Tasks.put(id, {topic = new_topic; description = new_description; 
	  
	  completed = false});
      true;
    }
    else
    {
      false;
    }
  };

  // read
  public query func get_tasks() : async [Task] {
    Iter.toArray(Tasks.vals()); 
  };

  // update
  public func complete_task(id: Text) : async () {
    ignore do ? {
      let task_topic = Tasks.get(id)!.topic;
      let task_description = Tasks.get(id)!.description;

      Tasks.put(id, {topic = task_topic; description = task_description; completed = true});
    };
  };

  // delete
  public func delete_task(id: Text) : async () {
    Tasks.delete(id);
  }
};
