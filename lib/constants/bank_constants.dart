class BankInfo {
  final String id;
  final String displayName;
  final String androidPackage;
  final String iosUrlScheme;
  final String fallbackUrl;

  const BankInfo({
    required this.id,
    required this.displayName,
    required this.androidPackage,
    required this.iosUrlScheme,
    required this.fallbackUrl,
  });
}

class BankConstants {
  static const Map<String, BankInfo> supportedBanks = {
    'boursobank': BankInfo(
      id: 'boursobank',
      displayName: 'BoursoBank',
      androidPackage: 'com.boursorama.android.clients',
      iosUrlScheme: 'boursorama://',
      fallbackUrl: 'https://clients.boursorama.com/',
    ),
    'revolut': BankInfo(
      id: 'revolut',
      displayName: 'Revolut',
      androidPackage: 'com.revolut.revolut',
      iosUrlScheme: 'revolut://',
      fallbackUrl: 'https://www.revolut.com/',
    ),
    'lydia': BankInfo(
      id: 'lydia',
      displayName: 'Lydia / Sumeria',
      androidPackage: 'com.lydia',
      iosUrlScheme: 'lydia://',
      fallbackUrl: 'https://lydia-app.com/',
    ),
    'societe_generale': BankInfo(
      id: 'societe_generale',
      displayName: 'Société Générale',
      androidPackage: 'mobi.societegenerale.mobile.lappli',
      iosUrlScheme: 'societegenerale://',
      fallbackUrl: 'https://particuliers.societegenerale.fr/',
    ),
    'credit_agricole': BankInfo(
      id: 'credit_agricole',
      displayName: 'Crédit Agricole',
      androidPackage: 'fr.creditagricole.androidapp',
      iosUrlScheme: 'ca-mobile://',
      fallbackUrl: 'https://www.credit-agricole.fr/',
    ),
    'cic': BankInfo(
      id: 'cic',
      displayName: 'CIC',
      androidPackage: 'com.cic_prod.bad',
      iosUrlScheme: 'cic://',
      fallbackUrl: 'https://www.cic.fr/',
    ),
  };
}
