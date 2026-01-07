import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();
  static final String appName = 'GuROW';
  static final String splashIcon = 'assets/images/splash.svg';
  static final String afLogo = 'assets/images/gurow-logo.png';
  static final String commodity = "https://idscapp.gov.eg";
  static const String feedUrl = "http://164.160.104.175:6020/";
  static final String afUrl = "http://arabfinance.com:6060";
  static final String signalUrl = "http://164.160.104.175:7070";
  static final String supportEmail = 'connect@gurow.io';
  static final String instagramSocial = "https://www.instagram.com/gurow_app";
  static final String twitterSocial = "https://twitter.com/GuROW_app";
  static final String facebookSocial =
      "https://www.facebook.com/Gurow-109214402187687";
  static final Color appColor = Color.fromRGBO(110, 40, 102, 1);
  static final Color appColorDarkMode = Color.fromRGBO(204, 73, 189, 1);
  static final String introImage1 = 'assets/images/intro/intro1.png';
  static final String introImage2 = 'assets/images/intro/intro2.png';
  static final String introImage3 = 'assets/images/intro/intro3.png';
  static final String langIcon = 'assets/icons/language.png';
  static final String doneAsset = 'assets/animation_files/done.json';
  static final List<String> languages = ['English', 'Arabic'];

  static final adsHtmlIos = """
    <div class="mx-auto d-none d-sm-block d-md-none  d-sm-none d-lg-block text-center my-4">
        <script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
        <script>
            window.googletag = window.googletag || { cmd: [] };
            googletag.cmd.push(function () {
                googletag.defineSlot('/21717998887/Mobile-app-970x250', [970, 250], 'div-gpt-ad-1699215607710-0').addService(googletag.pubads());
                googletag.pubads().enableSingleRequest();
                googletag.enableServices();
            });
        </script>
        <!-- /21717998887/Mobile-app-970x250 -->
        <div id='div-gpt-ad-1699215607710-0' style='min-width: 970px; min-height: 250px;'>
            <script>
                googletag.cmd.push(function () { googletag.display('div-gpt-ad-1699215607710-0'); });
            </script>
        </div>
    </div>
    """;
  // final List<MySector> sectors = <MySector>[
  //   MySector('assets/icons/sectors/bank.svg', 'assets/icons/sectors/bank-dark.svg', 'sector:bank'),
  //   MySector('assets/icons/sectors/resources.svg', 'assets/icons/sectors/resources-dark.svg', 'sector:resources'),
  //   MySector('assets/icons/sectors/building.svg', 'assets/icons/sectors/building-dark.svg', 'sector:building'),
  //   MySector('assets/icons/sectors/construction.svg', 'assets/icons/sectors/construction-dark.svg', 'sector:construction'),
  //   MySector('assets/icons/sectors/education.svg', 'assets/icons/sectors/education-dark.svg', 'sector:education'),
  //   MySector('assets/icons/sectors/food.svg', 'assets/icons/sectors/food-dark.svg', 'sector:food'),
  //   MySector('assets/icons/sectors/health.svg', 'assets/icons/sectors/health-dark.svg', 'sector:health'),
  //   MySector('assets/icons/sectors/industrial.svg', 'assets/icons/sectors/industrial-dark.svg', 'sector:industrial'),
  //   MySector('assets/icons/sectors/communication.svg', 'assets/icons/sectors/communication-dark.svg', 'sector:communication'),
  //   MySector('assets/icons/sectors/financial.svg', 'assets/icons/sectors/financial-dark.svg', 'sector:financial'),
  //   MySector('assets/icons/sectors/paper.svg', 'assets/icons/sectors/paper-dark.svg', 'sector:paper'),
  //   MySector('assets/icons/sectors/realestate.svg', 'assets/icons/sectors/realestate-dark.svg', 'sector:realestate'),
  //   MySector('assets/icons/sectors/shipping.svg', 'assets/icons/sectors/shipping-dark.svg', 'sector:shipping'),
  //   MySector('assets/icons/sectors/textile.svg', 'assets/icons/sectors/textile-dark.svg', 'sector:textile'),
  //   MySector('assets/icons/sectors/trade.svg', 'assets/icons/sectors/trade-dark.svg', 'sector:trade'),
  //   MySector('assets/icons/sectors/travel.svg', 'assets/icons/sectors/travel-dark.svg', 'sector:travel'),
  // ];
  static final List<String> countryCodes = [
    '+20', // Egypt
    '+966', // Saudi Arabia
    '+965', // Kuwait
    '+974', // Qatar
    '+973', // Bahrain
    '+971', // United Arab Emirates
    '+962', // Jordan
    '+968', // Oman
    '+213', // Algeria
    '+212', // Morocco
    '+216', // Tunisia
    '+964', // Iraq
    '+249', // Sudan
    '+218', // Libya
    '+222', // Mauritania
    '+1', // United States
    '+49', // Germany
    '+34', // Spain
    '+33', // France
    '+39', // Italy
    '+86', // China
    '+81', // Japan
    '+44', // United Kingdom
    '+7', // Russia
    '+91', // India
    '+61', // Australia
    '+41', // Switzerland
    '+43', // Austria
    '+31', // Netherlands
    '+90', // Turkey
    '+27', // South Africa
    '+234', // Nigeria
    '+32', // Belgium
  ];

  static final Map<String, String> countryCodeNames = {
    '+20': 'eg', // Egypt
    '+966': 'sa', // Saudi Arabia
    '+965': 'kw', // Kuwait
    '+974': 'qa', // Qatar
    '+973': 'bh', // Bahrain
    '+971': 'ae', // United Arab Emirates
    '+962': 'jo', // Jordan
    '+961': 'lb', // Lebanon
    '+968': 'om', // Oman
    '+213': 'dz', // Algeria
    '+212': 'ma', // Morocco
    '+216': 'tn', // Tunisia
    '+964': 'iq', // Iraq
    '+963': 'sy', // Syria
    '+967': 'ye', // Yemen
    '+249': 'sd', // Sudan
    '+218': 'ly', // Libya
    '+222': 'mr', // Mauritania
    '+1': 'us', // United States
    '+49': 'de', // Germany
    '+34': 'es', // Spain
    '+33': 'fr', // France
    '+39': 'it', // Italy
    '+86': 'cn', // China
    '+81': 'jp', // Japan
    '+44': 'gb', // United Kingdom
    '+7': 'ru', // Russia
    '+91': 'in', // India
    '+61': 'au', // Australia
    '+41': 'ch', // Switzerland
    '+43': 'at', // Austria
    '+31': 'nl', // Netherlands
    '+90': 'tr', // Turkey
    '+27': 'za', // South Africa
    '+234': 'ng', // Nigeria
    '+32': 'be', // Belgium
  };
  static final Map<String, int> countryNumberLengths = {
    '+20': 10, // Egypt
    '+966': 9, // Saudi Arabia
    '+965': 8, // Kuwait
    '+974': 8, // Qatar
    '+973': 8, // Bahrain
    '+971': 9, // United Arab Emirates
    '+962': 9, // Jordan
    '+968': 8, // Oman
    '+213': 9, // Algeria
    '+212': 9, // Morocco
    '+216': 8, // Tunisia
    '+964': 10, // Iraq
    '+249': 9, // Sudan
    '+218': 10, // Libya
    '+222': 8, // Mauritania
    '+1': 10, // United States
    '+49': 10, // Germany
    '+34': 9, // Spain
    '+33': 9, // France
    '+39': 10, // Italy
    '+86': 10, // China
    '+81': 10, // Japan
    '+44': 10, // United Kingdom
    '+7': 10, // Russia
    '+91': 10, // India
    '+61': 9, // Australia
    '+41': 10, // Switzerland
    '+43': 10, // Austria
    '+31': 10, // Netherlands
    '+90': 10, // Turkey
    '+27': 10, // South Africa
    '+234': 10, // Nigeria
    '+32': 10, // Belgium
  };

  final watchlistColumns = [
    "name",
    "price",
    "change%",
    "vol",
    "trades",
    "turnover",
    "qty",
    "open",
    "close",
    "high",
    "low",
    "bQty",
    "bPrice",
    "aQty",
    "aPrice",
  ];

  static final aboutEn =
      """<p style='margin:0in;text-align:center;'><strong><span>Arab Finance for Information Technology prides itself on its long journey in the</span></strong></p>
<p style='margin:0in;text-align:center;'><strong><span>&nbsp;financial sector!</span></strong></p>
<p style='margin:0in;text-align:center;'><strong><span >After years of listening to the pains, needs and ambitions of its users, Arab Finance presents to the investment community in Egypt GuROW</span></strong></p>
<p style='margin:0in;text-align:center;'><strong><span>&nbsp;</span></strong></p>
<p style='margin:0in;'><span>GuROW is a full scalable financial, economic and investment app that enriches users with comprehensive knowledge, investment advice and effortless trading in multi asset-classes.</span></p>
<p style='margin:0in;'><span>Through our technology and a variety of market intelligent tools, our vision is to create the first full integrated investment community in Egypt through a multi-asset platform that acts as a hub by availing investment in multiple asset classes through third party collaboration and seamless integration with other fintech service providers offering the mass public, decision-makers, experienced investors, and novice investors informed investment guidance as well as smooth access to various financial services and products at the tips of their fingers.&nbsp;</span></p>
<p style='margin:0in;'><span>&nbsp;</span></p>
<p style='margin:0in;text-align:center;'><strong><span>We aim to unleash the power of technology and information to bring clarity to a complex market.</span></strong></p>""";

  static final aboutAr =
      """<p dir="RTL" style='margin:0in;font-size:15px;text-align:center;line-height:150%;'><strong><span style='font-size:16px;line-height:150%;'>تفخر شركة آراب فاينانس لتكنولوجيا المعلومات بخبرتها الواسعة في المجال المالي</span></strong></p>
<p dir="RTL" style='margin:0in;font-size:15px;text-align:center;line-height:150%;'><strong><span style='font-size:16px;line-height:150%;'>وبعد الأخذ بعين الاعتبار سنوات من ردود أفعال مُستخدمينا ، تُقدم آراب فاينانس&nbsp;</span></strong><strong><span style='font-size:16px;line-height:150%;'>جرو&nbsp;</span></strong><strong><span style='font-size:16px;line-height:150%;'>لمجتمع الاستثمار في مصر</span></strong><strong><span dir="LTR" style='font-size:16px;line-height:150%;'>.</span></strong></p>
<p dir="RTL" style='margin:0in;font-size:15px;text-align:justify;line-height:150%;'><span style='font-size:16px;line-height:150%;'>&nbsp;</span></p>
<p dir="RTL" style='margin:0in;font-size:15px;text-align:justify;line-height:150%;'><span style='font-size:16px;line-height:150%;'>جرو هو تطبيق مالي واقتصادي واستثماري متكامل قابل للتطوير، وصُمم خصيصًا لتلبية احتياجات مُستخدميه وتزويدهم بفهم شامل للمجال بطريقة فعالة ، باستخدام التكنولوجيا الحديثة و مجموعة متنوعة من أدوات السوق الذكية .</span></p>
<p dir="RTL" style='margin:0in;font-size:15px;text-align:justify;line-height:150%;'><span style='font-size:16px;line-height:150%;'>نسعي لأنشاء اول مجتمع استثماري شامل و متكامل في مصر من خلال منصة متعددة الأصول تعمل كمحور يتيح الاستثمار في فئات الأصول المتعددة من خلال التعاون مع أطراف خارجية و شركات التكنولوجيا المالية الأخرى التي تقدم المشورة و التوجيه للجمهور العام و صانعي القرار و المستثمرين و المبتدئين أو ذوي الخبرة ، فضلا عن تمكينهم من الوصول للعديد من الخدمات و المنتجات المالية بلمسة زر .&nbsp;</span></p>
<p dir="RTL" style='margin:0in;font-size:15px;text-align:justify;line-height:150%;'><span dir="LTR" style='font-size:16px;line-height:150%;'>&nbsp;</span></p>
<p dir="RTL" style='margin:0in;font-size:15px;text-align:justify;line-height:150%;'><strong><span style='font-size:16px;line-height:150%;'>لذلك، نسعى جاهدين لتحقيق الاستفادة القصوى من التكنولوجيا والمعلومات؛ مما يُساعدك على فهم أكثر شمولاً للسوق و ما يتبعه من مستجدات .&nbsp;</span></strong></p>""";

  static final termsEn =
      """<p style='line-height:150%;'>These terms and conditions of use (the &ldquo;Terms&rdquo;) are applicable to the use of GuROW application (the &ldquo;App&rdquo;) and constitute a legally binding agreement. In these Terms, &ldquo;GuROW&rdquo; refers to Arab Finance Information Technology, its owners, affiliates, agents, employees, officers and representatives. &ldquo;You&rdquo; or &ldquo;Your&rdquo; refers to you, the user of the App. By accessing and using this App, You are agreeing to be legally bound by these Terms use and you warrant to Arab Finance Information Technology that You are of legal age and legally competent to agree to these Terms. BY USING THIS APP, YOU ARE WARRANTING TO ARAB FINANCE INFORMATION TECHNOLOGY THAT YOUR USE OF THE APP AND THE ACCESS TO THE INFORMATION CONTAINED IN THE APP DOES NOT VIOLATE ANY LAW OR REGULATION APPLICABLE TO YOU. Please read these Terms carefully. If You do not agree to these Terms, do not use the App. Your use of this App will be deemed to constitute Your acceptance of all of these Terms. You are encouraged to print or retain a copy reference. Arab Finance Information Technology may change any term in these Terms at any time at its discretion. The changes will appear in these Terms, and Your use of this App after any changes have been posted will constitute Your agreement to the modified Terms and acceptance of all changes; therefore, You should check the date stated at the end of these Terms each time you access this App, before you begin using this App. You understand and agree that Arab Finance Information Technology may discontinue or change part, or all, of this App at any time, without notice. You also understand and agree that Arab Finance Information Technology may, at its sole discretion, discontinue or restrict Your use of this App for any reason and without notice.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Copyrights and Limitations on use:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Arab Finance Information Technology either owns, or is licensed to display the content displayed on this App (the &ldquo;Content&rdquo;). All Content is the property of Arab Finance Information Technology or its licensors and is protected by copyright and other intellectual property laws. The Content includes, for example, but is not limited to, stories, new releases, tools, calculators, logos, trademarks, and other items displayed on the App. This App and its Content may only be used for Your personal and noncommercial use.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 
                 <p style='line-height:107%;'><strong>Disclaimer:</strong></p>
                 <p style='line-height:150%;'>&nbsp;</p>
                 <p style='line-height:150%;'>This App includes facts, views, opinions, and recommendations of individuals and organizations deemed of interest. ARAB FINANCE INFORMATION TECHNOLOGY AND ITS LICENSORS ARE NOT GIVING INVESTMENT, LEGAL, TAX OR ANY OTHER PROFESSIONAL ADVICE AND YOU SHOULD NOT CONSTRUE THE CONTENT AS ANY SUCH ADVICE OR RELY ON THE CONTENT IN MAKING YOUR INVESTMENT AND OTHER DECISIONS. Arab Finance Information Technology and its licensors do not guarantee or warrant the accuracy, completeness, or timeliness of, or otherwise endorse these views, opinions, and recommendations or advocate the purchase or sale of any security or investment. Arab Finance Information Technology and its licensors cannot and do not warrant the accuracy, completeness, timeliness, noninfringement, merchantability, or fitness for a particular purpose of the content available through these sources. Neither Arab Finance nor its licensors shall be liable to You or anyone else for any decision made or action taken by You in reliance on the Content displayed on this App. YOU AGREE TO IDEMNIFY AND HOLD HARMLESS ARAB FINANCE INFORMATION TECHNOLOGY AND ITS LICENSORS AGAINST AND FROM ANY LIABILITY THAT ARAB FINANCE INFORMATION TECHNOLOGY OR ITS LICENSORS MAY INCUR AS A RESULT OF YOUR USE OF THE APP, INCLUDING, BUT NOT LIMITED TO, YOUR VIOLATION OF ANY OF THESE TERMS OR OF ANY COPYRIGHT OR OTHER INTELLECTUAL PROPERTY RIGHTS.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Links to third party sites:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>This App contains news related to other sources operated by persons or entities other than Arab Finance Information Technology. Such news is provided for Your reference and convenience only. You agree not to hold Arab Finance Information Technology responsible for the content or operations of the operators. Each operator site will contain a description of that site&rsquo;s privacy policy regarding any personal information. You are encouraged to read such privacy policy carefully before deciding to submit any personal or sensitive information.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Subscriptions:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Arab Finance Information Technology charges subscription fees for access to certain sections of the App (the &ldquo;Subscription Sections&rdquo;). If You choose to subscribe to any such Subscription Sections, You agree to pay to Arab Finance Information Technology all subscription fees in respect of the same. You also agree to pay all taxes and other similar levies that may be imposed by the competent authority having jurisdiction over You. You warrant and represent that all information submitted by You in an application for the Subscription Sections will be accurate, complete, current, and not misleading. Arab Finance Information Technology reserves the right, at its sole discretion, to limit or prevent Your access to the App, including the Subscription Sections. In the event that Arab Finance Information Technology exercises such right, Arab Finance Information Technology will refund to You a pro-rated portion of the subscription fees paid by You, if any, for the unused portion of the then current subscription period.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Communications:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Arab Finance Information Technology may communicate with You through the use of email or phone. You agree and understand that Arab Finance Information Technology may keep records of Your incoming and outgoing emails with Arab Finance Information Technology. Arab Finance Information Technology will provide You with telephone numbers of Arab Finance Information Technology for Your convenience. You understand and agree that Arab Finance may monitor and record these telephone communications.a</p>
                        <p style='line-height:200%;text-align:start;'><strong><span style=''><br>&nbsp;</span></strong><strong><span dir="RTL" style="">GuRow Ai</span></strong></p>

                 <p style='line-height:107%;'>&nbsp;</p>
                 
                 <p style='line-height:107%;'><strong><em>DISCLAIMER:</em></strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Please read the following disclaimer carefully before using our GuROW AI services. By accessing or utilizing our services, you acknowledge and agree to the terms outlined herein.</p>
                 <p style='line-height:150%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>No Personalized Advice:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Our financial GuROW AI provides general financial information and investment recommendations based on algorithms and historical data. It does not take into account your specific financial situation, goals, risk tolerance, or investment objectives. The information provided should not be considered as personalized financial advice.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Risk Disclosure:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>All investments carry inherent risks, and the value of investments can fluctuate. Past performance is not indicative of future results. It is essential to understand the risks associated with any investment and consult with a qualified financial advisor before making any investment decisions.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Limited Liability:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>We are not responsible for any losses, damages, or adverse financial outcomes that may result from using our GuROW AI services. You are solely responsible for your investment decisions, and you should perform your due diligence and seek professional advice when necessary.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Data Accuracy:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>While we strive to provide accurate and up-to-date information, we do not guarantee the accuracy, completeness, or reliability of the data used in our algorithms. Users are encouraged to verify information independently.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>No Guarantees:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>We do not guarantee any specific investment returns, outcomes, or the achievement of financial goals. The financial markets are subject to various factors that can impact performance, and no assurance can be given regarding the success of any investment strategy.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>User Responsibility:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>You are responsible for maintaining the security of your account credentials and ensuring that unauthorized access does not occur. We will not be held liable for any losses resulting from unauthorized access to your account.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Legal Compliance:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Users are responsible for complying with all applicable laws and regulations related to investments and financial transactions in their jurisdiction. Our services may not be available in all locations.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Changes to Terms:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>We reserve the right to modify, suspend, or terminate our GuROW AI services and the terms of use at any time without prior notice. It is your responsibility to review these terms regularly for updates or changes.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>No Endorsement:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>Any third-party products, services, or websites mentioned or linked to in our GuROW AI are for informational purposes only. We do not endorse or recommend any specific products or services.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:107%;'><strong>Indemnification:</strong></p>
                 <p style='line-height:107%;'>&nbsp;</p>
                 <p style='line-height:150%;'>By using our services, you agree to indemnify and hold us harmless from any claims, losses, liabilities, and expenses, including legal fees, arising from your use of our GuROW AI services or your violation of these terms.</p>
                 <p style='line-height:107%;'>&nbsp;</p>
                <p style='line-height:107%;'><strong>Contact Us:</strong></p>
<p style='line-height:150%;'>&nbsp;</p>
<p style='line-height:150%;'>If you have any questions or concerns regarding our GuROW AI services or this disclaimer, please contact us at <a href='mailto:support@optofolio.com'>support@optofolio.com</a></p>

<p style='line-height:150%;'><strong>Stock Limitations:</strong> Our financial GuROW AI provides investment recommendations exclusively from the EGX100. The algorithm focuses on this specific set of stocks and does not consider securities beyond the EGX100 index. EGX100 constituents are rebalanced by the EGX twice a year. At the 1st of February and the 1st of August, comprehensive rebalances are undertaken to adjust constituents (added or deleted). Accordingly, GuROW AI adjusts stocks selection.</p>
<p style='line-height:150%;'>&nbsp;</p>
                 <p style='line-height:150%;'>By using our financial GuROW AI services, you acknowledge that you have read, understood, and agreed to the terms and conditions outlined in this disclaimer. If you do not agree with any part of this disclaimer, you should refrain from using our services. Financial decisions should always be made with careful consideration of your individual circumstances and in consultation with a qualified financial advisor when necessary</p>
                 
                 """;
  static final termsAr =
      """<p style='line-height:150%;'><span dir="RTL" style="font-size:11px;line-height:150%;">هذه الشروط و الأحكام للإستخدام (&quot;أحكام الإستخدام&quot;) خاصة بإستخدام تطبيق جرو (&quot;التطبيق&quot;) و تشكل موافقة غير مشروطة. تشمل &quot; جرو&quot; في أحكام الإستخدام أراب فاينانس لتكنولوجيا المعلومات، و مساهميها، و الأشخاص المرتبطة بها و وكلائها و الموظفين و العاملين بها كذلك ممثليها. إستخدام &quot;أنت&quot; أو &quot;أنتم&quot; للإشارة لمستخدم التطبيق. الدخول و إستخدام هذا التطبيق يعتبر موافقة بإتباعاكم و إلتزامكم بهذه بأحكام الإستخدام و تتعهدوا بأنكم بالسن القانوني و لديكم الأهلية للموافقة علي أحكام الإستخدام. بإستخدامكم هذا التطبيق يعد تعهد لأراب فاينانس لتكنولوجيا المعلومات بعدم الإخلال بالقانون أو اللوائح المطبقة عليكم. يرجي قراءة أحكام الإستخدام بدقة. في حالة عدم قبولكم لأحكام الإستخدام فلا تستخدم التطبيق. إستخدامك للتطبيق يعد موافقة لأحكام الإستخدام. يمكنك طباعة و الإحتفاظ بصورة من أحكام الإستخدام. يحق لأراب فاينانس لتكنولوجيا المعلومات تعديل أي بند بأحكام الإستخدام فى أى وقت. و يبدأ سريان هذه التعديلات عند نشرها على الموقع.إطلاعكم على الشروط و الأحكام فى كل مرة تستخدمون فيها الموقع هى مسئوليتكم و استمراركم فى إستخدام التطبيق يفرض قبولكم للإلتزام بالشروط و الأحكام الأخيرة. جميع البيانات يجوز لنا في أي وقت تعديل شروط وأحكام الموقع الالكتروني دون توجيه إخطار مسبق لك بذلك. يمكنكم الدخول على موقعنا الالكتروني في أي وقت والإطلاع على أحدث نسخة من أحكام الإستخدام. في حال ما كانت الشروط والأحكام المعدلة غير مرضية أو غير مقبولة لديك، يتعين عليكم عدم الاستمرار والتوقف عن استخدام خدمات الموقع الالكتروني. لكن في حال استمراركم لاستخدام خدماتنا المتاحة على الموقع الالكتروني فذلك يعتبر موافقة منكم على الالتزام بالشروط والأحكام المعدلة لهذا الموقع الالكتروني. لأراب فاينانس لتكنولجيا المعلومات الحق في إلغاء أو تعديل أو الحد من إستخدامك للتطبيق دون أسباب أو إخطار</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:107%;text-align:start;'><strong><span style=''><br>&nbsp;</span></strong><strong><span dir="RTL" style="">حقوق النشر و حدود إستخدامها</span></strong></p>
        <p style='line-height:150%;text-align:start;'><span style='font-size:11px;line-height:150%;'><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">تملك أراب فاينانس لتكنولوجيا المعلومات أو لديها ترخيص بعرض المحتوي علي هذا التطبيق (&quot;المحتوي&quot;). كامل المحتوي ملكية لأراب فاينانس لتكنولوجيا المعلومات أو لمرخصيها و تتمتع بحماية حق النشر و قوانين الملكية الفكرية. يشمل المحتوي علي سبيل المثال الحكايات و الإصدارات الجديدة و الوسائل و ألات حاسبة و شعارات و علامات تجارية تعرض بالتطبيق. هذا التطبيق و المحتوي الخاص به للإستخدام الشخصي و ليس التجاري</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:107%;text-align:start;'><strong><span style=''><br>&nbsp;</span></strong><strong><span dir="RTL" style="">إخلاء مسئولية</span></strong></p>
        <p style='line-height:150%;text-align:start;'><span style='font-size:11px;line-height:150%;'><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">يحتوي هذا التطبيق علي وقائع و أراء و مقترحات من أشخاص و مؤسسات ذو أهمية. أراب فاينانس لتكنولوجيا المعلومات و مرخصيها لا يؤدون إستشارات إستثمارية أو قانونية أو ضريبية أو أي نوع من الإستشارات و لا يجب أخذ المحتوي علي أنه إستشارة يعتد بها في إتخاذ قرارات إستثمارية خاصة بكم. أراب فاينانس لتكنولوجيا المعلومات و مرخصيها لا يضمنوا و لا يتعهدوا بدقة أو كمال أو توقيت تلك الأراء و المقترحات و لا يدعموا شراء أو بيع أي ورقة مالية أو إستثمار. أراب فاينانس لتكنولوجيا المعلومات و مرخصيها لا يضمنوا دقة أو كمال أو توقيت أو تجارية أو إمكانية إستخدام المصادر. أراب فاينانس لتكنولوجيا المعلومات و مرخصيها لا يتحملوا المسئولية تجاهكم أو أي شخص أخر بمناسبة إجراء أو عدم إجراء بناءا علي المحتوي الظاهر بالتطبيق. و توافقون علي تعويض و إخلاء مسئولية أراب فاينانس لتكنولوجيا المعلومات و مرخصيها من أي إلتزام علي أراب فاينانس لتكنولوجيا المعلومات و مرخصيها من جراء إستخدامكم للتطبيق بما في ذلك أي إخلا لأحكام الإستخدام أو حقوق النشر أو حقوق الملكية الفكرية</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:107%;text-align:start;'><strong><span style=''><br>&nbsp;</span></strong><strong><span dir="RTL" style="">روابط مع الغير</span></strong></p>
        <p style='line-height:150%;text-align:start;'><span style='font-size:11px;line-height:150%;'><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">يحتوي هذا التطبيق علي مصادر خاضعة لأشخاص أو كيانات أخري. يتم إتاحة هذه الأخبار لكم للعلم فقط. أراب فاينانس لتكنولوجيا المعلومات غير مسئولة عن محتوي و تشغيل الروابط الخارجية. يرجي مراجعة إشتراطات الخصوصية الخاصة بكل موقع قبل إعطاء معلومات خاصة أو حساسة</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:107%;text-align:start;'><strong><span style=''><br>&nbsp;</span></strong><strong><span dir="RTL" style="">إشتراكات</span></strong></p>
        <p style='line-height:150%;text-align:start;'><span style='font-size:11px;line-height:150%;'><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">يوجد بالتطبيق بعض الصفحات التي تقوم أراب فاينانس لتكنولوجيا المعلومات بتقديمها بمقابل &quot;صفحات الإشتراكات&quot;. في حالة إختياركم الإشتراك في تلك الصفحات عليكم الموافقة بسداد قيمة الإشتراك لأراب فاينانس لتكنولوجيا المعلومات كما عليكم سداد كافة الضرائب و الرسوم المطبقة عليكم من قبل الجهات المختصة. و تتعهدوا و تلتزموا بأن جميع المعلومات التي تقدموها بنموذج صفحات الإشتراك دقيقة و كاملة و سارية و ليست علي سبيل التضليل. و تحتفظ أراب فاينانس لتكنولوجيا المعلومات بحقها المطلق للحد أو منع دخولكم التطبيق بما في ذلك صفحات الإشتراكات. و في حالة منعكم ستقوم أراب فاينانس لتكنولوجيا المعلومات برد الجزء المتبقي من الإشتراك المدفوع عن فترة الإشتراك المتبقية</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:107%;text-align:start;'><span style=''><br>&nbsp;</span><strong><span dir="RTL" style="">الإتصال</span></strong></p>
        <p style='line-height:150%;text-align:start;'><span style='font-size:11px;line-height:150%;'><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">تستطيع أراب فاينانس لتكنولوجيا المعلومات التواصل معكم عبر الهاتف أو الإيميل. لذلك توافقون علي قيام أراب فاينانس لتكنولوجيا المعلومات بحفظ ملفات من الإيميل الصادر و الوارد معكم، كذلك ستقوم أراب فاينانس لتكنولوجيا المعلومات بتوفير رقم هاتفي للتواصل مع العلم أن المكالمات الهاتفية قد تكون مسجلة</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:107%;'>&nbsp;</p>
        <p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">عدم تقديم المشورة الشخصية</span></strong></p>
                <p style='line-height:150%;text-align:start;'><span style='font-size:11px;line-height:150%;'><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">تستطيع أراب فاينانس لتكنولوجيا المعلومات التواصل معكم عبر الهاتف أو الإيميل. لذلك توافقون علي قيام أراب فاينانس لتكنولوجيا المعلومات بحفظ ملفات من الإيميل الصادر و الوارد معكم، كذلك ستقوم أراب فاينانس لتكنولوجيا المعلومات بتوفير رقم هاتفي للتواصل مع العلم أن المكالمات الهاتفية قد تكون مسجلة</span><span style='font-size:11px;line-height:150%;'>.</span></p>
        <p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">عدم تقديم المشورة الشخصية</span></strong></p>
        <p style='line-height:150%;text-align:start;'><strong><span style=''><br>&nbsp;</span></strong><strong><span dir="RTL" style="">GuRow Ai</span></strong></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">كشف المخاطر</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">جميع الاستثمارات تحمل مخاطر مضمنة، وقيمة الاستثمارات قد تتقلب. الأداء السابق لا يشكل مؤشرًا على النتائج المستقبلية. من الضروري فهم المخاطر المرتبطة بأي استثمار والتشاور مع مستشار مالي مؤهل قبل اتخاذ أي قرار استثماري.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">المسؤولية المحدودة</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">نحن لا نتحمل مسؤولية أي خسائر أو أضرار أو نتائج مالية سلبية قد تنتج عن استخدام خدمات جرو. أنت وحدك مسؤول عن قرارات الاستثمار الخاصة بك، ويجب عليك أداء البحث الضروري والبحث عن المشورة المهنية عند الضرورة.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">دقة البيانات</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">بينما نسعى لتقديم معلومات دقيقة ومحدثة، إلا أننا لا نضمن دقة أو اكتمال أو موثوقية البيانات المستخدمة في الخوارزميات. يُشجع المستخدمون على التحقق من المعلومات بشكل مستقل.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">عدم وجود ضمانات</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">نحن لا نضمن أي عوائد استثمار محددة أو نتائج أو تحقيق أهداف مالية. الأسواق المالية تخضع لعوامل متنوعة يمكن أن تؤثر على الأداء، ولا يمكن إعطاء أي تأكيد بشأن نجاح أي استراتيجية استثمارية.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">مسؤولية المستخدم</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">أنت مسؤول عن الحفاظ على أمان بيانات الحساب الخاصة بك وضمان عدم حدوث وصول غير مصرح به. لن نتحمل مسؤولية أي خسائر ناتجة عن وصول غير مصرح به إلى حسابك.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">امتثال قانوني</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">يجب عليك الامتثال لجميع القوانين واللوائح المعمول بها في اختصاصك الجغرافي بما يتعلق بالاستثمار والمعاملات المالية.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">التغييرات في الشروط والأحكام</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;"><br>&nbsp;</span><span dir="RTL" style="font-size:11px;line-height:150%;">نحتفظ بالحق في تعديل أو إنهاء خدماتنا وأحكام الاستخدام دون إشعار مسبق. ستصبح هذه التعديلات سارية المفعول عند نشرها على الموقع. من واجبك أن تتحقق من الشروط والأحكام في كل مرة تستخدم فيها التطبيق، ومواصلة استخدامك للتطبيق تعتبر موافقتك على الالتزام بآخر الشروط والأحكام.</span><span dir="RTL" style="font-size:11px;line-height:150%;">.</span></p>

<p style='line-height:150%;text-align:start;'><strong><span dir="RTL" style="">حدود الأسهم:</span></strong></p>
<p style='line-height:150%;text-align:start;'><span dir="RTL" style="font-size:11px;line-height:150%;">يقدم GuROW AI توصيات استثمارية حصرية من EGX100. يركز الخوارزم على هذه المجموعة المحددة من الأسهم ولا يأخذ في اعتباره الأوراق المالية خارج مؤشر EGX100. تتم مراجعة المؤشر مرتين سنويًا، مراجعة شاملة في بداية شهر فبراير وأغسطس من كل عام، والتي تشمل إضافة واستبعاد الشركات للمؤشر. ووفقًا لذلك، يتم تحديث الأسهم تلقائيًا.</span></p>
 """;

  static final adsHtml = """
  <div class="mx-auto d-none d-sm-block d-md-none  d-sm-none d-lg-block text-center my-4">
    <meta name="viewport" content="width=device-width, initial-scale=0.4">
    <script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
    <script>
        window.googletag = window.googletag || { cmd: [] };
        googletag.cmd.push(function () {
            googletag.defineSlot('/21717998887/Mobile-app-970x250', [970, 250], 'div-gpt-ad-1699215607710-0').addService(googletag.pubads());
            googletag.pubads().enableSingleRequest();
            googletag.enableServices();
        });
    </script>
    <!-- /21717998887/Mobile-app-970x250 -->
    <div id='div-gpt-ad-1699215607710-0' style='width: 100%; height:100%;'>
        <script>
            googletag.cmd.push(function () { googletag.display('div-gpt-ad-1699215607710-0'); });
        </script>
    </div>
</div>

    """;

  static GlobalKey<NavigatorState> navigatorState = GlobalKey<NavigatorState>();
  static List<String> dahabMasrCities = [
    'Cairo',
    'Alexandria',
    'Aswan',
    'Asyut',
    'Beheira',
    'Beni Suef',
    'Dakahlia',
    'Damietta',
    'Faiyum',
    'Gharbia',
    'Giza',
    'Ismailia',
    'Kafr el-Sheikh',
    'Luxor',
    'Matrouh',
    'Minya',
    'Monufia',
    'Port Said',
    'Qalyubia',
    'Qena',
    'Red Sea',
    'Sharqia',
    'Sohag',
    'Suez',
  ];
}
