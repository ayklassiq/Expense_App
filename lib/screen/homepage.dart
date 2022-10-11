import'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/transaction.dart';
import '../widgets/chart.dart';
import '../widgets/new_transaction.dart';
import '../widgets/transaction_list.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [];
  bool _showChart = false;
  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
        title: txTitle,
        amount: txAmount,
        date: chosenDate,
        id: DateTime.now().toString());
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
              onTap: () {},
              child: NewTransaction(_addNewTransaction),
              behavior: HitTestBehavior.opaque);
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        mediaQuery.orientation == Orientation.landscape;
    final    appBar =
    // Platform.isIOS ? CupertinoNavigationBar(
    //   // middle: const Text('Personal Expenses'),
    //   // trailing: Row(
    //   //   mainAxisSize: MainAxisSize.min,
    //   //   children: [
    //   //
    //   //     GestureDetector(
    //   //       child: const Icon(CupertinoIcons.add),
    //   //       onTap:() => _startAddNewTransaction(context)
    //   //     )
    //   //   ],
    //   ),
    // ):
    AppBar(
      title: const Text('Personal Expense'),
      actions: [
        IconButton(
          onPressed: () {
            _startAddNewTransaction(context);
          },
          icon: const Icon(Icons.add),
        )
      ],
    );
    final txListWidget = Container(
        height:
            (mediaQuery.size.height - appBar.preferredSize.height) *
                0.6,
        child: TransactionList(_userTransactions, _deleteTransaction));
    final  pageBody =  SafeArea(child:SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLandscape)
            Row(
              children: [
                Text('Show Chart', style: Theme.of(context).textTheme.subtitle1),
                Switch.adaptive(
                    activeColor: Theme.of(context).accentColor,
                    value: (_showChart),
                    onChanged: (val) {
                      setState(() {
                        _showChart = val;
                      });
                    }),
              ],
            ),
          if (!isLandscape)
            Container(
                height: (mediaQuery.size.height -
                    appBar.preferredSize.height -
                    mediaQuery.padding.top) *
                    0.4,
                child: Chart(_recentTransactions)),
          if (!isLandscape) txListWidget,
          if (isLandscape)
            _showChart
                ? Container(
                height: (mediaQuery.size.height -
                    appBar.preferredSize.height -
                    mediaQuery.padding.top) *
                    0.4,
                child: Chart(_recentTransactions))
                : txListWidget,
          Container(
            height: (mediaQuery.size.height -
                appBar.preferredSize.height) *
                0.6,
            child: TransactionList(_userTransactions, _deleteTransaction),
          )
        ],
      ),
    ),);
    return Platform.isIOS ? CupertinoPageScaffold(child: pageBody,) : Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS ? Container(): FloatingActionButton(
          onPressed: () {
            _startAddNewTransaction(context);
          },
          child: Icon(Icons.add)),
    );
  }
}
