import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Bool "mo:base/Bool";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Char "mo:base/Char";


actor {

    type ContactId = Nat32;
    type Contact = {
        name: Text;
        phone: Text;
        email: Text;
        isFavorite: Bool;
        isBlocked: Bool;
    };

    type ResponseContact = {
        name: Text;
        phone: Text;
        email: Text;
        isFavorite: Bool;
        isBlocked: Bool;
        id: Nat32;
    };

   private stable var next : ContactId = 0;

   private stable var contacts : Trie.Trie<ContactId, Contact> = Trie.empty();

   public func addContact(contact : Contact) : async Text {
    //alternatif olarak gösterebileceğimiz bir metot, tüm validasyonları bünyesine alan ve addContact'a özgü bir validasyon metodu
    // if ( addContactValidator(contact.phone) == false){
    //   return ("Phone number is not in the correct format!");

    // };
    if ( not validatePhoneNumberNumeric(contact.phone)){
            return ("Phone number must only contain numeric numbers");
    };
    if (not validatePhoneNumberSize(contact.phone)) {
            return ("Phone number must be a 10-digit");
        };
    if (contact.isBlocked == true and contact.isFavorite == true) {
            return ("A contact cannot be both marked as a favorite and blocked. ");
        };
    if( checkIfNumberAlreadyExists(contact.phone)){
      return ("Phone number already exists in your contacts");
    };

    let contactId = next;
    next += 1;
    contacts := Trie.replace(
      contacts,
      key(contactId),
      Nat32.equal,
      ?contact,
    ).0;
    return ("Contact Created Successfully");
  };

   public func delete(contactId : ContactId) : async Bool {
    let result = Trie.find(contacts, key(contactId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      contacts := Trie.replace(
        contacts,
        key(contactId),
        Nat32.equal,
        null,
      ).0;
    };
    return exists;
  };

  public func updateContact(contactId : ContactId, contact : Contact) : async Bool {
    if(updateContactValidator(contact.phone) ==false){
      return false;
    };
    let result = Trie.find(contacts, key(contactId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      contacts := Trie.replace(
        contacts,
        key(contactId),
        Nat32.equal,
        ?contact,
      ).0;
    };
    return exists;
  };

  public func getContacts () : async [(ResponseContact)]  {
    return Trie.toArray<ContactId, Contact, ResponseContact>(
    contacts,
    func (k, v) : (ResponseContact) {
      {id= k; name = v.name; phone = v.phone; email= v.email; isFavorite= v.isFavorite; isBlocked= v.isBlocked}
    }
  );
  };

  //buffer kullanımı için bir örnek
  // public func getAllContacts(): async [Contact]{
  //   let response = Buffer.Buffer<Contact>(0); 
  //   // var response : [Contact] = [];
  //   let iter = Trie.iter(contacts);

  //   for ((k, v) in iter) {
  //     response.add(v);
  //   };
  //   return Buffer.toArray(response); 
  // };
  
  public  func showContacts(): async Text {
    var allContacts =  await getContacts();
    var output: Text = "\n__ALL-CONTACTS_____";
    for (contact in allContacts.vals()){
      output#= "\n" # contact.name
    };
    output;
  };


  public func deleteByName(searchKey: Text) : async Text {
    let filteredContact: Trie.Trie<ContactId, Contact> = Trie.filter<ContactId, Contact>(contacts, func (key: ContactId, contact: Contact)  { contact.name == searchKey});
     var size = Trie.size(filteredContact);
     if (size == 0) {
      return ("The name you are looking for is not in the Contact Book");
     };
     var contact:[(ResponseContact)] = Trie.toArray<ContactId, Contact, ResponseContact>(
      filteredContact,
      func(k,v): (ResponseContact) {
        {id = k; name = v.name; phone = v.phone; email= v.email; isFavorite= v.isFavorite; isBlocked= v.isBlocked }
      }
     );
     var result: Text = " The contact is not deleted.Try again later";
     if(await delete(contact[0].id)) {result := "Deleted Successfully"};
    result;
  };

   public func deleteByPhone(searchKey: Text) : async Text {
    let filteredContact: Trie.Trie<ContactId, Contact> = Trie.filter<ContactId, Contact>(contacts, func (key: ContactId, contact: Contact)  { contact.phone == searchKey});
     var size = Trie.size(filteredContact);
     if (size == 0) {
      return ("The number you are looking for is not in the Contact Book");
     };
     var contact:[(ResponseContact)] = Trie.toArray<ContactId, Contact, ResponseContact>(
      filteredContact,
      func(k,v): (ResponseContact) {
        {id = k; name = v.name; phone = v.phone; email= v.email; isFavorite= v.isFavorite; isBlocked= v.isBlocked }
      }
     );
     var result: Text = "Contact" # contact[0].name #"Deleted Successfully";
     if(await delete(contact[0].id)) {result := "The contact is not deleted.Try again later"};
    result;
  };

  public func getContactByName(searchKey: Text) : async Text {

  let filteredContact: Trie.Trie<ContactId, Contact> = Trie.filter<ContactId, Contact>(contacts, func (key: ContactId, contact: Contact)  { contact.name == searchKey});
     var size = Trie.size(filteredContact);
     if (size == 0) {
      return ("The name you are looking for is not in the Contact Book");
     };
     var contact:[(ResponseContact)] = Trie.toArray<ContactId, Contact, ResponseContact>(
      filteredContact,
      func(k,v): (ResponseContact) {
        {id = k; name = v.name; phone = v.phone; email= v.email; isFavorite= v.isFavorite; isBlocked= v.isBlocked }
      }
     );
     var result: Text = "\n___CONTACT:___" 
     # "\nid: " #Nat32.toText(contact[0].id)  
     # "\nName:  " #contact[0].name  
     # "\nPhone: " #contact[0].phone  
     # "\nEmail: " # contact[0].email 
     # "\n";
     if (contact[0].isFavorite) {result #= " Favorite\n"} ;
     if (contact[0].isBlocked) {result #= " Blocked\n"} ;
     result;
  };

  public func getContactByPhone(searchKey: Text) : async Text {

  let filteredContact: Trie.Trie<ContactId, Contact> = Trie.filter<ContactId, Contact>(contacts, func (key: ContactId, contact: Contact)  { contact.phone == searchKey});
     var size = Trie.size(filteredContact);
     if (size == 0) {
      return ("The phone you are looking for is not in the Contact Book");
     };
     var contact:[(ResponseContact)] = Trie.toArray<ContactId, Contact, ResponseContact>(
      filteredContact,
      func(k,v): (ResponseContact) {
        {id = k; name = v.name; phone = v.phone; email= v.email; isFavorite= v.isFavorite; isBlocked= v.isBlocked }
      }
     );
     var result: Text = "\n___CONTACT:___" 
     # "\nName:  " #contact[0].name  
     # "\nPhone: " #contact[0].phone  
     # "\nEmail: " # contact[0].email 
     # "\n";
     if (contact[0].isFavorite) {result #= " Favorite"} ;
     if (contact[0].isBlocked) {result #= " Blocked"} ;
     result;
  };

  private func key(x : ContactId) : Trie.Key<ContactId> {
    return { hash = x; key = x };
  };

  private func validatePhoneNumberSize(phone: Text) : Bool {
        if (phone.size() != 10) {
            return false;
        };
        return true;
    };

  private func validatePhoneNumberNumeric(phone:Text) :  Bool{
    for (letter in phone.chars()){
      if( Char.isDigit(letter) == false){
        return false;
      };
    };
    return true;
  };


  private func checkIfNumberAlreadyExists(phone:Text) : Bool {
    let filteredContact: Trie.Trie<ContactId, Contact> = Trie.filter<ContactId, Contact>(contacts, func (key: ContactId, contact: Contact)  { contact.phone == phone});
     if (Trie.size(filteredContact) == 0) {
      return false;
     }
     else{
      return true;
     }
  };
   


  private func addContactValidator(phone:Text) :Bool{
    if( validatePhoneNumberSize(phone) == false or  validatePhoneNumberNumeric(phone:Text) == false  or  checkIfNumberAlreadyExists(phone:Text) == true){
      return false;
    };
    return true;

  };

  private func updateContactValidator(phone:Text) : Bool{
    if( validatePhoneNumberSize(phone) == false or  validatePhoneNumberNumeric(phone:Text) == false){
      return false;
    };
    return true;
  }
}
