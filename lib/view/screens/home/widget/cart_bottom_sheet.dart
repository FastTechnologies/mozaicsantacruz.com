import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/read_more_text.dart';
import 'package:flutter_restaurant/view/base/rating_bar.dart';
import 'package:flutter_restaurant/view/base/wish_button.dart';
import 'package:flutter_restaurant/view/screens/home/widget/product_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../helper/product_type.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/profile_provider.dart';
import '../../../../utill/app_toast.dart';
import '../../../../utill/routes.dart';
import '../../../base/custom_snackbar.dart';
import '../../../base/title_widget.dart';

class CartBottomSheet extends StatefulWidget {
  final Product product;
  final bool fromSetMenu;
  final Function callback;
  final CartModel cart;
  final int cartIndex;
  final bool fromCart;
  final bool fromPoints;

  CartBottomSheet(
      {@required this.product,
      this.fromSetMenu = false,
      this.callback,
      this.cart,
      this.cartIndex,
      this.fromCart = false,
      this.fromPoints = false});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  int _cartIndex;

  @override
  void initState() {
    Provider.of<ProductProvider>(context, listen: false)
        .initData(widget.product, widget.cart, context);
    Provider.of<ProductProvider>(context, listen: false)
        .getRecommendedSideList(context);
    Provider.of<ProductProvider>(context, listen: false)
        .getRecommendedBeveragesList(context);

    print('==is recommended${widget.product.isRecommended}');
    super.initState();
  }
  // _showDialog(Product product,ProductProvider productProvider) async {
  //   await Future.delayed(Duration(milliseconds: 50));
  //   showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (context) => Dialog(
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         ListView.builder(
  //           shrinkWrap: true,
  //             itemCount:Provider.of<ProductProvider>(context, listen: false).drinks.length ,
  //             itemBuilder: (context,i){
  //           return InkWell(
  //
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       InkWell(
  //                         onTap: (){
  //                           // productProvider.checkedItems.add(productProvider
  //                           //     .recommendedBeveragesList[index].id);
  //                           // setState(() {
  //                           //
  //                           // });
  //
  //                         },
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //
  //                               color: productProvider.checkedDrink.contains(productProvider
  //                                   .drinks[i])? Theme.of(context).primaryColor: Colors.transparent,
  //                               shape: BoxShape.circle,
  //
  //                               border: Border.all(
  //                                 color:productProvider.checkedDrink.contains(productProvider
  //                                     .drinks[i])? Theme.of(context).primaryColor: Colors.black,
  //
  //                               )
  //                           ),
  //                           child: Icon(Icons.done,color: Colors.white,size: 15,),
  //                         ),
  //                       ),
  //                       SizedBox(width: 10,),
  //                       Text(productProvider.drinks[i],
  //                           style: rubikRegular.copyWith(
  //                               fontSize: Dimensions.FONT_SIZE_LARGE)),
  //                     ],
  //                   ),
  //
  //
  //                 ],
  //               ),
  //             ),
  //           );
  //         }),
  //       ],
  //     ),
  //   ));
  // }
  @override
  Widget build(BuildContext context) {
    Variation _variation = Variation();

    return Consumer<CartProvider>(builder: (context, _cartProvider, child) {
      _cartProvider.setCartUpdate(false);
      return Stack(
        children: [
          Container(
            width: 600,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: ResponsiveHelper.isMobile(context)
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))
                  : BorderRadius.all(Radius.circular(20)),
            ),
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                double _startingPrice;
                double _endingPrice;
                if (widget.product.choiceOptions.length != 0) {
                  List<double> _priceList = [];
                  widget.product.variations
                      .forEach((variation) => _priceList.add(variation.price));
                  _priceList.sort((a, b) => a.compareTo(b));
                  _startingPrice = _priceList[0];
                  if (_priceList[0] < _priceList[_priceList.length - 1]) {
                    _endingPrice = _priceList[_priceList.length - 1];
                  }
                } else {
                  _startingPrice = widget.product.price;
                }

                List<String> _variationList = [];
                for (int index = 0;
                    index < widget.product.choiceOptions.length;
                    index++) {
                  _variationList.add(widget.product.choiceOptions[index]
                      .options[productProvider.variationIndex[index]]
                      .replaceAll(' ', ''));
                }
                String variationType = '';
                bool isFirst = true;
                _variationList.forEach((variation) {
                  if (isFirst) {
                    variationType = '$variationType$variation';
                    isFirst = false;
                  } else {
                    variationType = '$variationType-$variation';
                  }
                });

                double price = widget.product.price;
                for (Variation variation in widget.product.variations) {
                  if (variation.type == variationType) {
                    price = variation.price;
                    _variation = variation;
                    break;
                  }
                }
                double priceWithDiscount = PriceConverter.convertWithDiscount(
                    context,
                    price,
                    widget.product.discount,
                    widget.product.discountType);
                double addonsCost = 0;
                List<AddOn> _addOnIdList = [];
                for (int index = 0;
                    index < widget.product.addOns.length;
                    index++) {
                  if (productProvider.addOnActiveList[index]) {
                    addonsCost = addonsCost +
                        (widget.product.addOns[index].price *
                            productProvider.addOnQtyList[index]);
                    _addOnIdList.add(AddOn(
                        id: widget.product.addOns[index].id,
                        quantity: productProvider.addOnQtyList[index]));
                  }
                }

                DateTime _currentTime =
                    Provider.of<SplashProvider>(context, listen: false)
                        .currentTime;
                DateTime _start = DateFormat('hh:mm:ss')
                    .parse(widget.product.availableTimeStarts);
                DateTime _end = DateFormat('hh:mm:ss')
                    .parse(widget.product.availableTimeEnds);
                DateTime _startTime = DateTime(
                    _currentTime.year,
                    _currentTime.month,
                    _currentTime.day,
                    _start.hour,
                    _start.minute,
                    _start.second);
                DateTime _endTime = DateTime(
                    _currentTime.year,
                    _currentTime.month,
                    _currentTime.day,
                    _end.hour,
                    _end.minute,
                    _end.second);
                if (_endTime.isBefore(_startTime)) {
                  _endTime = _endTime.add(Duration(days: 1));
                }
                bool _isAvailable = _currentTime.isAfter(_startTime) &&
                    _currentTime.isBefore(_endTime);
                print('--from poinst:${widget.fromPoints}');

                CartModel _cartModel = CartModel(
                    widget.fromPoints == false ? price : 0.0,
                    widget.fromPoints
                        ? double.parse(widget.product.loyaltyPoints)
                        : 0.0,
                    priceWithDiscount,
                    [_variation],
                    widget.fromPoints == false
                        ? (price -
                            PriceConverter.convertWithDiscount(
                                context,
                                price,
                                widget.product.discount,
                                widget.product.discountType))
                        : 0,
                    productProvider.quantity,
                    widget.fromPoints == false
                        ? price -
                            PriceConverter.convertWithDiscount(context, price,
                                widget.product.tax, widget.product.taxType)
                        : 0,
                    _addOnIdList,
                    widget.product,
                    false,
                    widget.fromPoints);

                _cartIndex = _cartProvider.isExistInCart(
                  widget.product.id,
                  variationType.isEmpty ? null : variationType,
                  false,
                  null,
                );
                print('is exit : $_cartIndex');
                print('is null : ${productProvider.relatedProducts != null}');

                double priceWithQuantity =
                    priceWithDiscount * productProvider.quantity;
                double priceWithAddons = priceWithQuantity + addonsCost;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveHelper.isMobile(context)
                        ? Container(
                            margin: EdgeInsets.only(bottom: 10),
                            height: 5,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5)),
                          )
                        : SizedBox(),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(
                              ResponsiveHelper.isMobile(context)
                                  ? 0
                                  : Dimensions.PADDING_SIZE_EXTRA_LARGE),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Product
                                _productView(
                                  context,
                                  _startingPrice,
                                  _endingPrice,
                                  price,
                                  priceWithDiscount,
                                  _cartModel,
                                ),
                                _description(context),

                                _variationView(productProvider, variationType),
                                widget.product.choiceOptions.length > 0
                                    ? SizedBox(
                                        height: Dimensions.PADDING_SIZE_LARGE)
                                    : SizedBox(),
                                widget.product.isRecommended == '1'
                                    ? Column(
                                        children: [
                                          productProvider.recommendedSidesList !=
                                                      null &&
                                                  productProvider
                                                          .recommendedSidesList
                                                          .length >
                                                      0
                                              ? ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 20, 0, 20),
                                                          child: Text(
                                                              'Recommended Sides',
                                                              style: rubikRegular
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .FONT_SIZE_OVER_LARGE)),
                                                        ),
                                                      ],
                                                    )
                                                  :
                                          TitleWidget(
                                                      title:
                                                          'Recommended Sides',
                                                    )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          productProvider.isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                              Color>(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ))
                                              : productProvider
                                                              .recommendedSidesList !=
                                                          null &&
                                                      productProvider
                                                              .recommendedSidesList
                                                              .length >
                                                          0
                                                  ? ProductView(
                                                      productType: ProductType
                                                          .RECOMMENDED_SIDES,
                                                      isFromCart: true,
                                                      isFromCartSheet: true,
                                                    )
                                                  : SizedBox(),

                                          // Order type
                                          // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                                          productProvider.recommendedBeveragesList !=
                                                      null &&
                                                  productProvider
                                                          .recommendedBeveragesList
                                                          .length >
                                                      0
                                              ? ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 20, 0, 20),
                                                          child: Text(
                                                              'Recommended Beverages',
                                                              style: rubikRegular
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .FONT_SIZE_OVER_LARGE)),
                                                        ),
                                                      ],
                                                    )
                                                  : TitleWidget(
                                                      title:
                                                          'Recommended Beverages',
                                                    )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          productProvider.isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                              Color>(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ))
                                              : productProvider
                                                              .recommendedBeveragesList !=
                                                          null &&
                                                      productProvider
                                                              .recommendedBeveragesList
                                                              .length >
                                                          0
                                                  ? ProductView(
                                                      productType: ProductType
                                                          .RECOMMENDED_BEVERAGES,
                                                      isFromCart: true,
                                                      isFromCartSheet: true,
                                                    )
                                                  : SizedBox(),
                                        ],
                                      )
                                    : SizedBox.shrink(),

                                // SizedBox(
                                //   height: 220,
                                //   child: ListView.separated(
                                //     itemCount: productProvider
                                //         .recommendedBeveragesList.length,
                                //     itemBuilder: (context, index) {
                                //       var product=productProvider
                                //           .recommendedBeveragesList[index];
                                //       return Padding(
                                //         padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                                //         child: InkWell(
                                //           onTap: (){
                                //             if(product.name=='Soft Drinks'){
                                //               print('==soft drink');
                                //               _showDialog(product,productProvider);
                                //             }
                                //
                                //
                                //             if(productProvider.checkedItems.contains(productProvider
                                //                 .recommendedBeveragesList[index].id)){
                                //               productProvider.checkedItems.remove(productProvider
                                //                   .recommendedBeveragesList[index].id);
                                //               var cinde=_cartProvider.cartList.indexWhere((element) => element.product.id==product.id);
                                //
                                //
                                //               Provider.of<CartProvider>(
                                //                   context,
                                //                   listen: false)
                                //                   .removeFromCart(
                                //                   cinde);
                                //
                                //               setState(() {
                                //
                                //               });
                                //             }else{
                                //               productProvider.checkedItems.add(productProvider
                                //                   .recommendedBeveragesList[index].id);
                                //               setState(() {
                                //
                                //               });
                                //
                                //               if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()){
                                //                 debugPrint(
                                //                     '==cehck listid:${product.choiceOptions
                                //                         .length}');
                                //
                                //                   if (product.choiceOptions
                                //                       .length !=
                                //                       0) {
                                //                     List<double> _priceList =
                                //                     [];
                                //                     product.variations.forEach(
                                //                             (variation) =>
                                //                             _priceList.add(
                                //                                 variation
                                //                                     .price));
                                //                     _priceList.sort((a, b) =>
                                //                         a.compareTo(b));
                                //                     _startingPrice =
                                //                     _priceList[0];
                                //                     if (_priceList[0] <
                                //                         _priceList[
                                //                         _priceList.length -
                                //                             1]) {
                                //                       _endingPrice = _priceList[
                                //                       _priceList.length -
                                //                           1];
                                //                     }
                                //                   } else {
                                //                     _startingPrice =
                                //                         product.price;
                                //                   }
                                //
                                //                   List<String> _variationList =
                                //                   [];
                                //                   for (int index = 0;
                                //                   index <
                                //                       product.choiceOptions
                                //                           .length;
                                //                   index++) {
                                //                     print('===index:${index}');
                                //                     _variationList.add(product
                                //                         .choiceOptions[index]
                                //                         .options[productProvider
                                //                         .variationIndex[
                                //                     index]]
                                //                         .replaceAll(' ', ''));
                                //                   }
                                //                   String variationType = '';
                                //                   bool isFirst = true;
                                //                   _variationList
                                //                       .forEach((variation) {
                                //                     if (isFirst) {
                                //                       variationType =
                                //                       '$variationType$variation';
                                //                       isFirst = false;
                                //                     } else {
                                //                       variationType =
                                //                       '$variationType-$variation';
                                //                     }
                                //                   });
                                //
                                //                   double price = product.price;
                                //                   for (Variation variation
                                //                   in product.variations) {
                                //                     if (variation.type ==
                                //                         variationType) {
                                //                       price = variation.price;
                                //                       _variation = variation;
                                //                       break;
                                //                     }
                                //                   }
                                //                   double priceWithDiscount =
                                //                   PriceConverter
                                //                       .convertWithDiscount(
                                //                       context,
                                //                       price,
                                //                       product.discount,
                                //                       product
                                //                           .discountType);
                                //                   double addonsCost = 0;
                                //                   List<AddOn> _addOnIdList = [];
                                //
                                //
                                //                   DateTime _currentTime =
                                //                       Provider.of<SplashProvider>(
                                //                           context,
                                //                           listen: false)
                                //                           .currentTime;
                                //                   DateTime _start = DateFormat(
                                //                       'hh:mm:ss')
                                //                       .parse(product
                                //                       .availableTimeStarts);
                                //                   DateTime _end = DateFormat(
                                //                       'hh:mm:ss')
                                //                       .parse(product
                                //                       .availableTimeEnds);
                                //                   DateTime _startTime =
                                //                   DateTime(
                                //                       _currentTime.year,
                                //                       _currentTime.month,
                                //                       _currentTime.day,
                                //                       _start.hour,
                                //                       _start.minute,
                                //                       _start.second);
                                //                   DateTime _endTime = DateTime(
                                //                       _currentTime.year,
                                //                       _currentTime.month,
                                //                       _currentTime.day,
                                //                       _end.hour,
                                //                       _end.minute,
                                //                       _end.second);
                                //                   if (_endTime
                                //                       .isBefore(_startTime)) {
                                //                     _endTime = _endTime
                                //                         .add(Duration(days: 1));
                                //                   }
                                //                   bool _isAvailable =
                                //                       _currentTime.isAfter(
                                //                           _startTime) &&
                                //                           _currentTime.isBefore(
                                //                               _endTime);
                                //
                                //
                                //                   CartModel _cartModel = CartModel(
                                //                       price,
                                //                       0.0,
                                //                       priceWithDiscount,
                                //                       [_variation],
                                //                       (price -
                                //                           PriceConverter
                                //                               .convertWithDiscount(
                                //                               context,
                                //                               price,
                                //                               product
                                //                                   .discount,
                                //                               product
                                //                                   .discountType)),
                                //                       1,
                                //                       price -
                                //                           PriceConverter
                                //                               .convertWithDiscount(
                                //                               context,
                                //                               price,
                                //                               product.tax,
                                //                               product
                                //                                   .taxType),
                                //                       _addOnIdList,
                                //                       product,
                                //                       false,false);
                                //
                                //                   _cartProvider.addToCart(
                                //                       _cartModel, _cartIndex);
                                //
                                //               }else{
                                //                 appToast(text: 'You need to login first');
                                //               }
                                //             }
                                //
                                //           },
                                //           child: Row(
                                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //             children: [
                                //               Row(
                                //                 children: [
                                //                   InkWell(
                                //                     onTap: (){
                                //                       // productProvider.checkedItems.add(productProvider
                                //                       //     .recommendedBeveragesList[index].id);
                                //                       // setState(() {
                                //                       //
                                //                       // });
                                //
                                //                     },
                                //                     child: Container(
                                //                       decoration: BoxDecoration(
                                //
                                //                           color: productProvider.checkedItems.contains(productProvider
                                //                               .recommendedBeveragesList[index].id)? Theme.of(context).primaryColor: Colors.transparent,
                                //                           borderRadius: BorderRadius.circular(5),
                                //                           border: Border.all(
                                //                             color:productProvider.checkedItems.contains(productProvider
                                //                                 .recommendedBeveragesList[index].id)? Theme.of(context).primaryColor: Colors.black,
                                //
                                //                           )
                                //                       ),
                                //                       child: Icon(Icons.done,color: Colors.white,size: 15,),
                                //                     ),
                                //                   ),
                                //                   SizedBox(width: 10,),
                                //                   Text(productProvider.recommendedBeveragesList[index].name,
                                //                       style: rubikRegular.copyWith(
                                //                           fontSize: Dimensions.FONT_SIZE_LARGE)),
                                //                 ],
                                //               ),
                                //
                                //               Text(
                                //                   '${PriceConverter.convertPrice(context, productProvider.recommendedBeveragesList[index].price)}',
                                //                   style: rubikRegular.copyWith(
                                //                       fontSize: Dimensions
                                //                           .FONT_SIZE_LARGE)),
                                //             ],
                                //           ),
                                //         ),
                                //       );
                                //
                                //
                                //     },
                                //     separatorBuilder: (context, ind) {
                                //       return Divider();
                                //     },
                                //   ),
                                // )

                                /// Addons view
                                //
                                // _addonsView(context, productProvider),

                                Row(children: [
                                  Text(
                                      '${getTranslated('total_amount', context)}:',
                                      style: rubikMedium.copyWith(
                                          fontSize:
                                              Dimensions.FONT_SIZE_LARGE)),
                                  SizedBox(
                                      width:
                                          Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  Text(
                                      PriceConverter.convertPrice(
                                          context, priceWithAddons),
                                      style: rubikBold.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.FONT_SIZE_LARGE,
                                      )),
                                ]),
                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                                //Add to cart Button
                                // if (ResponsiveHelper.isDesktop(context))
                                //   _cartButton(
                                //       _isAvailable, context, _cartModel),
                              ]),
                        ),
                      ),
                    ),
                    // if (ResponsiveHelper.isDesktop(context))
                      _cartButton(_isAvailable, context, _cartModel),
                  ],
                );
              },
            ),
          ),
          ResponsiveHelper.isMobile(context)
              ? SizedBox()
              : Positioned(
                  right: 10,
                  top: 5,
                  child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close)),
                ),
        ],
      );
    });
  }

  Widget _addonsView(BuildContext context, ProductProvider productProvider) {
    return widget.product.addOns.length > 0
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getTranslated('addons', context),
                style:
                    rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
                childAspectRatio: (1 / 1.1),
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.product.addOns.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (!productProvider.addOnActiveList[index]) {
                      productProvider.addAddOn(true, index);
                    } else if (productProvider.addOnQtyList[index] == 1) {
                      productProvider.addAddOn(false, index);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        bottom:
                            productProvider.addOnActiveList[index] ? 2 : 20),
                    decoration: BoxDecoration(
                      color: productProvider.addOnActiveList[index]
                          ? Theme.of(context).primaryColor
                          : ColorResources.BACKGROUND_COLOR,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: productProvider.addOnActiveList[index]
                          ? [
                              BoxShadow(
                                color: Colors.grey[
                                    Provider.of<ThemeProvider>(context)
                                            .darkTheme
                                        ? 900
                                        : 300],
                                blurRadius: Provider.of<ThemeProvider>(context)
                                        .darkTheme
                                    ? 2
                                    : 5,
                                spreadRadius:
                                    Provider.of<ThemeProvider>(context)
                                            .darkTheme
                                        ? 0
                                        : 1,
                              )
                            ]
                          : null,
                    ),
                    child: Column(children: [
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text(widget.product.addOns[index].name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: rubikMedium.copyWith(
                                  color: productProvider.addOnActiveList[index]
                                      ? ColorResources.COLOR_WHITE
                                      : ColorResources.COLOR_BLACK,
                                  fontSize: Dimensions.FONT_SIZE_SMALL,
                                )),
                            SizedBox(height: 5),
                            Text(
                              PriceConverter.convertPrice(
                                  context, widget.product.addOns[index].price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: rubikRegular.copyWith(
                                  color: productProvider.addOnActiveList[index]
                                      ? ColorResources.COLOR_WHITE
                                      : ColorResources.COLOR_BLACK,
                                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL),
                            ),
                          ])),
                      productProvider.addOnActiveList[index]
                          ? Container(
                              height: 25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).cardColor),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (productProvider
                                                  .addOnQtyList[index] >
                                              1) {
                                            productProvider.setAddOnQuantity(
                                                false, index);
                                          } else {
                                            productProvider.addAddOn(
                                                false, index);
                                          }
                                        },
                                        child: Center(
                                            child:
                                                Icon(Icons.remove, size: 15)),
                                      ),
                                    ),
                                    Text(
                                        productProvider.addOnQtyList[index]
                                            .toString(),
                                        style: rubikMedium.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_SMALL)),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => productProvider
                                            .setAddOnQuantity(true, index),
                                        child: Center(
                                            child: Icon(Icons.add, size: 15)),
                                      ),
                                    ),
                                  ]),
                            )
                          : SizedBox(),
                    ]),
                  ),
                );
              },
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          ])
        : SizedBox();
  }

  Widget _quantityView(
    BuildContext context,
    CartModel _cartModel,
  ) {
    return Row(children: [
      Text(getTranslated('quantity', context),
          style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      Expanded(child: SizedBox()),
      _quantityButton(context, _cartModel),
    ]);
  }

  Widget _variationView(ProductProvider productProvider, String variationType) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.product.choiceOptions.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.product.choiceOptions[index].title,
              style:
                  rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 10,
              childAspectRatio: (1 / 0.25),
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.product.choiceOptions[index].options.length,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () {
                  productProvider.setCartVariationIndex(
                    index,
                    i,
                    widget.product,
                    variationType,
                    context,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  decoration: BoxDecoration(
                    color: productProvider.variationIndex[index] != i
                        ? ColorResources.BACKGROUND_COLOR
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.product.choiceOptions[index].options[i].trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: rubikRegular.copyWith(
                      color: productProvider.variationIndex[index] != i
                          ? ColorResources.COLOR_BLACK
                          : ColorResources.COLOR_WHITE,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(
              height: index != widget.product.choiceOptions.length - 1
                  ? Dimensions.PADDING_SIZE_LARGE
                  : 0),
        ]);
      },
    );
  }

  Widget _description(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getTranslated('description', context),
          style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      Align(
        alignment: Alignment.topLeft,
        child: ReadMoreText(
          widget.product.description ?? '',
          trimLines: 2,
          trimCollapsedText: getTranslated('show_more', context),
          trimExpandedText: getTranslated('show_less', context),
          moreStyle: robotoRegular.copyWith(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
          ),
          lessStyle: robotoRegular.copyWith(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
          ),
        ),
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
    ]);
  }

  Widget _cartButton(
      bool _isAvailable, BuildContext context, CartModel _cartModel) {
    return Column(children: [
      _isAvailable
          ? SizedBox()
          : Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(children: [
                Text(getTranslated('not_available_now', context),
                    style: rubikMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                    )),
                Text(
                  '${getTranslated('available_will_be', context)} ${DateConverter.convertTimeToTime(widget.product.availableTimeStarts, context)} '
                  '- ${DateConverter.convertTimeToTime(widget.product.availableTimeEnds, context)}',
                  style: rubikRegular,
                ),
              ]),
            ),
      CustomButton(
          btnTxt: getTranslated(
            _cartIndex != -1 ? 'update_in_cart' : 'add_to_cart',
            context,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          onTap: () {
            if (Provider.of<AuthProvider>(context, listen: false)
                .isLoggedIn()) {
              if (widget.fromPoints) {
                debugPrint('=from1');

                Provider.of<ProductProvider>(context, listen: false)
                    .updateLoyaltyPoints(_cartModel.points, context);
                setState(() {});
              }
              Navigator.pop(context);
              Provider.of<CartProvider>(context, listen: false)
                  .addToCart(_cartModel, _cartIndex);
            } else {
              Navigator.pushNamed(context, Routes.getLoginRoute());

              // showCustomSnackBar(
              //     getTranslated('now_you_are_in_guest_mode', context), context);
              // debugPrint('need to login first');
            }
          }),
    ]);
  }

  Widget _productView(
    BuildContext context,
    double _startingPrice,
    double _endingPrice,
    double price,
    double priceWithDiscount,
    CartModel cartModel,
  ) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FadeInImage.assetNetwork(
              placeholder: Images.placeholder_rectangle,
              image:
                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${widget.product.image}',
              width: ResponsiveHelper.isMobile(context)
                  ? 100
                  : ResponsiveHelper.isTab(context)
                      ? 140
                      : ResponsiveHelper.isDesktop(context)
                          ? 140
                          : null,
              height: ResponsiveHelper.isMobile(context)
                  ? 100
                  : ResponsiveHelper.isTab(context)
                      ? 140
                      : ResponsiveHelper.isDesktop(context)
                          ? 140
                          : null,
              fit: BoxFit.cover,
              imageErrorBuilder: (c, o, s) => Image.asset(
                Images.placeholder_rectangle,
                width: ResponsiveHelper.isMobile(context)
                    ? 100
                    : ResponsiveHelper.isTab(context)
                        ? 140
                        : ResponsiveHelper.isDesktop(context)
                            ? 140
                            : null,
                height: ResponsiveHelper.isMobile(context)
                    ? 100
                    : ResponsiveHelper.isTab(context)
                        ? 140
                        : ResponsiveHelper.isDesktop(context)
                            ? 140
                            : null,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE),
                    ),
                  ),
                  if (!ResponsiveHelper.isMobile(context))
                    WishButton(product: widget.product),
                ],
              ),
              // SizedBox(height: 10),
              // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     RatingBar(rating: widget.product.rating.length > 0 ? double.parse(widget.product.rating[0].average) : 0.0, size: 15),
              //     widget.product.productType != null ? VegTagView(product: widget.product) : SizedBox(),
              //   ],
              // ),
              SizedBox(height: 10),

              // Row( mainAxisSize: MainAxisSize.min, children: [
              //   Expanded(
              //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,  children: [
              //       Text(
              //         widget.product.description,
              //         maxLines: 2,
              //         overflow: TextOverflow.ellipsis,
              //         style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,fontWeight: FontWeight.w400),
              //       ),
              //
              //
              //
              //
              //     ]),
              //   ),
              //
              // ]),
              //
              // SizedBox(height: 10),

              Row(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          child: Text(
                            '${PriceConverter.convertPrice(context, _startingPrice, discount: widget.product.discount, discountType: widget.product.discountType)}'
                            '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(
                                context,
                                _endingPrice,
                                discount: widget.product.discount,
                                discountType: widget.product.discountType,
                              )}' : ''}',
                            style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              overflow: TextOverflow.ellipsis,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        price > priceWithDiscount
                            ? FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    '${PriceConverter.convertPrice(context, _startingPrice)}'
                                    '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice)}' : ''}',
                                    style: rubikMedium.copyWith(
                                        color: ColorResources.COLOR_GREY,
                                        decoration: TextDecoration.lineThrough,
                                        overflow: TextOverflow.ellipsis),
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ]),
                ),
                if (ResponsiveHelper.isMobile(context))
                  WishButton(product: widget.product),
              ]),
              if (!ResponsiveHelper.isMobile(context))
                _quantityView(context, cartModel)
            ]),
          ),
        ]);
  }

  Widget _quantityButton(BuildContext context, CartModel _cartModel) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(5)),
      child: Row(children: [
        InkWell(
          onTap: () => productProvider.quantity > 1
              ? productProvider.setQuantity(false)
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL,
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Icon(Icons.remove, size: 20),
          ),
        ),
        Text(productProvider.quantity.toString(),
            style: rubikMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE)),
        InkWell(
          onTap: () => productProvider.setQuantity(true),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL,
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Icon(Icons.add, size: 20),
          ),
        ),
      ]),
    );
  }
}

class VegTagView extends StatelessWidget {
  final Product product;

  const VegTagView({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              blurRadius: 5,
              color: Theme.of(context).backgroundColor.withOpacity(0.05))
        ],
      ),
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
              child: Image.asset(
                Images.getImageUrl(
                  '${product.productType}',
                ),
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
            Text(
              getTranslated('${product.productType}', context),
              style:
                  robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          ],
        ),
      ),
    );
  }
}


