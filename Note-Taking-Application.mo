import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Bool "mo:base/Bool";
import Option "mo:base/Option";

actor {

  type NoteId = Nat32;
  type Note = {
    title : Text;
    content : Text;
  };

  private stable var next : NoteId = 0;

  private stable var notes : Trie.Trie<NoteId, Note> = Trie.empty();

  public func addNote(title : Text, content : Text) : async Text {
    let noteId = next;
    next += 1;
    let note : Note = { title = title; content = content };
    notes := Trie.replace(
      notes,
      key(noteId),
      Nat32.equal,
      ?note,
    ).0;
    return ("Note Created Successfully");
  };

  public func updateNote(noteId : NoteId, title : Text, content : Text) : async Bool {
    let result = Trie.find(notes, key(noteId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      let note : Note = { title = title; content = content };
      notes := Trie.replace(
        notes,
        key(noteId),
        Nat32.equal,
        ?note,
      ).0;
    };
    return exists;
  };

  public func deleteNote(noteId : NoteId) : async Bool {
    let result = Trie.find(notes, key(noteId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      notes := Trie.replace(
        notes,
        key(noteId),
        Nat32.equal,
        null,
      ).0;
    };
    return exists;
  };

  public func getNoteById(noteId : NoteId) : async Option.Option<Note> {
    return Trie.find(notes, key(noteId), Nat32.equal);
  };

  private func key(x : NoteId) : Trie.Key<NoteId> {
    return { hash = x; key = x };
  };

};
