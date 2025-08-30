part of 'cart_cubit.dart';

class CartState extends Equatable {
  const CartState({this.productIdToQuantity = const <int, int>{}});

  final Map<int, int> productIdToQuantity;

  CartState copyWith({Map<int, int>? productIdToQuantity}) {
    return CartState(productIdToQuantity: productIdToQuantity ?? this.productIdToQuantity);
  }

  @override
  List<Object?> get props => <Object?>[productIdToQuantity];
}
