/* Live demo — interactive mock of the ahk-manager app */
const { useState: useStateD, useEffect: useEffectD, useMemo } = React;

const DemoSidebarItem = ({ icon, label, active, onClick }) => (
  <button className={`demo-sb-item ${active ? "active" : ""}`} onClick={onClick}>
    {icon}
    <span className="demo-sb-item-text">{label}</span>
  </button>
);

const DemoCard = ({ name, desc, modified, author, t, onAction }) => (
  <div className="demo-card">
    <div style={{ minWidth: 0 }}>
      <div className="demo-card-name">{name}</div>
      <div className="demo-card-meta">
        <span style={{ color: "var(--muted-foreground)" }}>{desc}</span>
      </div>
      <div className="demo-card-meta">
        <span>{t.demo.modified}: </span><span className="strong">{modified}</span>
        <span> | {t.demo.author}: </span><span className="strong">{author}</span>
      </div>
    </div>
    <div className="demo-card-actions">
      <button className="btn btn-ghost btn-icon-sm" title="Folder" onClick={onAction}><Ico.Folder size={14} /></button>
      <button className="btn btn-ghost btn-icon-sm" title="Refresh" onClick={onAction}><Ico.RefreshCcw size={14} /></button>
      <button className="btn btn-ghost btn-icon-sm" title="Delete" onClick={onAction}><Ico.Trash size={14} /></button>
    </div>
  </div>
);

const DemoBindRow = ({ label, k, listening, onClick }) => (
  <div className="demo-binds-row">
    <span>{label}</span>
    <button className={`demo-keybind ${listening ? "listening" : ""}`} onClick={onClick}>
      {listening ? "press..." : k || "—"}
    </button>
  </div>
);

const Demo = ({ t, lang }) => {
  const [route, setRoute] = useStateD("downloaded");
  const [query, setQuery] = useStateD("");
  const [binds, setBinds] = useStateD(window.DEFAULT_BINDS[lang]);
  const [listening, setListening] = useStateD(-1);

  useEffectD(() => { setBinds(window.DEFAULT_BINDS[lang]); }, [lang]);

  useEffectD(() => {
    if (listening < 0) return;
    const onKey = (e) => {
      e.preventDefault();
      let k = e.key;
      if (k === " ") k = "Space";
      if (k === "Control") k = "Ctrl";
      if (k === "Escape") k = "";
      if (k.startsWith("Arrow")) k = k.replace("Arrow", "");
      setBinds(prev => prev.map((b, i) => i === listening ? { ...b, key: k } : b));
      setListening(-1);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [listening]);

  const filtered = useMemo(() => {
    if (!query) return window.MACRO_CATALOG;
    const q = query.toLowerCase();
    return window.MACRO_CATALOG.filter(m =>
      m.name.toLowerCase().includes(q) ||
      m.desc[lang].toLowerCase().includes(q) ||
      m.tags.some(tag => tag.includes(q))
    );
  }, [query, lang]);

  const titleByRoute = t.demo.titleByRoute;

  return (
    <section className="section" id="demo">
      <SectionHeader eyebrow={t.demo.eyebrow} title={t.demo.title} lead={t.demo.lead} />
      <div className="reveal demo-wrap" style={{ marginTop: 32 }}>
        <div className="demo-chrome">
          <span className="demo-dot"></span>
          <span className="demo-dot"></span>
          <span className="demo-dot"></span>
          <span className="demo-chrome-title">
            <Ico.Box size={11} /> ahk-manager.exe
          </span>
        </div>
        <div className="demo-app">
          {/* Sidebar */}
          <div className="demo-sidebar">
            <div className="demo-sb-logo">
              <img src="../assets/cat.svg" alt="" />
              <div className="demo-sb-logo-text">
                <div className="demo-sb-logo-name">ahk-manager</div>
                <div className="demo-sb-logo-ver">v0.4.2</div>
              </div>
            </div>
            <div className="demo-sb-group-label">{t.demo.groups.git}</div>
            <DemoSidebarItem icon={<Ico.Download size={16} />} label={t.demo.pages.downloaded} active={route === "downloaded"} onClick={() => setRoute("downloaded")} />
            <DemoSidebarItem icon={<Ico.ShoppingBag size={16} />} label={t.demo.pages.get} active={route === "get"} onClick={() => setRoute("get")} />
            <DemoSidebarItem icon={<Ico.Library size={16} />} label={t.demo.pages.lib} active={route === "lib"} onClick={() => setRoute("lib")} />
            <div className="demo-sb-group-label">{t.demo.groups.misc}</div>
            <DemoSidebarItem icon={<Ico.Command size={16} />} label={t.demo.pages.binds} active={route === "binds"} onClick={() => setRoute("binds")} />
            <div className="demo-sb-spacer"></div>
            <DemoSidebarItem icon={<Ico.Settings size={16} />} label={lang === "ru" ? "Настройки" : "Settings"} />
          </div>
          {/* Main */}
          <div className="demo-main">
            <div className="demo-topbar">
              <div className="demo-topbar-title">{titleByRoute[route]}</div>
              {(route === "downloaded" || route === "get") && (
                <div className="demo-search">
                  <Ico.Search size={14} />
                  <input
                    placeholder={t.demo.searchPh}
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                  />
                  <kbd>/</kbd>
                </div>
              )}
              <span className="tag green" style={{ marginLeft: 8 }}>{t.demo.version}</span>
            </div>
            <div className="demo-content">
              {(route === "downloaded" || route === "get") && (
                <>
                  {route === "get" && (
                    <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 12 }}>
                      <button className="btn btn-primary btn-sm">
                        <Ico.ArrowDownToLine size={14} /> {lang === "ru" ? "Скачать всё" : "Download all"}
                      </button>
                    </div>
                  )}
                  {filtered.length === 0 && (
                    <div className="demo-empty">
                      <img src="../assets/cat.svg" alt="" />
                      <div>{lang === "ru" ? "Ничего не найдено" : "Nothing found"}</div>
                    </div>
                  )}
                  {filtered.map((m, i) => (
                    <DemoCard key={i} name={m.name} desc={m.desc[lang]} modified={m.modified} author={m.author} t={t} onAction={() => {}} />
                  ))}
                </>
              )}
              {route === "lib" && (
                <>
                  {[
                    { name: "wf-macro", desc: lang === "ru" ? "Официальный каталог макросов" : "Official macro catalog", modified: "2026-04-21", author: "lazy-world" },
                    { name: "my-personal-rolls", desc: lang === "ru" ? "Личные скрипты" : "Personal scripts", modified: "2026-04-12", author: "you" }
                  ].map((m, i) => (
                    <DemoCard key={i} name={m.name} desc={m.desc} modified={m.modified} author={m.author} t={t} onAction={() => {}} />
                  ))}
                  <button className="btn btn-outline btn-md" style={{ marginTop: 12 }}>
                    <Ico.Plus size={14} /> {lang === "ru" ? "Добавить библиотеку" : "Add library"}
                  </button>
                </>
              )}
              {route === "binds" && (
                <div className="demo-binds">
                  <h3 style={{ margin: "0 0 12px", fontSize: 13, fontWeight: 600, textAlign: "center" }}>
                    {lang === "ru" ? "Базовые бинды" : "Base binds"}
                  </h3>
                  {binds.map((b, i) => (
                    <DemoBindRow
                      key={i}
                      label={b.label}
                      k={b.key}
                      listening={listening === i}
                      onClick={() => setListening(i)}
                    />
                  ))}
                  <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 12 }}>
                    <button className="btn btn-primary btn-sm" onClick={() => setBinds(window.DEFAULT_BINDS[lang])}>
                      <Ico.RefreshCcw size={14} /> {lang === "ru" ? "Сбросить" : "Reset"}
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

window.Demo = Demo;
