import Order "mo:base/Order";

module {

  type Order = Order.Order;

  public type Tree<X, Y> = {
    #node : (key: X, value: Y, l: Tree<X, Y>, r: Tree<X, Y>, compareFunc: (X, X) -> Order);
    #leaf;
  };

  public type Traversal = { #preorder; #postorder; #inorder };

};