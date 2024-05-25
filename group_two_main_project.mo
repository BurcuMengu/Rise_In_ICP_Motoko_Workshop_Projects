import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

actor SocialMedia {

  type Post = {
    author : Principal;
    content : Text;
    timestamp : Time.Time;
  };

  func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n));
  };

  var posts = Map.HashMap<Nat, Post>(0, Nat.equal, natHash); // Gönderilerin ID'leri ile eşleştirildiği HashMap
  var nextId : Nat = 0; // Bir sonraki gönderi ID'sini tutan değişken

  // Tüm gönderileri getirme işlemi
  public query func getPosts() : async [(Nat, Post)] {
    // Tüm gönderileri döndüren query fonksiyonu
    Iter.toArray(posts.entries()); // HashMap içindeki tüm gönderileri diziye dönüştürüyor
  };

  // Yeni gönderi ekleme işlemi
  public shared (msg) func addPost(content : Text) : async Text {
    // Yeni gönderi ekleyen fonksiyon
    let id = nextId; // Yeni gönderi ID'si oluşturuluyor
    posts.put(id, { author = msg.caller; content = content; timestamp = Time.now() }); // Gönderi HashMap'e ekleniyor
    nextId += 1; // Bir sonraki gönderi ID'si artırılıyor
    "Gönderi başarıyla eklendi. Gönderi ID'si: " # Nat.toText(id); // Sonuç metni döndürülüyor
  };

  // Belirli bir gönderiyi görüntüleme işlemi
  public query func viewPost(id : Nat) : async ?Post {
    // Belirli bir gönderiyi döndüren query fonksiyonu
    posts.get(id); // Gönderiyi ID'si ile getiriyor
  };

  // Tüm gönderileri temizleme işlemi
  public func clearPosts() : async () {
    // Tüm gönderileri temizleyen fonksiyon
    for (key : Nat in posts.keys()) {
      // HashMap içindeki tüm anahtarları alıyor
      ignore posts.remove(key); // Gönderileri temizliyor
    };
  };

  // Gönderiyi düzenleme işlemi
  public shared (msg) func editPost(id : Nat, newContent : Text) : async Bool {
    // Gönderiyi düzenleyen fonksiyon
    switch (posts.get(id)) {
      // Gönderi ID'si ile gönderiye erişiliyor
      case (?post) {
        // Gönderi varsa
        if (post.author == msg.caller) {
          // Yazar fonksiyonu çağıran kişi ise
          posts.put(id, { author = msg.caller; content = newContent; timestamp = post.timestamp }); // Gönderi düzenleniyor
          return true; // Başarılı olduğu belirtiliyor
        } else {
          return false; // Yetkilendirme hatası
        };
      };
      case null {
        // Gönderi ID'si geçersizse
        return false; // Geçersiz gönderi ID'si hatası
      };
    };
  };

};
