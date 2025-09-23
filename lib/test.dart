/*
Container(
    width: 440,
    height: 956,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.white),
    child: Stack(
        children: [
            Positioned(
                left: 73,
                top: 858,
                child: Container(
                    width: 293,
                    height: 48,
                    child: Stack(
                        children: [
                            Positioned(
                                left: -73,
                                top: 64,
                                child: Container(
                                    width: 440,
                                    height: 34,
                                    decoration: BoxDecoration(color: const Color(0xFF2A323F)),
                                ),
                            ),
                            Positioned(
                                left: -73,
                                top: -21,
                                child: Container(
                                    width: 440,
                                    height: 86,
                                    decoration: BoxDecoration(color: const Color(0xFF2A323F)),
                                ),
                            ),
                            Positioned(
                                left: 3,
                                top: 0,
                                child: Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                ),
                            ),
                            Positioned(
                                left: -6,
                                top: 32,
                                child: Text(
                                    'Home',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 110,
                                top: 32,
                                child: Text(
                                    'My Assets',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 247,
                                top: 32,
                                child: Text(
                                    'Profile',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 258,
                                top: 0,
                                child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: ShapeDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/30x30"),
                                            fit: BoxFit.cover,
                                        ),
                                        shape: OvalBorder(),
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 135,
                                top: 0,
                                child: Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 50,
                top: 553.99,
                child: SizedBox(
                    width: 188.53,
                    height: 22.94,
                    child: Text(
                        'Favorite Assets',
                        style: TextStyle(
                            color: const Color(0xFF2A323F),
                            fontSize: 25,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 40,
                top: 195,
                child: Container(
                    width: 352,
                    height: 116,
                    child: Stack(
                        children: [
                            Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                    width: 352,
                                    height: 116,
                                    decoration: ShapeDecoration(
                                        color: const Color(0x99FEEF4C),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(28),
                                        ),
                                    ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Container(
                                                width: double.infinity,
                                                height: 56,
                                                padding: const EdgeInsets.all(4),
                                                decoration: ShapeDecoration(
                                                    color: const Color(0x99FEEF4C),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(28),
                                                            topRight: Radius.circular(28),
                                                        ),
                                                    ),
                                                ),
                                                child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 4,
                                                    children: [
                                                        Container(
                                                            width: 48,
                                                            height: 48,
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                    Container(
                                                                        width: 40,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: ShapeDecoration(
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(100),
                                                                            ),
                                                                        ),
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                                Container(
                                                                                    width: double.infinity,
                                                                                    height: 40,
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Container(width: 24, height: 24, child: Stack()),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                                height: double.infinity,
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    spacing: 10,
                                                                    children: [
                                                                        Container(
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 1,
                                                                                children: [
                                                                                    Text(
                                                                                        'Important',
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFF2A323F),
                                                                                            fontSize: 25,
                                                                                            fontFamily: 'Roboto',
                                                                                            fontWeight: FontWeight.w600,
                                                                                            height: 0.96,
                                                                                            letterSpacing: 0.50,
                                                                                        ),
                                                                                    ),
                                                                                ],
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        ),
                                                        Container(
                                                            width: 48,
                                                            height: 48,
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                    Container(
                                                                        width: 40,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: ShapeDecoration(
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(100),
                                                                            ),
                                                                        ),
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                                Container(
                                                                                    width: double.infinity,
                                                                                    height: 40,
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Container(width: 24, height: 24, child: Stack()),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Container(
                                                width: double.infinity,
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Container(
                                                            width: double.infinity,
                                                            decoration: ShapeDecoration(
                                                                shape: RoundedRectangleBorder(
                                                                    side: BorderSide(
                                                                        width: 1,
                                                                        strokeAlign: BorderSide.strokeAlignCenter,
                                                                        color: const Color(0xFF79747E) /* Schemes-Outline */,
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Container(
                                                width: double.infinity,
                                                height: 72,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 25,
                                top: 65,
                                child: SizedBox(
                                    width: 303,
                                    height: 36,
                                    child: Text.rich(
                                        TextSpan(
                                            children: [
                                                TextSpan(
                                                    text: 'Overdue maintenance on ',
                                                    style: TextStyle(
                                                        color: const Color(0xFF2A323F),
                                                        fontSize: 17,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.18,
                                                        letterSpacing: 0.50,
                                                    ),
                                                ),
                                                TextSpan(
                                                    text: 'Pittsburgh Fiberglass Claw Hammer',
                                                    style: TextStyle(
                                                        color: const Color(0xFF2A323F),
                                                        fontSize: 17,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w400,
                                                        textDecoration: TextDecoration.underline,
                                                        height: 1.18,
                                                        letterSpacing: 0.50,
                                                    ),
                                                ),
                                                TextSpan(
                                                    text: '.',
                                                    style: TextStyle(
                                                        color: const Color(0xFF2A323F),
                                                        fontSize: 17,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.18,
                                                        letterSpacing: 0.50,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 60,
                top: 608,
                child: Container(
                    width: 341,
                    height: 210,
                    child: Stack(
                        children: [
                            Positioned(
                                left: 0,
                                top: 14,
                                child: Container(
                                    width: 924,
                                    height: 163,
                                    child: Stack(
                                        children: [
                                            Positioned(
                                                left: 308,
                                                top: 0,
                                                child: Container(
                                                    width: 154,
                                                    height: 163,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 7,
                                                                top: 133,
                                                                child: SizedBox(
                                                                    width: 147,
                                                                    height: 30,
                                                                    child: Text(
                                                                        'Graphic Pencils',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 7,
                                                                top: 107,
                                                                child: SizedBox(
                                                                    width: 80.47,
                                                                    height: 22.36,
                                                                    child: Text(
                                                                        'Derwent',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 148,
                                                                    height: 99,
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD9D9D9),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 49,
                                                                top: 25,
                                                                child: Container(width: 51, height: 51, child: Stack()),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 462,
                                                top: 0,
                                                child: Container(
                                                    width: 154,
                                                    height: 163,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 7,
                                                                top: 133,
                                                                child: SizedBox(
                                                                    width: 147,
                                                                    height: 30,
                                                                    child: Text(
                                                                        'Stratocaster Guitar',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w600,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 7,
                                                                top: 107,
                                                                child: SizedBox(
                                                                    width: 80.47,
                                                                    height: 22.36,
                                                                    child: Text(
                                                                        'Fender',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 148,
                                                                    height: 99,
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD9D9D9),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 49,
                                                                top: 25,
                                                                child: Container(width: 51, height: 51, child: Stack()),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Container(
                                                    width: 154,
                                                    height: 163,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 7,
                                                                top: 133,
                                                                child: SizedBox(
                                                                    width: 147,
                                                                    height: 30,
                                                                    child: Text(
                                                                        '350W Power Station',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 7,
                                                                top: 107,
                                                                child: SizedBox(
                                                                    width: 80.47,
                                                                    height: 22.36,
                                                                    child: Text(
                                                                        'Predator',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 148,
                                                                    height: 99,
                                                                    decoration: ShapeDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage("https://placehold.co/148x99"),
                                                                            fit: BoxFit.fill,
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 154,
                                                top: 0,
                                                child: Container(
                                                    width: 154,
                                                    height: 163,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 7,
                                                                top: 133,
                                                                child: SizedBox(
                                                                    width: 147,
                                                                    height: 30,
                                                                    child: Text(
                                                                        '4 Gal Backpack Chemical Spr...',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 7,
                                                                top: 107,
                                                                child: SizedBox(
                                                                    width: 80.47,
                                                                    height: 22.36,
                                                                    child: Text(
                                                                        'Niagara',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 148,
                                                                    height: 99,
                                                                    decoration: ShapeDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage("https://placehold.co/148x99"),
                                                                            fit: BoxFit.cover,
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 616,
                                                top: 0,
                                                child: Container(
                                                    width: 154,
                                                    height: 163,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 7,
                                                                top: 133,
                                                                child: SizedBox(
                                                                    width: 147,
                                                                    height: 30,
                                                                    child: Text(
                                                                        'Screwdriver Bit Set',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 7,
                                                                top: 107,
                                                                child: SizedBox(
                                                                    width: 80.47,
                                                                    height: 22.36,
                                                                    child: Text(
                                                                        'Predator',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 148,
                                                                    height: 99,
                                                                    decoration: ShapeDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage("https://placehold.co/148x99"),
                                                                            fit: BoxFit.cover,
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 770,
                                                top: 0,
                                                child: Container(
                                                    width: 154,
                                                    height: 163,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 7,
                                                                top: 133,
                                                                child: SizedBox(
                                                                    width: 147,
                                                                    height: 30,
                                                                    child: Text(
                                                                        'V15 Detect Vacuum',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 7,
                                                                top: 107,
                                                                child: SizedBox(
                                                                    width: 80.47,
                                                                    height: 22.36,
                                                                    child: Text(
                                                                        'Dyson',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 148,
                                                                    height: 99,
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD9D9D9),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 49,
                                                                top: 25,
                                                                child: Container(width: 51, height: 51, child: Stack()),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 956,
                                top: 71,
                                child: SizedBox(
                                    width: 78,
                                    height: 25,
                                    child: Text(
                                        '+ 5 more',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                        ),
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 935,
                                top: 32,
                                child: Container(
                                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                    width: 140.01,
                                    decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                color: const Color(0x662A323F),
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 48,
                top: 366.53,
                child: SizedBox(
                    width: 319,
                    height: 27.24,
                    child: Text(
                        'Upcoming Maintenance',
                        style: TextStyle(
                            color: const Color(0xFF2A323F),
                            fontSize: 25,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 50,
                top: 396,
                child: Container(
                    width: 341,
                    height: 127,
                    child: Stack(
                        children: [
                            Positioned(
                                left: 329,
                                top: 34,
                                child: Container(
                                    width: 1400,
                                    height: 69,
                                    child: Stack(
                                        children: [
                                            Positioned(
                                                left: 1322,
                                                top: 22,
                                                child: SizedBox(
                                                    width: 78,
                                                    height: 25,
                                                    child: Text(
                                                        '+ 5 more',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 17,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Container(
                                                    width: 304,
                                                    height: 69,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 103,
                                                                    height: 69,
                                                                    decoration: ShapeDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage("https://placehold.co/103x69"),
                                                                            fit: BoxFit.fill,
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 26,
                                                                child: SizedBox(
                                                                    width: 194,
                                                                    height: 41,
                                                                    child: Text(
                                                                        'Pittsburgh Fiberglass Claw Hammer    Reoil ',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 2,
                                                                child: SizedBox(
                                                                    width: 174,
                                                                    height: 17,
                                                                    child: Text(
                                                                        'Aug. 12, 2025',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 313,
                                                                top: 6,
                                                                child: Container(
                                                                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                                                    width: 58,
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(
                                                                            side: BorderSide(
                                                                                width: 1,
                                                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                                                color: const Color(0x662A323F),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 228,
                                                top: 58,
                                                child: Container(
                                                    width: 3,
                                                    height: 3,
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xBF2A323F),
                                                        shape: OvalBorder(),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 550,
                                                top: 37,
                                                child: Container(
                                                    width: 3,
                                                    height: 3,
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xBF2A323F),
                                                        shape: OvalBorder(),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 905,
                                                top: 37,
                                                child: Container(
                                                    width: 3,
                                                    height: 3,
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xBF2A323F),
                                                        shape: OvalBorder(),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 1242,
                                                top: 58,
                                                child: Container(
                                                    width: 3,
                                                    height: 3,
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xBF2A323F),
                                                        shape: OvalBorder(),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 330,
                                                top: 0,
                                                child: Container(
                                                    width: 304,
                                                    height: 69,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 103,
                                                                    height: 69,
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD9D9D9),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 26,
                                                                child: SizedBox(
                                                                    width: 194,
                                                                    height: 41,
                                                                    child: Text(
                                                                        'Pygmie Goat    Vet Check Up',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 2,
                                                                child: SizedBox(
                                                                    width: 174,
                                                                    height: 17,
                                                                    child: Text(
                                                                        'Oct. 13, 2025',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 33,
                                                                top: 17,
                                                                child: Container(width: 36, height: 35, child: Stack()),
                                                            ),
                                                            Positioned(
                                                                left: 313,
                                                                top: 6,
                                                                child: Container(
                                                                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                                                    width: 58,
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(
                                                                            side: BorderSide(
                                                                                width: 1,
                                                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                                                color: const Color(0x662A323F),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 660,
                                                top: 0,
                                                child: Container(
                                                    width: 304,
                                                    height: 69,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 103,
                                                                    height: 69,
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD9D9D9),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 26,
                                                                child: SizedBox(
                                                                    width: 194,
                                                                    height: 41,
                                                                    child: Text(
                                                                        'Stanley Hammer   Re-oil the Wood',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 2,
                                                                child: SizedBox(
                                                                    width: 174,
                                                                    height: 17,
                                                                    child: Text(
                                                                        'Nov. 23, 2025',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 33,
                                                                top: 17,
                                                                child: Container(width: 36, height: 35, child: Stack()),
                                                            ),
                                                            Positioned(
                                                                left: 313,
                                                                top: 6,
                                                                child: Container(
                                                                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                                                    width: 58,
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(
                                                                            side: BorderSide(
                                                                                width: 1,
                                                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                                                color: const Color(0x662A323F),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 990,
                                                top: 0,
                                                child: Container(
                                                    width: 304,
                                                    height: 69,
                                                    child: Stack(
                                                        children: [
                                                            Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                    width: 103,
                                                                    height: 69,
                                                                    decoration: ShapeDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage("https://placehold.co/103x69"),
                                                                            fit: BoxFit.cover,
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 26,
                                                                child: SizedBox(
                                                                    width: 194,
                                                                    height: 41,
                                                                    child: Text(
                                                                        'Niagara 4 Gal Backpack Chemical Sprayer   Ref...',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w200,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 110,
                                                                top: 2,
                                                                child: SizedBox(
                                                                    width: 174,
                                                                    height: 17,
                                                                    child: Text(
                                                                        'Jan. 23, 2026',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFF2A323F),
                                                                            fontSize: 17,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Positioned(
                                                                left: 313,
                                                                top: 6,
                                                                child: Container(
                                                                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                                                    width: 58,
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(
                                                                            side: BorderSide(
                                                                                width: 1,
                                                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                                                color: const Color(0x662A323F),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 0,
                                top: 34,
                                child: Container(
                                    width: 304,
                                    height: 69,
                                    child: Stack(
                                        children: [
                                            Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Container(
                                                    width: 103,
                                                    height: 69,
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFD9D9D9),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 110,
                                                top: 26,
                                                child: SizedBox(
                                                    width: 194,
                                                    height: 41,
                                                    child: Text(
                                                        'Pittsburgh Fiberglass Claw Hammer    Re-oil ...',
                                                        style: TextStyle(
                                                            color: const Color(0xFF2A323F),
                                                            fontSize: 17,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w200,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 110,
                                                top: 2,
                                                child: SizedBox(
                                                    width: 174,
                                                    height: 17,
                                                    child: Text(
                                                        'Aug. 12, 2025',
                                                        style: TextStyle(
                                                            color: const Color(0xFF2A323F),
                                                            fontSize: 17,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Positioned(
                                                left: 33,
                                                top: 17,
                                                child: Container(width: 36, height: 35, child: Stack()),
                                            ),
                                            Positioned(
                                                left: 313,
                                                top: 6,
                                                child: Container(
                                                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                                    width: 58,
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                width: 1,
                                                                strokeAlign: BorderSide.strokeAlignCenter,
                                                                color: const Color(0x662A323F),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 230,
                                top: 36,
                                child: Text(
                                    '! Late',
                                    style: TextStyle(
                                        color: const Color(0xFFDE3636),
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 23,
                top: 172,
                child: Container(
                    width: 100,
                    height: 100,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                ),
            ),
            Positioned(
                left: 0,
                top: 0,
                child: Container(
                    width: 440,
                    height: 142,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Stack(
                        children: [
                            Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                    width: 440,
                                    height: 142,
                                    decoration: BoxDecoration(color: const Color(0xFF2A323F)),
                                ),
                            ),
                            Positioned(
                                left: 40,
                                top: 41,
                                child: SizedBox(
                                    width: 109,
                                    height: 87,
                                    child: Text(
                                        'HE',
                                        style: TextStyle(
                                            color: const Color(0xFFFEEF4C),
                                            fontSize: 75,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w800,
                                        ),
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        ],
    ),
)
*/