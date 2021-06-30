import Order "mo:base/Order";

module {

    type Order = Order.Order;

    public type Tree<X, Y> = {
        #node : (
            key: X,
            value: Y,
            l: Tree<X, Y>,
            r: Tree<X, Y>,
            compareFunc: (X, X) -> Order,
        );
        #leaf;
    };

    // Specifies a traversal order of the BST - used as an argument for iter() in BST.mo 
    public type Traversal = { #preorder; #postorder; #inorder };

};
