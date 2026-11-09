enum AppLanguage {
  pl('Polski', '🇵🇱'),
  en('English', '🇬🇧'),
  de('Deutsch', '🇩🇪'),
  es('Español', '🇪🇸'),
  fr('Français', '🇫🇷'),
  uk('Українська', '🇺🇦');

  const AppLanguage(this.name, this.flag);
  final String name;
  final String flag;
}

class I18n {
  I18n._();
  static final I18n instance = I18n._();

  AppLanguage _current = AppLanguage.pl;
  AppLanguage get current => _current;

  void setLanguage(AppLanguage lang) {
    _current = lang;
  }

  // 1. Tool names
  String get toolBrush => switch (_current) {
        AppLanguage.pl => 'Pędzel',
        AppLanguage.en => 'Paint',
        AppLanguage.de => 'Malen',
        AppLanguage.es => 'Pintar',
        AppLanguage.fr => 'Pinceau',
        AppLanguage.uk => 'Пензель',
      };

  String get toolStamps => switch (_current) {
        AppLanguage.pl => 'Stemple',
        AppLanguage.en => 'Stamp',
        AppLanguage.de => 'Stempel',
        AppLanguage.es => 'Sellos',
        AppLanguage.fr => 'Tampon',
        AppLanguage.uk => 'Штампи',
      };

  String get toolMagic => switch (_current) {
        AppLanguage.pl => 'Magia',
        AppLanguage.en => 'Magic',
        AppLanguage.de => 'Magie',
        AppLanguage.es => 'Magia',
        AppLanguage.fr => 'Magie',
        AppLanguage.uk => 'Магія',
      };

  String get toolFill => switch (_current) {
        AppLanguage.pl => 'Wiadro',
        AppLanguage.en => 'Fill',
        AppLanguage.de => 'Füllen',
        AppLanguage.es => 'Rellenar',
        AppLanguage.fr => 'Remplir',
        AppLanguage.uk => 'Заливка',
      };

  String get toolShapes => switch (_current) {
        AppLanguage.pl => 'Kształty',
        AppLanguage.en => 'Shapes',
        AppLanguage.de => 'Formen',
        AppLanguage.es => 'Figuras',
        AppLanguage.fr => 'Formes',
        AppLanguage.uk => 'Фігури',
      };

  String get toolLines => switch (_current) {
        AppLanguage.pl => 'Linie',
        AppLanguage.en => 'Lines',
        AppLanguage.de => 'Linien',
        AppLanguage.es => 'Líneas',
        AppLanguage.fr => 'Lignes',
        AppLanguage.uk => 'Лінії',
      };

  String get toolColoring => switch (_current) {
        AppLanguage.pl => 'Koloruj',
        AppLanguage.en => 'Coloring',
        AppLanguage.de => 'Ausmalen',
        AppLanguage.es => 'Colorear',
        AppLanguage.fr => 'Coloriage',
        AppLanguage.uk => 'Розмальовки',
      };

  String get toolEraser => switch (_current) {
        AppLanguage.pl => 'Gumka',
        AppLanguage.en => 'Eraser',
        AppLanguage.de => 'Radierer',
        AppLanguage.es => 'Goma',
        AppLanguage.fr => 'Gomme',
        AppLanguage.uk => 'Гумка',
      };

  // 2. Shelf Labels
  String get brushShape => switch (_current) {
        AppLanguage.pl => 'Kształt pędzla:',
        AppLanguage.en => 'Brush shape:',
        AppLanguage.de => 'Pinselform:',
        AppLanguage.es => 'Forma del pincel:',
        AppLanguage.fr => 'Forme du pinceau :',
        AppLanguage.uk => 'Форма пензля:',
      };

  String get lineBrush => switch (_current) {
        AppLanguage.pl => 'Pędzel dla linii:',
        AppLanguage.en => 'Line brush:',
        AppLanguage.de => 'Linienpinsel:',
        AppLanguage.es => 'Pincel de línea:',
        AppLanguage.fr => 'Pinceau pour ligne :',
        AppLanguage.uk => 'Пензель лінії:',
      };

  String get stampSize => switch (_current) {
        AppLanguage.pl => 'Rozmiar:',
        AppLanguage.en => 'Size:',
        AppLanguage.de => 'Größe:',
        AppLanguage.es => 'Tamaño:',
        AppLanguage.fr => 'Taille :',
        AppLanguage.uk => 'Розмір:',
      };

  String get magicEffect => switch (_current) {
        AppLanguage.pl => 'Efekt magii:',
        AppLanguage.en => 'Magic effect:',
        AppLanguage.de => 'Magie-Effekt:',
        AppLanguage.es => 'Efecto mágico:',
        AppLanguage.fr => 'Effet magique :',
        AppLanguage.uk => 'Ефект магії:',
      };

  String get coloringPages => switch (_current) {
        AppLanguage.pl => 'Kolorowanki:',
        AppLanguage.en => 'Coloring pages:',
        AppLanguage.de => 'Ausmalbilder:',
        AppLanguage.es => 'Páginas para colorear:',
        AppLanguage.fr => 'Coloriages :',
        AppLanguage.uk => 'Розмальовки:',
      };

  String get blankCanvas => switch (_current) {
        AppLanguage.pl => '📄 Czysta kartka',
        AppLanguage.en => '📄 Blank paper',
        AppLanguage.de => '📄 Leeres Blatt',
        AppLanguage.es => '📄 Papel en blanco',
        AppLanguage.fr => '📄 Page blanche',
        AppLanguage.uk => '📄 Чистий аркуш',
      };

  String get brushSizesScale => switch (_current) {
        AppLanguage.pl => '10 Rozmiarów Pędzla',
        AppLanguage.en => '10 Brush Sizes',
        AppLanguage.de => '10 Pinselgrößen',
        AppLanguage.es => '10 Tamaños de Pincel',
        AppLanguage.fr => '10 Tailles de Pinceau',
        AppLanguage.uk => '10 Розмірів Пензля',
      };

  // 3. Shapes
  String get shapeCircle => switch (_current) {
        AppLanguage.pl => '⭕ Koło',
        AppLanguage.en => '⭕ Circle',
        AppLanguage.de => '⭕ Kreis',
        AppLanguage.es => '⭕ Círculo',
        AppLanguage.fr => '⭕ Cercle',
        AppLanguage.uk => '⭕ Коло',
      };

  String get shapeSquare => switch (_current) {
        AppLanguage.pl => '🔲 Kwadrat',
        AppLanguage.en => '🔲 Square',
        AppLanguage.de => '🔲 Quadrat',
        AppLanguage.es => '🔲 Cuadrado',
        AppLanguage.fr => '🔲 Carré',
        AppLanguage.uk => '🔲 Квадрат',
      };

  String get shapeTriangle => switch (_current) {
        AppLanguage.pl => '🔺 Trójkąt',
        AppLanguage.en => '🔺 Triangle',
        AppLanguage.de => '🔺 Dreieck',
        AppLanguage.es => '🔺 Triángulo',
        AppLanguage.fr => '🔺 Triangle',
        AppLanguage.uk => '🔺 Трикутник',
      };

  String get shapeStar => switch (_current) {
        AppLanguage.pl => '⭐ Gwiazda',
        AppLanguage.en => '⭐ Star',
        AppLanguage.de => '⭐ Stern',
        AppLanguage.es => '⭐ Estrella',
        AppLanguage.fr => '⭐ Étoile',
        AppLanguage.uk => '⭐ Зірка',
      };

  String get shapeFilled => switch (_current) {
        AppLanguage.pl => 'Pełny kształt',
        AppLanguage.en => 'Filled',
        AppLanguage.de => 'Ausgefüllt',
        AppLanguage.es => 'Relleno',
        AppLanguage.fr => 'Rempli',
        AppLanguage.uk => 'Заповнений',
      };

  String get shapeOutline => switch (_current) {
        AppLanguage.pl => 'Tylko obrys',
        AppLanguage.en => 'Outline only',
        AppLanguage.de => 'Nur Umriss',
        AppLanguage.es => 'Solo contorno',
        AppLanguage.fr => 'Contour seul',
        AppLanguage.uk => 'Лише контур',
      };

  // 4. Magic Effects Names
  String get magicGrass => switch (_current) {
        AppLanguage.pl => 'Trawa',
        AppLanguage.en => 'Grass',
        AppLanguage.de => 'Gras',
        AppLanguage.es => 'Hierba',
        AppLanguage.fr => 'Herbe',
        AppLanguage.uk => 'Трава',
      };

  String get magicRainbow => switch (_current) {
        AppLanguage.pl => 'Tęcza',
        AppLanguage.en => 'Rainbow',
        AppLanguage.de => 'Regenbogen',
        AppLanguage.es => 'Arcoíris',
        AppLanguage.fr => 'Arc-en-ciel',
        AppLanguage.uk => 'Веселка',
      };

  String get magicRealRainbow => switch (_current) {
        AppLanguage.pl => 'Łuk tęczy',
        AppLanguage.en => 'Real Rainbow',
        AppLanguage.de => 'Echter Bogen',
        AppLanguage.es => 'Arco real',
        AppLanguage.fr => 'Véritable arc',
        AppLanguage.uk => 'Дуга веселки',
      };

  String get magicBricks => switch (_current) {
        AppLanguage.pl => 'Cegły',
        AppLanguage.en => 'Bricks',
        AppLanguage.de => 'Ziegel',
        AppLanguage.es => 'Ladrillos',
        AppLanguage.fr => 'Briques',
        AppLanguage.uk => 'Цегла',
      };

  String get magicChalk => switch (_current) {
        AppLanguage.pl => 'Kreda',
        AppLanguage.en => 'Chalk',
        AppLanguage.de => 'Kreide',
        AppLanguage.es => 'Tiza',
        AppLanguage.fr => 'Craie',
        AppLanguage.uk => 'Крейда',
      };

  String get magicBlur => switch (_current) {
        AppLanguage.pl => 'Rozmycie',
        AppLanguage.en => 'Blur',
        AppLanguage.de => 'Unschärfe',
        AppLanguage.es => 'Desenfoque',
        AppLanguage.fr => 'Flou',
        AppLanguage.uk => 'Розмиття',
      };

  String get magicRails => switch (_current) {
        AppLanguage.pl => 'Tory',
        AppLanguage.en => 'Tracks',
        AppLanguage.de => 'Gleise',
        AppLanguage.es => 'Vías',
        AppLanguage.fr => 'Rails',
        AppLanguage.uk => 'Колія',
      };

  String get magicFoam => switch (_current) {
        AppLanguage.pl => 'Piana',
        AppLanguage.en => 'Foam',
        AppLanguage.de => 'Schaum',
        AppLanguage.es => 'Espuma',
        AppLanguage.fr => 'Mousse',
        AppLanguage.uk => 'Піна',
      };

  String get magicConfetti => switch (_current) {
        AppLanguage.pl => 'Konfetti',
        AppLanguage.en => 'Confetti',
        AppLanguage.de => 'Konfetti',
        AppLanguage.es => 'Confeti',
        AppLanguage.fr => 'Confettis',
        AppLanguage.uk => 'Конфеті',
      };

  String get magicFlower => switch (_current) {
        AppLanguage.pl => 'Kwiaty',
        AppLanguage.en => 'Flowers',
        AppLanguage.de => 'Blumen',
        AppLanguage.es => 'Flores',
        AppLanguage.fr => 'Fleurs',
        AppLanguage.uk => 'Квіти',
      };

  // 5. Tux Messages
  String get tuxWelcome => switch (_current) {
        AppLanguage.pl => 'Witaj w KidsPaint! Wybierz pędzel lub stempel i maluj!',
        AppLanguage.en => 'Welcome to KidsPaint! Pick a brush or stamp and paint!',
        AppLanguage.de => 'Willkommen bei KidsPaint! Wähle einen Pinsel oder Stempel und male!',
        AppLanguage.es => '¡Bienvenido a KidsPaint! ¡Elige un pincel o sello y a pintar!',
        AppLanguage.fr => 'Bienvenue dans KidsPaint ! Choisis un pinceau ou un tampon et dessine !',
        AppLanguage.uk => 'Ласкаво просимо до KidsPaint! Оберіть пензель чи штамп і творіть!',
      };

  String get tuxBrushTip => switch (_current) {
        AppLanguage.pl => 'Wybierz kształt pędzla i kolor, aby rysować!',
        AppLanguage.en => 'Pick a brush shape and color to start painting!',
        AppLanguage.de => 'Wähle eine Pinselform und eine Farbe, um zu malen!',
        AppLanguage.es => '¡Elige una forma de pincel y un color para pintar!',
        AppLanguage.fr => 'Choisis une forme de pinceau et une couleur pour peindre !',
        AppLanguage.uk => 'Оберіть форму пензля та колір для малювання!',
      };

  String get tuxStampTip => switch (_current) {
        AppLanguage.pl => 'Wybierz stempel Tuxa lub zwierzątka i kliknij na płótno!',
        AppLanguage.en => 'Pick a Tux or animal stamp and tap on the canvas!',
        AppLanguage.de => 'Wähle einen Tux- oder Tierstempel und klicke auf die Leinwand!',
        AppLanguage.es => '¡Elige un sello de Tux o animales y pulsa en el lienzo!',
        AppLanguage.fr => 'Choisis un tampon Tux ou animal et clique sur la toile !',
        AppLanguage.uk => 'Оберіть штамп з Туксом чи твариною і торкніться полотна!',
      };

  String get tuxLinesTip => switch (_current) {
        AppLanguage.pl => 'Kliknij i przeciągnij, aby narysować prostą linię pędzlem!',
        AppLanguage.en => 'Click and drag to stretch a straight brush line!',
        AppLanguage.de => 'Klicke und ziehe, um eine gerade Linie mit dem Pinsel zu ziehen!',
        AppLanguage.es => '¡Haz clic y arrastra para trazar una línea recta con el pincel!',
        AppLanguage.fr => 'Clique et glisse pour tracer une ligne droite avec le pinceau !',
        AppLanguage.uk => 'Натисніть і проведіть лінію обраним пензлем!',
      };

  String get tuxShapesTip => switch (_current) {
        AppLanguage.pl => 'Wybierz kształt (koło, kwadrat, gwiazda) i rozciągnij go na płótnie!',
        AppLanguage.en => 'Pick a shape (circle, square, star) and drag it on the canvas!',
        AppLanguage.de => 'Wähle eine Form (Kreis, Quadrat, Stern) und ziehe sie auf die Leinwand!',
        AppLanguage.es => '¡Elige una forma (círculo, cuadrado, estrella) y arrástrala por el lienzo!',
        AppLanguage.fr => 'Choisis une forme (cercle, carré, étoile) et étire-la sur la toile !',
        AppLanguage.uk => 'Оберіть фігуру (коло, квадрат, зірка) та розтягніть її на полотні!',
      };

  String get tuxMagicTip => switch (_current) {
        AppLanguage.pl => 'Magia! Spróbuj narysować trawę, tęczę, cegły lub kredę!',
        AppLanguage.en => 'Magic! Try painting grass, rainbow, bricks, or chalk!',
        AppLanguage.de => 'Magie! Male Gras, Regenbogen, Ziegel oder Kreide!',
        AppLanguage.es => '¡Magia! ¡Prueba a pintar hierba, arcoíris, ladrillos o tiza!',
        AppLanguage.fr => 'Magie ! Essaie de dessiner de l’herbe, un arc-en-ciel, des briques ou de la craie !',
        AppLanguage.uk => 'Магія! Спробуйте намалювати траву, веселку, цеглу чи крейду!',
      };

  String get tuxFillTip => switch (_current) {
        AppLanguage.pl => 'Wiadro: kliknij na płótnie, aby zalać cały obszar kolorem!',
        AppLanguage.en => 'Fill bucket: tap inside any area to flood it with color!',
        AppLanguage.de => 'Farbeimer: Klicke in einen Bereich, um ihn komplett auszufüllen!',
        AppLanguage.es => 'Cubo de pintura: ¡toca dentro de cualquier área para llenarla de color!',
        AppLanguage.fr => 'Remplissage : clique dans une zone fermée pour la remplir de couleur !',
        AppLanguage.uk => 'Відро заливки: натисніть у замкненій області для заливки кольором!',
      };

  String get tuxColoringTip => switch (_current) {
        AppLanguage.pl => 'Wybierz kolorowankę lub szablon do zamalowania!',
        AppLanguage.en => 'Pick a coloring template or starter to fill and paint!',
        AppLanguage.de => 'Wähle eine Malvorlage zum Ausmalen!',
        AppLanguage.es => '¡Elige una lámina para colorear o un marco para pintar!',
        AppLanguage.fr => 'Choisis un coloriage ou un modèle à peindre !',
        AppLanguage.uk => 'Оберіть розмальовку чи шаблон для розфарбовування!',
      };

  String get tuxEraserTip => switch (_current) {
        AppLanguage.pl => 'Gumka: wymazuj niepotrzebne linie na biało!',
        AppLanguage.en => 'Eraser: wipe away any lines back to clean white!',
        AppLanguage.de => 'Radierer: Radiere Linien wieder weiß weg!',
        AppLanguage.es => 'Goma: ¡borra los trazos para dejarlos blancos!',
        AppLanguage.fr => 'Gomme : efface les traits pour retrouver du blanc !',
        AppLanguage.uk => 'Гумка: витирайте зайві лінії до білого!',
      };

  // 6. Stamp categories
  String stampCategory(String key) => switch (key) {
        'tux' => switch (_current) {
            AppLanguage.pl => 'Tux Pingwin',
            AppLanguage.en => 'Tux Penguin',
            AppLanguage.de => 'Tux Pinguin',
            AppLanguage.es => 'Pingüino Tux',
            AppLanguage.fr => 'Manchot Tux',
            AppLanguage.uk => 'Пінгвін Тукс',
          },
        'animals' => switch (_current) {
            AppLanguage.pl => 'Zwierzątka',
            AppLanguage.en => 'Animals',
            AppLanguage.de => 'Tiere',
            AppLanguage.es => 'Animales',
            AppLanguage.fr => 'Animaux',
            AppLanguage.uk => 'Тваринки',
          },
        'vehicles' => switch (_current) {
            AppLanguage.pl => 'Pojazdy',
            AppLanguage.en => 'Vehicles',
            AppLanguage.de => 'Fahrzeuge',
            AppLanguage.es => 'Vehículos',
            AppLanguage.fr => 'Véhicules',
            AppLanguage.uk => 'Транспорт',
          },
        'space' => switch (_current) {
            AppLanguage.pl => 'Kosmos',
            AppLanguage.en => 'Space',
            AppLanguage.de => 'Weltraum',
            AppLanguage.es => 'Espacio',
            AppLanguage.fr => 'Espace',
            AppLanguage.uk => 'Космос',
          },
        'food' => switch (_current) {
            AppLanguage.pl => 'Jedzenie',
            AppLanguage.en => 'Food',
            AppLanguage.de => 'Essen',
            AppLanguage.es => 'Comida',
            AppLanguage.fr => 'Nourriture',
            AppLanguage.uk => 'Їжа',
          },
        'plants' => switch (_current) {
            AppLanguage.pl => 'Przyroda',
            AppLanguage.en => 'Plants & Nature',
            AppLanguage.de => 'Pflanzen & Natur',
            AppLanguage.es => 'Plantas y Naturaleza',
            AppLanguage.fr => 'Plantes & Nature',
            AppLanguage.uk => 'Природа',
          },
        _ => key,
      };
}
