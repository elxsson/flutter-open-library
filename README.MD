# 📚 flutter-open-library — Projeto de POO (Flutter)

Aplicativo de busca e exploração de livros que consome a [Open Library API](https://openlibrary.org), desenvolvido como projeto da disciplina de Programação Orientada a Objetos.

---

## ✨ Funcionalidades (6 telas)

| Tela | Rota | Descrição | Status |
|------|------|-----------|--------|
| **Home** | `/` | Livros em alta do dia + chips de categorias | ✅ |
| **Search** | `/search` | Busca dinâmica por título, autor ou assunto | ✅ |
| **Book Detail** | `/book` | Capa, título, autores, descrição e subjects do livro | ✅ |
| **Author** | `/author` | Foto, bio, data de nascimento e obras do autor | ✅ |
| **Subject** | `/subject` | Livros e autores de uma categoria/assunto | ✅ |
| **About** | `/about` | Informações sobre o app e o desenvolvedor | ⬜ |

---

## 🧱 Arquitetura

- **UI** separada da lógica (`ui/screens` e `ui/widgets`)
- Gerência de estado com **flutter_hooks** (`HookWidget`, `useState`, `useEffect`) + **ValueNotifier**
- Gerência de rotas com **get (GetX)** (`GetMaterialApp`, `getPages`, `Get.toNamed`)
- Camada de serviços (`services/` e `data/`) isolando todo o consumo de API e estado global

---

## 🎨 Identidade visual

| Uso | Cor |
|-----|-----|
| Primária | `#7E5349` |
| Secundária | `#FDECD6` |
| Contraste | `#DBA67A` |
| Fundo claro | `#E0E0E0` |

Bordas arredondadas em todos os elementos (padrão 16px). Layout responsivo: mobile primeiro, com largura máxima de 700px no web.

---

## 🌐 API utilizada

**[Open Library](https://openlibrary.org)** — pública, gratuita, sem necessidade de chave de API.

| Função | Endpoint |
|--------|----------|
| Trending diário | `GET /trending/daily.json` |
| Busca (título/autor/assunto) | `GET /search.json?q={query}` |
| Detalhe do livro | `GET /works/{olid}.json` |
| Detalhe do autor | `GET /authors/{olid}.json` |
| Obras do autor | `GET /authors/{olid}/works.json` |
| Livros por assunto | `GET /subjects/{name}.json?details=true` |
| Capa do livro | `https://covers.openlibrary.org/b/id/{id}-M.jpg` |
| Foto do autor | `https://covers.openlibrary.org/a/olid/{olid}-M.jpg` |

---

## 🚀 Como rodar (qualquer máquina)

### 1. Instalar o Flutter SDK

Acesse e siga o guia para o seu sistema operacional:

👉 https://docs.flutter.dev/get-started/install

Após instalar, confirme que está tudo OK:

```bash
flutter doctor
```

> O Flutter já inclui o Dart — não é necessário instalar separadamente.

### 2. Clonar o repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd book_finder_app
```

### 3. Gerar pastas das plataformas

O projeto foi iniciado sem as pastas `android/`, `ios/` etc. Execute o comando abaixo para criá-las:

```bash
flutter create --platforms=android .
```

Isso cria a estrutura necessária para compilar o APK sem sobrescrever o código existente.

### 4. Instalar as dependências

```bash
flutter pub get
```

### 5. Rodar o app

```bash
flutter run
```

Ou em uma plataforma específica:

```bash
# Web (Chrome)
flutter run -d chrome

# Android (emulador ou dispositivo físico)
flutter run -d android

# Windows / macOS / Linux
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

---

## 📦 Dependências principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_hooks: ^0.20.5
  get: ^4.7.3
  http: ^1.2.1
  cached_network_image: ^3.3.1
```

---

## 📁 Estrutura do projeto

```
lib/
├── main.dart
├── core/
│   ├── theme/app_theme.dart
│   └── constants/app_colors.dart
├── models/
│   ├── book.dart
│   ├── author.dart
│   └── subject.dart
├── services/
│   └── book_service.dart
├── data/
│   └── data_service.dart
└── ui/
    ├── screens/
    │   ├── home_screen.dart
    │   ├── search_screen.dart
    │   ├── book_detail_screen.dart
    │   ├── author_screen.dart
    │   ├── subject_screen.dart
    │   └── about_screen.dart
    └── widgets/
        ├── book_card.dart
        ├── book_cover.dart
        ├── author_card.dart
        ├── search_bar_widget.dart
        ├── subject_chip.dart
        └── app_bottom_nav.dart

```

---

## 📱 Gerar APK para celular (Android)

Siga os passos abaixo após ter o repositório clonado e as plataformas já geradas.

### 1. Verificar o ambiente

```bash
flutter doctor
```

Certifique-se de que o **Android SDK** está instalado e aparece como OK. Se não estiver, instale o [Android Studio](https://developer.android.com/studio) e configure o SDK Manager.

### 2. Build do APK (debug)

```bash
flutter build apk --debug
```

O APK será gerado em:

```
build/app/outputs/flutter-apk/app-debug.apk
```

### 3. Instalar no celular

Conecte o celular via USB com **depuração USB** ativada e execute:

```bash
flutter install
```

### APK release (assinado)

Para distribuir o app, gere uma versão release:

```bash
flutter build apk --release
```

> O APK release exige uma **keystore** configurada. Veja o guia oficial: https://docs.flutter.dev/deployment/android#signing-the-app

---
