import 'package:dartz/dartz.dart';
import '../networking/faileur.dart';

class NoParams {}

abstract class UseCase<T, Param> {
  Future<Either<Faileur, T>> call([Param params]);
}

abstract class UseCase1<T, Param, Param2, Param3, Param4> {
  Future<Either<Faileur, T>> call(
      [Param params, Param2 params2, Param3 params3, Param4 params4]);
}
abstract class UseCase4<T, Param, Param2, Param3, Param4, Param5,Param6> {
  Future<Either<Faileur, T>> call(
      [Param params, Param2 params2, Param3 params3, Param4 params4, Param5 params5,Param6 params6]);
}
abstract class UseCase5<T, Param, Param2, Param3, Param4, Param5> {
  Future<Either<Faileur, T>> call(
      [Param params, Param2 params2, Param3 params3, Param4 params4, Param5 params5]);
}

abstract class ReceiptUseCase<T, Param, Param2, Param3, Param4, Param5, Param6,
    Param7, Param8, Param9, Param10, Param11> {
  Future<Either<Faileur, T>> call([
    Param params,
    Param2 params2,
    Param3 params3,
    Param4 params4,
    Param5 params5,
    Param6 params6,
    Param7 params7,
    Param8 params8,
    Param9 params9,
    Param10 params10,
    Param11 params11,
  ]);
}

abstract class PostUseCase<T, Param, Param2, Param3, Param4, Param5, Param6,
    Param7> {
  Future<Either<Faileur, T>> call(
      [Param params1,
      Param2 params2,
      Param3 params3,
      Param4 params4,
      Param5 params5,
      Param6 params6,
      Param7 params7]);
}

abstract class UseCase2<T, Param, Param2, Param3> {
  Future<Either<Faileur, T>> call(
      [Param params, Param2 params2, Param3 params3]);
}

abstract class UseCase3<T, Param, Param2> {
  Future<Either<Faileur, T>> call([Param params, Param2 params2]);
}

enum BillType { all, credit, paid, partiallyPaidBills, refundedBills }

enum ClientSort {
  aToZ,
  zToA,
  lowestCredit,
  highestCredit,
  lowestOrder,
  highestOrder,
}

enum PaymentState {
  paid,
  free,
  pending,
  unPaid,
  processing,
  partiallyPaid,
  declined,
  refunded,
  earnings,
  other
}
enum SortingBy{
  product,
  quantity,
  spending,
  merchant,
  visit,
  avgSpending,
  purchases,
  date,
  tags
}
String getPaymentStateString(PaymentState state) {
  switch (state) {
    case PaymentState.paid:
      return "Paid";
    case PaymentState.free:
      return "Free";
    case PaymentState.pending:
      return "Pending";
    case PaymentState.unPaid:
      return "Unpaid";
    case PaymentState.processing:
      return "Processing";
    case PaymentState.partiallyPaid:
      return "Partially Paid";
    case PaymentState.declined:
      return "Declined";
    case PaymentState.refunded:
      return "Refunded";
    case PaymentState.earnings:
      return "Earnings";
    case PaymentState.other:
      return "Other";
  }
}
