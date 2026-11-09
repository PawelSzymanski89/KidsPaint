# KidsPaint — Reverse Engineering Specification & Architecture Analysis
> **Projekt:** KidsPaint (Fork & UX Rewrite projektu Tux Paint)  
> **Lokalizacja:** `/Users/qbmobile/HobbyProjects/KidsPaint`  
> **Metodologia:** Reverse Engineering Analysis (REA) oparta na statycznej dekompozycji kodu źródłowego Tux Paint 0.9.36 (C / SDL2).

---

## 1. Wstęp i cele dekompozycji

Tux Paint to klasyczny, wieloplatformowy program graficzny dla dzieci (od lat 3), rozwijany od 2002 roku na licencji GNU GPL v2+. Projekt posiada bogaty silnik graficzny, dziesiątki wbudowanych narzędzi, 73 wtyczki efektów („Magic”), wsparcie dla szablonów i kolorowanek, wielojęzyczność oraz dźwięki ze sceną stereo.

Głównym problemem Tux Painta jest **przestarzały interfejs (UX/UI)**:
* Sztywne, toporne kolumny przycisków o stałym układzie z epoki monitorów 640x480 / 800x600.
* Blokujące, synchroniczne pętle modalne (`while(!done)`) dla dialogów Otwórz, Nowy, Zapisz, Drukuj.
* Brak obsługi nowoczesnych gestów (pinch-to-zoom, obracanie dwoma palcami, płynne przewijanie list).
* Ograniczone wsparcie dla warstw (dostępna jest tylko pojedyncza, częściowa warstwa „Label”).
* Brak płynnego skalowania wektorowego i nowoczesnego layoutu dotykowego (iPad / tablet / ekran dotykowy).

Projekt **KidsPaint** zakłada zachowanie bogactwa funkcji, pieczątek, dźwięków i efektów Tux Painta przy całkowitym przepisaniu architektury UX/UI na nowoczesną, przyjazną dzieciom i responsywną.

---

## 2. Architektura systemu i model renderowania

### 2.1. Stos technologiczny oryginału
* **Język:** C (C99), `src/tuxpaint.c` (~33 300 linii kodu stanowiących trzon monolitu).
* **Warstwa prezentacji i audio:** SDL2 (`SDL_Surface`, `SDL_Texture`, `SDL_Renderer`, `SDL_mixer`).
* **Formaty grafik i fontów:** `SDL_image` (PNG, SVG przez librsvg/nanosvg), `SDL_ttf` + `Fontconfig` + `FriBidi` / `Pango` dla tekstu wielojęzycznego.
* **Architektura wtyczek:** Dynamicznie ładowane biblioteki dzielone (`.so` / `.dylib` / `.dll`) w katalogu `magic/src/` oparte o interfejs C `tp_magic_api.h`.

### 2.2. Model powierzchni graficznych (Canvas Pipeline)
1. **Warstwa tła (Background):**
   * Jednolity kolor lub predefiniowany szablon („Starter” / „Template”).
   * Obsługa 4 trybów dopasowania: `SCALE_MODE_NONE`, `SCALE_MODE_HORIZ`, `SCALE_MODE_VERT`, `SCALE_MODE_BOTH`.
2. **Główna powierzchnia płótna (`canvas`):**
   * Bufor pikseli RGB(A) o docelowej rozdzielczości obrazu.
   * Na tej powierzchni zachodzą trwałe operacje rastrowe (Brush, Line, Shape, Fill, Eraser, Magic raster).
3. **Warstwa obiektowa tekstu (`label_node` list):**
   * Dynamiczna lista jednokierunkowa obiektów tekstowych zachowujących treść, pozycję, font, kolor i styl dopóki użytkownik nie zatwierdzi ich na płótnie (`LABEL_APPLY`).
4. **Bufor roboczy podglądu (Interactive Preview Overlay):**
   * Rysowanie tymczasowe gumowej linii (`Line`), rozciągania/rotacji kształtu (`Shape XOR/Preview`), obrysu pieczątki (`Stamp XOR`) lub rozmiaru gumki (`Eraser XOR`).
5. **Historia operacji (Undo / Redo Buffer):**
   * Pierścieniowy bufor kopii całego płótna (`undo_stack[]`) z synchronizacją stanu listy etykiet (`label_node`).

### 2.3. Układ ekranu (Layout Grid)
Ekran podzielony jest na 5 głównych stref:
* **Lewa kolumna (`r_tools`):** Pasek narzędzi głównych (2 kolumny kafelków).
* **Prawa kolumna (`r_toolopt`):** Podnarzędzia i opcje wybranego narzędzia (pędzle, pieczątki, kształty, czcionki, efekty).
* **Środek (`r_canvas`):** Obszar roboczy płótna.
* **Dolny pasek (`r_colors`):** Paleta barw + próbnik (pipeta) + koło barw + mikser farb.
* **Dolna belka statusowa (`r_tuxarea`):** Maskotka (Tux / zwierzak) oraz dymek tekstowy z podpowiedziami głosowymi i tekstowymi dla dziecka.

---

## 3. Szczegółowa dekompozycja narzędzi (Tools Inventory)

| ID | Narzędzie | Kluczowe funkcje i parametry | Zachowanie UX |
|---|---|---|---|
| **0** | `TOOL_BRUSH` (Paint) | Pędzle rastrowe, animowane (zmieniają klatkę w trakcie ruchu), kątowe (zależne od kierunku pociągnięcia), regulacja odstępu (`brush_spacing`). | Rysowanie odręczne z natychmiastowym śladem i dźwiękiem chlapania/pędzla. |
| **1** | `TOOL_STAMP` | Kategorie tematyczne, skalowanie rozmiaru (slider), odbicie lustrzane poziome/pionowe, obrót (rotacja), odtwarzanie efektu dźwiękowego i wymowy lektora (TTS / opis tekstowy). | Kliknięcie wstawia pieczątkę; możliwość podglądu zarysu przed upuszczeniem. |
| **2** | `TOOL_LINES` | Rysowanie prostych linii pędzlem o wybranym kształcie; wyświetlanie kąta nachylenia w stopniach w czasie rzeczywistym; przyciąganie kątowe. | Przeciągnięcie myszą/palcem, podgląd gumowej linii, zwolnienie zatwierdza. |
| **3** | `TOOL_SHAPES` | 13 kształtów geometrycznych x 2 warianty (obrys / wypełnienie) = 26 figur. Tryb ekspansji od środka (`CENTER`) lub od narożnika (`CORNER`). | Interakcja dwuetapowa: 1. rozciągnięcie do żądanego rozmiaru, 2. obrót wokół własnej osi. |
| **4** | `TOOL_TEXT` | Czcionki TrueType ze skanera systemowego; pogrubienie, kursywa, zmiana rozmiaru; wirtualna klawiatura ekranowa; bezpośrednie wpisywanie na płótno. | Kliknięcie stawia kursor; pisanie tekstu; klawisz Enter/Tab spłaszcza tekst na stałe do płótna. |
| **5** | `TOOL_LABEL` | Wektorowa etykieta tekstowa. Te same właściwości co Text, ale tekst pozostaje niezależnym obiektem. Tryb selektora (`LABEL_SELECT`) pozwala kliknąć etykietę, przesunąć ją, zmienić treść lub font. | Dziecko może w każdej chwili poprawić napis; przycisk "Zastosuj" (`LABEL_APPLY`) łączy go z płótnem. |
| **6** | `TOOL_FILL` | 4 algorytmy wypełniania: 1. Jednolite (flood fill z progiem tolerancji), 2. Gradient liniowy, 3. Gradient radialny, 4. Gradient kształtowy (shaped contour fill). | Kliknięcie w dowolny zamknięty obszar natychmiast zalewa go kolorem lub przejściem tonalnym. |
| **7** | `TOOL_MAGIC` | 73 zaawansowane wtyczki efektów specjalnych (katalog poniżej). Tryb pędzla (Brush/Drag) lub tryb pełnoekranowy (Click/Filter). | Dzieci uwielbiają te efekty: trawa, tęcza, klocki, zniekształcenia, fale, bloki, kalejdoskop. |
| **8** | `TOOL_UNDO` | Cofanie ostatniego kroku (bufor zrzutów płótna + synchronizacja węzłów etykiet). | Dźwięk cofnięcia („Oops!”), odzyskanie poprzedniego stanu. |
| **9** | `TOOL_REDO` | Ponawianie cofniętego kroku. | Dźwięk powrotu. |
| **10** | `TOOL_ERASER` | Gumka kwadratowa i okrągła (ostra oraz miękka z antyaliasingiem/fuzzy) w kilku rozmiarach. Przywraca kolor papieru/tła. | Pociągnięcie wymazuje narysowane elementy. Skrót szybkiej gumki (klawisz X). |
| **11** | `TOOL_NEW` | Tworzenie nowego rysunku: czysty arkusz koloru, kolorowanki z konturem („Starters”) lub tła z nakładką przezroczystą („Templates”). | Galeria kafelkowa wyboru tła z potwierdzeniem zachowania bieżącej pracy. |
| **12** | `TOOL_OPEN` | Przeglądarka zapisanych prac: kafelki miniaturek, data zapisu, usuwanie (z koszem), tryb pokazu slajdów („Slides”) oraz eksport do animowanego GIF-a. | Dziecko widzi wyłącznie swoje prace w postaci dużych obrazków. |
| **13** | `TOOL_SAVE` | Automatyczne generowanie unikalnych nazw (hash/data), inteligentne zapytanie: „Zastąpić stary obrazek czy zapisać jako nowy?”. | Prosty i bezpieczny dialog chroniący przed przypadkowym nadpisaniem. |
| **14** | `TOOL_PRINT` | Drukowanie z opcją blokady rodzicielskiej (ograniczenie liczby wydruków w czasie, potwierdzenie). | Dźwięk drukarki i integracja z systemowym buforem wydruku. |
| **15** | `TOOL_QUIT` | Wyjście z aplikacji z dymkiem pytającym: „Czy na pewno chcesz wyjść?” oraz „Czy zapisać przed wyjściem?”. | Bezpieczne zakończenie sesji bez utraty rysunku. |

---

## 4. Kształty geometryczne (26 wariantów)

Zdefiniowane w `src/shapes.h`:
1. **Kwadrat** (`SHAPE_SQUARE`, obrys i wypełnienie) — zablokowane proporcje 1:1.
2. **Prostokąt** (`SHAPE_RECTANGLE`, obrys i wypełnienie) — dowolne proporcje.
3. **Koło** (`SHAPE_CIRCLE`, obrys i wypełnienie) — zablokowane proporcje 1:1.
4. **Elipsa** (`SHAPE_ELLIPSE`, obrys i wypełnienie) — dowolne proporcje.
5. **Trójkąt** (`SHAPE_TRIANGLE`, obrys i wypełnienie) — 3 boki.
6. **Pięciokąt** (`SHAPE_PENTAGON`, obrys i wypełnienie) — 5 boków.
7. **Sześciokąt** (`SHAPE_HEXAGON`, obrys i wypełnienie) — 6 boków.
8. **Siedmiokąt** (`SHAPE_HEPTAGON`, obrys i wypełnienie) — 7 boków.
9. **Ośmiokąt** (`SHAPE_OCTAGON`, obrys i wypełnienie) — 8 boków.
10. **Romb** (`SHAPE_RHOMBUS`, obrys i wypełnienie) — 4 boki.
11. **Gwiazda 3-ramienna** (`SHAPE_TRIANGLE_STAR`, obrys i wypełnienie).
12. **Gwiazda 4-ramienna** (`SHAPE_RHOMBUS_STAR`, obrys i wypełnienie).
13. **Gwiazda 5-ramienna** (`SHAPE_PENTAGON_STAR`, obrys i wypełnienie).

---

## 5. System kolorów i mikser (Color Pipeline)

1. **Podstawowa paleta barw:** Kafelki definiowane w plikach konfiguracyjnych (domyślnie 17 wyrazistych kolorów).
2. **Próbnik / Pipeta (`COLOR_SELECTOR`):** Pobieranie koloru bezpośrednio z dowolnego piksela płótna (także przez przytrzymanie Ctrl).
3. **Koło barw (`COLOR_PICKER`):** Płynny wybór odcienia i nasycenia (HSV) dla starszych dzieci.
4. **Mikser farb (`COLOR_MIXER`):**
   * Rewelacyjna funkcja edukacyjna symulująca mieszanie prawdziwych pigmentów (subtraktywne mieszanie barw, np. żółty + niebieski = zielony).
   * Dziecko dolewa kropelki farb i obserwuje powstawanie nowego koloru.

---

## 6. Pełny katalog 73 wtyczek „Magic” (Efekty Specjalne)

Wszystkie wtyczki zlokalizowane w `magic/src/`:
1. **alien** — zamiana kolorów na „kosmiczne / fluorescencyjne” odcienie.
2. **ascii** — konwersja fragmentu obrazu w mozaikę znaków tekstowych ASCII.
3. **blind** — żaluzje okienne (poziome i pionowe przesłony).
4. **blocks_etc** — pikseloza, mozaika klockowa (bloki Lego-style).
5. **bloom** — efekt poświaty i rozbłysku jasnych punktów.
6. **blur** — rozmycie Gaussa (zmiękczanie krawędzi).
7. **bricks** — malowanie muru z cegieł (duże i małe cegły).
8. **calligraphy** — pędzel kaligraficzny o zmiennej szerokości zależnej od kąta.
9. **cartoon** — styl komiksowy (konturowanie + posteryzacja kolorów).
10. **checkerboard** — szachownica.
11. **clone** — stempel klonujący (kopiowanie fragmentu rysunku w inne miejsce).
12. **colorsep** — rozszczepienie kanałów barwnych (CMYK / RGB offset).
13. **comicdot** — raster drukarski (kropki w stylu starych komiksów Pop Art).
14. **confetti** — rozsypywanie kolorowego konfetti.
15. **crescent** — rysowanie półksiężyców.
16. **distortion** — zniekształcenia falowe i soczewkowe.
17. **dither** — rasteryzacja / dithering w stylu retro komputerów.
18. **emboss** — efekt płaskorzeźby / wytłoczenia w kamieniu.
19. **emitter** — cząsteczkowy emiter iskier, gwiazdek i drobinek.
20. **fade_darken** — przyciemnianie lub rozjaśnianie barw.
21. **fisheye** — efekt obiektywu rybie oko (wypukłość/wklęsłość).
22. **flower** — automatycznie rosnące łodygi z kwiatami.
23. **foam** — piana mydlana z pękającymi bąbelkami.
24. **fold** — zagięcie narożnika kartki papieru.
25. **fractal** — geometryczne fraktale (drzewa, paprocie, śnieżynki).
26. **fretwork** — meandry i tradycyjne plecionki geometryczne.
27. **glasstile** — widok przez szybę ze szkła ornamentowego.
28. **googlyeyes** — doklejanie ruchomych, plastikowych oczu z obracającymi się źrenicami.
29. **grass** — realistycznie wyrastające kępki trawy w różnych odcieniach zieleni.
30. **halftone** — półtony drukarskie.
31. **kaleidox** — 4-osiowy kalejdoskop symetryczny.
32. **kalidescope** — obrotowy kalejdoskop zwierciadlany.
33. **light** — snop światła / latarka rozświetlająca mrok.
34. **lightning** — błyskawice i pioruny.
35. **maze** — automatyczny generator labiryntów.
36. **metalpaint** — metaliczna farba z chromowanym połyskiem.
37. **mirror_f** — lustrzane odbicie lewo/prawo lub góra/dół.
38. **mosaic** — mozaika ze szklanych/kamiennych kafelków.
39. **mosaic_shaped** — mozaika z kafelków o nieregularnych kształtach.
40. **n_pt_persp** — siatka perspektywy zbieżnej n-punktowej.
41. **negative** — negatyw (odwrócenie kolorów).
42. **noise** — dodawanie kolorowego szumu/ziarna.
43. **perspective** — pochylanie i zniekształcanie perspektywiczne płaszczyzny.
44. **pixels** — powiększanie pikseli pod pędzlem.
45. **polyfill** — wielokątne wypełnianie obszarów.
46. **puzzle** — cięcie rysunku w układankę puzzli.
47. **rails** — malowanie torów kolejowych z podkładami.
48. **rain** — strugi deszczu i kałuże.
49. **rainbow** — płynny łuk tęczy wszystkimi kolorami.
50. **realrainbow** — fotorealistyczna tęcza z łukiem fizycznym.
51. **reflection** — odbicie lustrzane w tafli wody z falami.
52. **ribbon** — powiewająca, skręcająca wstążka 3D.
53. **ripples** — koncentryczne fale na wodzie po upuszczeniu kamyka.
54. **rosette** — symetryczne rozety kwiatowe.
55. **rotate** — obracanie fragmentu kółka wokół osi.
56. **sharpen** — wyostrzanie rozmytych krawędzi.
57. **shift** — przesunięcie wierszy/kolumn pikseli.
58. **smooth** — antyaliasing i wygładzanie krawędzi pociągnięć.
59. **smudge** — rozmazywanie palcem mokrej farby na płótnie.
60. **snow** — płatki śniegu i zaspy śnieżne.
61. **spiral** — rysowanie spiral i ślimacznic.
62. **spraypaint** — puszka ze sprayem (aerograf).
63. **stretch** — elastyczne rozciąganie fragmentu obrazu jak guma.
64. **string** — siatki geometryczne ze sznurków i nitek.
65. **swirls** — wirowe zawirowania farby.
66. **tessell** — parkietaż / teselacja powierzchni.
67. **tint** — barwienie wybranym odcieniem (filtr barwny).
68. **toothpaste** — wyciskanie dwukolorowej pasty do zębów.
69. **tornado** — wir trąby powietrznej wciągający piksele.
70. **trochoids** — spirograf (hipotrochoidy i epitrochoidy).
71. **tv** — linie kineskopu starego telewizora CRT.
72. **waves** — poziome fale zniekształcające obraz.
73. **xor** — matematyczny filtr inwersji bitowej XOR.

---

## 7. Podsystemy pomocnicze i dostępność

1. **Dźwięki przestrzenne (Stereo Panning):**
   * Wyliczanie panoramy stereo `SNDPOS_LEFT` ... `SNDPOS_RIGHT` zależnie od pozycji kursora X na ekranie.
   * Każde narzędzie i pieczątka posiada unikalny sampel WAV/OGG.
2. **Klawiatura ekranowa (`onscreen_keyboard.c`):**
   * Duże klawisze dotykowe pojawiające się przy narzędziach Text i Label, eliminujące potrzebę posiadania klawiatury fizycznej.
3. **Ułatwienia dla najmłodszych (Toddler Modes):**
   * Opcje konfiguracyjne: ignorowanie prawego przycisku myszy, wyłączenie kółka myszy, proste kształty, blokada wyjścia (`--noquit`), blokada druku (`--noprint`).
4. **Pokaz slajdów i eksport GIF:**
   * Możliwość wybrania sekwencji rysunków, ustalenia czasu przejścia i wyeksportowania animowanego gifa (`gifenc.c`).

---

## 8. Wytyczne nowego UX/UI dla KidsPaint

Przepisanie interfejsu KidsPaint powinno skupić się na następujących fundamentach nowoczesnego UX:
1. **Responsywny, bezszwowy layout (Canvas-First):**
   * Płótno zajmuje maksymalną przestrzeń ekranu.
   * Paski narzędzi powinny być pływające lub dokowalne, z automatycznym zwijaniem na mniejszych ekranach (smartfony, tablety).
2. **Gesty dotykowe (Multi-Touch):**
   * 2 palce: płynny zoom (pinch), obracanie płótna i przesuwanie (pan).
   * 1 palec / rysik (Apple Pencil / stylisy): rysowanie z detekcją siły nacisku (pressure sensitivity).
3. **Nowoczesna paleta kolorów:**
   * Duże, miękkie, estetyczne kółka barw.
   * Zachowanie genialnego „Miksera farb”, ale w estetyce pastelowej palety malarskiej.
4. **Warstwy i nieniszcząca edycja:**
   * Architektura warstw (Background, Linework, Coloring, Text/Stickers), co zapobiega zniszczeniu konturów kolorowanki podczas zamalowywania.
5. **Asynchroniczny model zdarzeń:**
   * Zastąpienie starych blokujących pętli `while(!done)` nowoczesnym modelem sterowanym stanem (State Pattern / Reactive UI).
6. **Katalog zasobów (Asset Pipeline):**
   * Wsparcie dla wektorów SVG w pieczątkach i szablonach, co zapewni ostrość na ekranach Retina / 4K.
