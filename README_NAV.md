# Navigationsstruktur & Responsivitet i Outfitly

## Översikt

Outfitly använder en **responsiv navigationslösning** som automatiskt växlar mellan mobil/tablet och desktop beroende på skärmbredd. Detta hanteras genom en kombination av:

- **MobileBottomNav**: Bottennavigering och AppBar för mobil och tablet.
- **DesktopSidebar**: Sidomeny för desktop.
- **DynamicDesktopTitle** och **DynamicMobileAppBarTitle**: Dynamiska titelrader som visar ikon + titel för aktuell sida.
- **_SidebarShell** (i `app_router.dart`): Växlar automatiskt mellan mobilnav och desktopnav beroende på skärmbredd.

---

## Viktiga filer och deras ansvar

### `/widgets/nav_bars/mobile_botton_nav.dart`
- Visar en bottennavigering med fyra huvudknappar på mobil och tablet.
- Hanterar även en "Wardrobe"-knapp med expanderbar undermeny.
- Navigerar till rätt sida vid knapptryck.
- Visar AppBar via `DynamicMobileAppBarTitle` på mobil/tablet.

### `/widgets/nav_bars/desktop_sidebar.dart`
- Visar en vertikal sidomeny på desktop.
- Markerar aktiv sida och hanterar hover/selected-states.
- Innehåller även temaväxlare och logout-knapp.
- Skugga på höger sida för tydlig separation från innehållet.

### `/widgets/nav_bars/dynamic_mobile_appbar_title.dart`
- Visar ikon + titel för aktuell sida i AppBar på mobil/tablet.
- Innehåller även temaväxlare och logout-knapp, placerade till höger.

### `/widgets/nav_bars/dynamic_desktop_title.dart`
- Visar ikon + titel för aktuell sida i innehållsdelen på desktop (ingen AppBar).

### `/router/app_router.dart`
- Innehåller `_SidebarShell` som automatiskt väljer navigation:
  - **MobileBottomNav** om `maxWidth < 900`
  - **DesktopSidebar** annars
- Gör det enkelt att ha en gemensam kodbas för alla plattformar.

---

## Hur det fungerar

- **Mobil/Tablet**:
  - `MobileBottomNav` visas längst ner.
  - AppBar visas med `DynamicMobileAppBarTitle` (ikon + titel + knappar).
- **Desktop**:
  - `DesktopSidebar` visas till vänster.
  - Ingen AppBar – istället visas `DynamicDesktopTitle` högst upp i innehållet.

---

## Fördelar

- **Responsivt**: Automatisk växling mellan mobil och desktop.
- **Enhetlig användarupplevelse**: Samma färglogik och states för navigation på alla plattformar.
- **Lätt att utöka**: Lägg till nya sidor i `appRoutes` så dyker de upp i både mobil- och desktopnav.

---
