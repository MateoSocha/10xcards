# Dokument wymagań produktu (PRD) - 10xDevs Cards

## 1. Przegląd produktu
Produkt "10xDevs Cards" ma na celu usprawnienie procesu tworzenia fiszek edukacyjnych poprzez:
- Automatyczne generowanie fiszek z wprowadzonego tekstu lub wgranych plików (PDF, MD, TXT; max. 5MB) z użyciem AI.
- Umożliwienie ręcznego tworzenia fiszek za pomocą prostego formularza.
- Zarządzanie kontami użytkowników (rejestracja, logowanie, reset hasła, usunięcie konta).

## 2. Problem użytkownika
Użytkownicy mają problem z czasochłonnym tworzeniem wysokiej jakości fiszek ręcznie, co w konsekwencji obniża efektywność nauki i odstrasza początkujących. Dodatkowo, optymalne dzielenie informacji na fiszki bywa nieintuicyjne, co utrudnia naukę poprzez powtórki.

## 3. Wymagania funkcjonalne
- AI generowanie fiszek:
  - Możliwość wprowadzenia tekstu (kopiuj-wklej) jako źródła informacji.
  - Obsługa wgrywania plików (PDF, MD, TXT) o maksymalnym rozmiarze 5MB.
  - Wyświetlanie w ramach widoku listy "AI fiszki"
- Ręczne tworzenie fiszek:
  - Formularz umożliwiający wprowadzenie "przodu" i "tyłu" fiszki.
  - Wyświetlanie w ramach widoku listy "Moje fiszki"
- Zarządzanie fiszkami:
  - Przeglądanie, edycja oraz usuwanie fiszek.
- System kont użytkowników:
  - Rejestracja, logowanie, reset hasła oraz usunięcie konta.
- Recenzja fiszek generowanych przez AI:
  - Fiszki generowane przez AI są traktowane jako kandydaci (draft) i wymagają recenzji przez użytkownika (akceptacja, edycja, odrzucenie).
  - Oznaczenie fiszek etykietką "DRAFT"
- Statystyki generowania fiszek
  - Informacja ile fiszek zostało wygenerowanych ręcznie
  - Informacja ile fiszek zostało wygenerowanych przez AI (uwzględnienie ilości odrzuconych fiszek)
- Wymagania prawne i ograniczenia
  - Dane osobowe użytkowników i fiszek przechowywane zgodnie z RODO

## 4. Granice produktu
- Brak implementacji zaawansowanego algorytmu powtórek (biblioteki open-source).
- Import ograniczony do plików PDF, MD, TXT; inne formaty (np. DOCX) nie są obsługiwane.
- Brak możliwości współdzielenia zestawów fiszek między użytkownikami.
- Brak integracji z innymi platformami edukacyjnymi.
- Produkt dostępny wyłącznie jako aplikacja webowa (brak wersji mobilnej).

## 5. Historyjki użytkowników

### US-001
- Tytuł: Generowanie fiszek z tekstu
- Opis: Użytkownik wprowadza tekst poprzez kopiuj-wklej, a system generuje na jego podstawie propozycje fiszek.
- Kryteria akceptacji:
  - Tekst jest przetwarzany przez AI w celu wygenerowania kandydatów na fiszki.
  - Kandydaci są prezentowani użytkownikowi do recenzji z możliwością edycji, akceptacji lub odrzucenia.

### US-002
- Tytuł: Generowanie fiszek z pliku
- Opis: Użytkownik wgrywa plik w formacie PDF, MD lub TXT o maksymalnym rozmiarze 5MB, a system generuje propozycje fiszek.
- Kryteria akceptacji:
  - System weryfikuje format i rozmiar pliku.
  - Po pozytywnej walidacji, zawartość pliku jest przetwarzana przez AI i prezentowana jako kandydat na fiszki.

### US-003
- Tytuł: Ręczne tworzenie fiszek
- Opis: Użytkownik korzysta z prostego formularza do tworzenia fiszek poprzez ręczne wprowadzenie treści "przodu" i "tyłu".
- Kryteria akceptacji:
  - Formularz umożliwia dodanie obu części fiszki.
  - Fiszki utworzone ręcznie są zapisywane w bazie danych i dostępne do późniejszej edycji oraz powtórek.

### US-004
- Tytuł: Zarządzanie kontem użytkownika (uwierzytelnianie i autoryzacja)
- Opis: Użytkownik ma możliwość rejestracji, logowania, resetowania hasła oraz usunięcia konta, co zapewnia bezpieczny dostęp do zasobów aplikacji.
- Kryteria akceptacji:
  - Proces rejestracji wymaga podania unikalnego adresu e-mail oraz hasła.
  - Użytkownik może zalogować się i uzyskać dostęp do swojego konta.
  - Opcja resetowania hasła działa poprzez potwierdzony email.
  - Użytkownik może usunąć swoje konto, po czym wszystkie dane powiązane z kontem są usuwane.

### US-005
- Tytuł: Recenzja i zarządzanie kandydatami na fiszki
- Opis: Użytkownik recenzuje fiszki wygenerowane przez AI, decydując o ich akceptacji, edycji lub odrzuceniu przed zapisaniem.
- Kryteria akceptacji:
  - System umożliwia podgląd wygenerowanych fiszek.
  - Użytkownik ma opcje modyfikacji treści fiszek przed zatwierdzeniem.
  - Dla każdej recenzji system loguje datę, powód edycji lub odrzucenia.
  
## 6. Metryki sukcesu
- 75% fiszek generowanych przez AI musi zostać zaakceptowanych przez użytkowników po recenzji.
- 75% fiszek tworzonych przez użytkowników powinno pochodzić z funkcji generowania przez AI.
- System musi wykazywać stabilność przy jednoczesnym rozwoju wszystkich funkcjonalności, zapewniając bezpieczeństwo danych użytkowników oraz spójność integracji z algorytmem powtórek.
