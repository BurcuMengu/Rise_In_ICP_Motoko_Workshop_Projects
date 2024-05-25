import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Types "Types";

actor {
  let ic : Types.IC = actor ("aaaaa-aa");
  type Id = Nat32;

  type Coins_cart = {
    purchase_type: Types.CoinList;
    addCoin: Types.CoinList;
    purchase_amount: Nat32;
  };

  private stable var next : Id = 0;
  private stable var cart : Trie.Trie<Id, Coins_cart> = Trie.empty();
  private stable var temp: Trie.Trie<Id, Coins_cart> = Trie.empty();
  private stable var wallet: Trie.Trie<Id, Coins_cart> = Trie.empty();

  public func get_coin_compare(coin_value_1: Types.CoinList, coin_value_2: Types.CoinList ) : async Text {
    var coin_1 = "ICP";
    var coin_2 = "USDT";
    switch(coin_value_1) {
      case(#BTC) { coin_1 := "BTC" };
      case(#ETH) { coin_1 := "ETH"};
      case(#ICP) { coin_1 := "ICP"};
      case(#SOL) { coin_1 := "SOL"};
      case(#BNB) { coin_1 := "BNB"};
      case(#USDT) { coin_1 := "USDT"};
      case(#TRY) { coin_1 := "TRY"};
    };

      switch(coin_value_2) {
      case(#BTC) { coin_2 := "BTC" };
      case(#ETH) { coin_2 := "ETH"};
      case(#ICP) { coin_2 := "ICP"};
      case(#SOL) { coin_2 := "SOL"};
      case(#BNB) { coin_2 := "BNB"};
      case(#USDT) { coin_2 := "USDT"};
      case(#TRY) { coin_2 := "TRY"};
    };
    // URL'yi ayarlayın
    let host : Text = "min-api.cryptocompare.com";
    let url = "https://" # host # "/data/price?fsym=" # coin_1 # "&tsyms=" # coin_2 # "";
    // Başlıkları ayarlayın
    let request_headers = [
        { name = "Host"; value = host },
        { name = "User-Agent"; value = "exchange_rate_canister" },
    ];

    // HTTP isteği için argümanları hazırlayın
    let http_request : Types.HttpRequestArgs = {
        url = url;
        headers = request_headers;
        body = null; // İsteğe bağlı
        method = #get;
    };

    Cycles.add(20_949_972_000);

    // HTTP isteğini yapın ve yanıtı bekleyin
    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

    // Yanıtı dekode edin
    let response_body: Blob = Blob.fromArray(http_response.body);
    let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
        case (null) { "No value returned" };
        case (?y) { y };
    };

    // Yanıtın gövdesini döndürün
    decoded_text
  };

  public func add_cart(coin_cart: Coins_cart) : async Id {
    let id = next;
    next += 1;
    cart := Trie.replace(
      cart,
      key(id),
      Nat32.equal,
      ?coin_cart,
    ).0;
    return id;
  };

  public query func read(id : Id) : async ? Coins_cart {
    let result = Trie.find(cart, key(id), Nat32.equal);
    return result;
  };

  public func deleteCart(id: Id) : async Bool{
    let result = Trie.find(cart, key(id), Nat32.equal);
    let exists = Option.isSome(result); 
    if (exists) {
      cart := Trie.replace(
        cart,
        key(id),
        Nat32.equal,
        null
      ).0;
    };

    exists
  };

  public func updateCart(id: Id, new_product: Coins_cart) : async Bool {
    let result = Trie.find(cart, key(id), Nat32.equal);
    let exists = Option.isSome(result);
    if(exists) {
      cart := Trie.replace(
        cart,
        key(id),
        Nat32.equal,
        ?new_product
      ).0;   
    };
    exists
  };

  public func order() : async (){
    temp := Trie.clone(cart);
    wallet := Trie.merge(wallet, temp, Nat32.equal);
  };
  
  public query func read_wallet(id : Id) : async ? Coins_cart {
    let result = Trie.find(wallet, key(id), Nat32.equal);
    return result;
  };

  public func clear_cart() : async (){
    cart := Trie.empty();
  };

  private func key(x : Id) : Trie.Key<Id> {
    return { hash = x; key = x };
  };

}
