class ApiStringsAF {
  static const baseUrl = "https://af-securities.com:9090/";
  static const getMobileToken = "api/Token/GetMobileToken";
  static const appKey = "1YE/48WCxBZN2VUPjSf8pgh7-IsXQva7YMDs1-pPTm0=";
  static const getAccountList = "api/Client/GetAccountList";
  static const getClientPortfolio = "api/Client/GetClientPortfolio";
  static const getClientPurchasePower = "api/Client/GetClientPurchasePower";
  static const getClientCashPosition = "api/Client/GetClientCashPosition";
  static const marginCalculator = "api/Client/MarginCalculator";
  static const getClientStatementPDF = "api/Client/getClientStatementPDF";
  static const getMyPortfolioMarketWatch = "api/Client/GetMyPortfolioMarketWatch";
  static const getMyPortfolioSymbols = "api/Client/GetMyPortfolioSymbols";
  static const getClientProfile = "api/Client/GetClientProfile";
  static const getClientInformation = "api/Client/GetClientInformation";
  static const getCustodianList = "api/Client/GetCustodianList";
  static const getClientCustodianList = "api/Client/GetClientCustodianList";
  static const saveClientActivityLog = "api/Client/SaveClientActivityLog";
  static const postMarketWatchByID = "api/Client/PostMarketWatchByID";
  static const getMarketWatchList = "api/Client/GetMarketWatchList";
  static const removeMarketWatchByID = "api/Client/RemoveMarketWatchByID";
  static const getClientMarketWatch = "api/Client/GetClientMarketWatch";
  static const getClientMarketWatchSymbols = "api/Client/GetClientMarketWatchSymbols";
  static const postClientMarketWatch = "api/Client/PostClientMarketWatch";
  static const getClientPortfolioPDF = "api/Client/getClientPortfolioPDF";

  // Orders API s
  static const String postOrder = 'api/Orders/PostOrder';
  static const String updateOrder = 'api/Orders/UpdateOrder';
  static const String getOrder = 'api/Orders/GetOrder';
  static const String cancelOrder = 'api/Orders/CancelOrder';
  static const String getMyOrders = 'api/Orders/GetMyOrders';
  static const String getMyOrdersByRange = 'api/Orders/GetMyOrdersByRange';
  static const String getRequiredInvestmentAmount = 'api/Orders/getRequiredInvestmentAmount';
  static const String getEGXMarketStatus = 'api/Orders/GetEGXMarketStatus';
  static const String getOrderTransactions = 'api/Orders/getOrderTransactions';
  static const String getOrderTransactionsWidget = 'api/Orders/getOrderTransactionsWidget';
  static const String notifyProrataOrder = 'api/Orders/NotifyProrataOrder';
  static const String toggleSuspendedOrder = 'api/Orders/ToggleSuspendedOrder';
  static const String suspendOrder = 'api/Orders/SuspendOrder';
  static const String unSuspendOrder = 'api/Orders/UnSuspendOrder';

  // Invoice API endpoints
  static const String getClientInvoice = "api/Invoice/getClientInvoice";
  static const String getInvoicePDF = "api/Invoice/getInvoicePDF";

  static const String feedBaseUrl = "http://164.160.104.175:6020/";
  // stocks
  static const String getAllStocks = "api/DelayedFeed/GetAllMarketWatch";

  // journal
  static const String getClientAccountsPortfolioDetails = "api/Journal/getClientAccountsPortfolioDetails";
  static const String createJournal = "api/Journal/CreateJournal";
  static const String transferClientJournal = "api/Journal/TransferClientJournal";
  static const String getBankAccounts = "api/Journal/getBankAccounts";
  static const String transferClientStocks = "api/Journal/TransferClientStocks";

  static const String postPayableRequest = "api/OnlineTrading/PostPayableRequest";
  static const String postReceivableRequest = "api/OnlineTrading/PostReceivableRequest";
  static const String postCallBackRequest = "api/OnlineTrading/PostCallBackRequest";
  static const String postRequestStockBook = "api/OnlineTrading/PostRequestStockBook";
  static const String postActionRequest = "api/OnlineTrading/PostActionRequest";
  static const String tPlusZeroRequest = "api/OnlineTrading/TPlusZeroRequest";

  // settings
  static const String getBOSymbol = "api/Settings/GetBOSymbol";
  static const String getActiveBanksInsights = "api/Settings/GetActiveBanksInsights";

  static const String addDemoClient = 'api/DemoClient/AddDemoClient';
  static const String isValidDemoClient = 'api/DemoClient/IsValidDemoClient';
  static const String addDemoClientQuestionnaire = 'api/DemoClient/AddDemoClientQuestionnaire';
  static const String changeStatus = 'api/DemoClient/ChangeStatus';
  static const String updateDigifiedResponse = 'api/DemoClient/UpdateDigifiedResponse';
  static const String verifyMobile = 'api/DemoClient/VerifyMobile';
  static const String verifyMobileOTP = 'api/DemoClient/VerifyMobileOTP';
  static const String isActiveDemoClient = 'api/DemoClient/ISActiveDemoClient';
  static const String getDemoClientInfo = 'api/DemoClient/GetDemoClientInfo';
  static const String getDemoClientQuestionnaire = 'api/DemoClient/GetDemoClientQuestionnaire';
  static const String getQuestionQuestionnaire = 'api/DemoClient/GetQuestionQuestionnaire';
  static const String postDemoClientVlenseRequest = 'api/DemoClient/PostDemoClientVlenseRequest';

  // Offline Orders
  static const String postOfflineOrder = 'api/OfflineOrders/PostOfflineOrder';
  static const String approveOfflineOrder = 'api/OfflineOrders/ApproveOfflineOrder';
  static const String cancelOfflineOrder = 'api/OfflineOrders/CancelOfflineOrder';
  static const String createTransaction = 'api/OfflineOrders/CreateTransaction';
  static const String displayAvailableFunds = 'api/OfflineOrders/DisplayAvailableFunds';
  static const String displayFundDetails = 'api/OfflineOrders/DisplayFundDetails';
  static const String displayFundPriceHistory = 'api/OfflineOrders/DisplayFundPriceHistory';

  //online orders
  static const String newFundAccountRequest = 'api/OnlineTrading/NewFundAccountRequest';
}
