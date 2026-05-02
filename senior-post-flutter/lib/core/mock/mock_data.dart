import 'mock_models.dart';

/// 内置假数据：用户、明信片、评论、信件、邮票流水、兴趣标签。
abstract final class MockData {
  static final List<MockInterestTag> interests = const [
    MockInterestTag(id: 'gardening', label: 'Gardening'),
    MockInterestTag(id: 'reading', label: 'Reading'),
    MockInterestTag(id: 'cooking', label: 'Cooking'),
    MockInterestTag(id: 'travel', label: 'Slow travel'),
    MockInterestTag(id: 'photography', label: 'Film photography'),
    MockInterestTag(id: 'music', label: 'Classical music'),
    MockInterestTag(id: 'jazz', label: 'Jazz & blues'),
    MockInterestTag(id: 'history', label: 'World history'),
    MockInterestTag(id: 'genealogy', label: 'Family history'),
    MockInterestTag(id: 'crafts', label: 'Hand crafts'),
    MockInterestTag(id: 'birds', label: 'Bird watching'),
    MockInterestTag(id: 'language', label: 'Language exchange'),
    MockInterestTag(id: 'tea', label: 'Tea & coffee'),
    MockInterestTag(id: 'painting', label: 'Watercolor'),
    MockInterestTag(id: 'volunteer', label: 'Volunteering'),
    MockInterestTag(id: 'walking', label: 'Long walks'),
  ];

  static const _now = 2026;

  static final List<MockUser> users = [
    MockUser(
      id: 'u_001',
      nickname: 'Margaret',
      email: 'margaret@example.com',
      countryCode: 'GB',
      countryName: 'United Kingdom',
      birthYear: _now - 62,
      bio:
          'Retired librarian in the Cotswolds. I keep a small garden, write letters, and listen to BBC Radio 3.',
      interests: const ['reading', 'gardening', 'classical-music'],
      isVip: true,
    ),
    MockUser(
      id: 'u_002',
      nickname: 'Henrik',
      email: 'henrik@example.com',
      countryCode: 'SE',
      countryName: 'Sweden',
      birthYear: _now - 58,
      bio:
          'Forester from Dalarna. I love jazz, slow travel and exchanging seeds by post.',
      interests: const ['jazz', 'slow-travel', 'volunteering'],
    ),
    MockUser(
      id: 'u_003',
      nickname: 'Yuki',
      email: 'yuki@example.com',
      countryCode: 'JP',
      countryName: 'Japan',
      birthYear: _now - 67,
      bio:
          'Tea master in Kyoto. Looking for friends who appreciate craft, autumn light and quiet conversation.',
      interests: const ['tea', 'crafts', 'photography'],
    ),
    MockUser(
      id: 'u_004',
      nickname: 'Eleanor',
      email: 'eleanor@example.com',
      countryCode: 'US',
      countryName: 'United States',
      birthYear: _now - 71,
      bio:
          'Retired English teacher near Boston. I exchange letters in three languages and watercolor postcards.',
      interests: const ['language', 'painting', 'history'],
      isVip: true,
    ),
    MockUser(
      id: 'u_005',
      nickname: 'Pierre',
      email: 'pierre@example.com',
      countryCode: 'FR',
      countryName: 'France',
      birthYear: _now - 65,
      bio:
          'Bookseller in the 5th arrondissement. Prefer slow letters over screens.',
      interests: const ['reading', 'history', 'jazz'],
    ),
    MockUser(
      id: 'u_006',
      nickname: 'Greta',
      email: 'greta@example.com',
      countryCode: 'DE',
      countryName: 'Germany',
      birthYear: _now - 55,
      bio:
          'Berlin-based ornithologist. Always happy to talk about migrating birds or the city libraries.',
      interests: const ['birds', 'walking', 'volunteering'],
    ),
    MockUser(
      id: 'u_007',
      nickname: 'Lin',
      email: 'lin@example.com',
      countryCode: 'CN',
      countryName: 'China',
      birthYear: _now - 60,
      bio: '退休中学语文教师。喜欢手写、园艺与古典音乐，慢慢回信，慢慢相识。',
      interests: const ['gardening', 'classical-music', 'language'],
    ),
    MockUser(
      id: 'u_008',
      nickname: 'Diego',
      email: 'diego@example.com',
      countryCode: 'AR',
      countryName: 'Argentina',
      birthYear: _now - 64,
      bio: 'Tango aficionado from Buenos Aires. I write letters in three colors of ink.',
      interests: const ['music', 'language', 'volunteering'],
    ),
  ];

  static MockUser get currentUser => MockUser(
    id: 'me_001',
    nickname: 'Edith',
    email: 'edith@example.com',
    countryCode: 'GB',
    countryName: 'United Kingdom',
    birthYear: _now - 56,
    bio:
        'Retired nurse near Edinburgh. I love long walks, slow letters and pressing flowers.',
    interests: const ['walking', 'gardening', 'reading'],
    isVip: false,
  );

  static List<MockPost> posts() {
    final now = DateTime.now();
    return [
      MockPost(
        id: 'p_001',
        author: users[0],
        content:
            'A foggy morning in the Cotswolds. The hedges glistened with cobwebs. I made tea, opened the window, and wrote three postcards before breakfast.',
        createdAt: now.subtract(const Duration(hours: 2)),
        commentCount: 3,
      ),
      MockPost(
        id: 'p_002',
        author: users[2],
        content:
            'Today I visited a small shrine in northern Kyoto. The priest gave me a stamped paper with the date written in calligraphy. I will keep it next to my desk for a while.',
        createdAt: now.subtract(const Duration(hours: 5)),
        commentCount: 7,
      ),
      MockPost(
        id: 'p_003',
        author: users[1],
        content:
            'The forest is finally turning. I sent two seed letters today — one to Sapporo, one to Edinburgh. Slow distances feel right at my age.',
        createdAt: now.subtract(const Duration(hours: 9)),
        commentCount: 2,
      ),
      MockPost(
        id: 'p_004',
        author: users[6],
        content:
            '今天去江边走了很久。看了一会儿水鸟，又去邮局寄了三封信。希望都能慢慢到。',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        commentCount: 5,
      ),
      MockPost(
        id: 'p_005',
        author: users[3],
        content:
            'Painted a small watercolor of the harbor today. Putting it in the post for a friend in Lisbon — she said she missed the New England light.',
        createdAt: now.subtract(const Duration(days: 1, hours: 12)),
        commentCount: 4,
      ),
      MockPost(
        id: 'p_006',
        author: users[4],
        content:
            'The rain came again. I sat in the shop, sorting an old box of postcards from 1962 and thinking how every stamp tells a story.',
        createdAt: now.subtract(const Duration(days: 2)),
        commentCount: 1,
      ),
    ];
  }

  static List<MockComment> commentsFor(String postId) {
    final now = DateTime.now();
    return [
      MockComment(
        id: 'c_${postId}_1',
        author: users[1],
        content: 'This morning sounds wonderful. I will send a card next week.',
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
      MockComment(
        id: 'c_${postId}_2',
        author: users[3],
        content: 'I keep my pen and paper next to the kettle for the same reason.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MockComment(
        id: 'c_${postId}_3',
        author: users[2],
        content: '寒い朝はとても綺麗です。',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  static List<MockLetter> letters() {
    final now = DateTime.now();
    return [
      MockLetter(
        id: 'l_001',
        peer: users[0],
        preview: 'Dear Edith, the chrysanthemums in your last postcard…',
        body:
            'Dear Edith,\n\nThank you for the photograph of the chrysanthemums. The light through the window reminds me of my grandmother\'s house. I will write again on Sunday with the recipe you asked about.\n\nFondly,\nMargaret',
        type: LetterType.registered,
        status: LetterStatus.delivered,
        sentAt: now.subtract(const Duration(hours: 1)),
        deliveryAt: now.subtract(const Duration(hours: 1)),
        outgoing: false,
      ),
      MockLetter(
        id: 'l_002',
        peer: users[2],
        preview: 'I picked up your card at the post office this morning…',
        body:
            'Dear Edith,\n\nI picked up your card at the post office this morning. The bamboo paper is lovely — thank you. I have included a small piece of pressed maple from the temple grounds.\n\nWith warm wishes,\nYuki',
        type: LetterType.standard,
        status: LetterStatus.delivering,
        sentAt: now.subtract(const Duration(minutes: 36)),
        deliveryAt: now.add(const Duration(hours: 1, minutes: 24)),
        outgoing: false,
      ),
      MockLetter(
        id: 'l_003',
        peer: users[5],
        preview: 'Hello from Berlin — the starlings are back…',
        body:
            'Dear Edith,\n\nThe starlings are back over the canal. I thought of you as I watched them turn together at sunset. Greta',
        type: LetterType.standard,
        status: LetterStatus.delivered,
        sentAt: now.subtract(const Duration(days: 1)),
        deliveryAt: now.subtract(const Duration(hours: 22)),
        outgoing: false,
      ),
      MockLetter(
        id: 'l_004',
        peer: users[3],
        preview: 'Edith, I am sending you a watercolor of the harbor…',
        body:
            'Dear Edith,\n\nA watercolor of the harbor today. Slow currents, a few sailing boats. May yours be a calm afternoon. — Eleanor',
        type: LetterType.registered,
        status: LetterStatus.delivered,
        sentAt: now.subtract(const Duration(days: 2)),
        deliveryAt: now.subtract(const Duration(days: 2)),
        outgoing: false,
      ),
    ];
  }

  static List<MockStampLedgerEntry> stampLedger() {
    final now = DateTime.now();
    return [
      MockStampLedgerEntry(
        id: 'sl_1',
        title: 'Daily login bonus',
        delta: 3,
        balanceAfter: 3,
        at: now.subtract(const Duration(hours: 8)),
      ),
      MockStampLedgerEntry(
        id: 'sl_2',
        title: 'Posted a postcard',
        delta: 1,
        balanceAfter: 4,
        at: now.subtract(const Duration(hours: 6)),
      ),
      MockStampLedgerEntry(
        id: 'sl_3',
        title: 'Sent registered letter to Margaret',
        delta: -1,
        balanceAfter: 3,
        at: now.subtract(const Duration(hours: 5)),
      ),
      MockStampLedgerEntry(
        id: 'sl_4',
        title: 'Speed up: letter to Yuki',
        delta: -1,
        balanceAfter: 2,
        at: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  static const List<({String code, String nameEn, String nameZh})>
  countries = [
    (code: 'GB', nameEn: 'United Kingdom', nameZh: '英国'),
    (code: 'US', nameEn: 'United States', nameZh: '美国'),
    (code: 'FR', nameEn: 'France', nameZh: '法国'),
    (code: 'DE', nameEn: 'Germany', nameZh: '德国'),
    (code: 'IT', nameEn: 'Italy', nameZh: '意大利'),
    (code: 'ES', nameEn: 'Spain', nameZh: '西班牙'),
    (code: 'SE', nameEn: 'Sweden', nameZh: '瑞典'),
    (code: 'NO', nameEn: 'Norway', nameZh: '挪威'),
    (code: 'JP', nameEn: 'Japan', nameZh: '日本'),
    (code: 'CN', nameEn: 'China', nameZh: '中国'),
    (code: 'AR', nameEn: 'Argentina', nameZh: '阿根廷'),
    (code: 'AU', nameEn: 'Australia', nameZh: '澳大利亚'),
    (code: 'CA', nameEn: 'Canada', nameZh: '加拿大'),
    (code: 'NZ', nameEn: 'New Zealand', nameZh: '新西兰'),
  ];
}
