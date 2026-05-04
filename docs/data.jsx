/* i18n strings — RU primary, EN secondary */

const STRINGS = {
  ru: {
    nav: { what: "что это", features: "фичи", demo: "демо", install: "установка", faq: "FAQ", contribute: "контрибуция" },
    hero: {
      badge: "v0.4.2 · сборка под Windows",
      titleA: "макросы для",
      titleB: "Warframe",
      titleC: ", без боли",
      lead: "Маленькая утилита для управления AHK-макросами.",
      ctaPrimary: "Загрузить для Windows",
      ctaSecondary: "Открыть на GitHub",
      meta1Label: "размер", meta1Value: "~38 МБ",
      meta2Label: "лицензия", meta2Value: "MIT",
      meta3Label: "ОС", meta3Value: "Windows 10 / 11",
      meta4Label: "стек", meta4Value: "Electron · React · AHK"
    },
    what: {
      eyebrow: "что это",
      title: "Менеджер AHK-скриптов с одним окном и нулём настроек",
      lead: "ahk-manager — клиент, который скачивает макросы из репозитория wf-macro, переписывает их под ваши клавиши и запускает в фоне. Ничего не устанавливает в систему, ничего не отправляет наружу. Открыли — закрыли. Кот наблюдает."
    },
    features: {
      eyebrow: "фичи",
      title: "Только то, что нужно для запуска макроса",
      items: [
        { title: "Качает скрипты", desc: "Каталог макросов из официального репо wf-macro. Обновления в один клик, проверка версии в углу.", meta: "git · pull only" },
        { title: "Запускает в фоне", desc: "Скрипты работают через встроенный AutoHotkey. Без установки в систему, без прав администратора.", meta: "ahk v2" },
        { title: "Ребайндит клавиши", desc: "Кликнул в поле, нажал клавишу — бинд заменился. Сохраняется локально в JSON, читаемый человеком.", meta: "press to bind" },
        { title: "Каталог библиотек", desc: "Библиотеки макросов берутся из репозитория wf-macro — официального каталога скриптов.", meta: "wf-macro" },
        { title: "Двуязычный", desc: "RU и EN из коробки. Переключатель в правом верхнем углу, без перезапуска.", meta: "ru · en" },
        { title: "Кот", desc: "Сидит в логотипе. В тёмной теме — белый. Никакой функциональности, кроме моральной поддержки.", meta: "cat is cat" }
      ]
    },
    demo: {
      eyebrow: "живое демо",
      title: "Так выглядит приложение",
      lead: "Кликабельный мокап настоящего интерфейса. Переключайтесь между страницами, ищите макросы, попробуйте ребайнд — нажмите на любую клавишу.",
      pages: { downloaded: "Downloaded", get: "Get scripts", lib: "Libraries", binds: "Binds" },
      groups: { git: "git", misc: "misc" },
      searchPh: "Поиск...",
      titleByRoute: {
        downloaded: "Downloaded", get: "Get scripts", lib: "Libraries", binds: "Binds"
      },
      modified: "Modified",
      author: "Author",
      version: "version: latest",
      empty: "Загрузка..."
    },
    install: {
      eyebrow: "установка",
      title: "Три шага. Без инсталлятора.",
      steps: [
        { title: "Скачайте релиз", desc: "Latest exe из вкладки Releases. Один файл, портативная сборка.", code: "ahk-manager-setup.exe" },
        { title: "Запустите", desc: "Откройте exe. Кот появится в трее. Если Defender нервничает — это нормально, исходники открыты.", code: "→ ahk-manager.exe" },
        { title: "Скачайте макросы", desc: "Перейдите на вкладку Get scripts → нажмите Download all. Готово.", code: "click · Download all" }
      ]
    },
    faq: {
      eyebrow: "FAQ",
      title: "Частые вопросы",
      items: [
        { q: "Это бан в Warframe?", a: "Нет. Все скрипты — простые маппинги клавиш и таймеры через AutoHotkey, как переназначение в любой Logitech G HUB. Не лезет в память клиента. Тем не менее — играете на свой страх и риск, ToS никто не отменял." },
        { q: "Откуда берутся скрипты?", a: "Из репо Lazy-World/wf-macro. Каталог открытый, любой может посмотреть исходники .ahk. Свои скрипты подключаются как git-библиотеки во вкладке Libraries." },
        { q: "Где хранятся настройки и бинды?", a: "Локально, в папке пользователя в обычном JSON. Можно открыть редактором, пересобрать, синхронизировать через свой Dropbox — приложение это не сломает." },
        { q: "Зачем кот?", a: "Кот — это кот." },
        { q: "Будет ли версия для Mac/Linux?", a: "Возможно. AutoHotkey — Windows-only, поэтому портирование требует подмены движка. PR-ы приветствуются." }
      ]
    },
    contribute: {
      eyebrow: "контрибуция",
      title: "Добавить свой скрипт — 3 шага",
      lead: "Скрипты живут в отдельном репо wf-macro. Они на чистом AHK v2, без мета-формата.",
      steps: [
        "Откройте папку со скриптами",
        "Положите .ahk в scripts/, конфиг по умолчанию — в scripts/cfg/",
        "Опишите назначение и клавиши в комментарии в шапке файла — пример есть в моём репозитории"
      ],
      ctaRepo: "Открыть wf-macro"
    },
    footer: {
      tagline: "Cat is cat. Сделано Lazy-World, лицензия MIT.",
      links: { repo: "wf-macro-loader", scripts: "wf-macro", releases: "Releases", license: "License" }
    }
  },
  en: {
    nav: { what: "what", features: "features", demo: "demo", install: "install", faq: "FAQ", contribute: "contribute" },
    hero: {
      badge: "v0.4.2 · windows build",
      titleA: "macros for",
      titleB: "Warframe",
      titleC: ", painless",
      lead: "A small utility for managing AHK macros.",
      ctaPrimary: "Download for Windows",
      ctaSecondary: "Open on GitHub",
      meta1Label: "size", meta1Value: "~38 MB",
      meta2Label: "license", meta2Value: "MIT",
      meta3Label: "os", meta3Value: "Windows 10 / 11",
      meta4Label: "stack", meta4Value: "Electron · React · AHK"
    },
    what: {
      eyebrow: "what it is",
      title: "An AHK script manager with one window and zero setup",
      lead: "ahk-manager is a client that pulls macros from the wf-macro repository, rewrites them to your keybinds, and runs them in the background. It installs nothing system-wide, sends nothing outside. Opened — closed. The cat watches."
    },
    features: {
      eyebrow: "features",
      title: "Only what you need to run a macro",
      items: [
        { title: "Pulls scripts", desc: "Catalog from the official wf-macro repo. One-click updates, version chip in the corner.", meta: "git · pull only" },
        { title: "Runs in background", desc: "Scripts execute via embedded AutoHotkey. No system install, no admin rights.", meta: "ahk v2" },
        { title: "Rebinds keys", desc: "Click a field, press a key — bind replaced. Stored locally as human-readable JSON.", meta: "press to bind" },
        { title: "Library catalog", desc: "Macro libraries are pulled from the wf-macro repository — the official catalog of scripts.", meta: "wf-macro" },
        { title: "Bilingual", desc: "RU and EN out of the box. Toggle in the top right, no restart needed.", meta: "ru · en" },
        { title: "Cat", desc: "Sits in the logo. White on dark mode. No functionality besides moral support.", meta: "cat is cat" }
      ]
    },
    demo: {
      eyebrow: "live demo",
      title: "This is what the app looks like",
      lead: "A clickable mock of the real UI. Switch pages, search macros, try a rebind — press any key.",
      pages: { downloaded: "Downloaded", get: "Get scripts", lib: "Libraries", binds: "Binds" },
      groups: { git: "git", misc: "misc" },
      searchPh: "Search...",
      titleByRoute: {
        downloaded: "Downloaded", get: "Get scripts", lib: "Libraries", binds: "Binds"
      },
      modified: "Modified",
      author: "Author",
      version: "version: latest",
      empty: "Loading..."
    },
    install: {
      eyebrow: "install",
      title: "Three steps. No installer.",
      steps: [
        { title: "Download release", desc: "Latest exe from the Releases tab. One file, portable build.", code: "ahk-manager-setup.exe" },
        { title: "Run it", desc: "Open the exe. The cat shows up in the tray. If Defender frowns — sources are open, it's fine.", code: "→ ahk-manager.exe" },
        { title: "Pull macros", desc: "Go to Get scripts → click Download all. Done.", code: "click · Download all" }
      ]
    },
    faq: {
      eyebrow: "FAQ",
      title: "Frequently asked",
      items: [
        { q: "Is this a ban in Warframe?", a: "No. The scripts are plain key remaps and timers over AutoHotkey, same as rebinding in Logitech G HUB. Doesn't touch client memory. That said — you play at your own risk, ToS still applies." },
        { q: "Where do scripts come from?", a: "From the Lazy-World/wf-macro repo. Catalog is public, any .ahk source can be inspected. Your own scripts plug in as git libraries on the Libraries tab." },
        { q: "Where are settings and binds stored?", a: "Locally in the user folder as plain JSON. Open it in any editor, edit, sync via your own Dropbox — the app won't choke on it." },
        { q: "Why a cat?", a: "Cat is cat." },
        { q: "Mac / Linux build?", a: "Maybe. AutoHotkey is Windows-only, so a port needs a different engine. PRs welcome." }
      ]
    },
    contribute: {
      eyebrow: "contribute",
      title: "Add your script in 3 steps",
      lead: "Scripts live in a separate repo, wf-macro. Pure AHK v2, no meta-format.",
      steps: [
        "Open the scripts folder",
        "Drop .ahk into scripts/, default config into scripts/cfg/",
        "Describe purpose and keys in a header comment of the file — there's an example in my repo"
      ],
      ctaRepo: "Open wf-macro"
    },
    footer: {
      tagline: "Cat is cat. Made by Lazy-World, MIT license.",
      links: { repo: "wf-macro-loader", scripts: "wf-macro", releases: "Releases", license: "License" }
    }
  }
};

window.STRINGS = STRINGS;

/* Mock macro catalog — plausible placeholder data */
const MACRO_CATALOG = [
  { name: "delay.ahk", desc: { ru: "Задержка между нажатиями для крафта", en: "Crafting press delay" }, modified: "2026-04-21", author: "lazy-world", tags: ["crafting", "qol"] },
  { name: "empty_ahk.ahk", desc: { ru: "Пустой шаблон для своих скриптов", en: "Empty template for your scripts" }, modified: "2026-04-15", author: "lazy-world", tags: ["template"] },
  { name: "fast_revive.ahk", desc: { ru: "Авто-зажатие X на оживлении напарника", en: "Auto-hold X on teammate revive" }, modified: "2026-03-30", author: "vesper", tags: ["coop", "qol"] },
  { name: "kuva_lich.ahk", desc: { ru: "Цикл проверки реликвий лича", en: "Lich relic check loop" }, modified: "2026-03-12", author: "tenno-hex", tags: ["lich", "farm"] },
  { name: "rivenroll.ahk", desc: { ru: "Прокрут ривенов с паузой на чтение", en: "Riven roll with read pause" }, modified: "2026-02-28", author: "rng-hater", tags: ["riven"] },
  { name: "ext_combo.ahk", desc: { ru: "Удерживание E для комбо мили", en: "Hold E for melee combo" }, modified: "2026-02-14", author: "lazy-world", tags: ["melee"] },
  { name: "fishing_loop.ahk", desc: { ru: "Цикл рыбалки на Cetus", en: "Cetus fishing loop" }, modified: "2026-01-30", author: "old-orb", tags: ["fishing"] },
  { name: "captura_pose.ahk", desc: { ru: "Циклы поз для каптуры", en: "Captura pose cycler" }, modified: "2026-01-18", author: "frame-art", tags: ["captura", "fashion"] }
];

window.MACRO_CATALOG = MACRO_CATALOG;

/* Bind list — used in demo binds page */
const DEFAULT_BINDS = {
  ru: [
    { label: "Прыжок-уклон", key: "Space" },
    { label: "Подбор предметов", key: "X" },
    { label: "Активация ульты", key: "4" },
    { label: "Парейровать атаку", key: "E" },
    { label: "Открыть инвентарь", key: "I" },
    { label: "Голосовой чат", key: "V" }
  ],
  en: [
    { label: "Bullet jump", key: "Space" },
    { label: "Pick up items", key: "X" },
    { label: "Activate ult", key: "4" },
    { label: "Parry melee", key: "E" },
    { label: "Open inventory", key: "I" },
    { label: "Voice chat", key: "V" }
  ]
};
window.DEFAULT_BINDS = DEFAULT_BINDS;
