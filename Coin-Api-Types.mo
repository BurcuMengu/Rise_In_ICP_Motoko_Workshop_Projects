module Types {

  public type Timestamp = Nat64;

    public type HttpRequestArgs = {
        url : Text;
        headers : [HttpHeader];
        body : ?[Nat8];
        method : HttpMethod;
    };

    public type HttpHeader = {
        name : Text;
        value : Text;
    };

    public type HttpMethod = {
        #get;
        #post;
        #head;
    };

    public type HttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };
    public type IC = actor {
        http_request : HttpRequestArgs -> async HttpResponsePayload;
    };

    public type CoinList = {
        #BTC;
        #ETH;
        #ICP;
        #SOL;
        #BNB;
        #USDT;
        #TRY;
    };
}
